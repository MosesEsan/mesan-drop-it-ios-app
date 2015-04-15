//
//  HomeTableViewController.m
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "HomeTableViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <CoreLocation/CoreLocation.h>

#import "DITableViewCell.h"
#import "PostTextTableViewCell.h"
#import "TimelineTableViewCell.h"
#import "ColouredTableViewCell.h"
#import "ProfileTableViewCell.h"

#import "AddPostViewController.h"
#import "CommentsTableViewController.h"

#import "UIFont+Montserrat.h"
#import "CCMBorderView.h"
#import "CCMPopupTransitioning.h"
#import "ABCIntroView.h"

#import "MHFacebookImageViewer.h"
#import "RTSpinKitView.h"
#import "UIScrollView+EmptyDataSet.h"
#import "JDFTooltipView.h"

#import "RESideMenu.h"
#import "DIDataManager.h"


//#import "RBMenu.h"

//Ad
#import <AvocarrotSDK/AvocarrotInstream.h>

@interface HomeTableViewController ()<AddPostViewControllerDataSource, CLLocationManagerDelegate, ABCIntroViewDelegate, ABCIntroViewDatasource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, AVInstreamAdDelegate, UIActionSheetDelegate>
{
    UILabel *layoutLabel;
    UIBarButtonItem *addNew;
    
    UIView *tableHeader;
    UILabel *toolTipLocation; //Hack
    JDFTooltipView *tooltip;
    
    
    ABCIntroView *introView;
    RTSpinKitView *spinner;
    
    BOOL showAlert;
    
    DIDataManager *shared;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;


@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;

@end

@implementation HomeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    shared = [DIDataManager sharedManager];
    shared.tableView = self.tableView;

    showAlert = NO;
    
