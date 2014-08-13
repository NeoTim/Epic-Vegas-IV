//
//  Cache.m
//  Epic Vegas IV
//
//  Created by Zach on 8/8/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "Cache.h"

@interface Cache()

@property (nonatomic, strong) NSCache *cache;
- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo;
@end

@implementation Cache
@synthesize cache;

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - Cache

- (void)clear {
    [self.cache removeAllObjects];
}



@end
