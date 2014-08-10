//
//  NewsFeedTableViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/9/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "NewsFeedTableViewController.h"
#import "PostTableViewCell.h"
#import "AppDelegate.h"
#import "LoadNextPageTableViewCell.h"

@interface NewsFeedTableViewController ()
@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, assign) NSInteger numObjectsBeforeNextPageLoad;
@end

@implementation NewsFeedTableViewController

@synthesize shouldReloadOnAppear;


NSInteger _numOfObjectsBeforeLoadMore;

#pragma mark - Initialization

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeProperties];
    }
    return  self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self initializeProperties];
    }
    return self;
}

-(void)initializeProperties
{
    
    // The className to query on
    self.parseClassName = @"Post";
    
    // Whether the built-in pagination is enabled
    self.paginationEnabled = YES;
    
    // Whether the built-in pull-to-refresh is enabled
    self.pullToRefreshEnabled = YES;
    
    // The number of objects to show per page
    self.objectsPerPage = 25;
    
    self.shouldReloadOnAppear = NO;
}

#pragma mark - UIViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self loadObjects];
    }
}

-(void)loadNextPage
{
    _numOfObjectsBeforeLoadMore = self.objects.count;
    [super loadNextPage];
}

-(BOOL)shouldShowLoadNextPageCell
{
    // if object count is not a multiple of the page size, then no
    if(self.objects.count % self.objectsPerPage != 0)
        return NO;
    
    // if the num of objects before load == the num of objects, then no
    if(_numObjectsBeforeNextPageLoad == self.objects.count)
        return  NO;

    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = self.objects.count;
    
    if (self.paginationEnabled && rows != 0 && [self shouldShowLoadNextPageCell])
        rows++;
    return rows;
}


#pragma mark - PFQueryTableViewController

