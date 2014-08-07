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

UIImageView* blurredImageView;
UIImageView* tintView;

BOOL isAddButtonPressed = NO;

float circleButtonImageRadius = 45;


UIButton *button1;
UIButton *button2;
UIButton *button3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

-(void)handleAddCompleted
{
    [self hideAddActionButtons];
    
    // remove blurred image view, // remove tint view
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{blurredImageView.alpha = 0; tintView.alpha = 0;} completion:nil];
    
    // rotate button now so that x becomes + again and change color back to normal
    [UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.8f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGAffineTransform scaleTrans =
                         CGAffineTransformMakeScale(1, 1);
                         
                         CGAffineTransform rotateTrans =
                         CGAffineTransformMakeRotation(0 * M_PI / 180);
                         
                         centerButtonImageView.transform = CGAffineTransformConcat(scaleTrans, rotateTrans);
                         centerButtonRedImageView.transform = CGAffineTransformConcat(scaleTrans, rotateTrans);
                         centerButtonImageView.alpha = 1.f;
                         centerButtonRedImageView.alpha = 0.f;
                     } completion:nil];

    
    isAddButtonPressed = NO;
}

- (IBAction)centerButtonClicked:(id)sender {
   
    if(isAddButtonPressed) {
        [self handleAddCompleted];
    }
    else {
        [self showAddActionButtons];
        isAddButtonPressed = YES;
        // initialize blurred image view
        blurredImageView = [[UIImageView alloc] initWithFrame:self.selectedViewController.view.frame];
        blurredImageView.image = [self blurredSnapshot];
        blurredImageView.alpha = 0;
        [self.selectedViewController.view addSubview:blurredImageView];
        
        UIImage* tintColorImage = [AppDelegate imageFromColor:[UIColor blackColor] forSize:self.selectedViewController.view.frame.size withCornerRadius:0];
        
        // initialize dark tint view
        tintView = [[UIImageView alloc] initWithFrame:self.selectedViewController.view.frame];
        tintView.alpha = 0;
        tintView.backgroundColor = [UIColor clearColor];
        tintView.opaque = NO;
        tintView.image = tintColorImage;
        
        [self.selectedViewController.view addSubview:tintView];
        
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{blurredImageView.alpha = 1; tintView.alpha = .3f;} completion:nil];
        
        
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
    
    [self createAddActionButtons];
}

/*
 Catch when user is selecting to another view controller.
 If the add button is pressed, then depress it.
 This does not get called when the add button is pressed.
 */
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    
    if(isAddButtonPressed)
    {
        [self handleAddCompleted];
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 * can check tags here if needed, but probably not needed
 */
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item  {
    
}

-(void)showAddActionButtons
{
    // Animate Position
    [UIView animateWithDuration:0.25 animations:^{
        float screenWidth = self.view.frame.size.width;
        float screenHeight = self.view.frame.size.height;
        float imageWidth = circleButtonImageRadius * 2;
        float imageHeight = circleButtonImageRadius * 2;
        
        [button1 setFrame:CGRectMake((screenWidth/3 - (imageWidth / 2)) - 25, (screenHeight - 160), imageWidth, imageHeight)];
        [button2 setFrame:CGRectMake((screenWidth/2 - (imageWidth / 2)), (screenHeight - 240), imageWidth, imageHeight)];
        [button3 setFrame:CGRectMake((2*screenWidth/3 - (imageWidth / 2) + 25), (screenHeight - 160), imageWidth, imageHeight)];
    } completion:^(BOOL finished) {
        //isAddButtonPressed = YES;
    }];
    
    // Animate Rotation
    // rotate button now so that x becomes + again and change color back to normal
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.0f];
    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
    animation.duration = 10.0f;
    animation.repeatCount = INFINITY;
    
    [button1.layer addAnimation:animation forKey:@"SpinAnimation"];
    [button2.layer addAnimation:animation forKey:@"SpinAnimation"];
    [button3.layer addAnimation:animation forKey:@"SpinAnimation"];
}

-(void)hideAddActionButtons
{
    
    float screenHeight = self.view.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [button1 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        [button2 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        [button3 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
    } completion:^(BOOL finished) {
        //self.buttonsExpanded = NO;
    }];
}

-(void)createAddActionButtons
{
    float screenHeight = self.view.frame.size.height;
    CGRect rect = CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0);
    
    button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button1.backgroundColor = [UIColor darkGrayColor];
    button2.backgroundColor = [UIColor darkGrayColor];
    button3.backgroundColor = [UIColor darkGrayColor];
    
    button1.layer.cornerRadius = circleButtonImageRadius;
    button2.layer.cornerRadius = circleButtonImageRadius;
    button3.layer.cornerRadius = circleButtonImageRadius;
    
    
    button1.layer.masksToBounds = NO;
    button2.layer.masksToBounds = NO;
    button3.layer.masksToBounds = NO;
        
    [button1 setImage:[UIImage imageNamed:@"Camera Image 70.png"] forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"full__0000s_0122_camera.png"] forState:UIControlStateNormal];
    [button3 setImage:[UIImage imageNamed:@"quote.png"] forState:UIControlStateNormal];
    
    button1.frame = rect;
    button2.frame = rect;
    button3.frame = rect;
    
    [button1 addTarget:self action:@selector(someButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(someButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button3 addTarget:self action:@selector(someButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
}

- (IBAction)someButtonClicked:(id)sender {

    
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
