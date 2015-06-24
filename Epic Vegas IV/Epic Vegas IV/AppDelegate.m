//
//  AppDelegate.m
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "Reachability.h"
#import "Cache.h"

@interface AppDelegate () {
    NSMutableData *_data;
    BOOL firstLaunch;
}


//@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;

- (void)setupearance;
- (BOOL)shouldProceedToMainInterface:(PFUser *)user;
- (BOOL)handleActionURL:(NSURL *)url;
@end

@implementation AppDelegate


+(AppDelegate*)sharedInstance
{
    return (AppDelegate*) [[UIApplication sharedApplication] delegate];
}

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Cache sharedCache].shouldRefreshMapOnDisplay = YES;
    [Cache sharedCache].shouldRefreshFriendsOnDisplay = YES;
    [Cache sharedCache].shouldRefreshNewsfeedOnDisplay = YES;
    [Cache sharedCache].shouldRefreshProfileOnDisplay = YES;
    
    CLLocationManager* locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    [locationManager requestAlwaysAuthorization];
    
    NSLog(@"Application did finish launching with options");
    
    // Parse initialization (keys hidden from public)
    [Parse setApplicationId:@"" clientKey:@""];

    [PFFacebookUtils initializeFacebook];
    
    // Track app open.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    PFACL *defaultACL = [PFACL ACL];
    // Enable public read access by default, with any newly created PFObjects belonging to the current user
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Set up our app's global UIAppearance
    [self setupearance];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    // Setup login delegate
    ((LoginViewController*)self.window.rootViewController).delegate = self;
    
    // If logged in, then present tab bar controller
    if ([PFUser currentUser]) {
        NSLog(@"PFUser already logged in detected");
        
        // check that user has profile photo
        if(![PFUser currentUser][@"profilePictureSmall"] || ![PFUser currentUser][@"profilePictureLarge"])
        {
            NSLog(@"Profile photo is missing");
            // ensure logged out
            [self ensureLoggedOutUserAndCleanCaches];
            return YES;
        }

        // Present Main UI
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] presentTabBarController];
        
        // Refresh current user with server side data -- checks if user is still valid and so on
        [[PFUser currentUser] refreshInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
        
        // update geo point
        [Utility updateCurrentUsersLocationWithOnlyIfStale:NO];
        return YES;
    }
    
    // no user, make sure cache is clean
    [self ensureLoggedOutUserAndCleanCaches];
    return YES;
}

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        NSLog(@"User does not exist.");
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] logOut];
        return;
    }
    
    // Check if user is missing a Facebook ID
    if ([Utility userHasValidFacebookData:[PFUser currentUser]]) {
        // User has Facebook ID.
        
        // refresh Facebook friends on each launch
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                }
            } else {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                }
            }
        }];
    } else {
        NSLog(@"Current user is missing their Facebook ID");
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidLoad:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidLoad:) withObject:result];
                }
            } else {
                if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(facebookRequestDidFailWithError:)]) {
                    [[UIApplication sharedApplication].delegate performSelector:@selector(facebookRequestDidFailWithError:) withObject:error];
                }
            }
        }];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([self handleActionURL:url]) {
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Clear badge and update installation, required for auto-incrementing badges.
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveInBackground];
    }
    
    // Clears out all notifications from Notification Center.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 1;
    application.applicationIconBadgeNumber = 0;
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

#pragma mark - LoginViewController

- (void)loginViewController:(LoginViewController *)loginController didLogInUser:(PFUser *)user {
    
    NSLog(@"App Delegate - Did log in user");

    // if no facebook data then fetch it from facebook
    if([Utility userHasProfilePictures:user])
    {
        // good to go
        [self presentTabBarController];
    }
    else
    {
        // get it from facebook
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}


#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {    
    [Utility processFacebookProfilePictureData:_data];
}


#pragma mark - AppDelegate

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated {
 
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    LoginViewController *loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    loginViewController.delegate = self;
    
    NSLog(@"Presenting Login Controller");
    
    [UIView transitionWithView:self.window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ self.window.rootViewController = loginViewController; }
                    completion:nil];
}

- (void)presentLoginViewController {
    [self presentLoginViewControllerAnimated:YES];
}

