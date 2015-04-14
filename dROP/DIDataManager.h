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

@interface DIDataManager : NSObject

@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *likes;
@property (nonatomic, strong) UITableView *tableView;


+ (id)sharedManager;

- (void)updatePostAtIndex:(NSInteger)index withPostObject:(NSDictionary *)postObject;

- (BOOL)likePostAtIndex:(NSInteger)index updateArray:(BOOL)update;

- (void)dislikePostAtIndex:(NSInteger)index updateArray:(BOOL)update;

- (void)deletePost:(NSDictionary *)postObject;

- (void)reportPostAtIndex:(NSInteger)index updateArray:(BOOL)update;


//Comments
- (void)getCommentsForObject:(PFObject *)postObject
                   withBlock:(void (^)(NSMutableArray *comments, NSError *error))completionBlock;

@end
