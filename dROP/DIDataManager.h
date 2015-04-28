//
//  DIDataManager.h
//  Drop It!
//
//  Created by Moses Esan on 12/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

typedef enum : NSUInteger {
    HOME,
    PROFILE,
} ViewType;

@interface DIDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *myPosts;
@property (nonatomic, strong) NSMutableArray *likedPosts;
@property (nonatomic, strong) NSMutableArray *allNotifications;

@property (nonatomic, strong) UITableView *homeTableView;
@property (nonatomic, strong) UITableView *profileTableView;
@property (nonatomic, strong) UITableView *notificationTableView;


+ (id)sharedManager;

- (void)getPostsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock
          currentLocation:(CLLocation *)currentLocation;
- (void)getUsersPostsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock;
- (void)getLikedPostsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock;
- (void)getUsersPoints:(void (^)(BOOL update, NSError *error))completionBlock;


- (BOOL)likePostAtIndex:(NSInteger)index forView:(ViewType)viewType;
- (void)dislikePostAtIndex:(NSInteger)index forView:(ViewType)viewType;
- (void)reportPostAtIndex:(NSInteger)index forView:(ViewType)viewType;
- (void)deletePostAtIndex:(NSInteger)index forView:(ViewType)viewType;
- (void)updatePostAtIndex:(NSInteger)index withPostObject:(NSDictionary *)postObject forView:(ViewType)view;

//- (void)updatePostAtIndex:(NSInteger)index withPostObject:(NSDictionary *)postObject;

//Comments
- (void)getCommentsForObject:(PFObject *)postObject
                   withBlock:(void (^)(NSMutableArray *comments, NSError *error))completionBlock;

//Notifications
- (void)getNotificationsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock;


@end
