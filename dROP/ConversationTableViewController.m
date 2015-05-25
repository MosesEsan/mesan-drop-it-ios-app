//
//  ConversationTableViewController.m
//  Drop It!
//
//  Created by Moses Esan on 22/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ConversationTableViewController.h"
#import <Firebase/Firebase.h>
#import "Config.h"
#import "ChatDataModel.h"

#import "ConversationTableViewCell.h"

@interface ConversationTableViewController ()
{
    ChatDataModel *dataManager;
}

@end

@implementation ConversationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *positveSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    positveSpacer.width = 22;
    
    UIButton *invitationsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    invitationsButton.frame = CGRectMake(0, 0, 28, 28);
    [invitationsButton setImage:[UIImage imageNamed:@"Invitations"] forState:UIControlStateNormal];
    invitationsButton.imageEdgeInsets = UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f);
    [invitationsButton setClipsToBounds:YES];
    invitationsButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [invitationsButton addTarget:self action:@selector(viewInvitations:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *viewInvitations = [[UIBarButtonItem alloc] initWithCustomView:invitationsButton];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:viewInvitations, positveSpacer, nil]];
    
    //0 - Shared Data Manager
    dataManager = [ChatDataModel sharedManager];

    
    //1- Get all conversation
    [dataManager getConversationsWithBlock:^(BOOL reload, NSError *error) {
       
        if (!error && reload){
            
            [self.tableView reloadData];
        }else if (error){
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Conversation Retrieval Failed!"
                                                                 message:@"We were unable to retrieve your conversations. Make sure you are connected to the interenet."
                                                                delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [errorAlert show];
        }
    }];
    
    /*
    PFQuery *query = [PFQuery queryWithClassName:@"Conversations"];
    [query whereKey:@"conversationId" equalTo:@"Post9h1k0WZHRNChatJENNY-KING-2017"];
    [query fromLocalDatastore];
    NSArray *delete = [query findObjects];
    
    [delete[0] unpin];*/
    
    //2 - Start A new Conversation - Testing Purpose
    //JENNY-KING-2000 //Jenny //9h1k0WZHRN
    /*
    [dataManager startNewConversationWithSenderId:[Config deviceId]
                                   withReceiverId:@"SIOBHAN-SMITH-2000"
                                 withReceiverName:@"Siobhan"
                                       withPostId:@"ylRa7HhPcA"
                                        withBlock:^(BOOL succeeded, NSError *error) {
                                            if (succeeded)
                                            {
                                                //Open the chat view controller
                                            }else if (error){
                                                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Conversation Failed!"
                                                                                                     message:@"We were unable to start a new conversation. Make sure you are connected to the interenet."
                                                                                                    delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                [errorAlert show];
                                            }
                                        }];
    */
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = BAR_STYLE;
    self.navigationController.navigationBar.barTintColor = BAR_TINT_COLOR2;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    return [dataManager.conversations count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ConversationTableViewCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Conversation%ld", (long)indexPath.row];
    
    ConversationTableViewCell *cell = (ConversationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    // Configure the cell...
    
    [cell setValues:dataManager.conversations[indexPath.row]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

@end
