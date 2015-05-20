//
//  ChatDataModel.m
//  Drop It!
//
//  Created by Moses Esan on 19/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ChatDataModel.h"


@implementation ChatDataModel

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {    }
    
    return self;
}

- (void)setUsersDetails
{
    //[self testMessages];
    
    self.chatMessages = [[NSMutableArray alloc] init];
                         
    //Create Avatars
    //Sender - This is the current user
    JSQMessagesAvatarImage *sendersImage =
    [JSQMessagesAvatarImageFactory avatarImageWithImage:_sendersAvatar
                                               diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    
    //Receiver - The person the user is chatting with
    JSQMessagesAvatarImage *receiversImage =
    [JSQMessagesAvatarImageFactory avatarImageWithImage:_recieversAvatar
                                               diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    self.avatars = @{ _sendersId : sendersImage,
                      _recieversId : receiversImage
                      };
    
    
    self.users = @{ _sendersId : _sendersName,
                    _recieversId : _recieversName
                    };
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
}

#pragma mark - Class Methods - Actions

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


#pragma mark - Testing Data - Actions

- (void)testMessages
{
    /**
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     */
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
@end
