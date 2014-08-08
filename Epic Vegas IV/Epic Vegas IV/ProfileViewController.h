//
//  ProfileViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface ProfileViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *fbProfilePicView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end
