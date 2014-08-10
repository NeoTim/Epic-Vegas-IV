//
//  PostTableViewCell.m
//  Epic Vegas IV
//
//  Created by Zach on 8/9/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "PostTableViewCell.h"

@implementation PostTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self initializeStyle];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [self initializeStyle];
}

-(void)initializeStyle
{
    float gray = 235.0/255.0;
    self.backgroundColor = [UIColor colorWithRed:gray green:gray blue:gray alpha:1];

    [self setSectionVisibility];
    [self setBorderCorners];
    [self setBorderWidths];
    [self setBorderColors];
    [self setBackgroundColors];
}

-(void)setSectionVisibility
{
    _photoView.hidden = YES;
    _locationView.hidden = YES;
    _commentsView.hidden = YES;
    _commentsSummaryView.hidden = YES;
}

-(void)setBorderCorners
{
    //_headerView.layer.cornerRadius = 4;
    
    _headerView.layer.masksToBounds = YES;
    _photoView.layer.masksToBounds = YES;
    _locationView.layer.masksToBounds = YES;
    _commentsView.layer.masksToBounds = YES;
    _commentsSummaryView.layer.masksToBounds = YES;
    _footerView.layer.masksToBounds = YES;
}

-(void)setBorderWidths
{
    float width = .1;
    _headerView.layer.borderWidth = width;
    _photoView.layer.borderWidth = width;
    _locationView.layer.borderWidth = width;
    _commentsView.layer.borderWidth = width;
    _commentsSummaryView.layer.borderWidth = width;
    _footerView.layer.borderWidth = width;
}
-(void)setBorderColors
{
    float borderColorGray = 150.0/255.0;
    CGColorRef color = [UIColor colorWithRed:borderColorGray green:borderColorGray blue:borderColorGray alpha:1].CGColor;
    _headerView.layer.borderColor = color;
    _photoView.layer.borderColor = color;
    _locationView.layer.borderColor = color;
    _commentsView.layer.borderColor = color;
    _commentsSummaryView.layer.borderColor = color;
    _footerView.layer.borderColor = color;
}

-(void)setBackgroundColors
{
    _headerView.backgroundColor = [UIColor whiteColor];
    _photoView.backgroundColor = [UIColor whiteColor];
    _locationView.backgroundColor = [UIColor whiteColor];
    _commentsView.backgroundColor = [UIColor whiteColor];
    _commentsSummaryView.backgroundColor = [UIColor whiteColor];
    _footerView.backgroundColor = [UIColor whiteColor];
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

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
