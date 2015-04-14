//
//  ProfileViewController.m
//  dROP
//
//  Created by Moses Esan on 08/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ProfileViewController.h"
#import "Config.h"
#import "PostTextTableViewCell.h"
#import "ColouredTableViewCell.h"
#import "CommentsTableViewController.h"
#import "UIFont+Montserrat.h"
#import "InfoViewController.h"
#import "CCMBorderView.h"
#import "CCMPopupTransitioning.h"

#import "MHFacebookImageViewer.h"
#import "RESideMenu.h"



@interface ProfileViewController ()
{
    UILabel *rankLabel;
    NSDate *lastUpdated;
    
    BOOL showAlert;
}

@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *likedPosts;

@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Profile";
    
    showAlert = NO;
    
    _allPosts = [[NSMutableArray alloc] init];
    _likedPosts = [[NSMutableArray alloc] init];
    
    dispatch_queue_t queriesQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queriesQueue, ^{
        [self queryForUsersPosts];
        [self queryForLikedPosts];
        [self queryForUsersPoints];
    });
    
    //Menu
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 23.0f, 23.0f);
    [menuBtn setImage:[Config drawListImage] forState:UIControlStateNormal];
    [menuBtn setClipsToBounds:YES];
    menuBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [menuBtn addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeCustom];
    info.frame = CGRectMake(0, 0, 22, 22);
    [info setImage:[UIImage imageNamed:@"Info"] forState:UIControlStateNormal];
    [info setClipsToBounds:YES];
    info.imageView.contentMode = UIViewContentModeScaleAspectFill;
    info.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    [info addTarget:self action:@selector(showPointsInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:info];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 85)];
    headerView.backgroundColor = [UIColor clearColor];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, 85 - 1.0f,
                                    WIDTH, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;
    [headerView.layer addSublayer:bottomBorder];
    
    
    UILabel *rankTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, CGRectGetWidth(headerView.frame), 30)];
    rankTitleLabel.backgroundColor = [UIColor clearColor];
    rankTitleLabel.text = @"RANK:";
    rankTitleLabel.textAlignment = NSTextAlignmentCenter;
    rankTitleLabel.font = [UIFont montserratFontOfSize:22.0f];
    rankTitleLabel.textColor = DATE_COLOR;
    [headerView addSubview:rankTitleLabel];
    
    rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 38, CGRectGetWidth(headerView.frame), 40)];
    rankLabel.backgroundColor = [UIColor clearColor];
    rankLabel.textAlignment = NSTextAlignmentCenter;
    rankLabel.font = [UIFont montserratFontOfSize:23.5f];
    rankLabel.textColor = DATE_COLOR;
    [headerView addSubview:rankLabel];
    
    self.tableView.tableHeaderView = headerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newPostAdded:)
                                                 name:NEW_POST_NOTIFICATION
                                               object:nil];
    
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
    
    NSDictionary *usersInfo  = [Config userPoints];
    
    rankLabel.text = [NSString stringWithFormat:@"%@ (%@)",usersInfo[@"Rank"],usersInfo[@"Points"]];
    
    if ([Config checkLastUpdated:lastUpdated withMaxDifference:20])
        [self queryForUsersPoints];
    
    [self.tableView reloadData];
}

- (void)queryForUsersPosts
{
    dispatch_queue_t userPostQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userPostQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query whereKey:@"deviceId" equalTo:[Config deviceId]];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!");
                } else {
                    
                    NSMutableArray *filteredPost = [Config filterPosts:objects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _allPosts = filteredPost;
                        
                        [self.tableView reloadData];
                    });
                }
            }];
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (showAlert == YES)
                {
                    [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
                    showAlert = NO;
                }
            });
        }
    });
}

- (void)queryForLikedPosts
{
    dispatch_queue_t userPostQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(userPostQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            NSArray *deviceId = @[[Config deviceId]];
            
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query whereKey:@"likes" containedIn:deviceId];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!");
                } else {
                    
                    NSMutableArray *filteredPost = [Config filterPosts:objects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _likedPosts = filteredPost;
                        
                        [self.tableView reloadData];
                    });
                }
            }];
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (showAlert == YES)
                {
                    [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
                    showAlert = NO;
                }
            });
        }
    });
}

