//
//  NewsFeedTableViewController2.m
//  Epic Vegas IV
//
//  Created by Zach on 8/10/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "NewsFeedTableViewController2.h"
#import "LoadNextPageTableViewCell.h"
#import "PostTableViewCell.h"
#import "NewsFeedTableViewCell.h"

@interface NewsFeedTableViewController2 ()




@end

@implementation NewsFeedTableViewController2

NSInteger itemsPerPage = 25;
NSInteger itemsLoaded = 0;
NSInteger currentPage = 0;
BOOL hasNextPage;
BOOL isCurrentlyRefreshing = NO;

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
    
    
    
    [self setupRefreshIndicator];
    [self refreshDataSources];
}

-(void)setupRefreshIndicator
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [self.refreshControl addTarget:self action:@selector(refreshControlPulled:) forControlEvents:UIControlEventValueChanged];
}

-(IBAction)refreshControlPulled:(id)sender
{
    [self refreshDataSources];
    [self.refreshControl endRefreshing];
}

-(void)refreshDataSources
{
    if(isCurrentlyRefreshing)
    {
        NSLog(@"Refresh Blocked");
        return;
    }

    NSLog(@"Refresh Started");

    isCurrentlyRefreshing = YES;
    
    _postsArray = [[NSMutableArray alloc] init];
 
    
    // show activity indicator if refresh control is not visibly refreshing
    if(!self.refreshControl.isRefreshing)
        [self showActivityIndicator];
   
    _lastRefreshDate = [NSDate date];
    currentPage = 0;
    hasNextPage = YES;
    
    [self loadNextPage];
}

-(void)loadNextPage
{
    PFQuery* postsQuery = [self queryForTable];

    postsQuery.limit = itemsPerPage;
    postsQuery.skip = itemsPerPage * currentPage++;
    
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void) {
                // background work

                // The find succeeded.
                NSLog(@"Successfully retrieved %d new posts.", objects.count);
                
                if(objects.count != itemsPerPage || objects.count == 0)
                    hasNextPage = NO;
                
                // add objects to posts array, make null objects for all other arrays
                for(id object in objects)
                {
                    [_postsArray addObject:object];
                }
                
                // update main ui thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.tableView reloadData];
                    [self hideActivityIndicator];
                    isCurrentlyRefreshing = NO;
                    NSLog(@"Refresh Ended");
                });
            });
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
    
-(void)showActivityIndicator
{
    _activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40,self.view.frame.size.height / 2 - 125,80,80)];
    
    //spinner.color = [UIColor darkGrayColor];
    _activityIndicator.backgroundColor = [UIColor darkGrayColor];
    _activityIndicator.layer.cornerRadius = 5;
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_activityIndicator startAnimating];
    [self.view addSubview:_activityIndicator];
}

-(void)hideActivityIndicator
{
    [_activityIndicator stopAnimating];
    //[self.view removeSubview:_activityIndicator ;]
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"photo"];
    [query includeKey:@"user"];
    //[query includeKey:@"user.profilePictureSmall"];

    // enforce last refresh date to get data in pages (so pages don't get messed up when new things are added after refresh)
    [query whereKey:@"createdAt" lessThanOrEqualTo:_lastRefreshDate];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // add an extra row for the get next page indicator
    if(hasNextPage && _postsArray.count >= 1)
        return _postsArray.count + 1;

    return _postsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the last cell is the load more cell
    if(hasNextPage && indexPath.row == _postsArray.count && _postsArray.count >= itemsPerPage)
    {
        LoadNextPageTableViewCell *cell = (LoadNextPageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell" forIndexPath:indexPath];
        
        UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[cell viewWithTag:123];
        [activityIndicator startAnimating];
        return cell;
    }

    @try {
        // otherwise is a post cell
        NewsFeedTableViewCell* cell = (NewsFeedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = (NewsFeedTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"PostCell"];
        }
        else{
            [cell clearCellForReuese];
        }
        
        [self configurePostCell:cell ForRowAtIndexPath:indexPath];
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    }
}


-(void)configurePostCell:(NewsFeedTableViewCell*)cell ForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *message = _postsArray[indexPath.row][@"message"] ?: @"[No Message]";
    cell.messageLabel.text = message;
    
    int postIndex = indexPath.row;
    PFObject* post = _postsArray[postIndex];
    if(!post)
        return;

    cell.messageLabel.text= post[@"message"] ?: @"";
    NSDate* createdAt = post.createdAt;
    NSString* subtitle = [Utility formattedDate:createdAt];
    cell.subtitleLabel.text = subtitle;

    if(post[@"user"])
    {
        cell.titleLabel.text = post[@"user"][@"displayName"] ?: @"";

        if(post[@"user"][@"profilePictureSmall"])
        {
            // set pic
            PFFile *userImageFile = post[@"user"][@"profilePictureSmall"];
            if (userImageFile)
            {
                [cell.userImageView setFile:userImageFile];
                [cell.userImageView loadInBackground];
            }
        }
    }
    
    if(post[@"photo"])
    {
        PFFile *photoImageFIle = post[@"photo"][@"thumbnail"];
        if (photoImageFIle)
        {
            [cell.photoImageView setFile:photoImageFIle];
            [cell.photoImageView loadInBackground];
        }
    }
}

- (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGRect frame = [text boundingRectWithSize:size
                                          options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil];
    return frame.size;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for the load more cell
    if(indexPath.row == _postsArray.count && hasNextPage)
        return  40;
    
    CGFloat height = 150;
    
    int postIndex = indexPath.row;
    PFObject* post = _postsArray[postIndex];
    if(!post)
        return height;
    
    NSString *theText=post[@"message"] ?: @"";
    CGSize labelSize = [theText sizeWithFont:[UIFont fontWithName: @"HelveticaNeue" size: 15.0f] constrainedToSize:CGSizeMake(300, 600)];
    height += labelSize.height;
    
    if(post[@"photo"])
    {        
        if(post[@"photo"][@"thumbnailHeight"])
        {
            CGFloat photoWidth = [post[@"photo"][@"thumbnailWidth"] floatValue];
            CGFloat photoHeight = [post[@"photo"][@"thumbnailHeight"] floatValue];
            
            CGFloat fixedWidth = 320 - 48;
            CGFloat heightMultiplier = fixedWidth / photoWidth;
            CGFloat scaledHeight = photoHeight * heightMultiplier;
            height += scaledHeight;
            
            NSLog(@"photo width = %f", scaledHeight);
        }
    }

    //NSLog(@"Height: %f", height);
    return height;
}

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}


#pragma scroll to bottom detection for load more cell

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
        [self checkIfAtLastCellAndShouldLoadNextPage:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self checkIfAtLastCellAndShouldLoadNextPage:scrollView];
}


-(void)checkIfAtLastCellAndShouldLoadNextPage:(UIScrollView*)scrollView
{
    if(!hasNextPage)
        return;
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 10;
    if(y > h - reload_distance) {
        NSLog(@"load more rows");
        [self loadNextPage];
    }
}

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
