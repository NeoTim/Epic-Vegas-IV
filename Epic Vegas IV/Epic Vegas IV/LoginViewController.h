//
//  LoginViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *epicLabel;
@property (weak, nonatomic) IBOutlet UILabel *vegasLabel;
@property (weak, nonatomic) IBOutlet UILabel *ivLabel;

@property (weak, nonatomic) IBOutlet FBLoginView *fbLoginView;

@end
