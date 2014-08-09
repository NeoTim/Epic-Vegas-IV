//
//  TabBarViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/5/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "TabBarController.h"
#import "AppDelegate.h"

@interface TabBarController ()

@property (strong, nonatomic) UILabel* shareContentLabel;

@end

@implementation TabBarController

UINavigationController* newsFeedController;
UINavigationController* locationController;
UIViewController* addViewController;
UINavigationController* notificationsController;
UINavigationController* profileController;
UIImageView* centerButtonImageView;
UIImageView* centerButtonRedImageView;

UIImageView* blurredImageView;
UIImageView* tintView;
UIImagePickerController *photoPicker;

BOOL isAddButtonPressed = NO;

float circleButtonImageRadius = 30;


UIButton *button1;
UIButton *button2;
UIButton *button3;

UIButton *buttonBorder1;
UIButton *buttonBorder2;
UIButton *buttonBorder3;
float addButtonActionBorderWidth = 10;
UIButton* selectExistingPhotoButton;

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
        
        UIImage* tintColorImage = [Utility imageFromColor:[UIColor blackColor] forSize:self.selectedViewController.view.frame.size withCornerRadius:0];
        
        // initialize dark tint view
        tintView = [[UIImageView alloc] initWithFrame:self.selectedViewController.view.frame];
        tintView.alpha = 0;
        tintView.backgroundColor = [UIColor clearColor];
        tintView.opaque = NO;
        tintView.image = tintColorImage;
        
        [self.selectedViewController.view addSubview:tintView];
        
        self.modalPresentationStyle = UIModalPresentationCurrentContext;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{blurredImageView.alpha = 1; tintView.alpha = .85f;} completion:nil];
        
        
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
    
    NSLog(@"Tab Bar Controller Did Load");

    // Do any additional setup after loading the view.
    [self setDelegate:self];
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
//                                                             bundle: nil];
//  
//    newsFeedController = [mainStoryboard instantiateViewControllerWithIdentifier:@"News Feed Navigation Controller"];
//    locationController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Location Navigation Controller"];
//    addViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Add View Controller"];
//    
//    notificationsController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Notifications Navigation Controller"];
//    profileController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Profile Navigation Controller"];
//    
//    [self setViewControllers:[NSArray arrayWithObjects:newsFeedController, locationController, addViewController, notificationsController, profileController,nil]];

    
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
    float screenWidth = self.view.frame.size.width;
    float screenHeight = self.view.frame.size.height;
    float imageWidth = circleButtonImageRadius * 2;
    float imageHeight = circleButtonImageRadius * 2;
    float bottom = 150;
    
    
    // Animate Position
    [UIView animateWithDuration:0.25 animations:^{
      
        _shareContentLabel.alpha = 1;
        
        button1.alpha = 1;
        button2.alpha = 1;
        button3.alpha = 1;
        
        buttonBorder1.alpha = 1;
        buttonBorder2.alpha = 1;
        buttonBorder3.alpha = 1;
        
        [button1 setFrame:CGRectMake((screenWidth/3 - (imageWidth / 2)) - 30, (screenHeight - bottom), imageWidth, imageHeight)];
        [button2 setFrame:CGRectMake((screenWidth/2 - (imageWidth / 2)), (screenHeight - bottom - 70), imageWidth, imageHeight)];
        [button3 setFrame:CGRectMake((2*screenWidth/3 - (imageWidth / 2) + 30), (screenHeight - bottom), imageWidth, imageHeight)];
        
        float borderWidth = circleButtonImageRadius * 2 + addButtonActionBorderWidth * 2;
        float borderHeight = circleButtonImageRadius * 2 + addButtonActionBorderWidth * 2;
        
        [buttonBorder1 setFrame:CGRectMake((screenWidth/3 - (imageWidth / 2)) - 30 - addButtonActionBorderWidth, (screenHeight - bottom) - addButtonActionBorderWidth, borderWidth, borderHeight)];
        [buttonBorder2 setFrame:CGRectMake((screenWidth/2 - (imageWidth / 2)) - addButtonActionBorderWidth, (screenHeight - bottom - 70 - addButtonActionBorderWidth), borderWidth, borderHeight)];
        [buttonBorder3 setFrame:CGRectMake((2*screenWidth/3 - (imageWidth / 2) + 30) - addButtonActionBorderWidth, (screenHeight - bottom - addButtonActionBorderWidth), borderWidth, borderHeight)];
        
    } completion:^(BOOL finished) {
        //isAddButtonPressed = YES;
    }];
    
    // Animate Rotation
    // rotate button now so that x becomes + again and change color back to normal
    
//    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//    animation.fromValue = [NSNumber numberWithFloat:0.0f];
//    animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
//    animation.duration = 10.0f;
//    animation.repeatCount = INFINITY;
    
    //[button1.layer addAnimation:animation forKey:@"SpinAnimation"];
    //[button2.layer addAnimation:animation forKey:@"SpinAnimation"];
    //[button3.layer addAnimation:animation forKey:@"SpinAnimation"];
}

