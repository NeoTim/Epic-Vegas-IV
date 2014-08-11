	//
//  PostToFeedViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/7/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "RemovePhotoViewController.h"

@interface PostToFeedViewController : UIViewController <UITextViewDelegate, UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, RemovePhotoViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

- (IBAction)cancelButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UITextField *placeholderTextField;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
- (IBAction)postButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView* attachedImageView;
@property (weak, nonatomic) IBOutlet UIButton *attachedImageButton;

@property (strong, nonatomic) UIImage* passedInImage;

-(void)attachImage:(UIImage*)image;
-(IBAction)showRemovePhotoButtonPressed:(id)sender;
@end
