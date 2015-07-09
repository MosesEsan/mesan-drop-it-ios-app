//
//  ChatDataModel.h
//  Drop It!
//
//  Created by Moses Esan on 19/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>

#import "JSQMessages.h"
#import "Config.h"

@interface ChatDataModel : NSObject


+ (id)sharedManager;

//Indicates the conversation currently opened in the Chat View Controller
//This means any new event received by the Conversation View Controller regarding this conversation
//Does not have to be handled
@property (nonatomic, strong) NSString *currentConversation;

@property (strong, nonatomic) NSMutableArray *conversations;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) NSMutableArray *connections;
@property (strong, nonatomic) NSMutableArray *invitations;

- (void)getAllConversations:(BOOL)openConnections;

+ (Firebase *)openChatConnection:(NSDictionary *)conversationObject;

//Gets all invitations from the remote datastore
- (void)getInvitationsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock;

//delete invitation
- (void)deleteInvitationAtIndex:(NSInteger)index;

//Gets all converstions from the local datastore
//Return Block -> reload (if new data was retrieved, Conversation View Controller needs to be reloaded), error (if an error occcurred)
- (void)getConversationsWithBlock:(void (^)(BOOL reload, NSError *error))completionBlock;

//Start a new conversation
- (void)startNewConversationWithSenderId:(NSString *)senderId
                          withReceiverId:(NSString *)receiverId
                        withReceiverName:(NSString *)receiverName
                              withPostId:(NSString *)postId
                               withBlock:(void (^)(BOOL succeeded, NSError *error, NSString *conversationId))completionBlock;
//Add a new conversation
- (void)addNewConversationWithConversationId:(NSString *)conversationId
                              withReceiverId:(NSString *)receiverId
                            withReceiverName:(NSString *)receiverName
                                  withPostId:(NSString *)postId
                                   withBlock:(void (^)(BOOL succeeded, NSError *error))completionBlock;

//Returns the last message for the conversationId passed
+ (void)getLastMessageWithConversationId:(NSString *)conversationId
                               withBlock:(void (^)(NSArray *objects, NSError *error))completionBlock;

+ (void)saveMessage:(NSString *)message
 withConversationId:(NSString *)conversationId
         withPostId:(NSString *)postId
       withSenderId:(NSString *)senderId
    withDisplayName:(NSString *)senderName
         withStatus:(NSString *)status
           withDate:(NSDate *)date
withCompletionBlock:(void (^)(NSString *objectId, BOOL succeeed))completionBlock;


+ (void)checkIfConversationExist:(NSString *)postId
                    withSenderId:(NSString *)senderId
                  withReceiverId:(NSString *)receiverId
                       withBlock:(void (^)(BOOL exist, PFObject *object, NSError *error))completionBlock;


+ (void)checkIfMessageExist:(NSString *)messageId
                  WithBlock:(void (^)(BOOL exist, NSError *error))completionBlock;


+ (void)getMessageswithConversationId:(NSString *)conversationId
                            withBlock:(void (^)(BOOL reload, NSArray *objects, NSError *error))completionBlock;


+ (NSDictionary *)createChatMessageWithId:(NSString *)messageId
                 withConversationId:(NSString *)conversationId
                         withPostId:(NSString *)postId
                       withSenderId:(NSString *)senderId
                    withDisplayName:(NSString *)senderName
                        withMessage:(NSString *)message
                           withDate:(NSDate *)date;

+ (JSQMessage *)createTextMessage:(NSString *)message
                     withSenderId:(NSString *)senderId
                  withDisplayName:(NSString *)senderName
                         withDate:(NSDate *)date;


+ (JSQMessage *)createPhotoMediaMessage:(UIImage *)image
                           withSenderId:(NSString *)senderId
                        withDisplayName:(NSString *)senderName;

+ (JSQMessage *)createLocationMediaMessage:(CLLocation *)location
                              withSenderId:(NSString *)senderId
                           withDisplayName:(NSString *)senderName
                            withCompletion:(JSQLocationMediaItemCompletionBlock)completion;

+ (JSQMessage *)createVideoMediaMessage:(NSURL *)videoURL
                           withSenderId:(NSString *)senderId
                        withDisplayName:(NSString *)senderName;

@end
