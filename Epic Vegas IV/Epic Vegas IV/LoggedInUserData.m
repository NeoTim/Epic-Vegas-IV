//
//  LoggedInUserData.m
//  Epic Vegas IV
//
//  Created by Zach on 8/7/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "LoggedInUserData.h"

@implementation LoggedInUserData

UIImage* profileImage;

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static LoggedInUserData* instance;
    
    dispatch_once(&onceToken, ^  //Use GCD to make a singleton with thread-safety
                  {
                      instance = [[self alloc] init];
                  });
    return instance;
}


@end
