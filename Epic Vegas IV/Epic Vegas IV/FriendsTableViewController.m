//
//  FriendsTableViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/12/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "FriendsTableViewController.h"
#import "LoadNextPageTableViewCell.h"
#import "FriendTableViewCell.h"
#import "ProfileTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"photo"];
    
    //[query includeKey:@"user.profilePictureSmall"];
    
    // enforce last refresh date to get data in pages (so pages don't get messed up when new things are added after refresh)
    [query whereKey:@"createdAt" lessThanOrEqualTo:self.lastRefreshDate];
    
    // A pull-to-refresh should always trigger a network request.
    [query setCachePolicy:kPFCachePolicyNetworkOnly];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //
    // If there is no network connection, we will hit the cache first.
    if (![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    return query;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self showUserProfileForIndexPath:indexPath];
}

-(void)showUserProfileForIndexPath:(NSIndexPath *)indexPath
{
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    ProfileTableViewController* profileViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"ProfileTableViewController"];
    
    PFUser* user = self.queryObjects[indexPath.row];
    profileViewController.profileUser = user;
    [self.navigationController pushViewController:profileViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // the last cell is the load more cell
    if(self.hasNextPage && indexPath.row == self.queryObjects.count && self.queryObjects.count >= self.itemsPerPage)
    {
        LoadNextPageTableViewCell *cell = (LoadNextPageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"LoadMoreCell" forIndexPath:indexPath];
        
        UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)[cell viewWithTag:123];
        [activityIndicator startAnimating];
        return cell;
    }
    
    @try {
        FriendTableViewCell* cell = (FriendTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = (FriendTableViewCell*)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"FriendCell"];
            
        }
        else{
            [cell clearCellForReuese];
        }
        
        [self configureCell:cell ForRowAtIndexPath:indexPath];
        return cell;
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
        return [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    }
}


-(void)configureCell:(FriendTableViewCell*)cell ForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.queryObjects.count < indexPath.row)
        return;

    if(self.queryObjects.count == 0)
    {
        NSLog(@"No query objects for my friends view, just returning unconfigured cell...");
        return;
    }
    
    int index = indexPath.row;
    PFObject* user = self.queryObjects[index];
    if(!user)
        return;
    
    NSString *displayName = user[@"displayName"] ?: @"[No Name]";
    cell.nameLabel.text = displayName;
    if(user[@"profilePictureSmall"])
    {
        // set pic
        PFFile *userImageFile = user[@"profilePictureSmall"];
        if (userImageFile)
        {
            [cell.userImageView setFile:userImageFile];
            [cell.userImageView loadInBackground];
        }
    }
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for the load more cell
    if(indexPath.row == self.queryObjects.count && self.hasNextPage)
        return  40;
    
    //if(indexPath.row == 0)
    //{
    //    // search row
    //    return  40;
   // }
    
    return 100;
}

@end
