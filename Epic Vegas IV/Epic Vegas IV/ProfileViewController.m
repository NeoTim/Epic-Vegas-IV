//
//  ProfileViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/4/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    
    
    NSString* profilePicUrlString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=400&height=400&return_ssl_resources=1", [PFUser currentUser][@"fbId"]];

    NSURL* profilePicUrl = [NSURL URLWithString:profilePicUrlString];
    
    [self downloadImageWithURL:profilePicUrl completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            _fbProfilePicView.image = image;
            _fbProfilePicView.clipsToBounds = YES;
        }
    }];
    
    _fbProfilePicView.layer.cornerRadius = _fbProfilePicView.layer.frame.size.height / 2;
    
    // Do any additional setup after loading the view.
    //_fbProfilePicView.profileID = [PFUser currentUser][@"fbId"];
    
    _userNameLabel.text = [PFUser currentUser][@"fbName"];
}

// http://natashatherobot.com/ios-how-to-download-images-asynchronously-make-uitableview-scroll-fast/
- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