- (void)presentTabBarController {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    _tabBarController = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
    
    NSLog(@"Presenting Tab Bar Controller");
    //self.window.rootViewController = _tabBarController;
    _tabBarController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    NSLog(@"Presenting Tab Controller");
    [self.window.rootViewController presentViewController:_tabBarController animated:YES completion:nil];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    // Download user's profile picture
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=800&height=800", [[PFUser currentUser] objectForKey:@"facebookId"]]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
}

- (void)logOut {
    NSLog(@"Logging out and clearing caches");
    [self ensureLoggedOutUserAndCleanCaches];
    [self presentLoginViewController];
}

-(void)ensureLoggedOutUserAndCleanCaches
{
    // clear cache
    [[Cache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:@"user"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];

}


#pragma mark - ()

// Set up appearance parameters
- (void)setupearance {
    NSLog(@"Setting up appearance");
    // set the text color for selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    
    // set the selected icon color
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    // remove the shadow
    [[UITabBar appearance] setShadowImage:nil];
    
    // Set the dark color to selected tab (the dimmed background)
    [[UITabBar appearance] setSelectionIndicatorImage:[Utility imageFromColor:[Utility getThemeColor] forSize:CGSizeMake(64, 49) withCornerRadius:0]];
    
    // Configure the tab bar background image
    //[[UITabBar appearance] setShadowImage:tabBarBackground];
    UIImage* tabBarBackground = [UIImage imageNamed:@"Tab Bar Separators.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    
    // Navigation Bar Theme Color
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[Utility getThemeColor],
      NSForegroundColorAttributeName, [UIColor whiteColor],
      NSForegroundColorAttributeName, [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      NSForegroundColorAttributeName, nil,
      NSFontAttributeName, nil]];
    
    // Navigation Bar Title Color
    [[UINavigationBar appearance] setTintColor:[Utility getThemeColor]];
}

- (void)monitorReachability {
    NSLog(@"Monitoring reachability");

    Reachability *hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
    
    hostReach.reachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
        
//        if ([self isParseReachable] && [PFUser currentUser] && self.homeViewController.objects.count == 0) {
//            // Refresh home timeline on network restoration. Takes care of a freshly installed app that failed to load the main timeline under bad network conditions.
//            // In this case, they'd see the empty timeline placeholder and have no way of refreshing the timeline unless they followed someone.
//            [self.homeViewController loadObjects];
//        }
    };
    
    hostReach.unreachableBlock = ^(Reachability*reach) {
        _networkStatus = [reach currentReachabilityStatus];
    };
    
    [hostReach startNotifier];
}

//- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
//    if ([Utility userHasValidFacebookData:[PFUser currentUser]]) {
//        //[MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
//        [self presentTabBarController];
//        
//        [self.navController dismissViewControllerAnimated:YES completion:nil];
//        return YES;
//    }
//    
//    return NO;
//}

- (BOOL)handleActionURL:(NSURL *)url {
    return NO;
}


- (void)facebookRequestDidLoad:(id)result {
    NSLog(@"Facebook request did load");

    // get user's profile info
    PFUser *user = [PFUser currentUser];
    
    if (user) {
        NSString *facebookName = result[@"name"];
        if (facebookName && [facebookName length] != 0) {
            [user setObject:facebookName forKey:@"displayName"];
        }
        
        NSString *facebookId = result[@"id"];
        if (facebookId && [facebookId length] != 0) {
            [user setObject:facebookId forKey:@"facebookId"];
        }
        
        PFUser* currentUser = [PFUser currentUser];
        
        NSString* gender =result[@"gender"];
        if(gender && gender.length != 0)
            currentUser[@"gender"] = gender;
        
        NSString* birthday =result[@"birthday"];
        if(birthday != nil)
            currentUser[@"birthday"] = birthday;
        
        NSString* relationship =result[@"relationship"];
        if(relationship != nil)
            currentUser[@"relationship"] = relationship;
        
        if(result[@"location"])
        {
            NSString* homeLocation = result[@"location"][@"name"];
            if(homeLocation && homeLocation.length != 0)
                currentUser[@"homeLocation"] = homeLocation;
        }
        
        NSString* email =result[@"email"];
        if(email && email.length != 0)
            currentUser[@"email"] = email;
        
        NSString* phone =result[@"phone"];
        if(phone && phone.length != 0)
            currentUser[@"phone"] = phone;
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self presentTabBarController];
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            [self logOut];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook Connection Issue"
                                                            message:@"The Facebook token was invalidated.  Make sure you have a network connection"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}


@end
