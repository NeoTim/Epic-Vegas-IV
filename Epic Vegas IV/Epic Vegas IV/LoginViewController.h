//
//  LoginViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>
#import "LoggedInUserData.h"

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *epicLabel;
@property (weak, nonatomic) IBOutlet UILabel *vegasLabel;
@property (weak, nonatomic) IBOutlet UILabel *ivLabel;


- (IBAction)fbLoginButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@end
