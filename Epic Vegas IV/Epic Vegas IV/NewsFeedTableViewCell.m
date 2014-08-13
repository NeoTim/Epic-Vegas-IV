//
//  NewsFeedTableViewCell.m
//  Epic Vegas IV
//
//  Created by Zach on 8/10/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "NewsFeedTableViewCell.h"
#import "ProfileTableViewController.h"

@implementation NewsFeedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self initializeStyle];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self initializeStyle];
    }
    return  self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self initializeStyle];
}

-(void)initializeStyle
{
    
    [self setSectionVisibility];
    [self setBorderCorners];
    [self setBorderWidths];
    [self setBorderColors];
    [self setBackgroundColors];
    [self setupImage];    
}

-(void)setupImage
{
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.layer.borderWidth = .1f;
    self.userImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.userImageView.layer.cornerRadius = 30;
    
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    //self.photoImageView.layer.borderWidth = .1f;
    //self.photoImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

-(void)clearCellForReuese
{
    self.userImageView.image = nil;
    self.photoImageView.image = nil;
    self.titleLabel.text = @"";
    self.subtitleLabel.text = @"";
    self.messageLabel.text = @"";
}

//-(void)setContentInvisible
//{
//    self.titleLabel.alpha = 0;
//    self.subtitleLabel.alpha = 0;
//    self.messageLabel.alpha = 0;
//    self.userImageView.alpha = 0;
//    self.photoView.alpha = 0;
//    
//    //cell.headerView.alpha = 0;
//    //cell.photoView.alpha = 0;
//    //cell.locationView.alpha = 0;
//    //cell.commentsView.alpha = 0;
//    //cell.commentsSummaryView.alpha = 0;
//    //cell.footerView.alpha = 0;
//}
//
//-(void)setContentVisible
//{
//    self.titleLabel.alpha = 1;
//    self.subtitleLabel.alpha = 1;
//    self.messageLabel.alpha = 1;
//    self.userImageView.alpha = 1;
//    self.photoView.alpha = 1;
//}


-(void)setSectionVisibility
{
    //    _photoView.hidden = YES;
    //    _locationView.hidden = YES;
    //    _commentsView.hidden = YES;
    //    _commentsSummaryView.hidden = YES;
}

-(void)setBorderCorners
{
    _cardView.layer.cornerRadius = 4;
    _cardView.layer.masksToBounds = YES;
}


-(void)setBorderWidths
{
    float width = .1;
    _cardView.layer.borderWidth = width;
}
-(void)setBorderColors
{
    float borderColorGray = 150.0/255.0;
    CGColorRef color = [UIColor colorWithRed:borderColorGray green:borderColorGray blue:borderColorGray alpha:1].CGColor;
    _cardView.layer.borderColor = color;
}

-(void)setBackgroundColors
{
    _cardView.backgroundColor = [UIColor whiteColor];
    
    float gray = 220.0/255.0;
    self.backgroundColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


- (IBAction)userImageViewClicked:(id)sender {
    if(self.delegate && _postUser)
        [self.delegate showUser:_postUser];
}

- (IBAction)userNameLabelClicked:(id)sender {
    if(self.delegate)
        [self.delegate showUser:_postUser];
}


@end