    //Menu
    UIButton *menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0, 0, 23.0f, 23.0f);
    [menuBtn setImage:[Config drawListImage] forState:UIControlStateNormal];
    [menuBtn setClipsToBounds:YES];
    menuBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [menuBtn addTarget:self action:@selector(presentLeftMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    
    //TitleView
    layoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    layoutLabel.textAlignment = NSTextAlignmentCenter;
    layoutLabel.backgroundColor = [UIColor clearColor];
    layoutLabel.textColor = [UIColor whiteColor];
    layoutLabel.userInteractionEnabled = YES;
    self.navigationItem.titleView = layoutLabel;
    
    [self updateNavBar];

    UIButton *addNewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addNewButton.frame = CGRectMake(0, 0, 23, 23);
    [addNewButton setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    [addNewButton setClipsToBounds:YES];
    addNewButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [addNewButton addTarget:self action:@selector(addNewPost:) forControlEvents:UIControlEventTouchUpInside];
    addNew = [[UIBarButtonItem alloc] initWithCustomView:addNewButton];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Configure TableView
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = TABLEVIEW2_COLOR;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newPostAdded:)
                                                 name:NEW_POST_NOTIFICATION
                                               object:nil];
    
    // Start location updates
    [self.locationManager startUpdatingLocation];
    
    // Cache any current location info
    CLLocation *currentLocation = self.locationManager.location;
    if (currentLocation) {
        self.currentLocation = currentLocation;
    }
    
    
    //Add Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                        action:@selector(refresh:)
              forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    
    //Table header
    [self tableHeader];
    
    //Check if Intro View has to be shown
    [self showIntroView];
    
    //Add Loading View
    spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes color:BAR_TINT_COLOR2];
    spinner.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, (CGRectGetHeight(self.view.frame) / 2) - 40);
    [spinner startAnimating];
    [self.view addSubview:spinner];
    
    
    //If app is in production mode, initialize Ad
    if ([Config appMode] == PRODUCTION)
    {
        // Initialize the Avocarrot SDK and start loading an ad
        AvocarrotInstream *myAd = [[AvocarrotInstream alloc] initWithController:self minHeightForRow:100.0f tableView:self.tableView];
        [myAd setApiKey: AVOCARROT_API_KEY];
        [myAd setSandbox:YES];
        [myAd setDelegate:self];
        [myAd setLogger:YES withLevel:@"ALL"];
        [myAd setFrequency:5 startPosition:3];
        
        // Show ad
        [myAd loadAdForPlacement: @"7ba813875be128917a7afe4f9550b23f1523fba2"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
    showAlert = YES;
    
    self.navigationController.navigationBar.barStyle = BAR_STYLE;
    self.navigationController.navigationBar.barTintColor = BAR_TINT_COLOR2;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (tooltip != nil)
        [tooltip hideAnimated:YES];
}


- (void)tableHeader
{
    tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10.0f)];
    tableHeader.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeader;
    
    //Hack for Tooltip
    toolTipLocation = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 90, 0)];
    toolTipLocation.backgroundColor = [UIColor redColor];
    [tableHeader addSubview:toolTipLocation];
    
    
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10.0f)];
    tableFooter.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = tableFooter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [shared.allPosts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject = shared.allPosts[indexPath.row];
    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    PFObject *parseObject = postObject[@"parseObject"];

    DITableViewCell *cell;
    
    //Check the type in other to know which type of cell to display
    PostCellType type = [Config cellType];
    
    if (type == TIMELINE)
    {
        NSString *cellIdentifier = [NSString stringWithFormat:@"TimelineCell%@",parseObject.objectId];
        TimelineTableViewCell *_cell = (TimelineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!_cell)
            _cell = [[TimelineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        _cell = [self setTimelineCellFrames:_cell withPostObject:postObject forIndex:indexPath.row];
        
        cell = _cell;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }else if (type == COLOURED){
        /*
        if ([Config isPostAuthor:postObject])
        {*/
            NSString *cellIdentifier = [NSString stringWithFormat:@"ColouredCell%@",parseObject.objectId];
            ColouredTableViewCell *_cell = (ColouredTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!_cell)
                _cell = [[ColouredTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell = _cell;
            /*
            
        }else{
            NSString *cellIdentifier = [NSString stringWithFormat:@"ProfileCell%@",parseObject.objectId];
            ProfileTableViewCell *_cell = (ProfileTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!_cell)
                _cell = [[ProfileTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            
            cell = _cell;
        }
        */
        [cell setFrameWithObject:postObject forIndex:indexPath.row];
        
        if (indexPath.row != ([shared.allPosts count] - 1))
            cell.bottomBorder.frame = CGRectMake(0, CGRectGetHeight(cell.mainContainer.frame) - 0.5f, CGRectGetWidth(cell.mainContainer.frame), .5f);
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
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

- (PostTextTableViewCell *)setListCellFrames:(PostTextTableViewCell *)_cell withPostObject:(NSDictionary *)postObject
{
    //Set Frames
    NSDictionary *subViewframes = [Config subViewFrames:postObject];
    
    _cell.postText.frame = [subViewframes[@"postTextFrame"] CGRectValue];
    _cell.postImage.frame = [subViewframes[@"imageFrame"] CGRectValue];
    _cell.actionsView.frame = [subViewframes[@"actionViewframe"] CGRectValue];
    
    return _cell;
}

- (TimelineTableViewCell *)setTimelineCellFrames:(TimelineTableViewCell *)_cell withPostObject:(NSDictionary *)postObject forIndex:(NSInteger)index
{
    //Set Frames
    NSDictionary *subViewframes = [Config subViewFrames2:postObject];
    _cell.line.frame = [subViewframes[@"lineFrame"] CGRectValue];
    _cell.lineBorder.frame = [subViewframes[@"lineBorderFrame"] CGRectValue];
    _cell.bubble.frame = [subViewframes[@"bubbleFrame"] CGRectValue];
    _cell.triangle.frame = [subViewframes[@"triangleFrame"] CGRectValue];
    
    _cell.mainContainer.frame = [subViewframes[@"containerFrame"] CGRectValue];
    _cell.postText.frame = [subViewframes[@"postTextFrame"] CGRectValue];
    _cell.postImage.frame = [subViewframes[@"imageFrame"] CGRectValue];
    _cell.actionsView.frame = [subViewframes[@"actionViewframe"] CGRectValue];
    
    //UIColor *rColor = [Config getBubbleColor];
    //_cell.bubble.layer.borderColor = rColor.CGColor;
    _cell.bubble.layer.borderColor = [Config getSideColor:index].CGColor;
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject = shared.allPosts[indexPath.row];
    NSString *postText = postObject[@"text"];
    
    CGFloat postTextHeight = [Config calculateHeightForText:postText withWidth:WIDTH - 55.0f withFont:TEXT_FONT];
    
    CGFloat height = 0;
    
    if ([Config cellType] == TIMELINE){
        
        height = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 5;
        
        if (postObject[@"parseObject"][@"pic"])
            height += 10 + IMAGEVIEW_HEIGHT;
    }else if ([Config cellType] == COLOURED){
        
       // if ([Config isPostAuthor:postObject])
     //   {
             height = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 3;
            
            if (postObject[@"parseObject"][@"pic"])
                height += 10 + IMAGEVIEW_HEIGHT;
       // }else{
         //   height = [Config calculateCellHeight:postObject];
      //  }
    }

    return height;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Post To Display";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"No post has been added to this location.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIImage imageNamed:@"Empty"];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    
    return [UIColor whiteColor];
}

#pragma mark - View Transitions

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentsTableViewController *viewPost = [[CommentsTableViewController alloc] initWithNibName:nil bundle:nil];
    viewPost.postObject = shared.allPosts[indexPath.row];
    viewPost.view.tag = indexPath.row;
    [self.navigationController pushViewController:viewPost animated:YES];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)index
{
    NSString *title = [actionSheet buttonTitleAtIndex:index];
    PostCellType mode;
    /*
    if ([title isEqualToString:@"List"])  mode = LIST;
    else
    */
    if ([title isEqualToString:@"Timeline"])  mode = TIMELINE;
    else if ([title isEqualToString:@"List"]) mode = COLOURED;
    
    if ([Config setCellType:mode]) {
        
        if ([title isEqualToString:@"List"])  self.tableView.tableHeaderView = nil;
        else [self tableHeader];
        
        [self.tableView reloadData];
    }
}

- (void)addNewPost:(UIBarButtonItem *)sender
{
    AddPostViewController *addNewPost = [[AddPostViewController alloc] initWithNibName:nil bundle:nil];
    addNewPost.dataSource = self;
    
    UINavigationController *addNC = [[UINavigationController alloc] initWithRootViewController:addNewPost];
   // self.homeNavigationController.navigationBar.barStyle = BAR_STYLE;
    addNC.navigationBar.barTintColor = [UIColor whiteColor];
    addNC.navigationBar.tintColor = BAR_TINT_COLOR2;
    addNC.navigationBar.translucent = NO;
    
    
    CCMPopupTransitioning *popup = [CCMPopupTransitioning sharedInstance];
    popup.destinationBounds = [[UIScreen mainScreen] bounds];
    popup.presentedController = addNC;
    
    popup.backgroundViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    popup.backgroundViewAlpha = 3.0f;
    popup.presentingController = self;
    
    [self presentViewController:addNC animated:YES completion:nil];
}

/*
- (void)viewProfile:(UIButton *)sender
{
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)viewMap:(UIButton *)sender
{
    MapViewController *mapView = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    mapView.dataSource = self;
    mapView.delegate = self;
    [self.navigationController presentViewController:mapView animated:YES completion:nil];
}
*/

#pragma mark - Location Manager

- (CLLocationManager *)locationManager
{
    if (_locationManager == nil)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }

    }
    return _locationManager;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    self.currentLocation = newLocation;
}

- (void)setCurrentLocation:(CLLocation *)currentLocation
{
    if (self.currentLocation == currentLocation) {
        return;
    }
    
    _currentLocation = currentLocation;
    
    [self queryForAllPostsNearLocation];
    
    
    //If app is not in testing mode, take the current location into consideration
    if ([Config appMode] != TESTING)
    {
        if ([Config checkAddPermission:_currentLocation] == YES)
        {
            self.navigationItem.rightBarButtonItem = addNew;
        }else{
            self.navigationItem.rightBarButtonItem = nil;
        }
    }else{
        self.navigationItem.rightBarButtonItem = addNew;
    }
}

- (CLLocation *)getUserCurrentLocation
{
    return self.currentLocation;
}

- (NSMutableArray *)getAllPosts
{
    return shared.allPosts;
}

- (void)newPostAdded:(NSNotification *)notification
{
    NSDictionary * info = notification.userInfo;
    PFObject *newObject = [info objectForKey:@"newObject"];
    
    //1 - Add New Post Array to the first position of the array
    [shared.allPosts insertObject:[Config createPostObject:newObject] atIndex:0];
    
    [self.tableView reloadData];
    
    [self queryForAllPostsNearLocation];
}


- (void)updateNavBar
{
    NSString *college = [Config college];
    
    if ([college isEqualToString:ALL_COLLEGES]
        || college == nil)
    {
        layoutLabel.text = @"DropIt";
        layoutLabel.font = [UIFont fontWithName:@"Belshaw" size:27.0f];
    }else{
        layoutLabel.text = [Config college];
        layoutLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
    }
    
    if ([Config checkAddPermission:_currentLocation] == YES)
    {
        self.navigationItem.rightBarButtonItem = addNew;
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)switchCollege
{
    [self updateNavBar];
    
    shared.allPosts = nil;
    [self.tableView reloadData];
    
    //Add Loading View
    [spinner startAnimating];
    
    [self queryForAllPostsNearLocation];
}



//Methods

- (void)queryForAllPostsNearLocation
{
    //NSLog(@"%@",[NSDate date]);
    
    dispatch_queue_t postsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(postsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query orderByDescending:@"createdAt"];
            
            //If app is not in testing mode, take the current location into consideration
            if ([Config appMode] != TESTING)
            {
                //If the current default college is not all, take the college name into consideration
                if (![[Config college] isEqualToString:ALL_COLLEGES])
                {
                    [query whereKey:@"college" containsString:[Config college]];
                }else{
                    /*
                    if (self.currentLocation != nil)
                    {
                        // Query for posts sort of kind of near users current location.
                        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:_currentLocation.coordinate.latitude
                                                                   longitude:_currentLocation.coordinate.longitude];
                        
                        [query whereKey:@"location" nearGeoPoint:point withinKilometers:ONE_HALF_MILE_RADIUS_KM];
                    }else{
                        NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
                    }
                    */
                }
                
            }
            
            //[query whereKey:@"objectId" equalTo:@"vc4OtBkcUN"];
            query.limit = 20;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    //[self filterPost:objects];
                    
                    [self setEmptyDatasetDelegate];
                    NSMutableArray *filteredPost = [Config filterPosts:objects];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        shared.allPosts = filteredPost;
                        [spinner stopAnimating];
                        [self.tableView reloadData];
                        
                    });
                }
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner stopAnimating];
                if (showAlert == YES)
                {
                    [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
                    showAlert = NO;
                }
            });
        }
    });
}

