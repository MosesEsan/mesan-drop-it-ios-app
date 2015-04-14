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
        _likes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)updatePostAtIndex:(NSInteger)index withPostObject:(NSDictionary *)postObject
{
    _allPosts[index] = postObject;
    
    [self.tableView reloadData];
}

- (BOOL)likePostAtIndex:(NSInteger)index updateArray:(BOOL)update
{
    NSDictionary *postObject = _allPosts[index];
    
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
    
    if (update)
        [self updatePostAtIndex:index withPostObject:postObject];
    
    
    //change the button state
    return !selected;
}

- (void)dislikePostAtIndex:(NSInteger)index updateArray:(BOOL)update
{
    NSDictionary *postObject = _allPosts[index];
    
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
    
    [self updatePostAtIndex:index withPostObject:postObject];
}

- (void)reportPostAtIndex:(NSInteger)index updateArray:(BOOL)update
{
    NSDictionary *postObject = _allPosts[index];
    
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
    
    if(update)
        [_allPosts removeObjectAtIndex:index];
}

- (void)deletePost:(NSDictionary *)postObject
{
    //get the Parse Object
    PFObject *parseObject = postObject[@"parseObject"];
    [parseObject deleteInBackground];
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


@end
