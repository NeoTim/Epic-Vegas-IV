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
    _cardView.backgroundColor = [UIColor whiteColor];    
    _cardView.layer.cornerRadius = 4;
    _cardView.layer.masksToBounds = YES;
    
    float borderColorGray = 150.0/255.0;
    _cardView.layer.borderColor = [UIColor colorWithRed:borderColorGray green:borderColorGray blue:borderColorGray alpha:1].CGColor;
    _cardView.layer.borderWidth = .1;
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
