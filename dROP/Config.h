//
//  Config.h
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#ifndef dROP_Config_h
#define dROP_Config_h

//#44B7C7
#define BAR_TINT_COLOR [UIColor colorWithRed:68/255.0f green:183/255.0f blue:199/255.0f alpha:1.0f]
#define BAR_TINT_COLOR2 [UIColor colorWithRed:103/255.0f green:199/255.0f blue:237/255.0f alpha:1.0f]
#define BAR_STYLE UIBarStyleBlackTranslucent
#define TINT_COLOR [UIColor whiteColor]
#define TRANSLUCENT NO;
#define CLIPS_TO_BOUNDS YES;

#define TEXT_FONT [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f]
#define DATE_FONT [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f]
#define LIKES_FONT [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.5f]
#define COMMENTS_FONT [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.5f]

#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define TOP_PADDING 12
#define LEFT_PADDING 16.5f

#define TEXT_WIDTH WIDTH - (LEFT_PADDING * 2)
#define IMAGEVIEW_HEIGHT 170
#define ACTIONS_VIEW_HEIGHT 28


#define DATE_COLOR [UIColor colorWithRed:137/255.0f green:143/255.0f blue:156/255.0f alpha:1.0f]
#define MESSAGE_COLOR [UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f]
#define TEXT_COLOR [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:1.0f]

#define ADD_POST_WIDTH WIDTH - 40
#define ADD_POST_HEIGHT 250

#define INFO_VIEW_WIDTH WIDTH - 40
#define INFO_VIEW_HEIGHT 320

#define POSTS_CLASS_NAME @"Posts"
#define COMMENTS_CLASS_NAME @"Comments"
#define USERS_CLASS_NAME @"_User"
#define LOCATIONS_CLASS_NAME @"Locations"
#define REWARDS_CLASS_NAME @"Rewards"

#define NEW_POST_TYPE @"New"
#define LIKE_POST_TYPE @"Like"
#define DISLIKE_POST_TYPE @"Dislike"
#define REPORT_POST_TYPE @"Report"



#define NEW_POST_NOTIFICATION @"NewPostAdded"

#define DEVICE_ID [[UIDevice currentDevice] identifierForVendor]

#define kViewRoundedCornerRadius 5.0f
#define kMaxCharacterCount 200

#define postPlaceholderText @"Drop Your Thoughts...."
#define messagePlaceholderText @"Leave a comment..."

#define POINTS_INTRO_TEXT @"You are rewarded with points everytime you add a new post and when another user likes your post. \r You lose points when another user dislikes or reports your post. \r You can redeem your points for a reward."

#define POINTS_BREAKDOWN_TEXT @"1 Post = 1 Point \r\r 1 Like = 2 Points \r\r 1 Dislike = (-)2 Points \r\r 1 Report = (-)5 Points"

#define NUMBER_OF_PAGES 4


//DEFAULT LOCATIONS


//#define ONE_MILE_RADIUS 1609.34
//#define FIVE_MILE_RADIUS 8046.72

@interface Config : NSObject

+ (NSMutableArray *)availableLocations;
+ (void)updateAvailableLocations:(NSDate *)lastUpdated;

+ (NSMutableArray *)rewards;
+ (void)updateRewards:(NSDate *)lastUpdated;

+ (NSString *)deviceId;

+ (NSString *)calculateTime:(id)time;

+ (NSMutableArray *)filterPosts:(NSArray *)postObject;
+ (NSMutableDictionary *)createPostObject:(PFObject *)parseObject;

+ (BOOL)isPostAuthor:(NSDictionary *)postObject;
+ (BOOL)getDisLikeStatus:(PFObject *)postObject;
+ (BOOL)getReportStatus:(PFObject *)postObject;

+ (CGFloat)calculateHeightForText:(NSString *)text withWidth:(CGFloat)width withFont:(UIFont *)font;

+ (BOOL)checkAddPermission:(CLLocation *)currentLocation;

+ (NSString *)likesCount:(NSInteger)likesCount;
+ (NSString *)repliesCount:(NSInteger)repliesCount;

+ (NSDictionary *)subViewFrames:(NSDictionary *)postObject;


+ (NSDictionary *)userPoints;
+ (void)incrementUserPoints;
+ (NSDictionary *)updateUserPoints:(NSInteger)points;
+ (NSString *)rankForPoints:(NSInteger)points;

+ (BOOL)checkLastUpdated:(NSDate *)lastUpdated withMaxDifference:(NSInteger)maxDifference;

+ (BOOL)checkInternetConnection;
+ (UIAlertView *)alertViewWithTitle:(NSString *)title withMessage:(NSString *)message;

+ (NSMutableArray *)introsInfo;

@end


#endif
