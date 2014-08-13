//
//  UserMapAnnotationView.m
//  Epic Vegas IV
//
//  Created by Zach on 8/12/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "UserMapAnnotationView.h"

@implementation UserMapAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        PVAttractionAnnotation *attractionAnnotation = self.annotation;
//        switch (attractionAnnotation.type) {
//            case PVAttractionFirstAid:
//                self.image = [UIImage imageNamed:@"firstaid"];
//                break;
//            case PVAttractionFood:
//                self.image = [UIImage imageNamed:@"food"];
//                break;
//            case PVAttractionRide:
//                self.image = [UIImage imageNamed:@"ride"];
//                break;
//            default:
//                self.image = [UIImage imageNamed:@"star"];
//                break;
//        }
    }
    
    return self;
}

@end
