//
//  PostTableViewCell.h
//  Epic Vegas IV
//
//  Created by Zach on 8/9/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoSizeLabel.h"

@interface PostTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet AutoSizeLabel *titleLabel;
@property (weak, nonatomic) IBOutlet AutoSizeLabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet PFImageView *userImageView;
@property (weak, nonatomic) IBOutlet AutoSizeLabel *messageLabel;

@end