- (void)queryForUsersPoints
{
    dispatch_queue_t usersPointsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(usersPointsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:USERS_CLASS_NAME];
            [query whereKey:@"deviceId" equalTo:[Config deviceId]];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        lastUpdated = [NSDate date];
                        
                        if ([objects count] > 0)
                        {
                            NSInteger points = [objects[0][@"points"] integerValue];
                            
                            NSDictionary *usersInfo  = [Config updateUserPoints:points];
                            
                            rankLabel.text = [NSString stringWithFormat:@"%@ (%@)",usersInfo[@"Rank"],usersInfo[@"Points"]];
                            
                        }
                    });
                }
            }];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) return [_allPosts count];
    else return [_likedPosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject;
    CGFloat max;
    NSString *cellIdentifier;
    
    if (indexPath.section == 0) {
        postObject = _allPosts[indexPath.row];
        max = [_allPosts count] - 1;
    }else{
        postObject = _likedPosts[indexPath.row];
        max = [_likedPosts count] - 1;
    }

    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    PFObject *parseObject = postObject[@"parseObject"];
    
    if (indexPath.section == 0) {
        cellIdentifier = [NSString stringWithFormat:@"MyPostCell%@",parseObject.objectId];
    }else{
        cellIdentifier = [NSString stringWithFormat:@"LikedPostCell%@",parseObject.objectId];
    }
    
    ColouredTableViewCell *cell = (ColouredTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[ColouredTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    [cell setFrameWithObject:postObject forIndex:indexPath.row];

    
    if (indexPath.row != max)
        cell.bottomBorder.frame = CGRectMake(0, CGRectGetHeight(cell.mainContainer.frame) - 0.5f, CGRectGetWidth(cell.mainContainer.frame), .5f);
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (parseObject[@"pic"])
    {
        cell.postImage.file = parseObject[@"pic"];
        cell.postImage.tag = 1;//indexPath.row;
        [cell.postImage loadInBackground];
        [cell.postImage setupImageViewerWithPFFile:cell.postImage.file onOpen:nil onClose:nil];
    }
    
    
    //if the user is the owner of the post
    //and the post has likes, show the smiley button
    //else hide it
    if ([Config isPostAuthor:postObject])
    {
        if (likesCount > 0) cell.smiley.hidden = NO;
        else cell.smiley.hidden = YES;
    }
    
    //If the value for the disliked index is not YES,
    //set the smiley selected state to the value of the liked index
    if (![postObject[@"disliked"] boolValue]){
        cell.smiley.selected = [postObject[@"liked"] boolValue];
    }else{
        //else  set the smiley selected state to NO
        //set the smiley highlighted state to the value of the disliked index to indicate the user has disliked the post
        cell.smiley.selected = NO;
        cell.smiley.highlighted = [postObject[@"disliked"] boolValue];
    }
    
    //If the user is not the post authour
    //They can like, dislike and report the post
    if (![Config isPostAuthor:postObject])
    {
        cell.smiley.tag = indexPath.row;
        [cell.smiley addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(cell) weakSelf = cell;
        
        [cell setSwipeGestureWithView:[Config viewWithImageName:@"cross"]
                                color:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                                    
                                    _cellToDelete = weakSelf;
                                    
                                    
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Options?"
                                                                                        message:@"What would you like to do?"
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"Cancel"
                                                                              otherButtonTitles:@"Dislike", @"Report",nil];
                                    [alertView show];
                                }];
    }else if ([Config isPostAuthor:postObject]){
        
        //If the user is th author of the post
        //allow the user to be able to delete the post
        __weak typeof(cell) weakSelf = cell;
        
        [cell setSwipeGestureWithView:[Config viewWithImageName:@"cross"]
                                color:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                                    
                                    _cellToDelete = weakSelf;
                                    
                                    
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Post"
                                                                                        message:@"Are yu sure you want to delete this post?"
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"No"
                                                                              otherButtonTitles:@"Yes",nil];
                                    [alertView show];
                                }];
    }
    
    cell.tag = indexPath.row;
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    cell.bottomBorder.backgroundColor = [tableView separatorColor].CGColor;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 31.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 31.0)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 8.0f, sectionHeaderView.frame.size.width, 14.0f)];
    
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.textColor = BAR_TINT_COLOR2;
    [headerLabel setFont:[UIFont montserratFontOfSize:12.5f]];
    [sectionHeaderView addSubview:headerLabel];
    
    switch (section) {
        case 0:
            headerLabel.text = @"MY POSTS";
            return sectionHeaderView;
            break;
        case 1:
            headerLabel.text = @"LIKED POSTS";
            return sectionHeaderView;
            break;
        default:
            break;
    }
    
    return sectionHeaderView;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject;
    
    if (indexPath.section == 0) postObject = _allPosts[indexPath.row];
    else postObject = _likedPosts[indexPath.row];
    
    NSString *postText = postObject[@"text"];
    
    CGFloat postTextHeight = [Config calculateHeightForText:postText withWidth:WIDTH - 55.0f withFont:TEXT_FONT];
    
    CGFloat height = 0;
    
    if ([Config cellType] == TIMELINE){
        
        height = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 5;
        
        if (postObject[@"parseObject"][@"pic"])
            height += 10 + IMAGEVIEW_HEIGHT;
    }else if ([Config cellType] == COLOURED){
        
        if ([Config isPostAuthor:postObject])
        {
            height = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 3;
            
            if (postObject[@"parseObject"][@"pic"])
                height += 10 + IMAGEVIEW_HEIGHT;
        }else{
            height = [Config calculateCellHeight:postObject];
        }
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject;
    
    if (indexPath.section == 0) postObject = _allPosts[indexPath.row];
    else postObject = _likedPosts[indexPath.row];
    
    CommentsTableViewController *viewPost = [[CommentsTableViewController alloc] initWithNibName:nil bundle:nil];
    viewPost.postObject = postObject;
    viewPost.view.tag = indexPath.row;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController pushViewController:viewPost animated:YES];
}

