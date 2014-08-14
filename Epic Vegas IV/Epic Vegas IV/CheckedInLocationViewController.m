//
//  CheckedInLocationViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/14/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "CheckedInLocationViewController.h"

@interface CheckedInLocationViewController ()

@end

@implementation CheckedInLocationViewController

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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    self.navigationItem.title = _pinTitle;
    
    // create a region and pass it to the Map View
    MKCoordinateRegion region;
    region.center.latitude = _lattitude;
    region.center.longitude = _longitude;
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta = 0.03;
    
    [_mapView setRegion:region animated:NO];

    MKPointAnnotation* annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(_lattitude, _longitude);
    annotation.title = _pinTitle;
    annotation.subtitle = _pinSubtitle;
    [_mapView addAnnotation:annotation];
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
