//
//  PostToFeedViewController.m
//  Epic Vegas IV
//
//  Created by Zach on 8/7/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "PostToFeedViewController.h"

@interface PostToFeedViewController ()

@end

@implementation PostToFeedViewController

int characterLimit = 150;

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
    _messageTextView.delegate = self;

    PFQuery *query = [PFQuery queryWithClassName:@"UserPhoto140"];
    [query getObjectInBackgroundWithId:[PFUser currentUser][@"userPhoto140ObjectId"] block:^(PFObject *userPhoto, NSError *error) {
        if(!error)
        {
            PFFile *theImage = [userPhoto objectForKey:@"imageFile"];
            NSData *imageData = [theImage getData];
            UIImage *image = [UIImage imageWithData:imageData];
            _profileImageView.image = image;
            
            // fade in profile pic
            [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:1.f initialSpringVelocity:1.f options:UIViewAnimationOptionCurveLinear animations:^{
                _profileImageView.alpha = 1;
            } completion:nil];
        }
        else{
            // Do something with the returned PFObject in the gameScore variable.
            NSLog(@"%@", error);
        }
    }];
    
    //_profileImageView.clipsToBounds = YES;
    _profileImageView.alpha = 0;
    //_profileImageView.layer.cornerRadius = _profileImageView.layer.frame.size.height / 2;
    
    [self updateCharacterCountString];
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //_placeholderTextField.hidden = YES;
}

- (void)textViewDidChange:(UITextView *)txtView
{
    _placeholderTextField.hidden = ([txtView.text length] > 0);
    [self updateCharacterCountString];
}

- (void)textViewDidEndEditing:(UITextView *)txtView
{
    _placeholderTextField.hidden = ([txtView.text length] > 0);
    [self updateCharacterCountString];
}

-(void)updateCharacterCountString
{
    NSString* text = _messageTextView.text;
    while([text characterAtIndex:text.length - 1] == ' ')
    {
        text = [text substringToIndex:text.length - 1];
    }
    
    _wordCountLabel.text = [NSString stringWithFormat:@"%d/%d", text.length, characterLimit];
    
    if(text.length > characterLimit)
        _wordCountLabel.textColor = [UIColor redColor];
    else
        _wordCountLabel.textColor = [UIColor blackColor];
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

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
