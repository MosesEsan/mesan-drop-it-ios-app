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

#import "PostTextTableViewCell.h"
#import "TimelineTableViewCell.h"

#import "AddPostViewController.h"
#import "ViewPostTableViewController.h"
#import "ProfileViewController.h"

#import "UIFont+Montserrat.h"
#import "CCMBorderView.h"
#import "CCMPopupTransitioning.h"
#import "ABCIntroView.h"
//#import "FBShimmeringView.h"

#import "FullScreenViewController.h"
#import "MapViewController.h"
#import "MHFacebookImageViewer.h"
#import "RTSpinKitView.h"
#import "UIScrollView+EmptyDataSet.h"

//Ad
#import <AvocarrotSDK/AvocarrotInstream.h>



@interface HomeTableViewController ()<AddPostViewControllerDataSource, ViewPostViewControllerDelegate, MapViewControllerDataSource, MapViewControllerDelegate, CLLocationManagerDelegate, ABCIntroViewDelegate, ABCIntroViewDatasource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, AVInstreamAdDelegate>
{
    //FBShimmeringView *shimmeringView;
    UIButton *profile;
    UIButton *mapButton;
    UIButton *addNew;
    UIBarButtonItem *negativeSpacer;
    
    ProfileViewController *profileViewController;
    
    ABCIntroView *introView;
    RTSpinKitView *spinner;
    
    BOOL showAlert;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;


@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *likes;

@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;


@end

@implementation HomeTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    _allPosts = [[NSMutableArray alloc] init];
    _likes = [[NSMutableArray alloc] init];
    showAlert = NO;
    
    //TitleView
    //shimmeringView = [[FBShimmeringView alloc] initWithFrame:CGRectMake(0, 2, 90, 37)];
    //[self.view addSubview:shimmeringView];
    
