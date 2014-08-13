//
//  PostToFeedViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/7/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "PostToFeedViewController.h"
#import "UIImage+ResizeAdditions.h"

@interface PostToFeedViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintToAdjust;

@property (strong, nonatomic) IBOutlet UIImagePickerController *photoPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *locationButton;

@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *resizedPhotoFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;

@property (nonatomic, strong) UIActionSheet *cameraActionSheet;

@property (nonatomic, strong) UIActivityIndicatorView* spinner;
@end

@implementation PostToFeedViewController


NSInteger characterLimit = 300;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
    [_messageTextView becomeFirstResponder];
    
    if(_passedInImage)
    {
        [self attachImage:_passedInImage withDelay:0];
        _passedInImage = nil;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _messageTextView.delegate = self;
    
    // round out profile image
    _profileImageView.clipsToBounds = YES;
    _profileImageView.alpha = 0;
    _profileImageView.layer.cornerRadius = _profileImageView.layer.frame.size.height / 2;
    
    // Load user's photo into the post text box
    if(!_profileImageView.image)
    {
        PFFile *imageFile = [[PFUser currentUser] objectForKey:@"profilePictureSmall"];
        if (imageFile) {
            [_profileImageView setFile:imageFile];
            [_profileImageView loadInBackground:^(UIImage *image, NSError *error) {
                if (!error) {
                    [UIView animateWithDuration:1.0f animations:^{
                        _profileImageView.alpha = 1.0f;
                    }];
                }
            }];
        }
    }
    else{
        [UIView animateWithDuration:1.0f animations:^{
            _profileImageView.alpha = 1.0f;
        }];
    }
    
    [self updateCharacterCountString];
    
//    // observe keyboard hide and show notifications to resize the text view appropriately
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
 
    // start editing text
    [self initMessageAccessoryView];
    [self initializeCameraActionSheet];
    
    _attachedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
}

-(void)initMessageAccessoryView
{
    UIToolbar* keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    //numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    _cameraButton =[[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(cameraButtonClicked:)];
    _cameraButton.image = [UIImage imageNamed:@"full__0000s_0122_camera.png"];
    _cameraButton.tintColor = [UIColor darkGrayColor];
    _cameraButton.width = 25;
    
    _locationButton = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonClicked:)];
    _locationButton.image = [UIImage imageNamed:@"Location Black.png"];
    _locationButton.tintColor = [UIColor darkGrayColor];
    _locationButton.width = 30;
    
    keyboardToolbar.items = [NSArray arrayWithObjects:_cameraButton,_locationButton, nil];
    [keyboardToolbar sizeToFit];
    
    [keyboardToolbar addSubview:_characterCountLabel];
    [_characterCountLabel setFrame:CGRectMake(250, 3, 50, 40)];
    _messageTextView.inputAccessoryView = keyboardToolbar;
}

- (IBAction)cameraButtonClicked:(id)sender {
    if(_attachedImageView.image)
    {
        // if already has photo then show the photo and see if they want to remove
        [self showRemovePhotoView];
    }
    else
    {
        _photoPicker = [[UIImagePickerController alloc] init];
        _photoPicker.delegate = self;
        _photoPicker.allowsEditing = NO;

        // if not, then ask if they want to choose existing photo or take a new photo
        [_cameraActionSheet showInView:self.view];
    }
}

-(void)initializeCameraActionSheet
{
    _cameraActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:nil
                                                          otherButtonTitles:@"Take photo", @"Choose Existing", nil];
    _cameraActionSheet.tag = 7431;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // action sheet for camera button press
    if(actionSheet.tag == 7431)
    {
        if (buttonIndex == 0) {
            // new photo
            _photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_photoPicker animated:YES completion:NULL];
            [_messageTextView resignFirstResponder];
        } else if (buttonIndex == 1) {
            // existing photo
            _photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_photoPicker animated:YES completion:NULL];
            [_messageTextView resignFirstResponder];
        }
    }
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage* originalImage=info[UIImagePickerControllerOriginalImage];
    
    // save image to camera roll but only if took a new photo from camera
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
        });
    }
    
    [self attachImage:originalImage withDelay:1.0f];
}

