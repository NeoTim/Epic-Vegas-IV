//
//  ProfileViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "ProfileViewController.h"

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
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto400"];
    id userPhoto = [PFUser currentUser][@"userPhoto400ObjectId"];
    if(userPhoto)
    {
        [query getObjectInBackgroundWithId:[PFUser currentUser][@"userPhoto400ObjectId"] block:^(PFObject *userPhoto, NSError *error) {
            if(!error)
            {
                PFFile *theImage = [userPhoto objectForKey:@"imageFile"];
                NSData *imageData = [theImage getData];
                UIImage *image = [UIImage imageWithData:imageData];
                _fbProfilePicView.image = image;
                
                // fade in profile pic
                [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
                    _fbProfilePicView.alpha = 1;
                } completion:nil];
            }
            else{
                // Do something with the returned PFObject in the gameScore variable.
                NSLog(@"%@", error);
            }
        }];
    }

    _fbProfilePicView.clipsToBounds = YES;
    _fbProfilePicView.alpha = 0;
    _fbProfilePicView.layer.cornerRadius = _fbProfilePicView.layer.frame.size.height / 2;
    
    // Do any additional setup after loading the view.
    //_fbProfilePicView.profileID = [PFUser currentUser][@"fbId"];
    
    _userNameLabel.text = [PFUser currentUser][@"fbName"];
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
            NSLog(@"Logging out");

            [PFUser logOut];
     
            // show login view
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                                     bundle: nil];
          
            UIViewController* loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginViewController"];
            
            [UIView transitionFromView:self.view.window.rootViewController.view
                                toView:loginViewController.view
                              duration:1.f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            completion:^(BOOL finished){
                                self.view.window.rootViewController = loginViewController;
                            }];
        }
    }
}

- (IBAction)shareLocationSwitchChanged:(id)sender {
}
@end
