//
//  UserLocationViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/13/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>
@interface UserLocationViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) PFUser* user;

@end
