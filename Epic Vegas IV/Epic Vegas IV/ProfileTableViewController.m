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
#import "UserLocationViewController.h"
#import "CheckedInLocationViewController.h"

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
        self.navigationItem.title = @"Me";
    }
    else {
        self.navigationItem.title = _profileUser[@"displayName"];
    }
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(_profileUser == [PFUser currentUser])
    {
        // current user so show the right bar item
        _rightBarbuttonItem.image = [UIImage imageNamed:@"Settings 44.png"];
        [_rightBarbuttonItem setEnabled:YES];
    }
    
    [self setupHeader];
}

-(CGFloat)getHeaderHeight
{
    CGFloat baseHeight = 367 + 8;
    
    CGFloat locationNameLabelHeight = 20;
    CGFloat lastUpdatedAndDistanceLabelHeight = 0;
    
    if(self.profileUser)
    {
        if(self.profileUser[@"currentLocation"])
            lastUpdatedAndDistanceLabelHeight = 20;
    }
    
    return baseHeight + locationNameLabelHeight + lastUpdatedAndDistanceLabelHeight;
}

-(void)setupHeader
{
    _profileHeaderView.frame = CGRectMake(0, 0, 320, [self getHeaderHeight]);
    
    _profileHeaderUserImageView.image = nil;
    
    _profileHeaderLocationNameLabel.text = nil;
    
    _profileHeaderLastUpdatedLabel.text = nil;
    
    [_profileHeaderMapButton setEnabled:NO];
    _profileHeaderMapButton.alpha = 0;
    
    _profileHeaderCardView.layer.cornerRadius = 4;
    
    // card border color
    float borderColorGray = 150.0/255.0;
    CGColorRef color = [UIColor colorWithRed:borderColorGray green:borderColorGray blue:borderColorGray alpha:1].CGColor;
    _profileHeaderCardView.layer.borderColor = color;
    
    // background color
    _profileHeaderCardView.backgroundColor = [UIColor whiteColor];
    float gray = 220.0/255.0;
    _profileHeaderView.backgroundColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1];
    
    
    _profileHeaderUserImageView.image = nil;
    _profileHeaderUserImageView.layer.cornerRadius = 272 / 2;
    _profileHeaderUserImageView.layer.masksToBounds = YES;
    _profileHeaderUserImageView.layer.borderWidth = .1f;
    _profileHeaderUserImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    if(_profileUser[@"profilePictureLarge"])
    {
        // set pic
        PFFile *userImageFile = _profileUser[@"profilePictureLarge"];
        if (userImageFile)
        {
            [_profileHeaderUserImageView setFile:userImageFile];
            [_profileHeaderUserImageView loadInBackground];
        }
    }
    
    // user name
    if(_profileUser && _profileUser[@"displayName"])
    {
        _profileHeaderUserNameLabel.text = _profileUser[@"displayName"];
        
        // setup location info
        NSString* locationName = _profileUser[@"currentLocationName"];
        
        _profileHeaderLocationNameLabel.textAlignment = NSTextAlignmentCenter;
        
        
        _profileHeaderLastUpdatedLabel.textAlignment = NSTextAlignmentCenter;
        if(locationName)
        {
            _profileHeaderLocationNameLabel.text = locationName;
        }
        else if(_profileUser[@"currentLocation"])
        {
            _profileHeaderLocationNameLabel.text = @"Unnamed Location";
        }
        else
        {
            _profileHeaderLocationNameLabel.text = @"Unknown Location";
        }
        
        if(_profileUser[@"currentLocation"])
        {
            NSString* distanceText = @"";
            
            // get distance if friend and current user have location geopoints
            if([PFUser currentUser] && [PFUser currentUser][@"currentLocation"])
            {
                PFGeoPoint* friendLocation = _profileUser[@"currentLocation"];
                PFGeoPoint* myLocation = [PFUser currentUser][@"currentLocation"];
                
                double miles = [friendLocation distanceInMilesTo:myLocation];
                distanceText = [NSString stringWithFormat:@"%.1f mi · ", miles];
                
                // get rid of leading zero
                if([distanceText hasPrefix:@"0."])
                    distanceText = [distanceText substringFromIndex:1];
            }
            
            // show map button
            [_profileHeaderMapButton setEnabled:YES];
            _profileHeaderMapButton.alpha = 1;
            
            // show when it was updated along with the mile distance
            NSDate* currentLocationUpdatedAt = _profileUser[@"currentLocationUpdatedAt"];
            if(currentLocationUpdatedAt)
            {
                NSString* updatedAtText =[Utility formattedDate:_profileUser[@"currentLocationUpdatedAt"]];
                
                _profileHeaderLastUpdatedLabel.text = [NSString stringWithFormat:@"%@%@", distanceText, updatedAtText];
            }
            else
            {
                _profileHeaderLastUpdatedLabel.text = nil;
            }
        }
        else
        {
            _profileHeaderLastUpdatedLabel.text = nil;
        }
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(_profileUser == [PFUser currentUser] && [Cache sharedCache].shouldRefreshProfileOnDisplay)
    {
        [Cache sharedCache].shouldRefreshProfileOnDisplay = NO;
        [self refreshDataSources];
    }
    else
    {
        // at least reload table to update times
        [self.tableView reloadData];
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
    //[query whereKeyExists:@"message"];
    
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
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // add an extra row for the get next page indicator
    if(self.hasNextPage && self.queryObjects.count >= 1)
        return self.queryObjects.count + 1;
    
    return self.queryObjects.count;
}

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
    
    return [self getPostCellForRowAtIndexPath:indexPath];
}

