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
                //NSLog(@"New user with facebook signed up and logged in! Id=%@,  User=%@, Password=%@, Email=%@", user.objectId, user.username, user.password, user.email);
                
                //[self fetchUserDataFromFacebook];
                //[self performSegueWithIdentifier:@"loggedInSegue" sender:self];
                //[self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
            } else {
                
                NSLog(@"Existing PFUser was logged in");
                //NSLog(@"User with facebook logged in!  Id=%@,  User=%@, Password=%@, Email=%@", user.objectId, user.username, user.password, user.email);
                
                //[self fetchUserDataFromFacebook];
                //[self performSegueWithIdentifier:@"loggedInSegue" sender:self];
                
                //[self.navigationController pushViewController:[[UserDetailsViewController alloc] initWithStyle:UITableViewStyleGrouped] animated:YES];
            }
            
            [self.delegate logInViewController:self didLogInUser:user];
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
                
                // get profile picture
                [self retrieveAndSaveProfileImageIfDoesntExist:400];
                
                // save a smaller image too
                [self retrieveAndSaveProfileImageIfDoesntExist:140];
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

-(void)retrieveAndSaveProfileImageIfDoesntExist:(int)imageWidth
{
    // see if the user already has the object
    NSString* userPointerName = [NSString stringWithFormat:@"userPhoto%dObjectId", imageWidth];
    
    if([PFUser currentUser][userPointerName] != nil)
    {
        // already has uploaded image
        NSLog(@"User already has image for '%@'", userPointerName);
        return;
    }
    
    // get profile picture
    NSString* profilePicUrlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%d&height=%d&return_ssl_resources=1", [PFUser currentUser][@"fbId"], imageWidth, imageWidth];
    
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: profilePicUrlString]]];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(imageWidth, imageWidth));
    [image drawInRect: CGRectMake(0, 0, imageWidth, imageWidth)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    
    [self uploadImage:imageData withClassName:[NSString stringWithFormat:@"UserPhoto%d", imageWidth] withUserPointerName:[NSString stringWithFormat:@"userPhoto%dObjectId", imageWidth]];
}

- (void)uploadImage:(NSData *)imageData withClassName:(NSString*)className withUserPointerName:(NSString*)userPointerName
{
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Create a PFObject around a PFFile and associate it with the current user
            PFObject *userPhoto = [PFObject objectWithClassName:className];
            [userPhoto setObject:imageFile forKey:@"imageFile"];
            
            // Set the access control list to current user for security purposes
            
            //userPhoto.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            
            PFUser *user = [PFUser currentUser];
            [userPhoto setObject:user forKey:@"user"];
            
            [userPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    user[userPointerName] = userPhoto.objectId;
                   
                    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (!error) {
                            //        [self refresh:nil];
                        }
                        else{
                            // Log details of the failure
                            NSLog(@"Error: %@ %@", error, [error userInfo]);
                        }
                    }];
            //        [self refresh:nil];
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            


        }
        else{
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    } progressBlock:^(int percentDone) {
        // Update your progress spinner here. percentDone will be between 0 and 100.
    }];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}
@end
