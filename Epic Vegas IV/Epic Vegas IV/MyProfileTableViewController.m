//
//  MyProfileTableViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/11/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import "ProfileTableViewCell.h"
#import "NewsFeedTableViewCell.h"
#import "LoadNextPageTableViewCell.h"

@interface MyProfileTableViewController ()

@end

@implementation MyProfileTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"photo"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // if first section, then that is the profile section picture
    if(section == 0)
        return 1;
    
    // add an extra row for the get next page indicator
    if(self.hasNextPage && self.queryObjects.count >= 1)
        return self.queryObjects.count + 1;
    
    return self.queryObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        // header row
        UITableViewCell *headerCell = (LoadNextPageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"ProfileHeader" forIndexPath:indexPath];

        if (headerCell == nil) {
            headerCell = (UITableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"ProfileHeader"];
        }
        else{
            
            PFImageView* profileImageView = (PFImageView*)[headerCell viewWithTag:756];
            profileImageView.image = nil;
        }
        
        PFImageView* profileImageView = (PFImageView*)[headerCell viewWithTag:756];
        profileImageView.image = nil;
        if([PFUser currentUser][@"profilePictureLarge"])
        {
            // set pic
            PFFile *userImageFile = [PFUser currentUser][@"profilePictureLarge"];
            if (userImageFile)
            {
                [profileImageView setFile:userImageFile];
                [profileImageView loadInBackground];
            }
        }

        return headerCell;
    }
    
    
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
    cell.messageLabel.text = message;
    
    int postIndex = indexPath.row;
    PFObject* post = self.queryObjects[postIndex];
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
    
    NSString *messageText=post[@"message"] ?: @"";
    //    CGSize labelSize = [messageText sizeWithFont:[UIFont fontWithName: @"HelveticaNeue-Medium" size: 14.0f] constrainedToSize:CGSizeMake(320 - 48, 2000)];
    //
    CGSize labelSize = [self getLabelSize:messageText withFontName:@"HelveticaNeue-Medium" withFontSize:14.0f forFixedWidth:320-48];
    
    BOOL hasPhoto = NO;
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
            
            // create the bottom padding constraint for the photo for 8 pixels space to the comments
            hasPhoto = YES;
            //            cell.messageHeightConstraint = [NSLayoutConstraint constraintWithItem:cell.messageLabel
            //                                                                          attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.0f constant:labelSize.height + 13.0f];
            //            cell.messageHeightConstraint.priority = UILayoutPriorityRequired;
            //            [cell.contentView addConstraint:cell.messageHeightConstraint];
        }
    }
    
    if(!hasPhoto)
    {
        // remove constraint
        //        if(cell.messageHeightConstraint)
        //            [cell.commentHolderView removeConstraint:cell.messageHeightConstraint];
        //
        //        cell.messageHeightConstraint = [NSLayoutConstraint constraintWithItem:cell.messageLabel
        //                                                                    attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1.0f constant:labelSize.height + 5.0f];
        //        cell.messageHeightConstraint.priority = UILayoutPriorityRequired;
        //        [cell.contentView addConstraint:cell.messageHeightConstraint];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
    {
        return 357;
    }
    else
    {
        // fixed height for the load more cell
        if(indexPath.row == self.queryObjects.count && self.hasNextPage)
            return  40;
        
        
        CGFloat height = 172; // this is the correct height
        
        
        int postIndex = indexPath.row;
        PFObject* post = self.queryObjects[postIndex];
        if(!post)
            return height;
        
        NSString *messageText=post[@"message"] ?: @"";
        
        CGSize labelSize = [self getLabelSize:messageText withFontName:@"HelveticaNeue-Medium" withFontSize:14.0f forFixedWidth:320-48];
        //    CGSize labelSize = [theText sizeWithFont:[UIFont fontWithName: @"HelveticaNeue-Medium" size: 14.0f] constrainedToSize:CGSizeMake(320 - 48, 2000)];
        height += labelSize.height;
        NSLog(@"label height = %f", labelSize.height);
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
                
                height += 8; // for the padding
            }
        }
        
        //NSLog(@"Height: %f", height);
        return height;
    }
}

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
