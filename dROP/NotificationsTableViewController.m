//
//  NotificationsTableViewController.m
//  Drop It!
//
//  Created by Moses Esan on 14/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "NotificationsTableViewController.h"

#import "Config.h"
#import "NotificationTableViewCell.h"
#import "CommentsTableViewController.h"
#import "RESideMenu.h"
#import "DIDataManager.h"

@interface NotificationsTableViewController ()
{
    NSDate *lastUpdated;
    
    BOOL showAlert;
    DIDataManager *shared;
}

@end

@implementation NotificationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    shared = [DIDataManager sharedManager];

    self.title = @"Notifications";
    
    showAlert = NO;
        
    dispatch_queue_t queriesQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queriesQueue, ^{
        
        [shared getNotificationsWithBlock:^(BOOL reload, NSError *error) {
            
            if (!error && reload)
            {
                [self.tableView reloadData];
            }else if (error){
                
                if (error.code == 0 && showAlert) {
                    [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
                    showAlert = NO;
                }
            }
        }];
    });
    
    //Menu
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 23.0f, 23.0f);
    [menuBtn setImage:[Config drawListImage] forState:UIControlStateNormal];
    [menuBtn setClipsToBounds:YES];
    menuBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [menuBtn addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];

    self.tableView.contentInset = UIEdgeInsetsMake(6, 0, 0, 0);

    //Add Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                       action:@selector(refresh:)
             forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    showAlert = YES;
    
    self.navigationController.navigationBar.barStyle = BAR_STYLE;
    self.navigationController.navigationBar.barTintColor = BAR_TINT_COLOR2;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

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
    return [shared.allNotifications count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *notificationObject = shared.allNotifications[indexPath.row];
    
    PFObject *parseObject = notificationObject[@"parseObject"];
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"NotificationCell%@",parseObject.objectId];
    
    NotificationTableViewCell *cell = (NotificationTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[NotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell setFrameWithObject:notificationObject forIndex:indexPath.row];
    
    //if (indexPath.row != max)
    cell.bottomBorder.frame = CGRectMake(0, CGRectGetHeight(cell.mainContainer.frame) - 0.5f, CGRectGetWidth(cell.mainContainer.frame), .5f);
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    cell.tag = indexPath.row;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    cell.bottomBorder.backgroundColor = [tableView separatorColor].CGColor;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notificationObject = shared.allNotifications[indexPath.row];
    return [NotificationTableViewCell getCellHeight:notificationObject];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *notificationObject = shared.allNotifications[indexPath.row];
    
    CommentsTableViewController *viewPost = [[CommentsTableViewController alloc] initWithNibName:nil bundle:nil];
    viewPost.postObject = [Config createPostObject:notificationObject[@"postObject"]];
    viewPost.view.tag = indexPath.row;
    //viewPost.viewType = NOTIFICATIONS;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:viewPost animated:YES];
}

-(void)refresh:(UIRefreshControl *)refresh
{
    [refresh endRefreshing];
    
    dispatch_queue_t queriesQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queriesQueue, ^{
        
        [shared getNotificationsWithBlock:^(BOOL reload, NSError *error) {
            
            if (!error && reload)
            {
                [self.tableView reloadData];
            }else if (error){
                
                if (error.code == 0 && showAlert) {
                    [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
                    showAlert = NO;
                }
            }
        }];
    });
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
