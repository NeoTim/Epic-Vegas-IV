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
    //NSString* fontName = @"BoldDotDigital-7";
    //NSString* fontName = @"AdvancedDotDigital-7";
    //NSString* fontName = @"TripleDotDigital-7";
    //NSString* fontName = @"ModernDotDigital-7"; // no
    //NSString* fontName = @"EnhancedDotDigital-7";
    //NSString* fontName = @"LEDCounter7";
    
    NSString* fontName = @"DS-Digital-BoldItalic";
    //NSString* fontName = @"AtomicClockRadio";
    //NSString* fontName = @"The-Vandor-Spot";
    
    
    //int fontSize = 74;
    //int fontSize = 50;
    int fontSize = 100;
    
    _epicLabel.font = [UIFont fontWithName:fontName size:fontSize];
    _vegasLabel.font = [UIFont fontWithName:fontName size:fontSize];
    _ivLabel.font = [UIFont fontWithName:fontName size:fontSize];

    _epicLabel.layer.masksToBounds = NO;
    _vegasLabel.layer.masksToBounds = NO;
    _ivLabel.layer.masksToBounds = NO;
}

-(void)printFonts
{
    // Code to print fonts
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

- (void)viewDidLoad
{
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
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"public_profile", @"email", @"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            }
            else if([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"])
            {
                NSLog(@"Please go to Settings->Facebook and allow Epic Vegas IV to use your Facebook Account.");
            }
            else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"New user with facebook signed up and logged in! Id=%@,  User=%@, Password=%@, Email=%@", user.objectId, user.username, user.password, user.email);

            [self fetchUserDataFromFacebook];
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
            //[self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        } else {
            NSLog(@"User with facebook logged in!  Id=%@,  User=%@, Password=%@, Email=%@", user.objectId, user.username, user.password, user.email);

            [self fetchUserDataFromFacebook];
            [self performSegueWithIdentifier:@"loggedInSegue" sender:self];
                        
            //[self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
        }
    }];
}

-(void)fetchUserDataFromFacebook
{
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
//    // Send request to Facebook
//    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        if (!error) {
//            // result is a dictionary with the user's Facebook data
//            NSDictionary *userData = (NSDictionary *)result;
//            
//            NSString *facebookID = userData[@"id"];
//            NSString *name = userData[@"name"];
//            NSString *location = userData[@"location"][@"name"];
//            NSString *gender = userData[@"gender"];
//            NSString *birthday = userData[@"birthday"];
//            NSString *relationship = userData[@"relationship_status"];
//            
//            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
//                        
//            //_fbProfilePicView.profileID = facebookID;
//            //_userNameLabel.text = name;
//            
//            
//            //UIImage *im = [UIImage imageWithData: [NSData dataWithContentsOfURL:pictureURL]];
//            
//            PFUser *currentUser = [PFUser currentUser];
//            currentUser[@"fbId"] = facebookID;
//            currentUser[@"fbGender"] = gender;
//            currentUser[@"fbName"] = name;
//            currentUser[@"fbBirthday"] = birthday;
//            currentUser[@"fbRelationship"] = relationship;
//            currentUser[@"fbLocation"] = location;
//            currentUser[@"fbProfilePicUrl"] = pictureURL;
//            [currentUser saveInBackground];
//        }
//    }];
    NSLog(@"Fetching user info from Facebook...");
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Store the current user's Facebook ID on the user
            
            NSDictionary *userData = (NSDictionary *)result;
            
//            NSString* fbId = [result objectForKey:@"id"];
//            NSString* name =[result objectForKey:@"name"];
//            NSString* gender =[result objectForKey:@"gender"];
//            NSString* birthday =[result objectForKey:@"birthday"];
//            NSString* relationship =[result objectForKey:@"relationship"];
            
            NSString* fbId = userData[@"id"];
            NSString* name =userData[@"name"];
            NSString* gender =userData[@"gender"];
            NSString* birthday =userData[@"birthday"];
            NSString* relationship =userData[@"relationship"];
            NSString* email =userData[@"email"];
            NSString* phone =userData[@"phone"];
            

            PFUser* currentUser = [PFUser currentUser];

            if(fbId != nil)
            {
                currentUser[@"fbId"] = fbId;
            }
        
            if(name != nil)
                currentUser[@"fbName"] = name;
            
            if(gender != nil)
                currentUser[@"fbGender"] = gender;
           
            if(birthday != nil)
                currentUser[@"fbBirthday"] = birthday;
            
            if(relationship != nil)
                currentUser[@"fbRelationship"] = relationship;
            
            if(userData[@"location"] != nil && userData[@"location"][@"name"] != nil)
                currentUser[@"fbLocation"] = userData[@"location"][@"name"];
          
            if(email != nil)
                currentUser[@"fbEmail"] = email;
            
            if(phone != nil)
                currentUser[@"fbPhone"] = phone;
            
            NSLog(@"Saving user:%@", [PFUser currentUser]);
            [[PFUser currentUser] saveInBackground];
        }
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
