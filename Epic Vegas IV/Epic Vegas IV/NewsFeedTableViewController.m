//
//  NewsFeedTableViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/9/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "PostTableViewCell.h"

@interface NewsFeedTableViewController ()

@property (strong, nonatomic) NSArray *posts;
@end

@implementation NewsFeedTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self initRefreshControl];
    
    [self refreshData];
   
}

-(void)refreshData
{
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    query.cachePolicy = kPFCachePolicyNetworkOnly;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        @synchronized(self) {
            
            NSLog(@"Retrieved Posts!: %@", objects);
            _posts = objects;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            });
            
            if (error) {
                return;
            }
        }
    }];

}

-(void)initRefreshControl
{
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
}

-(void)refreshView:(UIRefreshControl *)refresh {
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing data..."];
   
    [self refreshData];
    // custom refresh logic would be placed here...
//       NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//       [formatter setDateFormat:@"MMM d, h:mm a"];
//       NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
//                [formatter stringFromDate:[NSDate date]]];
//        refresh.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    [refresh endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self basicCellAtIndexPath:indexPath];
}

- (PostTableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    [self configureBasicCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureBasicCell:(PostTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* post = [_posts objectAtIndex:indexPath.row];
    
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.alpha = 0;
    cell.userImageView.layer.cornerRadius = cell.userImageView.layer.frame.size.height / 2;
    
    [self setTitleForCell:cell item:post];
    [self setSubtitleForCell:cell item:post];
    [self setMessageForCell:cell item:post];
}

- (void)setTitleForCell:(PostTableViewCell *)cell item:(NSDictionary *)post {
    
    NSString* userName = @"";
    NSString* actionDescription = @"";
    PFUser* userPointer = post[@"user"];
    if(userPointer)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        @try
        {
            PFObject* user = [query getObjectWithId:userPointer.objectId];
            if(user)
            {
                userName = user[kUserDisplayNameKey];
                if(userName)
                {
                    actionDescription = @"posted a message";
                }
                
                PFFile *imageFile = [user objectForKey:kUserProfilePicLargeKey];
                if (imageFile) {
                    
                    [cell.userImageView setFile:imageFile];
                    cell.userImageView.alpha = 0.f;
                    [cell.userImageView loadInBackground:^(UIImage *image, NSError *error) {
                        if (!error) {
                            [UIView animateWithDuration:0.5f animations:^{
                                cell.userImageView.alpha = 1.0f;
                            }];
                        }
                    }];
                }
            }
        }
        @catch(NSException *exception)
        {
            NSLog(@"Exception: %@", exception);
        }
    }
    
    if(!userName)
    {
        NSLog(@"Error getting username");
    }
    
    
    const CGFloat fontSize = 13;
    UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
    UIFont *regularFont = [UIFont systemFontOfSize:fontSize];
    UIColor *foregroundColor = [UIColor blackColor];
    
    // Create the attributes
    NSDictionary *boldAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                           boldFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                              regularFont, NSFontAttributeName, nil];
    const NSRange range = NSMakeRange(userName.length, actionDescription.length + 1); // range of the actionDescription after the user name
    
    // Create the attributed string (text + attributes)
    NSString* titleText = [NSString stringWithFormat:@"%@ %@", userName, actionDescription];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:titleText attributes:boldAttributes];
    [attributedText setAttributes:normalAttributes range:range];
    
    // Set it in our UILabel and we are done!
    [cell.titleLabel setAttributedText:attributedText];
}

- (void)setSubtitleForCell:(PostTableViewCell *)cell item:(NSDictionary *)post {
    NSString *subtitle = post[@"message"] ?: @"[No Message]";
    
    subtitle = @"1 hour ago.";
    // Some subtitles can be really long, so only display the
    // first 200 characters
    if (subtitle.length > 200) {
        subtitle = [NSString stringWithFormat:@"%@...", [subtitle substringToIndex:200]];
    }
    
    [cell.subtitleLabel setText:subtitle];
}

- (void)setMessageForCell:(PostTableViewCell *)cell item:(NSDictionary *)post {
    NSString *message = post[@"message"] ?: @"[No Message]";
    
    // Some messages can be really long, so only display the
    // first 200 characters
    if (message.length > 200) {
        message = [NSString stringWithFormat:@"%@...", [message substringToIndex:200]];
    }
    
    [cell.messageLabel setText:message];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
    static PostTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    });
    
    [self configureBasicCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
