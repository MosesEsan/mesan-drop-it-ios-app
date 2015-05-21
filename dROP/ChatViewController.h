//
//  ChatViewController.h
//  Drop It!
//
//  Created by Moses Esan on 19/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "JSQMessagesViewController.h"

#import "JSQMessages.h"

#import "DemoModelData.h"
#import "ChatDataModel.h"

//@class DemoMessagesViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

//- (void)didDismissJSQDemoViewController:(DemoMessagesViewController *)vc;

@end


@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate>

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) ChatDataModel *chatDataModel;


@property (strong, nonatomic) NSMutableArray *chatMessages;
@property (strong, nonatomic) NSDictionary *avatars;
@property (strong, nonatomic) NSDictionary *users;


@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) NSString *postId;
@property (strong, nonatomic) UIImage *sendersAvatar;
@property (strong, nonatomic) NSString *recieversId;
@property (strong, nonatomic) NSString *recieversDisplayName;
@property (strong, nonatomic) UIImage *recieversAvatar;



@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;


//- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

//- (void)closePressed:(UIBarButtonItem *)sender;

@end



