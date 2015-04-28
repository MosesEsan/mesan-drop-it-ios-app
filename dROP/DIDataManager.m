//
//  ConfigurationManager.m
//  Drop It!
//
//  Created by Moses Esan on 12/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "DIDataManager.h"
#import "Config.h"

@implementation DIDataManager

#pragma mark Singleton Methods


//defines a static variable (but only global to this translation unit)) called sharedMyManager
//initialised once and only once in sharedManager.
//The way we ensure that it’s only created once is by using the dispatch_once method from Grand Central Dispatch (GCD). This is thread safe and handled entirely by the OS for you so that you don’t have to worry about it at all.

+ (id)sharedManager
{
    static DIDataManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        _allPosts = [[NSMutableArray alloc] init];
        _myPosts = [[NSMutableArray alloc] init];
        _likedPosts = [[NSMutableArray alloc] init];
        _allNotifications = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Posts
- (void)getPostsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock
          currentLocation:(CLLocation *)currentLocation
{
    dispatch_queue_t postsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query orderByDescending:@"createdAt"];
            
            //If app is not in testing mode, take the current location into consideration
            if ([Config appMode] != TESTING)
            {
                //If the current default college is not all, take the college name into consideration
                if (![[Config college] isEqualToString:ALL_COLLEGES])
                {
                    [query whereKey:@"college" containsString:[Config college]];
                }else{
                    
                     if (currentLocation != nil)
                     {
                         // Query for posts sort of kind of near users current location.
                         PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                                                    longitude:currentLocation.coordinate.longitude];
                     
                         [query whereKey:@"location" nearGeoPoint:point withinKilometers:ONE_HALF_MILE_RADIUS_KM];
                     }else{
                         NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
                     }
                }
            }
            
            //[query whereKey:@"objectId" equalTo:@"vc4OtBkcUN"];
            query.limit = 20;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    
                    NSMutableArray *filteredPost = [Config filterPosts:objects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _allPosts = filteredPost;
                        
                        completionBlock(YES, nil);
                    });
                }
            }];
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"No Internet Connection!" code:0
                                                 userInfo:[NSDictionary dictionaryWithObject:@"No Working Internet Connection." forKey:NSLocalizedDescriptionKey]];
                completionBlock(NO, error);
            });
        }
    });
}

- (void)getUsersPostsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock

{
    dispatch_queue_t userPostQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userPostQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query whereKey:@"deviceId" equalTo:[Config deviceId]];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!");
                } else {
                    
                    NSMutableArray *filteredPost = [Config filterPosts:objects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _myPosts = filteredPost;
                        
                        completionBlock(YES, nil);
                    });
                }
            }];
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"No Internet Connection!" code:0
                                                 userInfo:[NSDictionary dictionaryWithObject:@"No Working Internet Connection." forKey:NSLocalizedDescriptionKey]];
                completionBlock(NO, error);
            });
        }
    });
}

- (void)getLikedPostsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock
{
    dispatch_queue_t userPostQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userPostQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            NSArray *deviceId = @[[Config deviceId]];
            
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query whereKey:@"likes" containedIn:deviceId];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!");
                } else {
                    
                    NSMutableArray *filteredPost = [Config filterPosts:objects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _likedPosts = filteredPost;
                        
                        completionBlock(YES, nil);
                    });
                }
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"No Internet Connection!" code:0
                                                 userInfo:[NSDictionary dictionaryWithObject:@"No Working Internet Connection." forKey:NSLocalizedDescriptionKey]];
                completionBlock(NO, error);
            });
        }
    });
}