-(void)hideAddActionButtons
{
    
    float screenHeight = self.view.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [button1 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        [button2 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        [button3 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
  
        [buttonBorder1 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        [buttonBorder2 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        [buttonBorder3 setFrame:CGRectMake(_centerButton.center.x, screenHeight, 0.0, 0.0)];
        
        button1.alpha = 0;
        button2.alpha = 0;
        button3.alpha = 0;
        
        buttonBorder1.alpha = 0;
        buttonBorder2.alpha = 0;
        buttonBorder3.alpha = 0;

        _shareContentLabel.alpha = 0;
        
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
    
    button1.backgroundColor = [Utility getThemeColor];
    button2.backgroundColor = [Utility getThemeColor];
    button3.backgroundColor = [Utility getThemeColor];
    
    button1.layer.cornerRadius = circleButtonImageRadius;
    button2.layer.cornerRadius = circleButtonImageRadius;
    button3.layer.cornerRadius = circleButtonImageRadius;
    
    button1.alpha = 0;
    button2.alpha = 0;
    button3.alpha = 0;
    
    buttonBorder1.alpha = 0;
    buttonBorder2.alpha = 0;
    buttonBorder3.alpha = 0;
    
    button1.layer.masksToBounds = NO;
    button2.layer.masksToBounds = NO;
    button3.layer.masksToBounds = NO;
        
    [button1 setImage:[UIImage imageNamed:@"Location 60.png"] forState:UIControlStateNormal];
    [button2 setImage:[UIImage imageNamed:@"Camera 60.png"] forState:UIControlStateNormal];
    [button3 setImage:[UIImage imageNamed:@"Write Text 60.png"] forState:UIControlStateNormal];
    
    button1.frame = rect;
    button2.frame = rect;
    button3.frame = rect;
    
    [button1 addTarget:self action:@selector(locationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button2 addTarget:self action:@selector(cameraButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button3 addTarget:self action:@selector(writeTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    buttonBorder1 = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBorder2 = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonBorder3 = [UIButton buttonWithType:UIButtonTypeCustom];

    float equalColorSplit = 220;
    UIColor* borderColor = [UIColor colorWithRed:equalColorSplit/255.0 green:equalColorSplit/255.0 blue:equalColorSplit/255.0 alpha:1.0];
    buttonBorder1.backgroundColor = borderColor;
    buttonBorder2.backgroundColor = borderColor;
    buttonBorder3.backgroundColor = borderColor;
    
    buttonBorder1.layer.cornerRadius = circleButtonImageRadius + addButtonActionBorderWidth;
    buttonBorder2.layer.cornerRadius = circleButtonImageRadius + addButtonActionBorderWidth;
    buttonBorder3.layer.cornerRadius = circleButtonImageRadius + addButtonActionBorderWidth;
    
    
    buttonBorder1.layer.masksToBounds = NO;
    buttonBorder2.layer.masksToBounds = NO;
    buttonBorder3.layer.masksToBounds = NO;
    
    buttonBorder1.frame = rect;
    buttonBorder2.frame = rect;
    buttonBorder3.frame = rect;
    
    buttonBorder1.userInteractionEnabled = NO;
    buttonBorder2.userInteractionEnabled = NO;
    buttonBorder3.userInteractionEnabled = NO;
    
    [self.view addSubview:buttonBorder1];
    [self.view addSubview:buttonBorder2];
    [self.view addSubview:buttonBorder3];
    
    [self.view addSubview:button1];
    [self.view addSubview:button2];
    [self.view addSubview:button3];
    
    
    float screenWidth = self.view.frame.size.width;
    float imageWidth = circleButtonImageRadius * 2;
    float imageHeight = circleButtonImageRadius * 2;
    float bottom = 150;

    _shareContentLabel = [[UILabel alloc] initWithFrame:CGRectMake((0), (screenHeight - bottom - 135), screenWidth, 50)];
    _shareContentLabel.textAlignment = NSTextAlignmentCenter;
    _shareContentLabel.alpha = 0;
    _shareContentLabel.textColor = borderColor;
    _shareContentLabel.text = @"What would you like to share?";
    _shareContentLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.view addSubview:_shareContentLabel];
}

- (IBAction)locationButtonClicked:(id)sender {
    [self handleAddCompleted];
    
    
}

- (IBAction)cameraButtonClicked:(id)sender {
    
    photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.allowsEditing = YES;
   
    [self handleAddCompleted];
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:photoPicker animated:YES completion:NULL];
    
    float screenWidth = self.view.frame.size.width;
    
    selectExistingPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 75, 8, 25, 25)];
    [selectExistingPhotoButton setImage:[UIImage imageNamed:@"All Images.png"] forState:UIControlStateNormal];
    [photoPicker.view addSubview:selectExistingPhotoButton];
    
    [selectExistingPhotoButton addTarget:self action:@selector(selectExistingPhotoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    //UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                         delegate:self
    //                                                cancelButtonTitle:@"Cancel"
    //                                           destructiveButtonTitle:nil
    //                                                otherButtonTitles:@"Take photo", @"Choose Existing", nil];
    //actionSheet.tag = 7432;
    //[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // action sheet for camera button press
    if(actionSheet.tag == 7432)
    {
        if (buttonIndex == 0) {
            photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:photoPicker animated:YES completion:NULL];
        } else if (buttonIndex == 1) {
            photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:photoPicker animated:YES completion:NULL];
        }
        else
        {
            
        }
    }
}

- (IBAction)writeTextButtonClicked:(id)sender {
    [self handleAddCompleted];

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    [self presentViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"Create Post Navigation Controller"] animated:YES completion:NULL];
}

-(IBAction)selectExistingPhotoButtonClicked:(id)sender
{
    selectExistingPhotoButton.alpha = 0;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
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

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    //self.imageView.image = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    // save image to camera roll!
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // if in camera than dismiss view, otherwise switch back to camera view
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
        [picker dismissViewControllerAnimated:YES completion:NULL];
    else
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        selectExistingPhotoButton.alpha = 1;
    }
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
