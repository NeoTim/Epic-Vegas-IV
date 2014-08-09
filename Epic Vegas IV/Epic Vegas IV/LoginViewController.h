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

@class LoginViewController;

// define the protocol for the delegate
@protocol LoginViewControllerDelegate

// define protocol functions that can be used in any class using this delegate
/// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(LoginViewController *)logInController didLogInUser:(PFUser *)user;
@end

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *epicLabel;
@property (weak, nonatomic) IBOutlet UILabel *vegasLabel;
@property (weak, nonatomic) IBOutlet UILabel *ivLabel;

// define delegate property
@property (nonatomic, assign) id  delegate;

- (IBAction)fbLoginButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@end