- (void)filterPost:(NSArray *)newPost
{
    NSMutableArray *newPosts = [[NSMutableArray alloc] init];
    
    for (PFObject *post in newPost)
    {
        //if the user has not reported this message or this message has less than 5 reports
        if (![Config getReportStatus:post])
        {
            [newPosts addObject:[Config createPostObject:post]];
        }
    }
    
    
    /*
    // 1. Any post in the new result that is not in the allpost array is moved to new posts array
    NSMutableArray *newPosts = [[NSMutableArray alloc] init];
    
    for (PFObject *post in newPost)
    {
        if (![_allPosts containsObject:post])
            [newPosts addObject:post];
    }
    // newPosts now contains our new objects.
    
    // 2. Any post in the allpost that is not in the new result is moved to remove posts array
    NSMutableArray *postsToRemove = [[NSMutableArray alloc] init];
    
    for (PFObject *currentPost in _allPosts)
    {
        if (![newPosts containsObject:currentPost]) {
            [postsToRemove addObject:currentPost];
        }
    }
    // postsToRemove has objects that didn't come in with our new results.
    
    //3. Then update by adding all the new post and then removing the irrelevant posts
    [_allPosts addObjectsFromArray:newPosts];
    [_allPosts removeObjectsInArray:postsToRemove];
    */
    [self.tableView reloadData];
    
}

