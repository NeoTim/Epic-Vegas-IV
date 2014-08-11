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
#import "AppDelegate.h"
#import "NewsFeedTableViewCell.h"

@interface NewsFeedTableViewController2 ()

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@property (nonatomic, strong) NSMutableArray* postsArray;
@property (nonatomic, strong) NSMutableArray* photosArray;
@property (nonatomic, strong) NSMutableArray* userPhotosArray;

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) NSDictionary* users;

@property (nonatomic, strong) NSDate* lastRefreshDate;

@end

@implementation NewsFeedTableViewController2

NSInteger itemsPerPage = 25;
NSInteger itemsLoaded = 0;
NSInteger currentPage = 0;
BOOL hasNextPage;

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
    
    [self refreshDataSources];
}


-(void)refreshDataSources
{
    _postsArray = [[NSMutableArray alloc] init];
    _photosArray = [[NSMutableArray alloc] init];
    _userPhotosArray = [[NSMutableArray alloc] init];
    [self showActivityIndicator];
   
    _lastRefreshDate = [NSDate date];
    currentPage = 0;
    hasNextPage = YES;
    
    [self loadNextPage];
}

-(void)loadNextPage
{
    PFQuery* postsQuery = [self queryForPosts];

    postsQuery.limit = itemsPerPage;
    postsQuery.skip = itemsPerPage * currentPage++;
    [postsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d new posts.", objects.count);
            
            if(objects.count != itemsPerPage || objects.count == 0)
                hasNextPage = NO;
            
            // add objects to posts array
            for(id object in objects)
                [_postsArray addObject:object];
            
            [self.tableView reloadData];
            [self hideActivityIndicator];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
//    
//    
//    int nextPageStart = itemsLoaded;
//    
//    for(int i = 0 ; i < itemsPerPage; i++)
//    {
//        int index = nextPageStart + i;
//        if(i >= _postsArray.count)
//            break; // no more posts
//        
//        PFObject* post = _postsArray[i];
//
//        PFUser* userPointer = post[@"user"];
//        if(userPointer)
//        {
//            PFObject* user = nil;
//            PFQuery *query = [PFQuery queryWithClassName:@"_User"];
//            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
//            
//            // query for user object, try from cache first
//            user = [query getObjectWithId:userPointer.objectId];
//            if(user)
//            {
//                UIImage *photoImage = nil;
//            }
//            else{
//                
//                NSLog(@"Error querying for user");
//            }
//            
//            
//        }
//    }
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

-(void)getNextPage
{
    
}

- (PFQuery *)queryForPosts {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    
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
    if(hasNextPage)
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

    // otherwise is a post cell
    NewsFeedTableViewCell* cell = (NewsFeedTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = (NewsFeedTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"PostCell"];
    }
    else{
        // clear out old content?
    }

    cell.aButton.titleLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    //cell.aButton.titleLabel.text = [_postsArray objectAtIndex:indexPath.row][@"message"];
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for the load more cell
    if(indexPath.row == _postsArray.count && hasNextPage)
        return  40;
    
    PostTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    return 80;
    
    //return [self heightForBasicCellAtIndexPath:indexPath];
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
