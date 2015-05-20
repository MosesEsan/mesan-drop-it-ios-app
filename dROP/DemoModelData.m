//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import "DemoModelData.h"


/**
 *  This is for demo/testing purposes only.
 *  This object sets up some fake model data.
 *  Do not actually do anything like this.
 */

@implementation DemoModelData

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self loadFakeMessages];
        
        /**
         *  Create avatar images once.
         *
         *  Be sure to create your avatars one time and reuse them for good performance.
         *
         *  If you are not using avatars, ignore this.
         */
        JSQMessagesAvatarImage *jsqImage = [JSQMessagesAvatarImageFactory avatarImageWithUserInitials:@"JSQ"
                                                                                      backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                                            textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                                                 font:[UIFont systemFontOfSize:14.0f]
                                                                                             diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *cookImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"apple.png"]
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *jobsImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"kiwi.png"]
                                                                                       diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        JSQMessagesAvatarImage *wozImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"lime.png"]
                                                                                      diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        
        self.avatars = @{ kJSQDemoAvatarIdSquires : jsqImage,
                          kJSQDemoAvatarIdCook : cookImage,
                          kJSQDemoAvatarIdJobs : jobsImage,
                          kJSQDemoAvatarIdWoz : wozImage };
        
        
        self.users = @{ kJSQDemoAvatarIdJobs : kJSQDemoAvatarDisplayNameJobs,
                        kJSQDemoAvatarIdCook : kJSQDemoAvatarDisplayNameCook,
                        kJSQDemoAvatarIdWoz : kJSQDemoAvatarDisplayNameWoz,
                        kJSQDemoAvatarIdSquires : kJSQDemoAvatarDisplayNameSquires };
        
        
        /**
         *  Create message bubble images objects.
         *
         *  Be sure to create your bubble images one time and reuse them for good performance.
         *
         */
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    }
    
    return self;
}

- (void)loadFakeMessages
{
    /**
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     
                     [ChatDataModel createTextMessage:@"Welcome to JSQMessages: A messaging UI framework for iOS."
                                         withSenderId:[Config deviceId]
                                      withDisplayName:@"Moses Esan"],
                     
                     
                     [ChatDataModel createTextMessage:@"It is simple, elegant, and easy to use. There are super sweet default settings, but you can customize like crazy."
                                         withSenderId:kJSQDemoAvatarIdSquires
                                      withDisplayName:kJSQDemoAvatarDisplayNameSquires],
                     
                     
                     [ChatDataModel createTextMessage:@"It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com."
                                         withSenderId:kJSQDemoAvatarIdSquires
                                      withDisplayName:kJSQDemoAvatarDisplayNameSquires],
                     
                     
                     [ChatDataModel createTextMessage:@"JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better."
                                         withSenderId:kJSQDemoAvatarIdSquires
                                      withDisplayName:kJSQDemoAvatarDisplayNameSquires],
                     
                     
                     [ChatDataModel createTextMessage:@"It is unit-tested, free, open-source, and documented."
                                         withSenderId:kJSQDemoAvatarIdSquires
                                      withDisplayName:kJSQDemoAvatarDisplayNameSquires],
                     
                     
                     [ChatDataModel createTextMessage:@"Now with media messages!"
                                         withSenderId:kJSQDemoAvatarIdSquires
                                      withDisplayName:kJSQDemoAvatarDisplayNameSquires],
                     nil];
    
    JSQMessage *photoMessage = [ChatDataModel createPhotoMediaMessage:[UIImage imageNamed:@"lady4"]
                                                         withSenderId:[Config deviceId]
                                                      withDisplayName:@"Moses Esan"];
    
    
    [self.messages addObject:photoMessage];
    
    
    
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];

    JSQMessage *locationMessage = [ChatDataModel createLocationMediaMessage:ferryBuildingInSF
                                                               withSenderId:[Config deviceId]
                                                            withDisplayName:@"Moses Esan"
                                                             withCompletion:nil];
    
    [self.messages addObject:locationMessage];
     */
}




@end
