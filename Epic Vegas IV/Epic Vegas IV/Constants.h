//
//  Constants.h
//  Epic Vegas IV
//
//  Created by Zach on 8/8/14.
//  Copyright (c) 2014 Zach Kohl. All rights reserved.
//

//
//  Constants.h
//  Anypic
//
//  Created by Mattieu Gamache-Asselin on 5/25/12.
//  Copyright (c) 2013 Parse. All rights reserved.
//

typedef enum {
	HomeTabBarItemIndex = 0,
	EmptyTabBarItemIndex = 1,
	ActivityTabBarItemIndex = 2
} TabBarControllerViewControllerIndex;


// Ilya     400680
// James    403902
// Brian    702499
// David    1225726
// Bryan    4806789
// Thomas   6409809
// Ashley   12800553
// Héctor   121800083
// Kevin    500011038
// Chris    558159381
// Henele   721873341
// Matt     723748661
// Andrew   865225242

#define kParseEmployeeAccounts [NSArray arrayWithObjects:@"400680", @"403902", @"702499", @"1225726", @"4806789", @"6409809", @"12800553", @"121800083", @"500011038", @"558159381", @"721873341", @"723748661", @"865225242", nil]

#pragma mark - NSUserDefaults
extern NSString *const kUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Launch URLs

extern NSString *const kLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const AppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const UtilityUserFollowingChangedNotification;
extern NSString *const UtilityUserLikedUnlikedPhotoCallbackFinishedNotification;
extern NSString *const UtilityDidFinishProcessingProfilePictureNotification;
extern NSString *const TabBarControllerDidFinishEditingPhotoNotification;
extern NSString *const TabBarControllerDidFinishImageFileUploadNotification;
extern NSString *const PhotoDetailsViewControllerUserDeletedPhotoNotification;
extern NSString *const PhotoDetailsViewControllerUserLikedUnlikedPhotoNotification;
extern NSString *const PhotoDetailsViewControllerUserCommentedOnPhotoNotification;


#pragma mark - User Info Keys
extern NSString *const PhotoDetailsViewControllerUserLikedUnlikedPhotoNotificationUserInfoLikedKey;
extern NSString *const kEditPhotoViewControllerUserInfoCommentKey;


#pragma mark - Installation Class

// Field keys
extern NSString *const kInstallationUserKey;


#pragma mark - PFObject Activity Class
// Class key
extern NSString *const kActivityClassKey;

// Field keys
extern NSString *const kActivityTypeKey;
extern NSString *const kActivityFromUserKey;
extern NSString *const kActivityToUserKey;
extern NSString *const kActivityContentKey;
extern NSString *const kActivityPhotoKey;

// Type values
extern NSString *const kActivityTypeLike;
extern NSString *const kActivityTypeFollow;
extern NSString *const kActivityTypeComment;
extern NSString *const kActivityTypeJoined;


#pragma mark - PFObject User Class
// Field keys
extern NSString *const kUserDisplayNameKey;
extern NSString *const kUserFacebookIDKey;
extern NSString *const kUserGenderKey;
extern NSString *const kUserRelationshipKey;
extern NSString *const kUserHomeLocationKey;
extern NSString *const kUserBirthdayKey;
extern NSString *const kUserEmailKey;
extern NSString *const kUserPhoneKey;
extern NSString *const kUserPhotoIDKey;
extern NSString *const kUserProfilePicSmallKey;
extern NSString *const kUserProfilePicMediumKey;
extern NSString *const kUserProfilePicLargeKey;
extern NSString *const kUserFacebookFriendsKey;
extern NSString *const kUserAlreadyAutoFollowedFacebookFriendsKey;


#pragma mark - PFObject Photo Class
// Class key
extern NSString *const kPhotoClassKey;

// Field keys
extern NSString *const kPhotoPictureKey;
extern NSString *const kPhotoThumbnailKey;
extern NSString *const kPhotoUserKey;
extern NSString *const kPhotoOpenGraphIDKey;


#pragma mark - Cached Photo Attributes
// keys
extern NSString *const kPhotoAttributesIsLikedByCurrentUserKey;
extern NSString *const kPhotoAttributesLikeCountKey;
extern NSString *const kPhotoAttributesLikersKey;
extern NSString *const kPhotoAttributesCommentCountKey;
extern NSString *const kPhotoAttributesCommentersKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kUserAttributesPhotoCountKey;
extern NSString *const kUserAttributesIsFollowedByCurrentUserKey;


#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPushPayloadPayloadTypeKey;
extern NSString *const kPushPayloadPayloadTypeActivityKey;

extern NSString *const kPushPayloadActivityTypeKey;
extern NSString *const kPushPayloadActivityLikeKey;
extern NSString *const kPushPayloadActivityCommentKey;
extern NSString *const kPushPayloadActivityFollowKey;

extern NSString *const kPushPayloadFromUserObjectIdKey;
extern NSString *const kPushPayloadToUserObjectIdKey;
extern NSString *const kPushPayloadPhotoObjectIdKey;