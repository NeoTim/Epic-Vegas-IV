//
//  CheckInViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/12/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "CheckInViewController.h"

@interface CheckInViewController ()

@end

@implementation CheckInViewController

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
    
    [self.locationNameTextField setDelegate:self];
    [self.locationNameTextField addTarget:self
                       action:@selector(textFieldFinished:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_locationNameTextField becomeFirstResponder];
    
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
            
            // Add the annotation to our map view
            //CLLocation* location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];

            
//            // Add an annotation
//            MKPointAnnotation *myLocationPoint = [[MKPointAnnotation alloc] init];
//            myLocationPoint.coordinate = location.coordinate;
//            myLocationPoint.title = @"Where am I?";
//            myLocationPoint.subtitle = @"I'm here!!!";
//            
//            [self.mapView addAnnotation:myLocationPoint];
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"currentLocation"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
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

- (IBAction)textFieldFinished:(id)sender
{
    NSLog(@"User checked in");

    // initiate a checkin???
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
