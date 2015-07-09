//
//  InvitationsTableViewController.m
//  Drop It!
//
//  Created by Moses Esan on 22/06/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "InvitationsTableViewController.h"
#import <Firebase/Firebase.h>
#import "Config.h"
#import "ChatDataModel.h"

#import "InvitationsTableViewCell.h"

@interface InvitationsTableViewController ()
{
    ChatDataModel *dataManager;
}

@end

@implementation InvitationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    self.title = @"Invitations";
    
    //0 - Shared Data Manager
    dataManager = [ChatDataModel sharedManager];
    
    // [self.tableView setEditing:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    //1- Get all invitations
    [self getInvitations];
    
    self.navigationController.navigationBar.barStyle = BAR_STYLE;
    self.navigationController.navigationBar.barTintColor = BAR_TINT_COLOR2;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)getInvitations
{
    //1- Get all conversation
    [dataManager getInvitationsWithBlock:^(BOOL reload, NSError *error) {
        
        if (!error && reload){
            
            [self.tableView reloadData];
        }else if (error){
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Invitations Retrieval Failed!"
                                                                 message:@"We were unable to retrieve your conversations. Make sure you are connected to the interenet."
                                                                delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [errorAlert show];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [dataManager.invitations count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [InvitationsTableViewCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Conversation%ld", (long)indexPath.row];
    
    InvitationsTableViewCell *cell = (InvitationsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[InvitationsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    // Configure the cell...
    
    [cell setValues:dataManager.invitations[indexPath.row]];
    
    return cell;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Accept" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        //accept the invitation
        NSDictionary *invitationObject = dataManager.invitations[indexPath.row];
        
        //add the conversation to the local storage
        //start a new conversation with status "accepted"
        PFObject *conversation = [PFObject objectWithClassName:@"Conversations"];
        conversation[@"conversationId"] = invitationObject[@"conversationId"];
        conversation[@"postId"] = invitationObject[@"postId"];
        conversation[@"senderId"] = [Config deviceId]; ///The user becomes the sender
        conversation[@"receiverId"] = invitationObject[@"senderId"]; //The person that requested the chat becomes the receiver
        conversation[@"receiverName"] = invitationObject[@"senderName"];
        conversation[@"status"] = @"accepted"; //indicates the chat invitation has been accepted
        conversation[@"date"] = [NSDate date];
        
        
        [conversation pinInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                //delete the invitation
                [dataManager deleteInvitationAtIndex:indexPath.row];
                
                // Delete the row from the data source
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                
                //Create a conversation object
                NSString *conversationId = conversation[@"conversationId"];
                NSString *postId = conversation[@"postId"];
                NSDictionary *conversationObject = @{
                                                     @"conversationId" : conversationId,
                                                     @"postId" : postId,
                                                     @"senderId" : conversation[@"senderId"],
                                                     @"receiverId" : conversation[@"receiverId"],
                                                     @"receiverName" : conversation[@"receiverName"],
                                                     @"date" : conversation[@"date"],
                                                     @"lastMessage" : [NSString stringWithFormat:@"Started on %@",[Config convertDate:conversation[@"date"]]]
                                                     };
                
                //add the conversation object to the shared array
                [dataManager.conversations addObject:conversationObject.mutableCopy];
                
                //open the connection
                Firebase *chatRef = [ChatDataModel openChatConnection:conversationObject];
                
                
                [dataManager.connections addObject:chatRef];
                
                //refresh the conversation table view fully
                NSDictionary *dict =[NSDictionary dictionaryWithObject:FULL_REFRESH forKey:@"refresh"];
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_CONVERSATION object:nil userInfo:dict];
                
                //Send push notification
                PFQuery *pushQuery = [PFInstallation query];
                [pushQuery whereKey:@"deviceId" equalTo:invitationObject[@"senderId"]];
                
                NSString *message = [NSString stringWithFormat:@"Moses accepted your chat invitation."];//paste device owner name **
                [PFPush sendPushMessageToQueryInBackground:pushQuery
                                               withMessage:message];
                
                //send a message as backup in case push notification was not delivered
                //Save in Local Datasore first - use the returned objectId as the messageId
                [ChatDataModel saveMessage:@"Moses accepted your chat invitation."
                        withConversationId:conversationId
                                withPostId:postId
                              withSenderId:conversation[@"senderId"]
                           withDisplayName:@"ME"
                                withStatus:@"Sent"
                                  withDate:[NSDate date]
                       withCompletionBlock:^(NSString *messageId, BOOL succeeed){
                           
                           if (succeeed){
                               
                               //This particular chat message - to be stored with a autoid
                               NSDictionary *chatMessage = [ChatDataModel createChatMessageWithId:messageId
                                                                               withConversationId:conversationId
                                                                                       withPostId:postId
                                                                                     withSenderId:conversation[@"senderId"]
                                                                                  withDisplayName:@"Moses Esan"
                                                                                      withMessage:@"Moses accepted your chat invitation."
                                                                                         withDate:[NSDate date]];
                               // Write data to Firebase
                               Firebase *chatMessageRef = [chatRef childByAutoId];
                               
                               [chatMessageRef setValue:chatMessage withCompletionBlock:^(NSError *error, Firebase *ref) {
                                   if (error) {
                                       NSLog(@"Data could not be saved.");
                                   } else {
                                       NSLog(@"Data saved successfully.");
                                   }
                               }];
                           }
                       }];
                
            }else if (error){
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Conversation Failed!"
                                                                     message:@"We were unable to start the conversation. Please try again."
                                                                    delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [errorAlert show];
            }
        }];
    }];
    
    
    
    button.backgroundColor = [UIColor greenColor]; //arbitrary color
    
    
    
    
    
    
    
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Decline" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        
        //delete the invitation
        [dataManager deleteInvitationAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }];
    
    button2.backgroundColor = [UIColor redColor]; //arbitrary color
    
    return @[button2,button]; //array with all the buttons you want. 1,2,3, etc...
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        
        
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
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


/*
 [[ChatDataModel sharedManager] addNewConversationWithConversationId:invitationObject[@"conversationId"]
 withReceiverId:invitationObject[@"senderId"] //the person that sent the invitation will be the recxeiver of our messages
 withReceiverName:invitationObject[@"senderName"]
 withPostId:invitationObject[@"postId"]
 withBlock:^(BOOL succeeded, NSError *error) {
 if (succeeded)
 {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 
 //delete the invitation
 [dataManager deleteInvitationAtIndex:indexPath.row];
 }else if (error){
 UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Conversation Failed!"
 message:@"We were unable to start the conversation. Please try again."
 delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
 [errorAlert show];
 }
 }];
 */

@end