- (void)getUsersPoints:(void (^)(BOOL update, NSError *error))completionBlock
{
    dispatch_queue_t usersPointsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(usersPointsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:USERS_CLASS_NAME];
            [query whereKey:@"deviceId" equalTo:[Config deviceId]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([objects count] > 0)
                        {
                            NSInteger points = [objects[0][@"points"] integerValue];
                            
                            [Config updateUserPoints:points];
                            
                            completionBlock(YES, nil);
                            
                        }else{
                            
                            completionBlock(NO, nil);
                        }
                    });
                }
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"No Internet Connection!" code:0
                                                 userInfo:[NSDictionary dictionaryWithObject:@"No Working Internet Connection." forKey:NSLocalizedDescriptionKey]];
                completionBlock(NO, error);
            });
        }
    });
}


- (NSDictionary *)getPostAtIndex:(NSInteger)index forView:(ViewType)viewType
{
    NSDictionary *postObject;
    
    if (viewType == HOME)
    {
        postObject = _allPosts[index];
    }else if (viewType == PROFILE){
        postObject = _likedPosts[index];
    }
    
    return postObject;
}

//Like Post
- (BOOL)likePostAtIndex:(NSInteger)index forView:(ViewType)viewType
{
    NSDictionary *postObject = [self getPostAtIndex:index forView:viewType];
    
    BOOL selected = [postObject[@"liked"] boolValue];
    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    
    [postObject setValue:[NSNumber numberWithBool:!selected] forKey:@"liked"];
    [postObject setValue:[NSNumber numberWithBool:NO] forKey:@"disliked"];
    
    //get the Parse Object
    PFObject *parseObject = postObject[@"parseObject"];
    if (selected == NO)
    {
        //increment number
        likesCount++;
        
        //Like Post
        [parseObject addUniqueObject:[Config deviceId] forKey:@"likes"];
        [parseObject removeObject:[Config deviceId] forKey:@"dislikes"];
        
        parseObject[@"type"] = LIKE_POST_TYPE;
        
        
    }else if (selected == YES){
        //decrement number
        likesCount--;
        
        //Unlike Post
        [parseObject removeObject:[Config deviceId] forKey:@"likes"];
        
        parseObject[@"type"] = UNLIKE_POST_TYPE;
    }
    
    [postObject setValue:[NSNumber numberWithInteger:likesCount] forKey:@"totalLikes"];
    
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            NSLog(@"Not liked");
        /****attn*/
    }];
    
    /****IMPORTANT***/
    [self updatePostAtIndex:index withPostObject:postObject forView:viewType];
    /****IMPORTANT***/
    
    //change the button state
    return !selected;
}

//Dislike Post
- (void)dislikePostAtIndex:(NSInteger)index forView:(ViewType)viewType
{
    NSDictionary *postObject = [self getPostAtIndex:index forView:viewType];
    
    BOOL highlighted = [postObject[@"disliked"] boolValue];
    
    [postObject setValue:[NSNumber numberWithBool:!highlighted] forKey:@"disliked"];
    
    //get the Parse Object and Modify Local Object
    PFObject *parseObject = postObject[@"parseObject"];
    if (highlighted == NO)
    {
        //Dislike Post
        [parseObject addUniqueObject:[Config deviceId] forKey:@"dislikes"];
        [parseObject removeObject:[Config deviceId] forKey:@"likes"];
        
        parseObject[@"type"] = DISLIKE_POST_TYPE;
        
        //If user had previously liked this photo
        //decrement the likes numn=ber
        BOOL liked = [postObject[@"liked"] boolValue];
        if(liked == YES)
        {
            //decrement number
            NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
            likesCount--;
            [postObject setValue:[NSNumber numberWithInteger:likesCount] forKey:@"totalLikes"];
            //attn set sender value
        }
        
        [postObject setValue:[NSNumber numberWithBool:NO] forKey:@"liked"];
    }
    
    //Update Remote Object
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            NSLog(@"Notdisliked");
        /****attn*/
    }];
    
    /****IMPORTANT***/
    [self updatePostAtIndex:index withPostObject:postObject forView:viewType];
    /****IMPORTANT***/
}

