//
//  MyProfileTableViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/11/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "QueryTableViewController.h"

@interface ProfileTableViewController : QueryTableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarbuttonItem;
@property (nonatomic, assign) PFUser* profileUser;
- (IBAction)facebookButtonPressed:(id)sender;
- (IBAction)mapButtonPressed:(id)sender;

@end