-(void)attachImage:(UIImage*)image withDelay:(CGFloat)delay
{
    _attachedImageView.image = image;
    _attachedImageView.layer.borderColor = [UIColor blackColor].CGColor;
    _attachedImageView.layer.borderWidth = .1f;
    _attachedImageButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_attachedImageButton addTarget:self action:@selector(showRemovePhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _cameraButton.tintColor = [UIColor redColor];
    
    // fade in picture
    _attachedImageView.alpha = 0;
    [UIView animateWithDuration:1.0f delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
        _attachedImageView.alpha = 1.0f;
    } completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)locationButtonClicked:(id)sender {
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
    [aTextView resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)txtView
{
    _placeholderTextField.hidden = ([txtView.text length] > 0);
    [self updateCharacterCountString];
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    _placeholderTextField.hidden = ([txtView.text length] > 0);
    [self updateCharacterCountString];
}

-(void)updateCharacterCountString
{
    NSString* text = [self getTruncatedText];
    
    _characterCountLabel.text = [NSString stringWithFormat:@"%d", characterLimit - text.length];
    
    if(text.length > characterLimit || text.length < 1)
    {
        // only color red if over max char limit
        if(text.length > characterLimit)
            _characterCountLabel.textColor = [UIColor redColor];
        else
            _characterCountLabel.textColor = [UIColor blackColor];
        
        _postButton.enabled = NO;
    }
    else
    {
        _postButton.enabled = YES;
        _characterCountLabel.textColor = [UIColor blackColor];
    }
}

-(NSString*)getTruncatedText
{
    NSString* text = _messageTextView.text;
    while([text characterAtIndex:text.length - 1] == ' ')
    {
        text = [text substringToIndex:text.length - 1];
    }
    return  text;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonPressed:(id)sender {
    // show spinner
    _spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40,self.view.frame.size.height / 2 - 125,80,80)];

    //spinner.color = [UIColor darkGrayColor];
    _spinner.backgroundColor = [UIColor darkGrayColor];
    _spinner.layer.cornerRadius = 5;
    _spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [_spinner startAnimating];
    [self.view addSubview:_spinner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // lots of code run in the background
        
        // Create Photo if there is a photo
        PFObject *photo = nil;
        if(_attachedImageView.image)
        {
            // FIX THIS
            UIImage* originalImage =_attachedImageView.image;
            
            CGFloat originalWidth = originalImage.size.width;
            CGFloat originalHeight = originalImage.size.height;
            NSLog(@"Original image width=%f, height=%f", originalWidth, originalHeight);
            
            BOOL widthIsLongSide = NO;
            if(originalWidth > originalHeight)
                widthIsLongSide = YES;

            // always resize to fit a certain width
            CGFloat thumbnailWidth = 640;
            CGFloat thumbnailHeightMultiplier = thumbnailWidth / originalWidth;
            
            CGFloat thumbnailHeight = originalHeight * thumbnailHeightMultiplier;
            thumbnailHeight = (CGFloat)(int)(thumbnailHeight + .5f); //round to nearest whole number
            
            NSLog(@"thumbnail image width=%f, height=%f", thumbnailWidth, thumbnailHeight);
          
            UIImage *thumbnailImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(thumbnailWidth, thumbnailHeight) interpolationQuality:kCGInterpolationHigh];
            
            // max length is 2048
            CGFloat longestLength = 1024;
            CGFloat resizeMultiplier = 1.0;
            if(originalHeight > originalWidth && originalHeight > longestLength)
            {
                // if height is long edge, then reduce if height is longer than 2048
                resizeMultiplier = longestLength / originalHeight;
            }
            else if(originalWidth > originalHeight && originalWidth > longestLength)
            {
                // if width is long edge, then reduce if width is > 2048
                resizeMultiplier = longestLength / originalWidth;
            }
            else if(originalWidth > longestLength) // sides are equal, but longer than allowed
            {
                resizeMultiplier = longestLength / originalWidth;
            }
            
            UIImage *largeImage = originalImage;
            CGFloat largeImageWidth = originalWidth;
            CGFloat largeImageHeight = originalHeight;
            if(resizeMultiplier != 1.0)
            {
                largeImageHeight = originalHeight * resizeMultiplier;
                largeImageHeight = (CGFloat)(int)(largeImageHeight + .5f); //round to nearest whole number
                
                largeImageWidth = originalWidth * resizeMultiplier;
                largeImageWidth = (CGFloat)(int)(largeImageWidth + .5f); //round to nearest whole number
                NSLog(@"resized large image width=%f, height=%f", largeImageWidth, largeImageHeight);
                
                largeImage = [originalImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(largeImageWidth, largeImageHeight) interpolationQuality:kCGInterpolationHigh];
            }
            else{
                NSLog(@"no resizing of original image");
            }
          
            // JPEG to decrease file size and enable faster uploads & downloads
            NSData *imageData = UIImageJPEGRepresentation(originalImage, 0.2f);
            NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, .4f); // should be good
            
            self.photoFile = [PFFile fileWithData:imageData];
            self.resizedPhotoFile = [PFFile fileWithData:thumbnailImageData];
            
            if (!self.photoFile || !self.resizedPhotoFile) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                return;
            }
            
            // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
            self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
            
            [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [self.resizedPhotoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    }];
                } else {
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
            }];
            
            // create a photo object
            photo = [PFObject objectWithClassName:@"Photo"];
            
            NSLog(@"photo with object id created: %@", photo.objectId);
            [photo setObject:[PFUser currentUser] forKey:@"user"];
            [photo setObject:self.resizedPhotoFile forKey:@"thumbnail"];
            photo[@"thumbnailWidth"] = [NSString stringWithFormat:@"%f", thumbnailWidth];
            photo[@"thumbnailHeight"] = [NSString stringWithFormat:@"%f", thumbnailHeight];
            
            // photos are public, but may only be modified by the user who uploaded them
            PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [photoACL setPublicReadAccess:YES];
            photo.ACL = photoACL;
            
            // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
            self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
            }];
            
            // Save the Photo PFObject
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                     
                    NSLog(@"thumbnail photo saved");
                    
                    [self createPostWithPhoto:photo];
                    
                    // in background upload the larger photo
                    [photo setObject:self.photoFile forKey:@"image"];
                    
                    photo[@"originalWidth"] = [NSString stringWithFormat:@"%f", largeImageWidth];
                    photo[@"originalHeight"] = [NSString stringWithFormat:@"%f", largeImageHeight];
                    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"large size photo saved");
                        }
                    }];

                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
                [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
            }];
        }
        else{
            // Create Post without image
            [self createPostWithPhoto:nil];
        }
    });
}

