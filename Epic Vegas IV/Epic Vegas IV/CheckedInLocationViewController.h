//
//  CheckedInLocationViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/14/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CheckedInLocationViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSString* pinTitle;
@property (nonatomic, strong) NSString* pinSubtitle;
@property (nonatomic, assign) double lattitude;
@property (nonatomic, assign) double longitude;

@end
