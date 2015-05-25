//
//  ChatDataModel.m
//  Drop It!
//
//  Created by Moses Esan on 19/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ChatDataModel.h"


@implementation ChatDataModel

#pragma mark Singleton Methods
//defines a static variable (but only global to this translation unit)) called sharedMyManager
//initialised once and only once in sharedManager.
//The way we ensure that it’s only created once is by using the dispatch_once method from Grand Central Dispatch (GCD). This is thread safe and handled entirely by the OS for you so that you don’t have to worry about it at all.

+ (id)sharedManager
{
    static ChatDataModel *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        _currentConversation = @"";
        _conversations = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - Class Methods - Actions

//Called when Conversations View Controller is opened
- (void)getConversationsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Conversations"];
    [query orderByDescending:@"date"];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL reload = NO;
        
        if (!error)
        {
            reload = YES;
            
            //Create the conversations objects
            for (PFObject *parseObject in objects)
            {
                //[self createConversationObject:conversationObject];
                
                NSString *lastMessage = [NSString stringWithFormat:@"Started on %@",[Config convertDate:parseObject[@"date"]]];
                NSArray *lastMessageObject = [ChatDataModel getLastMessageWithConversationId:parseObject[@"conversationId"]];
                
                if([lastMessageObject count] > 0)
                {
                    PFObject *messageObject = objects[0];
                    lastMessage = messageObject[@"message"];
                }
                
                NSDictionary *conversationObject = @{
                                                     @"conversationId" : parseObject[@"conversationId"],
                                                     @"postId" : parseObject[@"postId"],
                                                     @"senderId" : parseObject[@"senderId"],
                                                     @"receiverId" : parseObject[@"receiverId"],
                                                     @"receiverName" : parseObject[@"receiverName"],
                                                     @"date" : parseObject[@"date"],
                                                     @"lastMessage" : lastMessage
                                                     };
                [self.conversations addObject:conversationObject.mutableCopy];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionBlock(reload, error);
        });
    }];
}

//Called when user accepts chat invitation
- (void)startNewConversationWithSenderId:(NSString *)senderId
                          withReceiverId:(NSString *)receiverId
                        withReceiverName:(NSString *)receiverName
                              withPostId:(NSString *)postId
                               withBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock
{
    PFObject *conversation = [PFObject objectWithClassName:@"Conversations"];
    conversation[@"conversationId"] = [NSString stringWithFormat:@"Post%@Chat%@",postId,receiverId];
    conversation[@"postId"] = postId;
    conversation[@"senderId"] = senderId;
    conversation[@"receiverId"] = receiverId;
    conversation[@"receiverName"] = receiverName;
    conversation[@"date"] = [NSDate date];
    
    [conversation pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        completionBlock(succeeded, error);
    }];
}

//Called when Chat View Controller is opened
+ (NSArray *)getLastMessageWithConversationId:(NSString *)conversationId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"conversationId" equalTo:conversationId];
    [query orderByDescending:@"date"];
    [query fromLocalDatastore];
    NSArray *objects = [query findObjects];
    
    return objects;
}






+ (void)checkIfConversationExist:(NSString *)postId
                    withSenderId:(NSString *)senderId
                  withReceiverId:(NSString *)receiverId
                       withBlock:(void (^)(BOOL exist, PFObject *object, NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"ChatConversation"];
    [query whereKey:@"postId" equalTo:postId];
    [query whereKey:@"senderId" equalTo:senderId];
    [query whereKey:@"receiverId" equalTo:receiverId];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"error in geo query!");
                completionBlock(NO, nil, error);
            });
            
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([objects count] > 0)
                {
                    completionBlock(YES, objects[0],nil);
                }else{
                    
                    completionBlock(NO, nil, nil);
                }
                
            });
        }
    }];
}


//Called when Chat View Controller is opened
+ (void)getMessageswithConversationId:(NSString *)conversationId
                            withBlock:(void (^)(BOOL reload, NSArray *objects, NSError *error))completionBlock

{
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"conversationId" equalTo:conversationId];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in geo query!");
            completionBlock(NO, nil, error);
        } else {
            
    
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completionBlock(YES, objects, nil);
            });
        }
    }];
}

//Save new message
+ (void)saveMessage:(NSString *)message
 withConversationId:(NSString *)conversationId
         withPostId:(NSString *)postId
       withSenderId:(NSString *)senderId
    withDisplayName:(NSString *)senderName
         withStatus:(NSString *)status
           withDate:(NSDate *)date
withCompletionBlock:(void (^)(NSString *objectId, BOOL succeeed))completionBlock
{
    
    PFObject *chatMessage = [PFObject objectWithClassName:@"Messages"];
    chatMessage[@"conversationId"] = conversationId;
    chatMessage[@"postId"] = postId;
    chatMessage[@"senderId"] = senderId;
    chatMessage[@"senderName"] = senderName;
    chatMessage[@"message"] = message;
    chatMessage[@"status"] = status;
    chatMessage[@"date"] = date;
    
    BOOL result = [chatMessage pin];
     
    if (result)
    {
        PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
        PFObject *object = [query getFirstObject];
        
        completionBlock(object.objectId, YES);
        
    }else{
        
        completionBlock(nil, NO);
    }
}