//Report Post
- (void)reportPostAtIndex:(NSInteger)index forView:(ViewType)viewType
{
    NSDictionary *postObject = [self getPostAtIndex:index forView:viewType];
    
    //get the Parse Object and Report Post
    PFObject *parseObject = postObject[@"parseObject"];
    [parseObject addUniqueObject:[Config deviceId] forKey:@"reports"];
    
    parseObject[@"type"] = REPORT_POST_TYPE;
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            NSLog(@"NotReported");
        /****attn*/
    }];
    
    [self removePostObjectAtIndex:index withPostObject:postObject forView:viewType];
}

//Delete Post
- (void)deletePostAtIndex:(NSInteger)index forView:(ViewType)viewType
{
    NSDictionary *postObject = [self getPostAtIndex:index forView:viewType];
    
    //get the Parse Object
    PFObject *parseObject = postObject[@"parseObject"];
    [parseObject deleteInBackground];

    [self removePostObjectAtIndex:index withPostObject:postObject forView:viewType];
}

//Update Post Object and reload Table
- (void)updatePostAtIndex:(NSInteger)index
           withPostObject:(NSDictionary *)postObject
                  forView:(ViewType)view
{
    if (view == HOME)
    {
        _allPosts[index] = postObject;
        
        [self.homeTableView reloadData];
    }else if (view == PROFILE){
        _likedPosts[index] = postObject;
        
        [self.profileTableView reloadData];
    }
}

- (void)removePostObjectAtIndex:(NSInteger)index
                 withPostObject:(NSDictionary *)postObject
                        forView:(ViewType)viewType
{
    if (viewType == HOME)
        [_allPosts removeObjectAtIndex:index];
    else if (viewType == PROFILE)
        [_likedPosts removeObjectAtIndex:index];
}


#pragma mark - Comments
//Retrieve Comments
- (void)getCommentsForObject:(PFObject *)postObject
                   withBlock:(void (^)(NSMutableArray *comments, NSError *error))completionBlock
{
    dispatch_queue_t commentsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(commentsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:COMMENTS_CLASS_NAME];
            [query whereKey:@"postId" equalTo:postObject.objectId];
            [query orderByAscending:@"createdAt"];
            query.limit = 20;
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    NSMutableArray *filteredComments = [Config filterComments:objects];
                    completionBlock(filteredComments, nil);
                }
            }];
        }else{
            NSError *error = [NSError errorWithDomain:@"No Internet Connection!" code:0
                                             userInfo:[NSDictionary dictionaryWithObject:@"No Working Internet Connection." forKey:NSLocalizedDescriptionKey]];
            completionBlock(nil, error);
        }
    });
}


#pragma mark - Notifications
- (void)getNotificationsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock
{
    dispatch_queue_t userNotificationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userNotificationQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:NOTIFICATIONS_CLASS_NAME];
            [query includeKey:@"post"];
            [query includeKey:@"comment8"];
            [query whereKey:@"recipient" equalTo:[Config deviceId]];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!");
                } else {
                    
                    NSMutableArray *filteredNotifications = [[NSMutableArray alloc] init];
                    
                    for (PFObject *parseObject in objects)
                    {
                        NSString *notificationText = parseObject[@"message"];
                        PFObject *postObject = parseObject[@"post"];
                        NSString *type = parseObject[@"type"];
                        
                        NSDictionary *notificationObject = @{
                                                             @"text" : notificationText,
                                                             @"date" : parseObject.createdAt,
                                                             @"postObject" : postObject,
                                                             @"type" : type,
                                                             @"parseObject" : parseObject
                                                             };
                        
                        [filteredNotifications addObject:notificationObject.mutableCopy];
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _allNotifications = filteredNotifications;
                        
                        completionBlock(YES, nil);
                    });
                }
            }];
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"No Internet Connection!" code:0
                                                 userInfo:[NSDictionary dictionaryWithObject:@"No Working Internet Connection." forKey:NSLocalizedDescriptionKey]];
                completionBlock(NO, error);
                
            });
        }
    });
}


@end
