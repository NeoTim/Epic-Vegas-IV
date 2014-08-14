//
//  QueryTableViewController.h
//  Epic Vegas IV
//
//  Created by Zach on 8/11/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QueryTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, assign) BOOL shouldReloadOnAppear;
@property (nonatomic, retain, readonly) NSMutableArray* queryObjects;
//@property (nonatomic, strong) UIRefreshControl* tableRefreshControl;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic, retain, readonly) NSDate* lastRefreshDate;

@property (nonatomic, readonly) NSInteger itemsPerPage;
@property (nonatomic, readonly) NSInteger itemsLoaded;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic, readonly) BOOL hasNextPage;
@property (nonatomic, readonly) BOOL isCurrentlyRefreshing;

// override in child class
- (PFQuery *)queryForTable;

-(void)loadNextPage;

- (CGSize)text:(NSString *)text sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)textViewHeightForAttributedText:(NSAttributedString *)text andWidth:(CGFloat)width;

-(CGSize)getLabelSize:(NSString*)text withFontName:(NSString*)fontName withFontSize:(CGFloat)fontSize forFixedWidth:(CGFloat)width;

-(void)refreshDataSources;

@end
