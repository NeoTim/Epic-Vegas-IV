//
//  AppDelegate.h
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LoggedInUserData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSURL *pictureURL;

+ (UIColor*)getThemeColor;

+ (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock;
@end
