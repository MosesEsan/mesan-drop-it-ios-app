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
#import "ViewPostTableViewController.h"
#import "UIFont+Montserrat.h"
#import "InfoViewController.h"
#import "CCMBorderView.h"
#import "CCMPopupTransitioning.h"


@interface ProfileViewController ()
{
    UILabel *rankLabel;
    NSDate *lastUpdated;
}

@property (nonatomic, strong) NSMutableArray *allPosts;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        _allPosts = [[NSMutableArray alloc] init];
        
        [self queryForUsersPosts];
        [self queryForUsersPoints];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Profile";
    
    UIButton *info = [UIButton buttonWithType:UIButtonTypeCustom];
    info.frame = CGRectMake(0, 0, 22, 22);
    [info setImage:[UIImage imageNamed:@"Info-Small.png"] forState:UIControlStateNormal];
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
    if ([Config checkInternetConnection])
    {
        dispatch_queue_t userPostQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(userPostQueue, ^{
            
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query whereKey:@"deviceId" equalTo:[Config deviceId]];
            [query orderByDescending:@"createdAt"];
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!");
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _allPosts = [Config filterPosts:objects];
                        
                        [self.tableView reloadData];
                    });
                }
            }];
            
        });
    }else{
        
        [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
    }
}

- (void)queryForUsersPoints
{
    if ([Config checkInternetConnection])
    {
        dispatch_queue_t usersPointsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(usersPointsQueue, ^{
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
            
        });
    }
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
    return [_allPosts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject = _allPosts[indexPath.row];
    NSString *postText = postObject[@"text"];
    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    NSInteger repliesCount = [postObject[@"totalReplies"] integerValue];
    NSString *postDate = [Config calculateTime:postObject[@"date"]];
    NSString *cellIdentifier = [NSString stringWithFormat:@"BoxCell%ld",(long)indexPath.row];
    
    PostTextTableViewCell *_cell = (PostTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell)
        _cell = [[PostTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    _cell.selectionStyle= UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    _cell.postText.text = postText;
    _cell.date.text = postDate;
    _cell.comments.text = [Config repliesCount:repliesCount];
    [_cell.smiley setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
    
    //Set Frames
    NSDictionary *subViewframes = [Config subViewFrames:postObject];
    _cell.postText.frame = [subViewframes[@"postTextFrame"] CGRectValue];
    _cell.postImage.frame = [subViewframes[@"imageFrame"] CGRectValue];
    _cell.actionsView.frame = [subViewframes[@"actionViewframe"] CGRectValue];
    
    if (postObject[@"parseObject"][@"pic"])
    {
        _cell.postImage.file = postObject[@"parseObject"][@"pic"];
        [_cell.postImage loadInBackground];
    }
    
    if (![postObject[@"disliked"] boolValue]){
        _cell.smiley.selected = [postObject[@"liked"] boolValue];
    }else{
        _cell.smiley.selected = NO;
        _cell.smiley.highlighted = [postObject[@"disliked"] boolValue];
    }
    
    _cell.tag = indexPath.row;
    _cell.smiley.tag = indexPath.row;
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject = _allPosts[indexPath.row];
    NSString *postText = postObject[@"text"];
    
    CGFloat postTextHeight = [Config calculateHeightForText:postText withWidth:TEXT_WIDTH withFont:TEXT_FONT];
    
    if (postObject[@"parseObject"][@"pic"])
    {
        return TOP_PADDING + postTextHeight + 10 + IMAGEVIEW_HEIGHT + 12 + ACTIONS_VIEW_HEIGHT + 2;
    }else{
        return TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 2;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewPostTableViewController *viewPost = [[ViewPostTableViewController alloc] initWithNibName:nil bundle:nil];
    viewPost.postObject = _allPosts[indexPath.row];
    viewPost.delegate = nil;
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
    [self presentViewController:pointsInfo animated:YES completion:nil];
}

-(void)refresh:(UIRefreshControl *)refresh
{
    [refresh endRefreshing];
    
    [self queryForUsersPosts];
    [self queryForUsersPoints];
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
