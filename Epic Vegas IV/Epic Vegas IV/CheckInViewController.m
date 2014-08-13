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
    _currentGeoPoint = nil;
    
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
            
            _currentGeoPoint = geoPoint;

            
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [_locationNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length >= 1;
}



- (IBAction)textFieldFinished:(id)sender
{
    NSLog(@"User checked in");

    if(!_currentGeoPoint)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Issues"
                                                        message:@"Unable to locate you, ensure that you have allowed the app to see your location."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    // initiate a post checkin and dismiss the controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
   
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    NSString* locationName =[_locationNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    PFUser *user = [PFUser currentUser];
    post[@"user"] = user;
    post[@"location"] = _currentGeoPoint;
    post[@"locationName"] = locationName;
    post[@"type"] = @"post";
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
        {
            NSLog(@"Error saving Check In Post: %@", error);
        }
        else
        {
            NSLog(@"Saved Checkin Post");
        }
    }];
    
    // update user location as well
    [Utility updateCurrentUsersLocation:_currentGeoPoint withLocationName:locationName];
}

@end