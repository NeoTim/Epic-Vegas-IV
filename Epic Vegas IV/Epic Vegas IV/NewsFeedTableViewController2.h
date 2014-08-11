//
//  NewsFeedTableViewController2.h
//  Epic Vegas IV
//
//  Created by Zach on 8/10/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface NewsFeedTableViewController2 : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@property (nonatomic, strong) NSMutableArray* postsArray;

@property (nonatomic, strong) UIRefreshControl* refreshControl;

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, strong) NSDictionary* users;

@property (nonatomic, strong) NSDate* lastRefreshDate;


- (PFQuery *)queryForTable;

@end