- (void)likePost:(UIButton *)sender
{
    //change its state
    sender.selected = [shared likePostAtIndex:sender.tag updateArray:YES];
}

- (void)deletePost:(NSInteger)tag
{
    NSDictionary *postObject = shared.allPosts[tag];
    
    //get the Parse Object
    PFObject *parseObject = postObject[@"parseObject"];
    [parseObject deleteInBackground];
    
    [shared.allPosts removeObjectAtIndex:tag];
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if([title isEqualToString:@"Dislike"]) {

        [_cellToDelete swipeToOriginWithCompletion:^{
            
            [shared dislikePostAtIndex:_cellToDelete.tag updateArray:YES];
            
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
        [shared reportPostAtIndex:_cellToDelete.tag updateArray:YES];
        
        //Remove the cell
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
        
        _cellToDelete = nil;
        
    }else if([title isEqualToString:@"Yes"]) {
        
        [shared deletePost:shared.allPosts[_cellToDelete.tag]];
        [shared.allPosts removeObjectAtIndex:_cellToDelete.tag];
        
        //Remove the cell
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
        
        _cellToDelete = nil;
        
    }else{
        [_cellToDelete swipeToOriginWithCompletion:^{
        }];
        
        _cellToDelete = nil;
    }
}

#pragma mark - ViewPostViewControllerDelegate

-(void)refresh:(UIRefreshControl *)refresh
{
    [refresh endRefreshing];
    
    [self queryForAllPostsNearLocation];
}

- (void)showIntroView
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"intro_screen_viewed"])
    {
        introView = [[ABCIntroView alloc]initWithNibName:nil bundle:nil];
        introView.delegate = self;
        introView.datasource = self;
        introView.buttonText = @"Okay, I Got It!";
        
        CCMPopupTransitioning *popup = [CCMPopupTransitioning sharedInstance];
        popup.destinationBounds = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) + 20);
        popup.presentedController = introView;
        popup.presentingController = self;
        
        [self presentViewController:introView animated:YES completion:nil];
        
        tooltip = [[JDFTooltipView alloc] initWithTargetView:toolTipLocation hostView:self.view tooltipText:@"Tap The Title Label To Change Post Layout." arrowDirection:JDFTooltipViewArrowDirectionUp width:180.0f];
        tooltip.dismissOnTouch = YES;
        tooltip.tooltipBackgroundColour = [UIColor colorWithRed: 0.89 green: 0.6 blue: 0 alpha: 1];
        tooltip.textColour = [UIColor whiteColor];
        tooltip.font= [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5f];
        
        [tooltip show];
    }
}