- (PFQuery *)queryForTable {
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query orderByDescending:@"createdAt"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    /*
     This query will result in an error if the schema hasn't been set beforehand. While Parse usually handles this automatically, this is not the case for a compound query such as this one. The error thrown is:
     
     Error: bad special key: __type
     
     To set up your schema, you may post a photo with a caption. This will automatically set up the Photo and Activity classes needed by this query.
     
     You may also use the Data Browser at Parse.com to set up your classes in the following manner.
     
     Create a User class: "User" (if it does not exist)
     
     Create a Custom class: "Activity"
     - Add a column of type pointer to "User", named "fromUser"
     - Add a column of type pointer to "User", named "toUser"
     - Add a string column "type"
     
     Create a Custom class: "Photo"
     - Add a column of type pointer to "User", named "user"
     
     You'll notice that these correspond to each of the fields used by the preceding query.
     */
    
    return query;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if last row
    if (indexPath.row == self.objects.count && [self shouldShowLoadNextPageCell])
        return [self tableView:tableView cellForNextPageAtIndexPath:indexPath];
    else
        return [self basicCellAtIndexPath:indexPath];
}

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
    if(![self shouldShowLoadNextPageCell])
        return;
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if(y > h - reload_distance) {
        NSLog(@"load more rows");
        [self loadNextPage];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
    LoadNextPageTableViewCell *cell = (LoadNextPageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell" forIndexPath:indexPath];
    [cell.activityIndicator startAnimating];
    return cell;
}

- (PostTableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    [self configureBasicCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureBasicCellForAutoSize:(PostTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PFObject* post = [self.objects objectAtIndex:indexPath.row];
    [self setSubtitleForCell:cell forPost:post];
    [self setMessageForCell:cell forPost:post];
}

- (void)configureBasicCell:(PostTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Configure basic cell");
    PFObject* post = [self.objects objectAtIndex:indexPath.row];
    
    PFUser* userPointer = post[@"user"];
    
    if(!userPointer)
        return;

    cell.alpha = 0;
    cell.userImageView.alpha = 0;
    cell.photoView.alpha = 0;
    cell.headerView.alpha = 0;
    cell.footerView.alpha = 0;
    
    dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
    dispatch_async(myQueue, ^{
        
        // get user who posted
        PFObject* user = nil;
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        query.cachePolicy = kPFCachePolicyCacheElseNetwork;
        
        // query for user object, try from cache first
        user = [query getObjectWithId:userPointer.objectId];
        if(!user)
        {
            NSLog(@"Error querying for user");
            return;
        }
        
        
        UIImage *photoImage = nil;
        
        // query for photo object if there is one
        if(post[@"photo"])
        {
            PFObject* photoObject = post[@"photo"];
            if(photoObject)
            {
                PFObject* photo = [PFQuery getObjectOfClass:@"Photo" objectId:photoObject.objectId];
                if(photo)
                {
                    PFFile *theImage = [photo objectForKey:@"thumbnail"];
                    if(theImage)
                    {
                        NSData *imageData = [theImage getData];
                        photoImage = [UIImage imageWithData:imageData];
                    }
                }
            }
        }
        
        // query for user photo
        UIImage *userImage = nil;
        PFFile *userImageFile = [user objectForKey:kUserProfilePicSmallKey];
        if (userImageFile)
        {
            NSData *imageData = [userImageFile getData];
            userImage = [UIImage imageWithData:imageData];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update the UI
            [self setSubtitleForCell:cell forPost:post];
            [self setMessageForCell:cell forPost:post];
            [self setUserImageForCell:cell forUser:userImage];
            [self setTitleForCell:cell forUser:user];
            [self setPhotoImageForCell:cell forPhoto:photoImage];
            
            // fade in user image view
            [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut
                                         animations:^{
                                             cell.alpha = 1;
                                             cell.userImageView.alpha = 1;
                                             cell.photoView.alpha = 1;
                                             
                                             cell.headerView.alpha = 1;
                                             cell.footerView.alpha = 1;
                                         } completion:nil];

        });
    });
}

- (void)setPhotoImageForCell:(PostTableViewCell *)cell forPhoto:(UIImage *)photoImage {
    if(!photoImage)
    {
        cell.photoView.image = nil;
        return;
    }
    cell.photoView.image = photoImage;
}

- (void)setUserImageForCell:(PostTableViewCell *)cell forUser:(UIImage *)userImage {
    if(!userImage)
    {
        cell.userImageView.image = nil;
        return;
    }
    cell.userImageView.image = userImage;
    
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.layer.cornerRadius = 30;
    
//    PFFile *imageFile = [user objectForKey:kUserProfilePicSmallKey];
//    if (imageFile) {
//        NSLog(@"Setting image for cell");
//        [cell.userImageView setFile:imageFile];
//        
//        [cell.userImageView loadInBackground:^(UIImage *image, NSError *error) {
//            if (error) {
//                NSLog(@"Error loading user image: %@", error);
//            }
//            
//            // fade in user image view
//            [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.8f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut
//                             animations:^{
//                                 cell.userImageView.alpha = 1;
//                             } completion:nil];
//        }];
//    }
}

- (void)setTitleForCell:(PostTableViewCell *)cell forUser:(PFObject *)user {
    if(!user)
        return;
    
    NSString* userName = user[kUserDisplayNameKey];
    NSString* actionDescription = @"";
    if(!userName)
    {
        NSLog(@"Error getting username");
        return;
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

- (void)setSubtitleForCell:(PostTableViewCell *)cell forPost:(PFObject *)post {
    if(!post)
        return;
    
    NSDate* createdAt = post.createdAt;
    NSString* subtitle = [Utility formattedDate:createdAt];
    
    [cell.subtitleLabel setText:subtitle];
}

- (void)setMessageForCell:(PostTableViewCell *)cell forPost:(PFObject *)post {
    if(!post)
        return;
    
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
    
    // fixed size for the load next page cell
    if(self.paginationEnabled && indexPath.row == self.objects.count && [self shouldShowLoadNextPageCell])
        return  40;
    
    static PostTableViewCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    });
    
    [self configureBasicCellForAutoSize:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}





// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


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
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
