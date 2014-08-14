//
//  QueryTableViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/11/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "QueryTableViewController.h"

@interface QueryTableViewController ()

@end

@implementation QueryTableViewController


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
    
    _itemsPerPage = 25;
    _itemsLoaded = 0;
    _currentPage = 0;
    _hasNextPage = NO;
    _isCurrentlyRefreshing = NO;
    
    [self refreshDataSources];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setupRefreshIndicator];
}

// http://stackoverflow.com/questions/19240915/fix-uitableviewcontroller-offset-due-to-uirefreshcontrol-in-ios-7
-(void)setupRefreshIndicator
{
    if(!self.refreshControl)
    {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        [self.refreshControl addTarget:self action:@selector(refreshControlPulled:) forControlEvents:UIControlEventValueChanged];
        //self.refreshControl.hidden = YES;
    }
}

-(IBAction)refreshControlPulled:(id)sender
{
    [self refreshDataSources];
}

-(void)refreshDataSources
{
    if(self.isCurrentlyRefreshing)
    {
        NSLog(@"Refresh Blocked");
        if(self.refreshControl)
            [self.refreshControl endRefreshing];
     
        return;
    }
    
    NSLog(@"Refresh Started");
    
    // refresh location if stale
    [Utility updateCurrentUsersLocationWithOnlyIfStale:YES];
    
    _isCurrentlyRefreshing = YES;
    _queryObjects = [[NSMutableArray alloc] init];
    
    // show activity indicator if refresh control is not visibly refreshing
    //if(!self.refreshControl || !self.refreshControl.isRefreshing)
    //    [self showActivityIndicator];
    
    _lastRefreshDate = [NSDate date];
    _currentPage = 0;
    _hasNextPage = YES;
    
    [self loadNextPage];
}

-(void)loadNextPage
{
    PFQuery* postsQuery = [self queryForTable];
    
    postsQuery.limit = _itemsPerPage;
    postsQuery.skip = _itemsPerPage * _currentPage++;
    
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void) {
                // background work
                
                // The find succeeded.
                NSLog(@"Successfully retrieved %d new objects.", objects.count);
                
                if(objects.count != _itemsPerPage || objects.count == 0)
                    _hasNextPage = NO;
                
                // add objects to posts array, make null objects for all other arrays
                for(id object in objects)
                {
                    [_queryObjects addObject:object];
                }
                
                // update main ui thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.tableView reloadData];
                    [self hideActivityIndicator];
                    _isCurrentlyRefreshing = NO;
                    NSLog(@"Refresh Ended");
                    
                    self.refreshControl.hidden = NO;
                    
                    [self.refreshControl endRefreshing];
                });
            });
            
        } else {
            // Log details of the failure
            NSLog(@"Error during refresh: %@ %@", error, [error userInfo]);
            
            if(self.refreshControl)
                [self.refreshControl endRefreshing];
        }
    }];
    
    
    if(self.refreshControl)
        [self.refreshControl endRefreshing];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only allow deletions if
    PFUser* currentUser = [PFUser currentUser];
    if(!currentUser)
        return NO;
    
    // get object
    if(indexPath.row >= self.queryObjects.count )
        return NO;
    
    // check what kind of item it is
    PFObject* object = self.queryObjects[indexPath.row];
    if(!object)
        return NO;
    
   if([object.parseClassName isEqualToString:@"Post"])
   {
       // can delete if user owns the post
       
       PFUser* postUser = object[@"user"];
       if(postUser && [postUser.objectId isEqualToString:currentUser.objectId])
           return YES;
   }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // only allow deletions if
        PFUser* currentUser = [PFUser currentUser];
        if(!currentUser)
            return;
        
        // get object
        if(indexPath.row >= self.queryObjects.count )
            return;
        
        // check what kind of item it is
        PFObject* object = self.queryObjects[indexPath.row];
        if(!object)
            return;
        
        if([object.parseClassName isEqualToString:@"Post"])
        {
            // can delete if user owns the post
            
            PFUser* postUser = object[@"user"];
            if(!postUser)
                return;
            
            if(![postUser.objectId isEqualToString:currentUser.objectId])
                return;
            
            NSLog(@"Initiating delete of post of user: %@", object);
            
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(error)
                {
                    NSLog(@"Error deleting Post: %@", error);
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Deleting Post"
                                                                    message: [NSString stringWithFormat:@"Error: %@", error]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                else
                {
                    @try {                        
                        [self.queryObjects removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                        NSLog(@"Finished delete of post: %@", object);
                        
                        // set reload flags, any table may get corrupted
                        [Cache sharedCache].shouldRefreshNewsfeedOnDisplay = YES;
                        [Cache sharedCache].shouldRefreshProfileOnDisplay = YES;
                        [self refreshDataSources];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Exception after deleting row: %@", exception);
                    }
                }
            }];
            
        }
    }
}

-(void)showActivityIndicator
{
//    _activityIndicator = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40,self.view.frame.size.height / 2 - 125,80,80)];
//    
//    //spinner.color = [UIColor darkGrayColor];
//    _activityIndicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
//    _activityIndicator.opaque = NO;
//    _activityIndicator.layer.cornerRadius = 5;
//    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
//    [_activityIndicator startAnimating];
//    [self.view addSubview:_activityIndicator];
}

-(void)hideActivityIndicator
{
    //[_activityIndicator stopAnimating];
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
    if(_hasNextPage && _queryObjects.count >= 1)
        return _queryObjects.count + 1;
    
    return _queryObjects.count;
}



- (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    CGRect frame = [text boundingRectWithSize:size
                                      options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    return frame.size;
}


- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width
{
    UITextView *textView = [[UITextView alloc] init];
    [textView setAttributedText:text];
    CGSize size = [textView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    UIViewController* parentController = (UIViewController*)self.parentViewController;
//    UINavigationController* navController= (UINavigationController*)parentController.parentViewController;
//    UITabBarController* tabController= (UITabBarController*)navController.parentViewController;
//
//    if( [scrollView.panGestureRecognizer translationInView:self.view].y  < 0.0f ) {
//        [tabController.tabBar setHidden:YES];
//        [navController.toolbar setHidden:YES];
//    } else if ([scrollView.panGestureRecognizer translationInView:self.view].y  > 0.0f  ) {
//        [tabController.tabBar setHidden:NO];
//        [navController.toolbar setHidden:NO];
//    }
//    
//}

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

-(CGSize)getLabelSize:(NSString*)text withFontName:(NSString*)fontName withFontSize:(CGFloat)fontSize forFixedWidth:(CGFloat)width
{
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont fontWithName:fontName size:fontSize];
    gettingSizeLabel.text = [NSString stringWithFormat:@"%@       ", text];
    gettingSizeLabel.numberOfLines = 0;
    gettingSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize maximumLabelSize = CGSizeMake(width, 9999);
    
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    return expectSize;
}


-(void)checkIfAtLastCellAndShouldLoadNextPage:(UIScrollView*)scrollView
{
    if(!self.hasNextPage)
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
