//
//  ProfileViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    
    PFFile *imageFile = [[PFUser currentUser] objectForKey:kUserProfilePicLargeKey];
    if (imageFile) {
        [_fbProfilePicView setFile:imageFile];
        [_fbProfilePicView loadInBackground:^(UIImage *image, NSError *error) {
            if (!error) {
                [UIView animateWithDuration:0.5f animations:^{
                    _fbProfilePicView.alpha = 1.0f;
                }];
            }
        }];
    }

    _fbProfilePicView.clipsToBounds = YES;
    _fbProfilePicView.alpha = 0;
    _fbProfilePicView.layer.cornerRadius = _fbProfilePicView.layer.frame.size.height / 2;
    
    // Do any additional setup after loading the view.
    //_fbProfilePicView.profileID = [PFUser currentUser][@"fbId"];
    
    _userNameLabel.text = [PFUser currentUser][kUserDisplayNameKey];
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

- (IBAction)logOutButtonPressed:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to log out?"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Log Out", nil];
    actionSheet.tag = 7431;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // action sheet for logout confirmation
    if(actionSheet.tag == 7431)
    {
        if (buttonIndex == 0) {
            // log out
            [[AppDelegate sharedInstance] logOut];
        }
    }
}

- (IBAction)shareLocationSwitchChanged:(id)sender {
}
@end
