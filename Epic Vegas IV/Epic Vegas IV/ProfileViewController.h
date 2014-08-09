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

@class ProfileViewController;

@interface ProfileViewController : UIViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet PFImageView *fbProfilePicView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *logOutButton;

- (IBAction)logOutButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UISwitch *shareLocationSwitch;

- (IBAction)shareLocationSwitchChanged:(id)sender;

@end
