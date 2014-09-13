//
//  Utility.m
//  Epic Vegas IV
//
//  Created by Zach on 8/8/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

#import "Utility.h"
#import "UIImage+ResizeAdditions.h"

@implementation Utility

#pragma Colors

+ (UIColor*)getThemeColor
{
    UIColor* themeColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];
    return themeColor;
}

// http://jslim.net/blog/2014/05/05/ios-customize-uitabbar-appearance/
+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        return;
    }
    
    NSLog(@"Processing Facebook Profile Picture Data");
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            return;
        }
    }
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    UIImage *largeImage = [image thumbnailImage:800 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    //UIImage *mediumImage = [image thumbnailImage:640 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:120 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    NSData *largeImageData = UIImageJPEGRepresentation(largeImage, .6); // using JPEG for larger pictures
    //NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 1.0); // using JPEG for larger pictures
    //NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    NSData *smallRoundedImageData = UIImageJPEGRepresentation(smallRoundedImage, 1.0);
    
    if (largeImageData.length > 0) {
        PFFile *fileLargeImage = [PFFile fileWithData:largeImageData];
        [fileLargeImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileLargeImage forKey:@"profilePictureLarge"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded)
                    {
                        NSLog(@"Large profile pic saved");
                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(error)
                            {
                                NSLog(@"Error saving user");
//                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving user data"
//                                                                                message:[NSString stringWithFormat:@"%@", error]                                                                       delegate:nil
//                                                                      cancelButtonTitle:@"OK"
//                                                                      otherButtonTitles:nil];
//                                [alert show];
                            }
                        }];
                    }
                    else
                    {
                        NSLog(@"Error saving large profile picture.  Try logging out and logging back in");
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving large profile pic"
//                                                                        message:[NSString stringWithFormat:@"%@", error]                                                                       delegate:nil
//                                                              cancelButtonTitle:@"OK"
//                                                              otherButtonTitles:nil];
//                        [alert show];
                    }
                }];
            }
        }];
    }
    
    
    //    if (mediumImageData.length > 0) {
    //        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
    //        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //            if (!error) {
    //                [[PFUser currentUser] setObject:fileMediumImage forKey:@"profilePictureMedium"];
    //                [[PFUser currentUser] saveEventually];
    //            }
    //        }];
    //    }
    
    if (smallRoundedImageData.length > 0) {
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:@"profilePictureSmall"];
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(error)
                    {
                        NSLog(@"Error saving user");
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving user data"
//                                                                        message:[NSString stringWithFormat:@"%@", error]                                                                       delegate:nil
//                                                              cancelButtonTitle:@"OK"
//                                                              otherButtonTitles:nil];
//                        [alert show];
                    }
                }];
            }
            else
            {
                NSLog(@"Error saving small profile picture.");
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error saving small profile pic"
//                                                                message:[NSString stringWithFormat:@"%@", error]                                                                       delegate:nil
//                                                      cancelButtonTitle:@"OK"
//                                                      otherButtonTitles:nil];
//                [alert show];
                
            }
        }];
    }
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:@"facebookId"];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    PFFile *profilePictureLarge = [user objectForKey:@"profilePictureLarge"];
    //PFFile *profilePictureMedium = [user objectForKey:@"profilePictureMedium"];
    PFFile *profilePictureSmall = [user objectForKey:@"profilePictureSmall"];
    
    return (profilePictureLarge && profilePictureSmall);
}




#pragma mark Shadow Rendering

+ (void)drawSideAndBottomDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 5.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideAndTopDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y - 10.0f, rect.size.width + 20.0f, rect.size.height + 10.0f));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)drawSideDropShadowForRect:(CGRect)rect inContext:(CGContextRef)context {
    // Push the context
    CGContextSaveGState(context);
    
    // Set the clipping path to remove the rect drawn by drawing the shadow
    CGRect boundingRect = CGContextGetClipBoundingBox(context);
    CGContextAddRect(context, boundingRect);
    CGContextAddRect(context, rect);
    CGContextEOClip(context);
    // Also clip the top and bottom
    CGContextClipToRect(context, CGRectMake(rect.origin.x - 10.0f, rect.origin.y, rect.size.width + 20.0f, rect.size.height));
    
    // Draw shadow
    [[UIColor blackColor] setFill];
    CGContextSetShadow(context, CGSizeMake(0.0f, 0.0f), 7.0f);
    CGContextFillRect(context, CGRectMake(rect.origin.x,
                                          rect.origin.y - 5.0f,
                                          rect.size.width,
                                          rect.size.height + 10.0f));
    // Save context
    CGContextRestoreGState(context);
}

+ (void)addBottomDropShadowToNavigationBarForNavigationController:(UINavigationController *)navigationController {
    UIView *gradientView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, navigationController.navigationBar.frame.size.height, navigationController.navigationBar.frame.size.width, 3.0f)];
    [gradientView setBackgroundColor:[UIColor clearColor]];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor], nil];
    [gradientView.layer insertSublayer:gradient atIndex:0];
    navigationController.navigationBar.clipsToBounds = NO;
    [navigationController.navigationBar addSubview:gradientView];
}

/*
 http://stackoverflow.com/questions/10075898/ios-friendly-nsdate-format
 */