-(void)onDoneButtonPressed{
    
    //Uncomment so that the IntroView does not show after the user clicks "DONE"
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"YES"forKey:@"intro_screen_viewed"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSDictionary *)detailsForIndex:(NSInteger)index
{
    return [Config introsInfo][index];
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

- (void)setEmptyDatasetDelegate
{
    //Empty dataset
    if (self.tableView.emptyDataSetSource == nil)
        self.tableView.emptyDataSetSource = self;
    
    if (self.tableView.emptyDataSetDelegate == nil)
        self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    //self.tableView.tableFooterView = [UIView new];
    
}


- (BOOL)prefersStatusBarHidden
{
    return NO;
}


#pragma mark - AVInstreamAdDelegate

/**
 * Sent when an ad is not available along with the reason why.
 *
 * @param reason The reason why an ad was not returned.
 */
- (void)adDidNotLoad:(NSString *)reason
{
    //Log failure in parse
    //Create Parse Object
    PFObject *adObject = [PFObject objectWithClassName:ADS_CLASS_NAME];
    adObject[@"type"] = @"unavailable";
    adObject[@"reason"] = reason;
}

/**
 * Sent when an ad is loaded.
*/
- (void)adDidLoad
{
    //Log load in parse
    //Create Parse Object
    PFObject *adObject = [PFObject objectWithClassName:ADS_CLASS_NAME];
    adObject[@"type"] = @"loaded";
    
    [self logAdEvent:adObject];
}

/**
 * Sent when a error occurs while loading an ad.
 *
 * @param error The error.
 */
- (void)adDidFailToLoad:(NSError *)error
{
    //Log failure in parse
    //Create Parse Object
    PFObject *adObject = [PFObject objectWithClassName:ADS_CLASS_NAME];
    adObject[@"type"] = @"failed";
    adObject[@"error"] = [error description];
    
    [self logAdEvent:adObject];
}

/**
 * Sent immediately before the user will leave the app because of a ad click. Use this to
 * pause or save the app state before the user leaves the app.
 */
-(void)userWillLeaveApp
{
    //Log click in parse
    //Create Parse Object
    PFObject *adObject = [PFObject objectWithClassName:ADS_CLASS_NAME];
    adObject[@"type"] = @"click";
    
    [self logAdEvent:adObject];
}


- (void)logAdEvent:(PFObject *)adObject
{
    //Log click in parse
    dispatch_queue_t adsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(adsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            //Get Users Current Location
            CLLocation *currentLocation = [self getUserCurrentLocation];
            
            //Create Parse Object
            adObject[@"deviceId"] = [Config deviceId];
            adObject[@"college"] = [Config getClosestLocation:currentLocation];
            
            if (currentLocation != nil)
            {
                CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
                PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                                  longitude:currentCoordinate.longitude];
                adObject[@"location"] = currentPoint;
            }
            
            // Use PFACL to restrict future modifications to this object.
            PFACL *readOnlyACL = [PFACL ACL];
            [readOnlyACL setPublicReadAccess:YES];
            [readOnlyACL setPublicWriteAccess:NO];
            adObject.ACL = readOnlyACL;
            
            [adObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"Couldn't save!");
                    return;
                }
                if (succeeded) {
                    NSLog(@"Successfully saved!");
                } else {
                    NSLog(@"Failed to save.");
                }
            }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    });
}

@end
