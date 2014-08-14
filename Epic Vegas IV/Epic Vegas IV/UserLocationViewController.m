//
//  UserLocationViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/13/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "UserLocationViewController.h"
#import "UserMapAnnotation.h"

@interface UserLocationViewController ()

@end

@implementation UserLocationViewController

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
    
    _mapView.delegate = self;
    [self showUser];
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

-(void)showUser
{
    PFGeoPoint* geoPoint = _user[@"currentLocation"];
    if(!geoPoint)
        return;
    
    //MKPointAnnotation* point = [[MKPointAnnotation alloc] init];
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(geoPoint.latitude,geoPoint.longitude);
    
    UserMapAnnotation* userAnnotation = [[UserMapAnnotation alloc] init];
    userAnnotation.coordinate = coordinate;
    userAnnotation.title = _user[@"displayName"];
    

    // set title to be "zach's location" with just first name
    NSString* displayName = _user[@"displayName"];
    if(displayName)
    {
        NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *firstName = [displayNameComponents objectAtIndex:0];
        self.navigationItem.title = [NSString stringWithFormat:@"%@'s Location", firstName];
    }
    
    
    NSDate* updatedAt = _user[@"currentLocationUpdatedAt"];
    if(updatedAt)
        userAnnotation.subtitle = [Utility formattedDate:updatedAt];
    
    PFFile *imageFile = [_user objectForKey:@"profilePictureSmall"];
    if (imageFile) {
        [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if(!error)
            {
                //NSLog(@"adding map point for user: %@", userAnnotation.title);
                
                userAnnotation.userImage = [Utility imageWithRoundedCornersSize:15 usingImage:[UIImage imageWithData:data] scaledToSize:CGSizeMake(30, 30)];
                userAnnotation.user = _user;
                [self.mapView addAnnotation:userAnnotation];
            }
            else{
                NSLog(@"Error map point for user: %@.  Error: %@", userAnnotation.title, error);
            }
            
        }];
    }
    
    // create a region and pass it to the Map View
    MKCoordinateRegion region;
    region.center.latitude = geoPoint.latitude;
    region.center.longitude = geoPoint.longitude;
    region.span.latitudeDelta = 0.012;
    region.span.longitudeDelta = 0.012;
    
    [self.mapView setRegion:region animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // base it on the user (title)
    NSString *reuseIdentifier = annotation.title;
    
    MKAnnotationView *pinView = (MKAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    
    if(!pinView)
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                                        reuseIdentifier:reuseIdentifier];
        UserMapAnnotation* userAnnotation = (UserMapAnnotation*)annotation;
        //NSLog(@"setting map point for user: %@", userAnnotation.title);
        annotationView.canShowCallout = YES;
        annotationView.image = userAnnotation.userImage;
        return annotationView;
    }
    pinView.annotation = annotation;
    return pinView;
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

@end
