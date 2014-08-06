//
//  TabBarViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/5/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "TabBarViewController.h"
#import "AppDelegate.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

UINavigationController* newsFeedController;
UINavigationController* locationController;
UIViewController* addViewController;
UINavigationController* notificationsController;
UINavigationController* profileController;
UIImageView* centerButtonImageView;
UIImageView* centerButtonRedImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (IBAction)centerButtonClicked:(id)sender {
    NSLog(@"custom center clicked");
  
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.selectedViewController.view.frame];
    imageView.image = [self blurredSnapshot];
    imageView.alpha = 0;
    [self.selectedViewController.view addSubview:imageView];
    
    UIImage* tintColorImage = [AppDelegate imageFromColor:[UIColor blackColor] forSize:self.selectedViewController.view.frame.size withCornerRadius:0];

    UIImageView* tintView = [[UIImageView alloc] initWithFrame:self.selectedViewController.view.frame];
    tintView.alpha = 0;
    tintView.backgroundColor = [UIColor clearColor];
    tintView.opaque = NO;
    tintView.image = tintColorImage;
    
    [self.selectedViewController.view addSubview:tintView];
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{imageView.alpha = 1;} completion:nil];
    
     [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseIn animations:^{tintView.alpha = .3f;} completion:nil];
    
    // rotate button now so that + becomes x and change color to red
    [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.8f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGAffineTransform scaleTrans =
                         CGAffineTransformMakeScale(1, 1);

                         CGAffineTransform rotateTrans =
                         CGAffineTransformMakeRotation(45 * M_PI / 180);
                         
                         centerButtonImageView.transform = CGAffineTransformConcat(scaleTrans, rotateTrans);
                         centerButtonRedImageView.transform = CGAffineTransformConcat(scaleTrans, rotateTrans);
                         centerButtonImageView.alpha = 0.f;
                         centerButtonRedImageView.alpha = 1.f;
                     } completion:nil];
    
    }

/*
 * http://damir.me/ios7-blurring-techniques
 */
-(UIImage *)blurredSnapshot
{
    UIView* view = self.selectedViewController.view;
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, view.window.screen.scale);
    
    // There he is! The new API method
    [view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:NO];
    
    // Get the snapshot
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Now apply the blur effect using Apple's UIImageEffect category
    UIImage *blurredSnapshotImage = [snapshotImage applyBlurWithRadius:2.5f tintColor:[UIColor clearColor] saturationDeltaFactor:1.f maskImage:snapshotImage];
    
    // Be nice and clean your mess up
    UIGraphicsEndImageContext();
    
    return blurredSnapshotImage;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self setDelegate:self];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
  
    newsFeedController = [mainStoryboard instantiateViewControllerWithIdentifier:@"News Feed Navigation Controller"];
    locationController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Location Navigation Controller"];
    addViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Add View Controller"];
    
    notificationsController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Notifications Navigation Controller"];
    profileController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Profile Navigation Controller"];
    
    [self setViewControllers:[NSArray arrayWithObjects:newsFeedController, locationController, addViewController, notificationsController, profileController,nil]];

    
    _centerButton = [self addCenterButton];
    
    
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    BOOL result = NO;
    NSUInteger tabIndex = [tabBarController.viewControllers indexOfObject:viewController];
    
    if (viewController == [tabBarController.viewControllers objectAtIndex:tabIndex] &&
        tabIndex != tabBarController.selectedIndex) {
        
        // check if "+" tab item is being selected
        if (viewController == addViewController)
        {
            NSLog(@"Add Button Was Selected");
            result = NO;
        }
        else {
            result = YES;
        }
    }
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    
    NSLog(@"tab bar button selected");
    if(item.tag == 728)
    {
        // Plus button
        

        //item.image = [UIImage imageNamed:@"full__0000s_0101_drawer"];
        //[item setImage:[UIImage imageNamed:@"full__0000s_0101_drawer"]];
        
    }
}



// Create a custom UIButton and add it to the center of our tab bar
-(UIButton*) addCenterButton
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    
    UIImage* buttonImage = [UIImage imageNamed:@"Add Full Icon.png"];
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    
    
    [button addTarget:self action:@selector(centerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];  CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;

    
    CGPoint center = self.tabBar.center;
    center.y = center.y - self.tabBar.frame.origin.y - heightDifference/2.0;
    button.center = center;
    
    [self.tabBar addSubview:button];
    
    centerButtonImageView = [[UIImageView alloc] initWithFrame:button.frame];
    centerButtonImageView.image = buttonImage;
    centerButtonImageView.userInteractionEnabled = NO;
    [self.tabBar addSubview:centerButtonImageView];
    
    centerButtonRedImageView = [[UIImageView alloc] initWithFrame:button.frame];
    centerButtonRedImageView.image =[UIImage imageNamed:@"Add Red Icon.png"];
    centerButtonRedImageView.userInteractionEnabled = NO;
    centerButtonRedImageView.alpha= 0;
    [self.tabBar addSubview:centerButtonRedImageView];
    return button;
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

@end