    UILabel *layoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 90, 37)];
    layoutLabel.textAlignment = NSTextAlignmentLeft;//NSTextAlignmentCenter;
    layoutLabel.text = @"DropIt";
    layoutLabel.textColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    //layoutLabel.font =  [UIFont systemFontOfSize:21];
    layoutLabel.font = [UIFont montserratFontOfSize:20.0f];
    layoutLabel.backgroundColor = [UIColor clearColor];
    layoutLabel.textColor = [UIColor whiteColor];
    //layoutLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    
    //shimmeringView.contentView = layoutLabel;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:layoutLabel];
    //self.navigationItem.titleView = layoutLabel;

    
    //Profile and New
    profile = [UIButton buttonWithType:UIButtonTypeCustom];
    profile.frame = CGRectMake(0, 0, 23, 23);
    [profile setImage:[UIImage imageNamed:@"User"] forState:UIControlStateNormal];
    [profile setClipsToBounds:YES];
    profile.imageView.contentMode = UIViewContentModeScaleAspectFill;
    profile.imageEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [profile addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
    
    mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mapButton.frame = CGRectMake(0, 0, 23, 23);
    [mapButton setImage:[UIImage imageNamed:@"Map"] forState:UIControlStateNormal];
    [mapButton setClipsToBounds:YES];
    mapButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    mapButton.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    [mapButton addTarget:self action:@selector(viewMap:) forControlEvents:UIControlEventTouchUpInside];
    
    addNew = [UIButton buttonWithType:UIButtonTypeCustom];
    addNew.frame = CGRectMake(0, 0, 23, 23);
    [addNew setImage:[UIImage imageNamed:@"Add"] forState:UIControlStateNormal];
    [addNew setClipsToBounds:YES];
    addNew.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [addNew addTarget:self action:@selector(addNewPost:) forControlEvents:UIControlEventTouchUpInside];
    
    negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = 14;
    
    self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:profile],
                                                negativeSpacer,
                                                [[UIBarButtonItem alloc] initWithCustomView:mapButton]
                                                ];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Configure TableView
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = TABLEVIEW2_COLOR;

    //[self.tableView registerClass:[PostTextTableViewCell class] forCellReuseIdentifier:@"BoxCell"];
    [self.tableView registerClass:[TimelineTableViewCell class] forCellReuseIdentifier:@"BoxCell"];
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
    
    //Initialize profile Table View Controller
    profileViewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
    
    //Add Refresh Control
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self
                        action:@selector(refresh:)
              forControlEvents:UIControlEventValueChanged];
    
    [self.tableView addSubview:refreshControl];
    
    //Check if Intro View has to be shown
    [self showIntroView];
    
    //Table header
    [self tableHeader];
    
    //Add Loading View
    spinner = [[RTSpinKitView alloc] initWithStyle:RTSpinKitViewStyleWanderingCubes color:BAR_TINT_COLOR2];
    spinner.center = CGPointMake(CGRectGetWidth(self.view.frame) / 2, (CGRectGetHeight(self.view.frame) / 2) - 40);
    //spinner.backgroundColor = [UIColor clearColor];
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
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Start shimmering.
    //shimmeringView.shimmering = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)tableHeader
{
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10.0f)];
    tableHeader.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeader;
    
    UIView *_line = [[UIView alloc] initWithFrame:CGRectMake(7.5f, 0, 33, CGRectGetHeight(tableHeader.frame))];
    _line.backgroundColor = [UIColor clearColor];
    //[tableHeader addSubview:_line];
    
    CALayer *_lineBorder = [CALayer layer];
    _lineBorder.frame = CGRectMake(LEFT_PADDING - 1, CGRectGetHeight(tableHeader.frame) / 2, 2.0, CGRectGetHeight(tableHeader.frame) / 2);
    _lineBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;
    [_line.layer addSublayer:_lineBorder];
    
    CGFloat y = (CGRectGetHeight(tableHeader.frame) / 2) - (13/2);
    
    UIView *_bubble = [[UIView alloc] initWithFrame:CGRectMake((33/2) - (13/2), y, 13, 13)];
    _bubble.clipsToBounds = YES;
    _bubble.layer.cornerRadius = _bubble.frame.size.width / 2;
    //_bubble.layer.borderWidth = 4.0f;
    _bubble.backgroundColor = [Config getBubbleColor];
    _bubble.layer.masksToBounds = YES;
    _bubble.layer.borderColor = [UIColor whiteColor].CGColor;
    [_line addSubview:_bubble];
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
    PFObject *parseObject = postObject[@"parseObject"];
    NSString *cellIdentifier = [NSString stringWithFormat:@"BoxCell%@",parseObject.objectId];

    
    //Check the type in other to know which type of cell to display
    PostCellType type = [Config cellType];
    
    TimelineTableViewCell *_cell = (TimelineTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell)
        _cell = [[TimelineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    _cell.selectionStyle= UITableViewCellSelectionStyleNone;
    
    // Configure the cell...
    _cell.postText.text = postText;
    _cell.date.text = postDate;
    _cell.comments.text = [Config repliesCount:repliesCount];
    [_cell.smiley setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
    
    //Set Frames
    NSDictionary *subViewframes = [Config subViewFrames2:postObject];
    _cell.line.frame = [subViewframes[@"lineFrame"] CGRectValue];
    _cell.lineBorder.frame = [subViewframes[@"lineBorderFrame"] CGRectValue];
    _cell.bubble.frame = [subViewframes[@"bubbleFrame"] CGRectValue];
    _cell.triangle.frame = [subViewframes[@"triangleFrame"] CGRectValue];

    _cell.postContainer.frame = [subViewframes[@"containerFrame"] CGRectValue];
    _cell.postText.frame = [subViewframes[@"postTextFrame"] CGRectValue];
    _cell.postImage.frame = [subViewframes[@"imageFrame"] CGRectValue];
    _cell.actionsView.frame = [subViewframes[@"actionViewframe"] CGRectValue];
    
    UIColor *rColor = [Config getBubbleColor];
    _cell.bubble.layer.borderColor = rColor.CGColor;
    /*
    _cell.bubble.layer.borderWidth = 0;
    _cell.bubble.image = [UIImage imageNamed:[Config fruits]];
     */
    
    
    if (parseObject[@"pic"])
    {
        _cell.postImage.file = parseObject[@"pic"];
        _cell.postImage.tag = 1;//indexPath.row;
        [_cell.postImage loadInBackground];
        [_cell.postImage setupImageViewerWithPFFile:_cell.postImage.file onOpen:nil onClose:nil];
    }
    
    if (![postObject[@"disliked"] boolValue]){
        _cell.smiley.selected = [postObject[@"liked"] boolValue];
    }else{
        _cell.smiley.selected = NO;
        _cell.smiley.highlighted = [postObject[@"disliked"] boolValue];
    }
    
    _cell.tag = indexPath.row;
    
    //If the user is not the post authour
    //They can like, dislike and report the post
    if (![Config isPostAuthor:postObject])
    {
        _cell.smiley.tag = indexPath.row;
        [_cell.smiley addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(_cell) weakSelf = _cell;
        
        [_cell setSwipeGestureWithView:[self viewWithImageName:@"cross"]
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
    }
    
    _cell.bottomBorder.backgroundColor = [tableView separatorColor].CGColor;
    
    
    return _cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *postObject = _allPosts[indexPath.row];
    NSString *postText = postObject[@"text"];
    
    CGFloat postTextHeight = [Config calculateHeightForText:postText withWidth:WIDTH - 55.5f withFont:TEXT_FONT];
    
    if (postObject[@"parseObject"][@"pic"])
    {
        return TOP_PADDING + postTextHeight + 10 + IMAGEVIEW_HEIGHT + 12 + ACTIONS_VIEW_HEIGHT + 8;
    }else{
        return TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 8;
    }
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
    ViewPostTableViewController *viewPost = [[ViewPostTableViewController alloc] initWithNibName:nil bundle:nil];
    viewPost.postObject = _allPosts[indexPath.row];
    viewPost.delegate = self;
    viewPost.view.tag = indexPath.row;
    [self.navigationController pushViewController:viewPost animated:YES];
}

- (void)addNewPost:(UIBarButtonItem *)sender
{
    AddPostViewController *addNewPost = [[AddPostViewController alloc] initWithNibName:nil bundle:nil];
    
    addNewPost.dataSource = self;
    
    CCMPopupTransitioning *popup = [CCMPopupTransitioning sharedInstance];
    popup.destinationBounds = [[UIScreen mainScreen] bounds];
    popup.presentedController = addNewPost;
    
    popup.backgroundViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    popup.backgroundViewAlpha = 3.0f;
    popup.presentingController = self;
    
    [self presentViewController:addNewPost animated:YES completion:nil];
}

- (void)viewProfile:(UIButton *)sender
{
    [self.navigationController pushViewController:profileViewController animated:YES];
}

- (void)viewMap:(UIButton *)sender
{
    MapViewController *mapView = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    mapView.dataSource = self;
    mapView.delegate = self;
    /*
    UINavigationController *mapNavController = [[UINavigationController alloc] initWithRootViewController:mapView];
    mapNavController.navigationBar.barStyle = BAR_STYLE;
    mapNavController.navigationBar.barTintColor = BAR_TINT_COLOR2;
    mapNavController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    mapNavController.navigationBar.translucent = NO;
    */
    
    [self.navigationController presentViewController:mapView animated:YES completion:nil];
}

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
    
    if ([Config checkAddPermission:_currentLocation] == YES)
    {
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:profile],
                                                    negativeSpacer,
                                                    [[UIBarButtonItem alloc] initWithCustomView:mapButton],
                                                    negativeSpacer,
                                                    [[UIBarButtonItem alloc] initWithCustomView:addNew]
                                                    ];
    }else{
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:profile],
                                                    negativeSpacer,
                                                    [[UIBarButtonItem alloc] initWithCustomView:mapButton]
                                                    ];
    }
}

