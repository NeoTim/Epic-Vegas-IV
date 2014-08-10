//
//  PostToFeedViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/7/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "PostToFeedViewController.h"

@interface PostToFeedViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintToAdjust;

@property (strong, nonatomic) IBOutlet UIImagePickerController *photoPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *locationButton;

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
        PFFile *imageFile = [[PFUser currentUser] objectForKey:kUserProfilePicMediumKey];
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
    
    // observe keyboard hide and show notifications to resize the text view appropriately
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
 
    // start editing text
    [_messageTextView becomeFirstResponder];
    
    [self initMessageAccessoryView];
    
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
    }
    else
    {
        _photoPicker = [[UIImagePickerController alloc] init];
        _photoPicker.delegate = self;
        _photoPicker.allowsEditing = NO;

        // if not, then ask if they want to choose existing photo or take a new photo
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
        actionSheet.tag = 7431;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    // action sheet for camera button press
    if(actionSheet.tag == 7431)
    {
        if (buttonIndex == 0) {
            // new photo
            _photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:_photoPicker animated:YES completion:NULL];
        } else if (buttonIndex == 1) {
            // existing photo
            _photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:_photoPicker animated:YES completion:NULL];
        }
    }
}

#pragma mark - Image Picker Controller delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    // save image to camera roll!
    UIImage* originalImage=info[UIImagePickerControllerOriginalImage];
    UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
    
    _attachedImageView.image = originalImage;
    _attachedImageView.layer.borderColor = [UIColor blackColor].CGColor;
    _attachedImageView.layer.borderWidth = .1f;
    _cameraButton.tintColor = [UIColor redColor];
    
    // fade in picture
    _attachedImageView.alpha = 0;
    [UIView animateWithDuration:1.0f animations:^{
        _attachedImageView.alpha = 1.0f;
    }];
    
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

- (void)adjustSelection:(UITextView *)textView {
    
    // workaround to UITextView bug, text at the very bottom is slightly cropped by the keyboard
    if ([textView respondsToSelector:@selector(textContainerInset)]) {
        [textView layoutIfNeeded];
        CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        caretRect.size.height += textView.textContainerInset.bottom;
        [textView scrollRectToVisible:caretRect animated:NO];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (!_messageTextView.inputAccessoryView) {
        
    //    _messageTextView.inputAccessoryView = [self keyboardToolBar];  // use what's in the storyboard
    }
    
    [self adjustSelection:textView];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    [self adjustSelection:textView];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self adjustSelection:_messageTextView];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)postButtonPressed:(id)sender {
    // show spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 40,self.view.frame.size.height / 2 - 125,80,80)];

    //spinner.color = [UIColor darkGrayColor];
    spinner.backgroundColor = [UIColor darkGrayColor];
    spinner.layer.cornerRadius = 5;
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // lots of code run in the background
        
        PFObject *post = [PFObject objectWithClassName:@"Post"];
        [post setObject:[self getTruncatedText] forKey:@"message"];
        PFUser *user = [PFUser currentUser];
        [post setObject:user forKey:@"user"];
        [post save];
        
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                
            }
            else{
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // stop and remove the spinner on the background when done
                [spinner removeFromSuperview];
                
                // dismiss view
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];

    });
}


#pragma mark - Responding to keyboard events

- (void)adjustTextViewByKeyboardState:(BOOL)showKeyboard keyboardInfo:(NSDictionary *)info {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    // transform the UIViewAnimationCurve to a UIViewAnimationOptions mask
    UIViewAnimationCurve animationCurve = [info[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionBeginFromCurrentState;
    if (animationCurve == UIViewAnimationCurveEaseIn) {
        animationOptions |= UIViewAnimationOptionCurveEaseIn;
    }
    else if (animationCurve == UIViewAnimationCurveEaseInOut) {
        animationOptions |= UIViewAnimationOptionCurveEaseInOut;
    }
    else if (animationCurve == UIViewAnimationCurveEaseOut) {
        animationOptions |= UIViewAnimationOptionCurveEaseOut;
    }
    else if (animationCurve == UIViewAnimationCurveLinear) {
        animationOptions |= UIViewAnimationOptionCurveLinear;
    }
    
    [_messageTextView setNeedsUpdateConstraints];
    
    if (showKeyboard) {
        UIDeviceOrientation orientation = self.interfaceOrientation;
        BOOL isPortrait = UIDeviceOrientationIsPortrait(orientation);
        
        NSValue *keyboardFrameVal = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrame = [keyboardFrameVal CGRectValue];
        CGFloat height = isPortrait ? keyboardFrame.size.height : keyboardFrame.size.width;
        
        // adjust the constraint constant to include the keyboard's height
        self.constraintToAdjust.constant += height;
    }
    else {
        self.constraintToAdjust.constant = 0;
    }
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
    
    // now that the frame has changed, move to the selection or point of edit
    NSRange selectedRange = _messageTextView.selectedRange;
    [_messageTextView scrollRangeToVisible:selectedRange];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:YES keyboardInfo:userInfo];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    
    NSDictionary *userInfo = [notification userInfo];
    [self adjustTextViewByKeyboardState:NO keyboardInfo:userInfo];
}

@end
