//
//  AutoSizeLabel.m
//  Epic Vegas IV
//
//  Created by Zach on 8/9/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "AutoSizeLabel.h"

//http://www.raywenderlich.com/73602/dynamic-table-view-cell-height-auto-layout
/*
 If the label has multiple lines, it makes sure that preferredMaxLayoutWidth always equals the frame width.
 Sometimes, the intrinsicContentSize can be 1 point too short. It adds 1 point to the intrinsicContentSize if the label has multiple lines.
 */
@implementation AutoSizeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.numberOfLines == 0) {
        
        // If this is a multiline label, need to make sure
        // preferredMaxLayoutWidth always matches the frame width
        // (i.e. orientation change can mess this up)
        
        if (self.preferredMaxLayoutWidth != self.frame.size.width) {
            self.preferredMaxLayoutWidth = self.frame.size.width;
            [self setNeedsUpdateConstraints];
        }
    }
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    
    if (self.numberOfLines == 0) {
        
        // There's a bug where intrinsic content size
        // may be 1 point too short
        
        size.height += 1;
    }
    
    return size;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
