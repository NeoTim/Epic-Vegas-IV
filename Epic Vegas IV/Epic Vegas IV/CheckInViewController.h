//
//  CheckInViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/12/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CheckInViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *locationNameTextField;

- (IBAction)cancelButtonPressed:(id)sender;

@property (strong, nonatomic) PFGeoPoint* currentGeoPoint;

@end
