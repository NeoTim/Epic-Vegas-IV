//
//  RemovePhotoViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/10/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RemovePhotoViewController;

@protocol RemovePhotoViewControllerDelegate
-(void)removeAttachedPhoto;
@end


@interface RemovePhotoViewController : UIViewController
- (IBAction)removeButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *attachedImageView;

@property (nonatomic, assign) id  delegate;

@property (nonatomic, assign) UIImage*  imageToShow;

@end

