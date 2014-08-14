//
//  NewsFeedTableViewCell.h
//  Epic Vegas IV
//
//  Created by Zach on 8/10/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoSizeLabel.h"

@class NewsFeedTableViewCell;

@protocol NewsFeedTableViewCellDelegate

-(void)showUser:(PFUser*)user;
- (IBAction)checkinMapButtonPressed:(NewsFeedTableViewCell *)cell;
@end

@interface NewsFeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AutoSizeLabel *titleLabel;

@property (weak, nonatomic) IBOutlet AutoSizeLabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet AutoSizeLabel *messageLabel;
@property (weak, nonatomic) IBOutlet PFImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIImageView *cardView;

@property (nonatomic, assign) id  delegate;

@property (weak, nonatomic) IBOutlet UIView *commentHolderView;

- (IBAction)userImageViewClicked:(id)sender;
- (IBAction)userNameLabelClicked:(id)sender;

@property (strong, nonatomic) NSLayoutConstraint* messageHeightConstraint;

@property (nonatomic, assign) PFUser* postUser;
@property (weak, nonatomic) IBOutlet UIButton *mapButton;
- (IBAction)viewOnMapButton:(id)sender;

-(void)clearCellForReuese;

@end
