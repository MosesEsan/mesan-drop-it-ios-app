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


@property (strong, nonatomic) NSMutableArray *chatMessages;


//Users
@property (strong, nonatomic) NSString *sendersId;
@property (strong, nonatomic) NSString *sendersName;
@property (strong, nonatomic) UIImage *sendersAvatar;
@property (strong, nonatomic) NSString *recieversId;
@property (strong, nonatomic) NSString *recieversName;
@property (strong, nonatomic) UIImage *recieversAvatar;

@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) NSDictionary *users;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;


- (void)setUsersDetails;

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
