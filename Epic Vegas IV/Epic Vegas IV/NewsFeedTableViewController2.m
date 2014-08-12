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
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"photo"];
    [query includeKey:@"user"];
    //[query includeKey:@"user.profilePictureSmall"];

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
    
    NSString *message = self.queryObjects[indexPath.row][@"message"] ?: @"[No Message]";
    cell.messageView.text = message;
    
    // remove layout constraints
    if(cell.messageLabelHeightConstraint)
    {
        [cell removeConstraint:cell.messageLabelHeightConstraint];
    }
    
    int postIndex = indexPath.row;
    PFObject* post = self.queryObjects[postIndex];
    if(!post)
        return;

    // set height constraint for message
    NSString *theText=post[@"message"] ?: @"";
    CGSize labelSize = [theText sizeWithFont:[UIFont fontWithName: @"HelveticaNeue-Medium" size: 14.0f] constrainedToSize:CGSizeMake(320 - 48, 2000)];
    cell.messageLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:cell.messageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:labelSize.height];
    [cell addConstraint:cell.messageLabelHeightConstraint];
    
    
    cell.messageView.text= post[@"message"] ?: @"";
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for the load more cell
    if(indexPath.row == self.queryObjects.count && self.hasNextPage)
        return  40;
    
    CGFloat height = 150;
    
    int postIndex = indexPath.row;
    PFObject* post = self.queryObjects[postIndex];
    if(!post)
        return height;
    
    NSString *theText=post[@"message"] ?: @"";
    CGSize labelSize = [theText sizeWithFont:[UIFont fontWithName: @"HelveticaNeue-Medium" size: 14.0f] constrainedToSize:CGSizeMake(320 - 48, 2000)];
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


@end
