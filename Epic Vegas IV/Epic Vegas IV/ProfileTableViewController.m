//
//  MyProfileTableViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/11/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "NewsFeedTableViewCell.h"
#import "LoadNextPageTableViewCell.h"
#import "AutoSizeLabel.h"
#import "AppDelegate.h"

@interface ProfileTableViewController ()

@end

@implementation ProfileTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    if(!_profileUser)
    {
        _profileUser = [PFUser currentUser];
        self.title = @"Me";
    }
    else {
        self.title =_profileUser[@"displayName"];
    }

    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(_profileUser == [PFUser currentUser])
    {
        // current user so show the right bar item
        _rightBarbuttonItem.image = [UIImage imageNamed:@"Settings 44.png"];
        [_rightBarbuttonItem setEnabled:YES];
    }
    
    
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
    [query whereKey:@"user" equalTo:_profileUser];
    
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
        return [self getHeaderCellForRowAtIndexPath:indexPath];
    }
    
    // the last cell is the load more cell
    if(self.hasNextPage && indexPath.row == self.queryObjects.count && self.queryObjects.count >= self.itemsPerPage)
    {
        LoadNextPageTableViewCell *cell = (LoadNextPageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell" forIndexPath:indexPath];
        
        UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[cell viewWithTag:123];
        [activityIndicator startAnimating];
        return cell;
    }
    
    return [self getPostCellForRowAtIndexPath:indexPath];
}


-(UITableViewCell*)getHeaderCellForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    UIImageView* cardView = (UIImageView*)[headerCell viewWithTag:5];
    cardView.layer.cornerRadius = 4;
    
    // card border color
    float borderColorGray = 150.0/255.0;
    CGColorRef color = [UIColor colorWithRed:borderColorGray green:borderColorGray blue:borderColorGray alpha:1].CGColor;
    cardView.layer.borderColor = color;
    
    // background color
    cardView.backgroundColor = [UIColor whiteColor];
    float gray = 220.0/255.0;
    headerCell.backgroundColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1];
    
    
    PFImageView* profileImageView = (PFImageView*)[headerCell viewWithTag:756];
    profileImageView.image = nil;
    profileImageView.layer.cornerRadius = 272 / 2;
    profileImageView.layer.masksToBounds = YES;
    profileImageView.layer.borderWidth = .1f;
    profileImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if(_profileUser[@"profilePictureLarge"])
    {
        // set pic
        PFFile *userImageFile = _profileUser[@"profilePictureLarge"];
        if (userImageFile)
        {
            [profileImageView setFile:userImageFile];
            [profileImageView loadInBackground];
        }
    }
    
    // user name
    if(_profileUser && _profileUser[@"displayName"])
    {
        UILabel* userNameLabel = (UILabel*)[headerCell viewWithTag:6];
        userNameLabel.text = _profileUser[@"displayName"];
        userNameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return headerCell;
}

-(void)configurePostCell:(UITableViewCell*)cell ForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.queryObjects.count < indexPath.row)
        return;
    
    if(self.queryObjects.count == 0)
    {
        NSLog(@"No query objects for my profile view, just returning unconfigured cell...");
        return;
    }
    
    int postIndex = indexPath.row;
    PFObject* post = self.queryObjects[postIndex];
    if(!post)
        return;
    
    AutoSizeLabel* messageLabel = (AutoSizeLabel*)[cell viewWithTag:36];
    messageLabel.text= post[@"message"] ?: @"";
    NSDate* createdAt = post.createdAt;
    NSString* subtitle = [Utility formattedDate:createdAt];
    
    
    AutoSizeLabel* subtitleLabel = (AutoSizeLabel*)[cell viewWithTag:35];
    subtitleLabel.text = subtitle;
    
    if(post[@"photo"])
    {
        PFFile *photoImageFIle = post[@"photo"][@"thumbnail"];
        if (photoImageFIle)
        {
            PFImageView* photoImageView = (PFImageView*)[cell viewWithTag:37];
            //cell.photoImageView.alpha = 0;
            [photoImageView setFile:photoImageFIle];
            [photoImageView loadInBackground:^(UIImage *image, NSError *error) {
                //[UIView animateWithDuration:.25f animations:^{cell.photoImageView.alpha = 1;}];
            }];
        }
    }
}


-(UITableViewCell*)getPostCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        // otherwise is a post cell
        UITableViewCell* cell = (UITableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = (UITableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"PostCell"];
        }
        else{
            // clear for reuse
            AutoSizeLabel* messageLabel = (AutoSizeLabel*)[cell viewWithTag:36];
            AutoSizeLabel* subtitleLabel = (AutoSizeLabel*)[cell viewWithTag:35];
            PFImageView* photoImageView = (PFImageView*)[cell viewWithTag:37];
            
            messageLabel.text = nil;
            subtitleLabel.text = nil;
            photoImageView.image = nil;
        }
        
        [self configurePostCell:cell ForRowAtIndexPath:indexPath];
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return [self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
    {
        return 367;
    }
    else
    {
        // fixed height for the load more cell
        if(indexPath.row == self.queryObjects.count && self.hasNextPage)
            return  40;
        
        
        CGFloat height = 83; // this is the correct height
        
        
        int postIndex = indexPath.row;
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
                
                //height += 8; // for the padding
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