-(void)refreshDataSources;
{
    [super refreshDataSources];
    
    // also refresh the header
    [self setupHeader];
}


-(void)configurePostCell:(NewsFeedTableViewCell*)cell ForRowAtIndexPath:(NSIndexPath *)indexPath
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
    
    if(post[@"locationName"])
    {
        messageLabel.text = [NSString stringWithFormat:@"Checked in at '%@'", post[@"locationName"]];
        cell.mapButton.hidden = NO;
    }
    else
    {
        cell.mapButton.hidden = YES;
        messageLabel.text = post[@"message"] ?: @"";
    }
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
        NewsFeedTableViewCell* cell = (NewsFeedTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = (NewsFeedTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"PostCell"];
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
        
        cell.delegate = self;
        [self configurePostCell:cell ForRowAtIndexPath:indexPath];
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return [self.tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    }
}


- (IBAction)checkinMapButtonPressed:(NewsFeedTableViewCell *)cell
{
    NSLog(@"show map for cell");
    
    NSIndexPath* indexPath = [self.tableView indexPathForCell:cell];
    if(!indexPath)
        return;
    
    if(indexPath.row >= self.queryObjects.count)
        return;
    
    @try {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        CheckedInLocationViewController* checkedInLocationViewController = (CheckedInLocationViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"CheckedInLocationViewController"];

        PFObject* post = self.queryObjects[indexPath.row];
        if(!post || !post[@"location"])
            return;
        
        PFGeoPoint* geoPoint = post[@"location"];
        if(!geoPoint)
            return;
        
        NSString* locationName = post[@"locationName"];
        NSDate* checkinTime = post.createdAt;
        NSString* subtitle = nil;
        if(checkinTime)
        {
            subtitle = [Utility formattedDate:checkinTime];
        }
        
        checkedInLocationViewController.pinTitle = locationName;
        checkedInLocationViewController.pinSubtitle = subtitle;
        checkedInLocationViewController.lattitude = geoPoint.latitude;
        checkedInLocationViewController.longitude = geoPoint.longitude;
        
        [self.navigationController pushViewController:checkedInLocationViewController animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception showing checkin location: %@", exception);
    }
    @finally {
    
    }
    
    }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for the load more cell
    if(indexPath.row == self.queryObjects.count && self.hasNextPage)
        return  40;
    
    
    CGFloat height = 83 - 8 - 8; // this is the correct height
    
    
    int postIndex = indexPath.row;
    PFObject* post = self.queryObjects[postIndex];
    if(!post)
        return height;
    
    NSString *messageText;
    
    if(post[@"locationName"])
    {
        messageText = [NSString stringWithFormat:@"Checked in at '%@'", post[@"locationName"]];
    }
    else
        messageText = post[@"message"] ?: @"";
    
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
            
            height += 20; // for the padding
        }
    }
    
    //NSLog(@"Height: %f", height);
    return height;
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // happens when user clicks the map button
    if([segue.identifier isEqualToString:@"userLocationSegue"])
    {
        UserLocationViewController* userLocationViewController = (UserLocationViewController*)segue.destinationViewController;
        
        userLocationViewController.user = _profileUser;
    }
}

- (IBAction)facebookButtonPressed:(id)sender {
    if(_profileUser && _profileUser[@"facebookId"])
    {
        // open users facebook profile
        NSString* urlString = [NSString stringWithFormat:@"http://facebook.com/%@", _profileUser[@"facebookId"]];
        
        NSLog(@"Attempting to open facebook profile at %@", urlString);
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlString]];
    }
}

- (IBAction)mapButtonPressed:(id)sender {
    // don't use this, use the prepare for segue instead
}
@end
