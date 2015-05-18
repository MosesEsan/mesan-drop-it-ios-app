//
//  AppDelegate.m
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "AppDelegate.h"
#import "Config.h"

#import "MenuTableViewController.h"
#import "DIDataManager.h"

#import "HomeTableViewController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "CollegeTableViewController.h"
#import "NotificationsTableViewController.h"


#import "AddPostViewController.h"
#import "AddFlirtViewController.h"

#import "BROptionsButton.h"


@interface AppDelegate ()<BROptionButtonDelegate>
{
    NSDate *lastUpdated;
    MenuTableViewController *_menuTableViewController;
    
    
}

@property (strong, nonatomic) UITabBarController *tabBarController;


@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) HomeTableViewController *homeTableViewController;
@property (strong, nonatomic) CollegeTableViewController *collegeViewController;
@property (strong, nonatomic) MapViewController *mapViewController;
@property (strong, nonatomic) NotificationsTableViewController *notificationViewController;



@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
        
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    //[Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:PARSE_APPICATION_ID
                  clientKey:PARSE_CLIENT_KEY];
    
    if ([Config checkInternetConnection])
    {
        // [Optional] Track statistics around application opens.
        //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
    
    [DIDataManager sharedManager];

    HomeTableViewController *homeTableViewController = [[HomeTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    _profileViewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
    _homeTableViewController = [[HomeTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _collegeViewController = [[CollegeTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _notificationViewController = [[NotificationsTableViewController alloc] initWithStyle:UITableViewStylePlain];
    
    UINavigationController *profileNavigationController = [[UINavigationController alloc] initWithRootViewController:self.profileViewController];
    UINavigationController *homeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.homeTableViewController];
    UINavigationController *collegeNavigationController = [[UINavigationController alloc] initWithRootViewController:self.collegeViewController];
    UINavigationController *notificationNavigationController = [[UINavigationController alloc] initWithRootViewController:self.notificationViewController];

    _profileViewController.title = @"Profile";
    _profileViewController.tabBarItem.image = [[UIImage imageNamed:@"User2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _profileViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"User2"];
    //_profileViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);

    
    _homeTableViewController.title = @"Home";
    _homeTableViewController.tabBarItem.image = [[UIImage imageNamed:@"Home2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _homeTableViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"Home2"];
    //_homeTableViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);

    
    
    AddFlirtViewController *addNewFlirt = [[AddFlirtViewController alloc] initWithNibName:nil bundle:nil];
    addNewFlirt.title = @"Add";
    addNewFlirt.tabBarItem.image = [[UIImage imageNamed:@"Add2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    addNewFlirt.tabBarItem.selectedImage = [UIImage imageNamed:@"Add2"];

    
    
    _collegeViewController.title = @"Colleges";
    _collegeViewController.tabBarItem.image = [[UIImage imageNamed:@"University"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _collegeViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"University"];
    //_collegeViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
    
    _notificationViewController.title = @"Notifications";
    _notificationViewController.tabBarItem.image = [[UIImage imageNamed:@"Notification"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _notificationViewController.tabBarItem.selectedImage = [UIImage imageNamed:@"Notification"];
    //_notificationViewController.tabBarItem.imageInsets = UIEdgeInsetsMake(8, 0, -8, 0);
    
    //View Controllers
    NSArray *viewControllers =
    [NSArray arrayWithObjects:profileNavigationController, homeNavigationController, addNewFlirt, collegeNavigationController, notificationNavigationController, nil];
    
    //Create tab bar
    self.tabBarController = [[UITabBarController alloc] init];
    
    
    //set the view controllers for the tab bar controller
    [self.tabBarController setViewControllers:viewControllers];
    
    BROptionsButton *brOption = [[BROptionsButton alloc] initWithTabBar:self.tabBarController.tabBar forItemIndex:2 delegate:self];
   
    [brOption setImage:[UIImage imageNamed:@"Pen"] forBROptionsButtonState:BROptionsButtonStateNormal];
    [brOption setImage:[UIImage imageNamed:@"Close_White"] forBROptionsButtonState:BROptionsButtonStateOpened];
    
    // set the bar background color
    [[UITabBar appearance] setBackgroundImage:[AppDelegate imageFromColor:BAR_TINT_COLOR2 forSize:CGSizeMake(320, 49) withCornerRadius:0]];
   
    // set the text color for unselected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor, nil] forState:UIControlStateNormal];

    
    UIColor *titleHighlightedColor = BAR_TINT_COLOR2;
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       titleHighlightedColor, UITextAttributeTextColor,
                                                       nil] forState:UIControlStateHighlighted];
    
    // selected state
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BAR_TINT_COLOR2, UITextAttributeTextColor, nil] forState:UIControlStateSelected];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setSelectedImageTintColor:BAR_TINT_COLOR2];
    
    // remove the shadow
    [[UITabBar appearance] setShadowImage:nil];
    
    // Set the dark color to selected tab (the dimmed background)
    [[UITabBar appearance] setSelectionIndicatorImage:[AppDelegate imageFromColor:[UIColor whiteColor] forSize:CGSizeMake(64, 49) withCornerRadius:0]];
    
    self.tabBarController.selectedViewController=[self.tabBarController.viewControllers objectAtIndex:1];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window setRootViewController:self.tabBarController];
        
    //Make the window visible
    [self.window makeKeyAndVisible];
    
    // Register for push notifications
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }else{
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    lastUpdated = nil;
    /*
    
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
    
    */
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation[@"deviceId"] = [Config deviceId];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //Set the points user default value
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults integerForKey:@"Points"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"Points"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [Config setConfiguration];
    [Config updateAvailableLocations:lastUpdated];
    [Config updateRewards:lastUpdated];
    
    lastUpdated = [NSDate date];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (UIImage *)imageFromColor:(UIColor *)color forSize:(CGSize)size withCornerRadius:(CGFloat)radius
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Begin a new image that will be the new image with the rounded corners
    // (here with the size of an UIImageView)
    UIGraphicsBeginImageContext(size);
    
    // Add a clip before drawing anything, in the shape of an rounded rect
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius] addClip];
    // Draw your image
    [image drawInRect:rect];
    
    // Get the image, here setting the UIImageView image
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    // Lets forget about that we were drawing
    UIGraphicsEndImageContext();
    
    return image;
}


#pragma mark - BROptionButtonDelegate

// number of items
- (NSInteger)brOptionsButtonNumberOfItems:(BROptionsButton *)brOptionsButton
{
    return 2;
}

// respond to selection (show viewController, animation, alert...)
- (void)brOptionsButton:(BROptionsButton *)brOptionsButton didSelectItem:(BROptionItem *)item
{
    //[self setSelectedIndex:brOptionsButton.locationIndexInTabBar];
}


- (UIImage*)brOptionsButton:(BROptionsButton *)brOptionsButton imageForItemAtIndex:(NSInteger)index
{
    UIImage *image = [UIImage imageNamed:@"Apple"];
    
    return image;
}

// do any setups before displaying the button
- (void)brOptionsButton:(BROptionsButton*)optionsButton willDisplayButtonItem:(BROptionItem*)button {
    button.backgroundColor = [UIColor colorWithRed:10/255.0f green:91/255.0f blue:128/255.0f alpha:1.0f];
}


@end
