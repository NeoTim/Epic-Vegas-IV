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
#import "ProfileTableViewController.h"

@interface NewsFeedTableViewController2 ()




@end

@implementation NewsFeedTableViewController2


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
    
    self.tableView.allowsSelection = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if([Cache sharedCache].shouldRefreshNewsfeedOnDisplay)
    {
        [Cache sharedCache].shouldRefreshNewsfeedOnDisplay = NO;
        [self refreshDataSources];
    }
    else
    {
        // at least reload table to update times
        [self.tableView reloadData];
    }
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"photo"];
    [query includeKey:@"user"];
    [query whereKey:@"type" equalTo:@"post"];
    
    // only show messages
    [query whereKeyExists:@"message"];

    
    // enforce last refresh date to get data in pages (so pages don't get messed up when new things are added after refresh)
    [query whereKey:@"createdAt" lessThanOrEqualTo:self.lastRefreshDate];
    
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the last cell is the load more cell
    if(self.hasNextPage && indexPath.row == self.queryObjects.count && self.queryObjects.count >= self.itemsPerPage)
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
    if(self.queryObjects.count < indexPath.row)
        return;
    
    if(self.queryObjects.count == 0)
    {
        NSLog(@"No query objects for news feed view, just returning unconfigured cell...");
        return;
    }
    
    int postIndex = indexPath.row;
    PFObject* post = self.queryObjects[postIndex];
    if(!post)
        return;

    cell.messageLabel.text= post[@"message"] ?: @"";
    NSDate* createdAt = post.createdAt;
    NSString* subtitle = [Utility formattedDate:createdAt];
    cell.subtitleLabel.text = subtitle;

    
    cell.delegate = nil;
    if(post[@"user"])
    {
        cell.titleLabel.text = post[@"user"][@"displayName"] ?: @"";
        cell.postUser = post[@"user"];
        cell.delegate = self;
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
            //cell.photoImageView.alpha = 0;
            [cell.photoImageView setFile:photoImageFIle];
            [cell.photoImageView loadInBackground:^(UIImage *image, NSError *error) {
                //[UIView animateWithDuration:.25f animations:^{cell.photoImageView.alpha = 1;}];
            }];
        }
     }
}


-(void)showUser:(PFUser*)user
{
    if(user)
    {
        // show
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                 bundle: nil];
        
        ProfileTableViewController* profileViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ProfileTableViewController"];
        
        profileViewController.profileUser = user;
        
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for the load more cell
    if(indexPath.row == self.queryObjects.count && self.hasNextPage)
        return  40;
    
    
    CGFloat height = 172 - 43; // this is the correct height
    
    
    int postIndex = indexPath.row;
    if(postIndex >= self.queryObjects.count)
        return height;
    PFObject* post = self.queryObjects[postIndex];
    if(!post)
        return height;
    
    NSString *messageText=post[@"message"] ?: @"";
    
    CGSize labelSize = [self getLabelSize:messageText withFontName:@"HelveticaNeue-Medium" withFontSize:14.0f forFixedWidth:320-48];

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
            
            //NSLog(@"photo width = %f", scaledHeight);
            
            height += 8; // for the padding
        }
    }

    //NSLog(@"Height: %f", height);
    return height;
}


@end
