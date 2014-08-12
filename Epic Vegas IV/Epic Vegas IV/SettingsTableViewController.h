//
//  SettingsTableViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/11/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewController : UITableViewController <UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet UIButton *logOutButton;

- (IBAction)logOutButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

- (IBAction)openGoogleDocInSafari:(id)sender;

- (IBAction)openFacebookEventPageButtonPressed:(id)sender;

@end