+ (NSString *)formattedDate:(NSDate *)date
{
    NSTimeInterval secondsSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    
    if(secondsSinceDate < 4)
        return @"Just now";
    
    // print up to 24 hours as a relative offset
    if(secondsSinceDate < 24.0 * 60.0 * 60.0)
    {
        NSUInteger hoursSinceDate = (NSUInteger)(secondsSinceDate / (60.0 * 60.0));
        
        switch(hoursSinceDate)
        {
            default: return [NSString stringWithFormat:@"%d hours ago", hoursSinceDate];
            case 1: return @"1 hour ago";
            case 0:
            {
                NSUInteger minutesSinceDate = (NSUInteger)(secondsSinceDate / 60.0);
                
                if(minutesSinceDate < 1)
                    return [NSString stringWithFormat:@"%d %@" , (NSUInteger)secondsSinceDate, @"seconds ago"];
                else
                    return [NSString stringWithFormat:@"%d %@" , minutesSinceDate, @"minutes ago"];
            }
        }
    }
    else if( secondsSinceDate < 24.0 * 60.0 * 60.0 * 7)
    {
        // if less than one week then show the day of the week ex: "Thursday at 7:29 pm"
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEEE"];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"h:mm a"];
        
        return [NSString stringWithFormat:@"%@ %@" , [dateFormat stringFromDate:date], [timeFormat stringFromDate:date]];
    }
    else // show the date "August 5th at 7:29 pm"
    {
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MMMM dd"];
        
        NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
        [timeFormat setDateFormat:@"h:mm a"];
        
        return [NSString stringWithFormat:@"%@ %@" , [dateFormat stringFromDate:date], [timeFormat stringFromDate:date]];
    }
}


+ (void)updateCurrentUsersLocationWithOnlyIfStale:(BOOL)onlyUpdateIfStale
{
    PFUser* currentUser = [PFUser currentUser];
    if(currentUser)
    {
        if(onlyUpdateIfStale)
        {
            NSDate* lastUpdated = currentUser[@"currentLocationUpdatedAt"];
            if(lastUpdated)
            {
                NSTimeInterval secs = [[NSDate date] timeIntervalSinceDate:lastUpdated];
                
                // don't update if refreshed in the last five minutes
                if(secs / 60 < 5)
                    return;
            }
        }
        [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
            if (!error) {
                NSLog(@"Location was stale, user is currently at %f, %f", geoPoint.latitude, geoPoint.longitude);
                
                [Utility updateCurrentUsersLocation:geoPoint withLocationName:nil shouldRefreshMap:YES];
            }
            else
            {
                NSLog(@"error getting user location");
            }
        }];
    }
}

+ (void)updateCurrentUsersLocation:(PFGeoPoint*)geoPoint withLocationName:(NSString*)locationName shouldRefreshMap:(BOOL)refreshMapFlag
{
    PFUser* currentUser = [PFUser currentUser];
    if(currentUser)
    {
        BOOL isUserStillAtPreviousLocation = YES;
        
        PFGeoPoint* currentGeoPoint = currentUser[@"currentLocation"];
        if(currentGeoPoint)
        {
            CLLocation *locA = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
            
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:currentGeoPoint.latitude longitude:currentGeoPoint.longitude];
            
            CLLocationDistance distanceInMeters = [locA distanceFromLocation:locB];
            
            double mileInMeters = 1609.34;
            
            double miles = distanceInMeters / mileInMeters;
            
            NSLog(@"%f miles away from last known location", miles);
            
            // further than .3 miles away, then no longer at the same location
            if(miles > .3)
            {
                isUserStillAtPreviousLocation = NO;
                NSLog(@"user is not still at previous location, > %f miles away", miles);
            }
        }
        
        currentUser[@"currentLocation"] = geoPoint;
        currentUser[@"currentLocationUpdatedAt"] = [NSDate date];
        
        // leave the previous location there if the user is still at the location, otherwise remove it
        if(!isUserStillAtPreviousLocation && !locationName)
        {
            NSLog(@"Clearing current location name");
            [currentUser removeObjectForKey:@"currentLocationName"];
        }
        else if(locationName)
            currentUser[@"currentLocationName"] = locationName;
        
        // save current user
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(error)
            {
                NSLog(@"Error saving current user location: %@", error);
            }
            else
            {
                NSLog(@"Saved Current User Location Post");
                [Cache sharedCache].shouldRefreshMapOnDisplay = refreshMapFlag;
                [Cache sharedCache].shouldRefreshFriendsOnDisplay = YES;
                [Cache sharedCache].shouldRefreshProfileOnDisplay = YES;
            }
        }];
    }
}


//http://stackoverflow.com/questions/2658738/the-simplest-way-to-resize-an-uiimage
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    return [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:newSize interpolationQuality:kCGInterpolationHigh];
}

// http://stackoverflow.com/questions/10563986/uiimage-with-rounded-corners
+ (UIImage *)imageWithRoundedCornersSize:(float)cornerRadius usingImage:(UIImage *)original scaledToSize:(CGSize)newSize
{
    UIImage* scaled = [Utility imageWithImage:original scaledToSize:newSize];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:scaled];
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    // Draw your image
    [scaled drawInRect:imageView.bounds];
    
    // Get the image, here setting the UIImageView image
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return imageView.image;
}

@end
