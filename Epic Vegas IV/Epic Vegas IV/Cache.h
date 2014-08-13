//
//  Cache.h
//  Epic Vegas IV
//
//  Created by Zach on 8/8/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject

+ (Cache*)sharedCache;

- (void)clear;


@property (nonatomic, assign) BOOL shouldRefreshNewsfeedOnDisplay;
@property (nonatomic, assign) BOOL shouldRefreshProfileOnDisplay;
@property (nonatomic, assign) BOOL shouldRefreshFriendsOnDisplay;
@property (nonatomic, assign) BOOL shouldRefreshMapOnDisplay;

@end