- (void)newPostAdded:(NSNotification *)notification
{
    NSDictionary * info = notification.userInfo;
    PFObject *newObject = [info objectForKey:@"newObject"];
    
    //1 - Add New Post Array to the first position of the array
    [_allPosts insertObject:[Config createPostObject:newObject] atIndex:0];
    
    [self.tableView reloadData];
}

- (void)showPointsInfo:(UIBarButtonItem *)sender
{
    InfoViewController *pointsInfo = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
    
    CCMPopupTransitioning *popup = [CCMPopupTransitioning sharedInstance];
    popup.destinationBounds = CGRectMake(0, 0, INFO_VIEW_WIDTH, INFO_VIEW_HEIGHT);
    popup.presentedController = pointsInfo;
    popup.presentingController = self;
    
    
    popup.backgroundViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    popup.backgroundViewAlpha = 3.0f;
    
    [self presentViewController:pointsInfo animated:YES completion:nil];
}

-(void)refresh:(UIRefreshControl *)refresh
{
    [refresh endRefreshing];
    
    [self queryForUsersPosts];
    [self queryForUsersPoints];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Dislike"]) {
        
        [_cellToDelete swipeToOriginWithCompletion:^{
            //**[self dislikePost:_cellToDelete.tag];
            _cellToDelete = nil;
        }];
        
    }else if([title isEqualToString:@"Report"]) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Post"
                                                            message:@"Please tell us what is wrong with ths post."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Offensive content", @"Spam", @"Other", nil];
        [alertView show];
    }else if([title isEqualToString:@"Offensive content"] ||
             [title isEqualToString:@"Spam"] ||
             [title isEqualToString:@"Other"])
    {
        //**[self reportPost:_cellToDelete.tag];
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
    }else if([title isEqualToString:@"Yes"]) {
        //**[self deletePost:_cellToDelete.tag];
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [_cellToDelete swipeToOriginWithCompletion:^{
        }];
        
        _cellToDelete = nil;
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
