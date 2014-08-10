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
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet AutoSizeLabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIImageView *locationView;
@property (weak, nonatomic) IBOutlet UIImageView *commentsView;
@property (weak, nonatomic) IBOutlet UIImageView *commentsSummaryView;
@property (weak, nonatomic) IBOutlet UIImageView *footerView;


@end