-(void)createPostWithPhoto:(PFObject*)photo
{
    PFObject *post = [PFObject objectWithClassName:@"Post"];
    [post setObject:[self getTruncatedText] forKey:@"message"];
    PFUser *user = [PFUser currentUser];
    [post setObject:user forKey:@"user"];
    
    // set the post type to be "Post"
    post[@"type"] = @"post"; // normal post
    
    if(photo)
    {
        NSLog(@"saving photo with object id to post: %@", photo.objectId);
        [post setObject:photo forKey:@"photo"];
    }
    
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // stop and remove the spinner on the background when done
            [_spinner removeFromSuperview];
            
            // dismiss view
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];

}

- (IBAction)showRemovePhotoButtonPressed:(id)sender {
    if(_attachedImageView.image != nil)
        [self showRemovePhotoView];
}

-(void)showRemovePhotoView
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    RemovePhotoViewController* removePhotoViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Remove Photo View Controller"];
    
    removePhotoViewController.delegate = self;
    removePhotoViewController.imageToShow = _attachedImageView.image;
    [self.navigationController pushViewController:removePhotoViewController animated:YES];
}

-(void)removeAttachedPhoto
{
    // unhook attached image button event
    [_attachedImageButton removeTarget:self action:@selector(showRemovePhotoButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // remove attached image border
    _attachedImageView.layer.borderColor = [UIColor clearColor].CGColor;

    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _attachedImageView.alpha = 1.0f;
        _cameraButton.tintColor = [UIColor blackColor];
    }completion:^(BOOL finished) {
        _attachedImageView.image = nil;
    }];
}

@end
