//
//  LoginViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setupTitleFont
{
    // set font for epic vegas labels
    NSString* fontName = @"DS-Digital-BoldItalic";
    
    int fontSize = 100;
    
    _epicLabel.font = [UIFont fontWithName:fontName size:fontSize];
    _vegasLabel.font = [UIFont fontWithName:fontName size:fontSize];
    _ivLabel.font = [UIFont fontWithName:fontName size:fontSize];

    _epicLabel.layer.masksToBounds = NO;
    _vegasLabel.layer.masksToBounds = NO;
    _ivLabel.layer.masksToBounds = NO;
}

- (void)viewDidLoad
{
    NSLog(@"Login View Controller Did Load");
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.    
    [self setupTitleFont];
    
    // set login button rounded corners
    _fbLoginButton.layer.cornerRadius = 3;
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


- (IBAction)fbLoginButtonClicked:(id)sender {
    NSLog(@"Facebook Login Button Pressed");
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"public_profile", @"email", @"user_friends"];
    
    // Login PFUser using Facebook
    NSLog(@"Logging In PFUser");
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            
            NSLog(@"Error Logging In PFUser");
            if (!error) {
                NSLog(@"he user cancelled the Facebook login.");
            }
            else if([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"])
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Error"
                                                                message:@"Please go to Settings->Facebook and allow Epic Vegas IV to use your Facebook Account."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Login Error"
                                                                message:[NSString stringWithFormat:@"%@", error]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                NSLog(@"An error occurred logging in: %@", error);
            }
        }
        else{     
            NSLog(@"PFUser Logged In");
            if (user.isNew) {
                NSLog(@"New PFUser was created");
            } else {
                
                NSLog(@"Existing PFUser was logged in");
            }
            
            [self.delegate loginViewController:self didLogInUser:user];
        }
    }];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
