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

#import "JSQMessages.h"
#import "Config.h"

@interface ChatDataModel : NSObject

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