+ (void)checkIfMessageExist:(NSString *)messageId
                  WithBlock:(void (^)(BOOL exist, NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"];
    [query whereKey:@"messageId" equalTo:messageId];
    [query fromLocalDatastore];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"error in geo query!");
                completionBlock(NO, error);
            });
            
        } else {
        
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([objects count] > 0)
                {
                    completionBlock(YES, nil);
                }else{
                    
                    completionBlock(NO, nil);
                }
                
            });
        }
    }];
}

+ (JSQMessage *)createTextMessage:(NSString *)message
                           withSenderId:(NSString *)senderId
                        withDisplayName:(NSString *)senderName
                         withDate:(NSDate *)date
{
    
    JSQMessage *textMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                 senderDisplayName:senderName
                                                              date:date
                                                              text:message];
    
    return textMessage;
}

+ (JSQMessage *)createPhotoMediaMessage:(UIImage *)image
                   withSenderId:(NSString *)senderId
                withDisplayName:(NSString *)senderName
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:senderName
                                                         media:photoItem];
    return photoMessage;
}

+ (JSQMessage *)createLocationMediaMessage:(CLLocation *)location
                              withSenderId:(NSString *)senderId
                           withDisplayName:(NSString *)senderName
                            withCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:location withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:senderId
                                                      displayName:senderName
                                                            media:locationItem];
    return locationMessage;
}

+ (JSQMessage *)createVideoMediaMessage:(NSURL *)videoURL
                              withSenderId:(NSString *)senderId
                           withDisplayName:(NSString *)senderName
{
    
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:senderId
                                                   displayName:senderName
                                                         media:videoItem];
    return videoMessage;
}



- (void)createConversationObject:(PFObject *)parseObject
{
    //Get the last message for the conversation
    //If no messages, show date conversation started
    [ChatDataModel getLastMessageWithConversationId:parseObject[@"conversationId"]
                                          withBlock:^(NSArray *objects, NSError *error) {
                                              
                                              NSString *lastMessage = [NSString stringWithFormat:@"Started on %@",parseObject[@"date"]];
                                              
                                              if(!error)
                                              {
                                                  if([objects count] > 0)
                                                  {
                                                      PFObject *messageObject = objects[0];
                                                      lastMessage = messageObject[@"message"];
                                                  }
                                                  
                                              }else if (error){
                                                  
                                                  lastMessage = @"'Unable to get last message'";
                                              }
                                              
                                              
                                              NSDictionary *conversationObject = @{
                                                                                   @"conversationId" : parseObject[@"conversationId"],
                                                                                   @"postId" : parseObject[@"postId"],
                                                                                   @"senderId" : parseObject[@"senderId"],
                                                                                   @"receiverId" : parseObject[@"receiverId"],
                                                                                   @"receiverName" : parseObject[@"receiverName"],
                                                                                   @"date" : [NSDate date],//parseObject[@"date"],
                                                                                   @"lastMessage" : lastMessage
                                                                                   };
                                              [self.conversations addObject:conversationObject.mutableCopy];
                                          }];
}


#pragma mark - Testing Data - Actions
/*
- (void)testMessages
{
    
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     
    self.chatMessages = [[NSMutableArray alloc] initWithObjects:
                     
                     [ChatDataModel createTextMessage:@"Welcome to JSQMessages: A messaging UI framework for iOS."
                                         withSenderId:_sendersId
                                      withDisplayName:_sendersName
                                             withDate:[NSDate date]],
                     
                     
                     [ChatDataModel createTextMessage:@"It is simple, elegant, and easy to use. There are super sweet default settings, but you can customize like crazy."
                                         withSenderId:_recieversId
                                      withDisplayName:_recieversName
                                             withDate:[NSDate date]],
                     
                     
                     [ChatDataModel createTextMessage:@"It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com."
                                         withSenderId:_recieversId
                                      withDisplayName:_recieversName
                                             withDate:[NSDate date]],
                     
                     
                     [ChatDataModel createTextMessage:@"JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better."
                                         withSenderId:_sendersId
                                      withDisplayName:_sendersName
                                             withDate:[NSDate date]],
                     
                     
                     [ChatDataModel createTextMessage:@"It is unit-tested, free, open-source, and documented."
                                         withSenderId:_recieversId
                                      withDisplayName:_recieversName
                                             withDate:[NSDate date]],
                     
                     
                     [ChatDataModel createTextMessage:@"Now with media messages!"
                                         withSenderId:_recieversId
                                      withDisplayName:_recieversName
                                             withDate:[NSDate date]],
                     nil];
    
    JSQMessage *photoMessage = [ChatDataModel createPhotoMediaMessage:[UIImage imageNamed:@"lady4"]
                                                         withSenderId:_sendersId
                                                      withDisplayName:_sendersName];
    
    
    [self.chatMessages addObject:photoMessage];
    
    
    
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQMessage *locationMessage = [ChatDataModel createLocationMediaMessage:ferryBuildingInSF
                                                               withSenderId:_sendersId
                                                            withDisplayName:_sendersName
                                                             withCompletion:nil];
    
    [self.chatMessages addObject:locationMessage];
}
*/
@end
