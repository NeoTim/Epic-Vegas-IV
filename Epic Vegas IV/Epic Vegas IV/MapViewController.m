//
//  MapViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/12/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "MapViewController.h"
#import "AppDelegate.h"

@interface MapViewController ()

@end

@implementation MapViewController

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

-(void)viewDidAppear:(BOOL)animated
{
    // get geopoint if it is stale
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            NSLog(@"User is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
            
            // create a region and pass it to the Map View
            MKCoordinateRegion region;
            region.center.latitude = geoPoint.latitude;
            region.center.longitude = geoPoint.longitude;
            region.span.latitudeDelta = 0.012;
            region.span.longitudeDelta = 0.012;
            
            [self.mapView setRegion:region animated:YES];
        }
    }];

    // query for users
    PFQuery* query = [self queryForMap];
    _queryObjects = [[NSMutableArray alloc] init];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(queue, ^(void) {
                // background work
                
                // The find succeeded.
                NSLog(@"Successfully retrieved %d new objects.", objects.count);
   
                // add objects to posts array, make null objects for all other arrays
                for(id object in objects)
                {
                    [_queryObjects addObject:object];
                }
                
                // update main ui thread
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    
                    NSLog(@"Map data updated");
                    [self refreshMap];
                    
                });
            });
            
        } else {
            // Log details of the failure
            NSLog(@"Error during map refresh: %@ %@", error, [error userInfo]);
            
        }
    }];
}

-(void)refreshMap
{
    for(id object in _queryObjects)
    {
        PFUser* user = (PFUser*)object;
        PFGeoPoint* geoPoint = user[@"currentLocation"];
        if(!geoPoint)
            continue;
        
        MKPointAnnotation* point = [[MKPointAnnotation alloc] init];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude,geoPoint.longitude);

        point.coordinate = coordinate;
        
        point.title = user[@"displayName"];
        
        //point.title = @"Where am I?";
        //point.subtitle = @"I'm here!!!";
        NSLog(@"adding map point for user: %@", point.title);
        
        [self.mapView addAnnotation:point];
    }
    NSLog(@"Map refreshed");
}

- (PFQuery *)queryForMap {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"photo"];
    [query whereKeyExists:@"currentLocation"];
    
    
    //[query includeKey:@"user.profilePictureSmall"];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
