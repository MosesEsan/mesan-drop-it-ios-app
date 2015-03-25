//
//  Config.h
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#ifndef dROP_Config_h
#define dROP_Config_h

typedef NS_ENUM(NSInteger, AppMode) {
    DEVELOPMENT,
    TESTING,
    PRODUCTION
};

typedef NS_ENUM(NSInteger, PostCellType) {
    TIMELINE,
    COLOURED
};

#define PARSE_APPICATION_ID @"EWaIsQHXV8prkWHfFi2tHXBoFdx71pe8azI00afS"
#define PARSE_CLIENT_KEY @"KqXsbByx3UrGsxsbrSzhbnfUz60twTwXJgGRp2yC"

#define AVOCARROT_API_KEY @"ff01c005d9ff11d4e37456bcfd5dba75aac7e411"

#define APPSFIRE_CLIENT_KEY @"E2AA41E624CEF2A92F9FA86501D0EA30"
#define APPSFIRE_CLIENT_SECRET @"226b76189b85d2bbad5905024da9cfd2"



//#44B7C7 -- //1ABEC3
#define BAR_TINT_COLOR2 [UIColor colorWithRed:68/255.0f green:183/255.0f blue:199/255.0f alpha:1.0f]
//[UIColor colorWithRed:26/255.0f green:190/255.0f blue:195/255.0f alpha:1.0f]
//#define BAR_TINT_COLOR22 [UIColor colorWithRed:103/255.0f green:199/255.0f blue:237/255.0f alpha:1.0f]
#define BAR_STYLE UIBarStyleBlackTranslucent
#define TINT_COLOR [UIColor whiteColor]
#define TRANSLUCENT NO
#define CLIPS_TO_BOUNDS YES

//D7D6D4
//#define TABLEVIEW_COLOR 
#define TABLEVIEW2_COLOR [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.4f]


//F89A66 -
//[UIColor colorWithRed:248/255.0f green:154/255.0f blue:102/255.0f alpha:1.0f];

//D76E5A
//[UIColor colorWithRed:215/255.0f green:110/255.0f blue:90/255.0f alpha:1.0f];

#define TEXT_FONT [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f]
#define DATE_FONT [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f]
#define LIKES_FONT [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.5f]
#define COMMENTS_FONT [UIFont fontWithName:@"AvenirNext-DemiBold" size:12.5f]

#define WIDTH [[UIScreen mainScreen] bounds].size.width
#define TOP_PADDING 12
#define LEFT_PADDING 16.5f

#define TEXT_WIDTH WIDTH - (LEFT_PADDING * 2)
#define IMAGEVIEW_HEIGHT 160
#define ACTIONS_VIEW_HEIGHT 28

#define LINE_FRAME_WIDTH 33
#define BUBBLE_FRAME_WIDTH 14

#define CONTAINER_FRAME_X 7.5f
#define COLOURED_BAR_WIDTH 0.0f

#define PROFILE_PIC_WIDTH 50.0f

#define DATE_COLOR [UIColor colorWithRed:137/255.0f green:143/255.0f blue:156/255.0f alpha:1.0f]
#define MESSAGE_COLOR [UIColor colorWithRed:85/255.0f green:85/255.0f blue:85/255.0f alpha:1.0f]
#define TEXT_COLOR [UIColor colorWithRed:34/255.0f green:34/255.0f blue:34/255.0f alpha:1.0f]

#define ADD_POST_WIDTH WIDTH - 20
#define ADD_POST_HEIGHT 240

#define INFO_VIEW_WIDTH WIDTH - 40
#define INFO_VIEW_HEIGHT 320

#define POSTS_CLASS_NAME @"Posts"
#define COMMENTS_CLASS_NAME @"Comments"
#define USERS_CLASS_NAME @"_User"
#define LOCATIONS_CLASS_NAME @"Locations"
#define REWARDS_CLASS_NAME @"Rewards"
#define CONFIGURATION_CLASS_NAME @"Config"
#define ADS_CLASS_NAME @"Ads"

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


//Fruits





//#define ONE_MILE_RADIUS 1609.34km
#define ONE_HALF_MILE_RADIUS_KM 2.4140
#define ONE_HALF_MILE_RADIUS_MT 2414

//#define FIVE_MILE_RADIUS 8046.72

@interface Config : NSObject

+ (void)setConfiguration;
+ (AppMode)appMode;
+ (PostCellType)cellType;
+ (BOOL)setCellType:(PostCellType)mode;

+ (UIImage *)usersAvatar;
+ (NSString *)usersAvatarString;

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
+ (NSString *)getClosestLocation:(CLLocation *)currentLocation;

+ (NSString *)likesCount:(NSInteger)likesCount;
+ (NSString *)repliesCount:(NSInteger)repliesCount;

+ (NSDictionary *)subViewFrames:(NSDictionary *)postObject;
+ (NSDictionary *)subViewFrames2:(NSDictionary *)postObject;
+ (CGFloat)calculateCellHeight:(NSDictionary *)postObject;


+ (NSDictionary *)userPoints;
+ (void)incrementUserPoints;
+ (NSDictionary *)updateUserPoints:(NSInteger)points;
+ (NSString *)rankForPoints:(NSInteger)points;

+ (BOOL)checkLastUpdated:(NSDate *)lastUpdated withMaxDifference:(NSInteger)maxDifference;

+ (BOOL)checkInternetConnection;
+ (UIAlertView *)alertViewWithTitle:(NSString *)title withMessage:(NSString *)message;

+ (NSMutableArray *)introsInfo;

+ (NSString *)fruits;
+ (UIColor *)getBubbleColor;
+ (UIColor *)getSideColor:(NSInteger)index;
+ (PFImageView *)imageViewFrame:(CGRect)frame withImage:(UIImage *)image withColor:(UIColor *)color;

@end


#endif