- (CLLocation *)getUserCurrentLocation
{
    return self.currentLocation;
}

- (NSMutableArray *)getAllPosts
{
    return self.allPosts;
}

- (void)newPostAdded:(NSNotification *)notification
{
    NSDictionary * info = notification.userInfo;
    PFObject *newObject = [info objectForKey:@"newObject"];
    
    //1 - Add New Post Array to the first position of the array
    [_allPosts insertObject:[Config createPostObject:newObject] atIndex:0];
    
    [self.tableView reloadData];
    
    [self queryForAllPostsNearLocation];
}

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
                if (self.currentLocation == nil) {
                    NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
                }
                
                // Query for posts sort of kind of near users current location.
                PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:_currentLocation.coordinate.latitude
                                                           longitude:_currentLocation.coordinate.longitude];
                
                [query whereKey:@"location" nearGeoPoint:point withinKilometers:ONE_HALF_MILE_RADIUS_KM];
                
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
                        _allPosts = filteredPost;
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
    NSDictionary *postObject = _allPosts[sender.tag];
    
    BOOL selected = [postObject[@"liked"] boolValue];
    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    
    //change its state
    sender.selected = !selected;
    
    [postObject setValue:[NSNumber numberWithBool:!selected] forKey:@"liked"];
    [postObject setValue:[NSNumber numberWithBool:NO] forKey:@"disliked"];
    
    //get the Parse Object
    PFObject *parseObject = postObject[@"parseObject"];
    if (selected == NO)
    {
        //increment number
        likesCount++;
        
        //Like Post
        [parseObject addUniqueObject:[Config deviceId] forKey:@"likes"];
        [parseObject removeObject:[Config deviceId] forKey:@"dislikes"];
        
        parseObject[@"type"] = LIKE_POST_TYPE;

        
    }else if (selected == YES){
        //decrement number
        likesCount--;
        
        //Unlike Post
        [parseObject removeObject:[Config deviceId] forKey:@"likes"];
    }
    
    [postObject setValue:[NSNumber numberWithInteger:likesCount] forKey:@"totalLikes"];
    
    /*
    //set sender value;
    
    if (likesCount > 0)
        [sender setTitle:[NSString stringWithFormat:@"%ld",(long)likesCount] forState:UIControlStateNormal];
    else
        [sender setTitle:[NSString stringWithFormat:@""] forState:UIControlStateNormal];
    */
    
    [self updateAllPostsArray:sender.tag withPostObject:postObject];
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            sender.selected = selected; //return it to its previous state
         /****attn*/
    }];
}

