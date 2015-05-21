//
//  ChatViewController.m
//  Drop It!
//
//  Created by Moses Esan on 19/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ChatViewController.h"
#import <Firebase/Firebase.h>
#import "Config.h"

@interface ChatViewController ()
{
    Firebase *chatRef;
}
@end

@implementation ChatViewController

#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Chat";
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Hearts2"]];
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    
    self.showLoadEarlierMessagesHeader = YES;
    
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150;
     */
    
    //This Particular Chat - Use the PostId
    NSString *urlString = [NSString stringWithFormat:@"dropitchat.firebaseIO.com/%@",_conversationId];
    chatRef = [[Firebase alloc] initWithUrl:urlString];
    
    // Attach a block to read the data at our posts reference
    [chatRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [self receivedMessage:snapshot.value];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
    
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
     */

    
    
    self.chatMessages = [[NSMutableArray alloc] init];
    
    //Initialize Model to hold all data
    self.chatDataModel = [[ChatDataModel alloc] init];
    
    
    self.users = @{self.senderId : self.senderDisplayName,self.recieversId : _recieversDisplayName};

    //---------------------------------------------------------------------------------------------------------------------------------------------
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    //Create Avatars
    //Sender - This is the current user
    JSQMessagesAvatarImage *sendersImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:_sendersAvatar
                                                                                      diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    //Receiver - The person the user is chatting with
    JSQMessagesAvatarImage *receiversImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:_recieversAvatar
                                                                                        diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    self.avatars = @{ self.senderId : sendersImage,self.recieversId : receiversImage};
    //---------------------------------------------------------------------------------------------------------------------------------------------

    
    //get the messages for this conversation thread
    [ChatDataModel getMessageswithConversationId:self.conversationId
                                       withBlock:^(BOOL reload, NSArray *objects, NSError *error) {
                                           
                                           if (!error)
                                           {
                                               if (reload){
                                                   
                                                   for (int i =0; i < [objects count]; i++) {
                                                       
                                                       //Get the messag
                                                       PFObject *chatMessage = objects[i];
                                                       
                                                       //Create message object
                                                       JSQMessage *message =
                                                       [ChatDataModel createTextMessage:chatMessage[@"message"]
                                                                           withSenderId:chatMessage[@"senderId"]
                                                                        withDisplayName:chatMessage[@"senderName"]
                                                                               withDate:chatMessage[@"date"]];
                                                       
                                                       //Add to array
                                                       [self.chatMessages addObject:message];
                                                       
                                                   }
                                                   
                                                   //Finish
                                                   //[self finishSendingMessageAnimated:YES];
                                               }
                                           }
     }];
}


- (void)receivedMessage:(NSDictionary *)chatMessage
{
    /*  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    //[JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    //If the user is not the sender of the message
    if (![chatMessage[@"userId"] isEqualToString:self.senderId])
    {
        
        NSString *messageId = chatMessage[@"messageId"];
        
        
        //If the message is not currently in the database
        [ChatDataModel checkIfMessageExist:messageId
                                 WithBlock:^(BOOL exist, NSError *error){
                                     
                                     if (!error){
                                         if (!exist) {
                                             
                                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                             [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                                             NSDate *date = [dateFormatter dateFromString:chatMessage[@"date"]];
                                             
                                             //Save in Local Datasore and requery and reload table
                                             
                                             [ChatDataModel saveMessage:chatMessage[@"message"]
                                                     withConversationId:self.conversationId
                                                             withPostId:self.postId
                                                           withSenderId:chatMessage[@"message"]
                                                        withDisplayName:chatMessage[@"message"]
                                                             withStatus:@""
                                                               withDate:date
                                                    withCompletionBlock:^(NSString *objectId, BOOL succeeed){
                                                        
                                                        if (succeeed){
                                                            //requery
                                                            
                                                            //reload collection view
                                                            [self.collectionView reloadData];
                                                        }
                                                    }];
                                         }
                                     }
                                         
                                 }];
        
    }
}

- (void)saveMessage:(NSString *)text
           senderId:(NSString *)senderId
  senderDisplayName:(NSString *)senderDisplayName
               date:(NSDate *)date
{
    //Save in Local Datasore first - use the returned objectId as the messageId
    [ChatDataModel saveMessage:text
            withConversationId:self.conversationId
                    withPostId:self.postId
                  withSenderId:self.senderId
               withDisplayName:self.senderDisplayName
                    withStatus:@"Delivered"
                      withDate:date
           withCompletionBlock:^(NSString *objectId, BOOL succeeed){
               
               if (succeeed){
                   
                   NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                   [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                   NSString *dateString = [dateFormatter stringFromDate:date];
                   
                   //This particular chat message - to be stored with a autoid
                   NSDictionary *chatMessage = @{
                                                 @"messageId" : objectId,
                                                 @"userId" : self.senderId,
                                                 @"name": self.senderDisplayName,
                                                 @"message": text,
                                                 @"date": dateString,
                                                 @"status": @"Delivered"
                                                 };
                   // Write data to Firebase
                   Firebase *chatMessageRef = [chatRef childByAutoId];
                   
                   [chatMessageRef setValue:chatMessage withCompletionBlock:^(NSError *error, Firebase *ref) {
                       if (error) {
                           NSLog(@"Data could not be saved.");
                       } else {
                           NSLog(@"Data saved successfully.");
                           
                           //Push notification
                           
                           JSQMessage *message =
                           [ChatDataModel createTextMessage:text
                                               withSenderId:senderId
                                            withDisplayName:senderDisplayName
                                                   withDate:date];
                           
                           //Add to array
                           [self.chatMessages addObject:message];
                           
                           //Add new bubble
                           [self finishSendingMessageAnimated:YES];
                       }
                   }];
               }
           }];
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
 
    /*  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
 
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self saveMessage:text senderId:senderId senderDisplayName:senderDisplayName date:date];
}


/*
- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
 
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
 
    switch (buttonIndex) {
        case 0:
            [self.demoData addPhotoMediaMessage];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
            
        case 2:
            [self.demoData addVideoMediaMessage];
            break;
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}

*/



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView
       messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.chatMessages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.chatMessages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.chatMessages objectAtIndex:indexPath.item];
    
    
    
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.chatMessages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.chatMessages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.chatMessages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.chatMessages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.chatMessages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.chatMessages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

/*
#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}
*/
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
