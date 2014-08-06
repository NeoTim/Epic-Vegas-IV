//
//  TabBarViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/5/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

UINavigationController* newsFeedController;
UINavigationController* locationController;
UIViewController* addViewController;
UINavigationController* notificationsController;
UINavigationController* profileController;

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
    //addViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Add View Controller"];
    addViewController = [[UIViewController alloc] init];
    addViewController.view = nil;
    
    notificationsController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Notifications Navigation Controller"];
    profileController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Profile Navigation Controller"];
    
    [self setViewControllers:[NSArray arrayWithObjects:newsFeedController, locationController, addViewController, notificationsController, profileController,nil]];

    
    //_centerButton = [self addCenterButtonWithImage:[UIImage imageNamed:@"Add Full Icon.png"] highlightImage:nil];
    //[_centerButton addTarget:self
    //           action:@selector(centerButtonClicked:)
   //  forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSLog(@"Test");
    return YES;
}

//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    BOOL flag = NO;
//    NSUInteger tabIndex = [tabBarController.viewControllers indexOfObject:viewController];
//    
//    NSLog(@"Test");
//    if (viewController == [tabBarController.viewControllers objectAtIndex:tabIndex] &&
//        tabIndex != tabBarController.selectedIndex) {
//        
//        NSLog(@"Test2");
//      //  if ([viewController isMemberOfClass:addViewController]) {
//       //     if (![addViewController.tabBarItem isShowing])
//        //        [addViewController.tabBarItem show];
//         //   else
//         //       [addViewController.tabBarItem hide];
//       // }
//       // else {
//       //     flag = YES;
//       // }
//    }
//    return flag;
//}

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
-(UIButton*) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin
    | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonEvent) forControlEvents:UIControlEventTouchUpInside];
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    CGPoint center = self.tabBar.center;
    center.y = center.y - self.tabBar.frame.origin.y - heightDifference/2.0;
    button.center = center;
    
    [self.tabBar addSubview:button];
    return button;
}

- (void) buttonEvent{
    [self setSelectedIndex:2];
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
