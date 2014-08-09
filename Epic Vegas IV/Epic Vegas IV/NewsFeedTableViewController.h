//
//  NewsFeedTableViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/9/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