- (void)dislikePost:(NSInteger)tag
{
    NSDictionary *postObject = _allPosts[tag];
    
    BOOL highlighted = [postObject[@"disliked"] boolValue];
    
    [postObject setValue:[NSNumber numberWithBool:!highlighted] forKey:@"disliked"];
    
    //get the Parse Object
    PFObject *parseObject = postObject[@"parseObject"];
    if (highlighted == NO)
    {
        //Dislike Post
        [parseObject addUniqueObject:[Config deviceId] forKey:@"dislikes"];
        [parseObject removeObject:[Config deviceId] forKey:@"likes"];
        
        parseObject[@"type"] = DISLIKE_POST_TYPE;
        
        //If user had previously liked this photo
        //decrement the likes numn=ber
        BOOL liked = [postObject[@"liked"] boolValue];
        if(liked == YES)
        {
            //decrement number
            NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
            likesCount--;
            [postObject setValue:[NSNumber numberWithInteger:likesCount] forKey:@"totalLikes"];
            //attn set sender value
        }
        
        [postObject setValue:[NSNumber numberWithBool:NO] forKey:@"liked"];
    }
    
    [self updateAllPostsArray:tag withPostObject:postObject];
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            NSLog(@"Notdisliked");
        /****attn*/
    }];
}

- (void)reportPost:(NSInteger)tag
{
    NSDictionary *postObject = _allPosts[tag];
    
    //get the Parse Object and Report Post
    PFObject *parseObject = postObject[@"parseObject"];
    [parseObject addUniqueObject:[Config deviceId] forKey:@"reports"];
    
    parseObject[@"type"] = REPORT_POST_TYPE;

    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            NSLog(@"NotReported");
        /****attn*/
    }];
    
    [_allPosts removeObjectAtIndex:tag];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if([title isEqualToString:@"Dislike"]) {

        [_cellToDelete swipeToOriginWithCompletion:^{
            [self dislikePost:_cellToDelete.tag];
            _cellToDelete = nil;
        }];
        
    }else if([title isEqualToString:@"Report"]) {
        
        [self reportPost:_cellToDelete.tag];
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [_cellToDelete swipeToOriginWithCompletion:^{
        }];
        
        _cellToDelete = nil;
    }
}

#pragma mark - ViewPostViewControllerDelegate

- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject
{
    _allPosts[index] = postObject;
    
    [self.tableView reloadData];
}

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


- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.backgroundColor = [UIColor clearColor];
    
    return imageView;
}

- (void)showFullScreen:(UITapGestureRecognizer *)gesture
{
    NSInteger tag = gesture.view.tag;
    NSDictionary *postObject = _allPosts[tag];
    PFFile *file = postObject[@"parseObject"][@"pic"];
    
    FullScreenViewController *fullScreen = [[FullScreenViewController alloc] initWithFile:file];
    
    CCMPopupTransitioning *popup = [CCMPopupTransitioning sharedInstance];
    popup.destinationBounds = [[UIScreen mainScreen] bounds];
    //popup.backgroundViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    popup.presentedController = fullScreen;
    popup.presentingController = self;
    
    [self presentViewController:fullScreen animated:YES completion:nil];
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
