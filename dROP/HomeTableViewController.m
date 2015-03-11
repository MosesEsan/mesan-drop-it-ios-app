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

@interface HomeTableViewController ()<AddPostViewControllerDataSource, ViewPostViewControllerDelegate, CLLocationManagerDelegate, ABCIntroViewDelegate, ABCIntroViewDatasource>
{
    NSMutableArray *availableLocations;
    UIButton *addNew;
    
    ProfileViewController *profileViewController;
    
    ABCIntroView *introView;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;


@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, strong) NSMutableArray *likes;

@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;


@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _allPosts = [[NSMutableArray alloc] init];
    _likes = [[NSMutableArray alloc] init];
    
    
    UIButton *profile = [UIButton buttonWithType:UIButtonTypeCustom];
    profile.frame = CGRectMake(0, 0, 24, 24);
    [profile setImage:[UIImage imageNamed:@"User-Small.png"] forState:UIControlStateNormal];
    [profile setClipsToBounds:YES];
    profile.imageView.contentMode = UIViewContentModeScaleAspectFill;
    profile.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    [profile addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:profile];
    
    //TitleView
    UILabel *layoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 60, 37)];
    layoutLabel.textAlignment = NSTextAlignmentCenter;
    layoutLabel.text = @"dropit";
    layoutLabel.textColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    //layoutLabel.font =  [UIFont systemFontOfSize:21];
    layoutLabel.font = [UIFont montserratFontOfSize:20.0f];
    self.navigationItem.titleView = layoutLabel;
    
    addNew = [UIButton buttonWithType:UIButtonTypeCustom];
    addNew.frame = CGRectMake(0, 0, 24, 24);
    [addNew setImage:[UIImage imageNamed:@"Add2-Small.png"] forState:UIControlStateNormal];
    [addNew setClipsToBounds:YES];
    addNew.imageView.contentMode = UIViewContentModeScaleAspectFill;
    ///addNew.imageEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    [addNew addTarget:self action:@selector(addNewPost:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //Configure TableView
    self.tableView.backgroundColor = [UIColor whiteColor];
    //[self.tableView registerClass:[PostTextTableViewCell class] forCellReuseIdentifier:@"BoxCell"];
    [self.tableView registerClass:[TimelineTableViewCell class] forCellReuseIdentifier:@"BoxCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if(availableLocations == nil) availableLocations = [Config availableLocations];
    
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
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
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
    /*
    PostTextTableViewCell *_cell = (PostTextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!_cell)
        _cell = [[PostTextTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    _cell.selectionStyle= UITableViewCellSelectionStyleNone;
    */
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
    _cell.postText.frame = [subViewframes[@"postTextFrame"] CGRectValue];
    _cell.postImage.frame = [subViewframes[@"imageFrame"] CGRectValue];
    _cell.actionsView.frame = [subViewframes[@"actionViewframe"] CGRectValue];
    
    if (postObject[@"parseObject"][@"picture"])
    {
        _cell.postImage.file = postObject[@"parseObject"][@"picture"];
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
    
    //If the user is not the post authour
    //They can like, dislike and report the post
    if (![Config isPostAuthor:postObject])
    {
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
    
    CGFloat postTextHeight = [Config calculateHeightForText:postText withWidth:TEXT_WIDTH - (LEFT_PADDING * 2) withFont:TEXT_FONT];
    
    if (postObject[@"parseObject"][@"picture"])
    {
        return TOP_PADDING + postTextHeight + 10 + IMAGEVIEW_HEIGHT + 12 + ACTIONS_VIEW_HEIGHT;
    }else{
        return TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT;
    }
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
    popup.destinationBounds = CGRectMake(0, 0, ADD_POST_WIDTH, ADD_POST_HEIGHT);
    //popup.backgroundViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    popup.presentedController = addNewPost;
    popup.presentingController = self;
    
    
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addNewPost];
    //navigationController.navigationBarHidden = YES;
    
    [self presentViewController:addNewPost animated:YES completion:nil];
}

- (void)viewProfile:(UIButton *)sender
{
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma marlk - Location Manager

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
    
    [self queryForAllPostsNearLocation:self.currentLocation];
    
    if ([Config checkAddPermission:_currentLocation] == YES)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addNew];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (CLLocation *)getUserCurrentLocation
{
    return self.currentLocation;
}

- (void)newPostAdded:(NSNotification *)notification
{
    NSDictionary * info = notification.userInfo;
    PFObject *newObject = [info objectForKey:@"newObject"];
    
    //1 - Add New Post Array to the first position of the array
    [_allPosts insertObject:[Config createPostObject:newObject] atIndex:0];
    
    [self.tableView reloadData];
    
    [self queryForAllPostsNearLocation:self.currentLocation];
}

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation
{
    if ([Config checkInternetConnection])
    {
        dispatch_queue_t postsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(postsQueue, ^{
            

            PFQuery *query = [PFQuery queryWithClassName:POSTS_CLASS_NAME];
            [query orderByDescending:@"createdAt"];
            
            
            if (currentLocation == nil) {
                NSLog(@"%s got a nil location!", __PRETTY_FUNCTION__);
            }
            
            // Query for posts sort of kind of near our current location.
            PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                                                       longitude:currentLocation.coordinate.longitude];
            
            [query whereKey:@"location" nearGeoPoint:point withinKilometers:8];
            query.limit = 20;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    //[self filterPost:objects];
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

- (void)dislikePost
{
    NSDictionary *postObject = _allPosts[_cellToDelete.tag];
    
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
    
    [self updateAllPostsArray:_cellToDelete.tag withPostObject:postObject];
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            _cellToDelete.highlighted = highlighted; //return it to its previous state
        /****attn*/
    }];
}

- (void)reportPost
{
    NSDictionary *postObject = _allPosts[_cellToDelete.tag];
    
    //get the Parse Object and Report Post
    PFObject *parseObject = postObject[@"parseObject"];
    [parseObject addUniqueObject:[Config deviceId] forKey:@"reports"];
    
    parseObject[@"type"] = REPORT_POST_TYPE;

    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            NSLog(@"Reported");
        /****attn*/
    }];
    
    [_allPosts removeObjectAtIndex:_cellToDelete.tag];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if([title isEqualToString:@"Dislike"]) {

        [_cellToDelete swipeToOriginWithCompletion:^{
            [self dislikePost];
            _cellToDelete = nil;
        }];
        
    }else if([title isEqualToString:@"Report"]) {
        
        [self reportPost];
        [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
    }else{
        [_cellToDelete swipeToOriginWithCompletion:^{
        }];
        
        _cellToDelete = nil;
    }
}

- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject
{
    _allPosts[index] = postObject;
    
    [self.tableView reloadData];
}

-(void)refresh:(UIRefreshControl *)refresh
{
    [refresh endRefreshing];
    
    [self queryForAllPostsNearLocation:self.currentLocation];
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


- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    
    return imageView;
}


@end
