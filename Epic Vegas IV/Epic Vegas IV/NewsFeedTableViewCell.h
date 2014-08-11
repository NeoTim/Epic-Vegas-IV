//
//  NewsFeedTableViewCell.h
//  Epic Vegas IV
//
//  Created by Zach on 8/10/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoSizeLabel.h"

@interface NewsFeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet AutoSizeLabel *titleLabel;

@property (weak, nonatomic) IBOutlet AutoSizeLabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet AutoSizeLabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIImageView *cardView;

-(void)clearCellForReuese;

@end
