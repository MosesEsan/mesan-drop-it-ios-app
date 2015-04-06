//
//  DEMOMenuViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 10/10/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "DEMOLeftMenuViewController.h"
#import "HomeTableViewController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "Config.h"

#define TABLEVIEW_HEIGHT HEIGHT - 70

@interface DEMOLeftMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;
@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) MapViewController *mapViewController;


@property (strong, readwrite, nonatomic) UIViewController *currentViewController;

@end

@implementation DEMOLeftMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, (self.view.frame.size.width / 2) - 20, TABLEVIEW_HEIGHT) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
    
    
    //_homeTableViewController = [[HomeTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _profileViewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
    _mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    
    _mapViewController.dataSource = _homeTableViewController;
    _mapViewController.delegate = _homeTableViewController;
}

- (void)setHomeTableViewController:(HomeTableViewController *)homeTableViewController
{
    _currentViewController = homeTableViewController;
    _homeTableViewController = (HomeTableViewController *)_currentViewController;
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *newContentViewController;
    
    if (indexPath.row == 0){
        newContentViewController = _profileViewController;
    }else if (indexPath.row == 1){
        newContentViewController = _homeTableViewController;
    }else if (indexPath.row == 2){
        newContentViewController = _mapViewController;

    }else if (indexPath.row == 3){
        
    }
    
    if (newContentViewController != _currentViewController)
    {
        
        if (indexPath.row == 2)
        {
            [self.sideMenuViewController setContentViewController:newContentViewController
                                                         animated:YES];
        }else{
            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:newContentViewController]
                                                         animated:YES];
        }
        
        _currentViewController = newContentViewController;
    }
    
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGRectGetHeight(tableView.frame) / 5;
    
    if (indexPath.row == 0)
        return height * 2;
    
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell%ld",indexPath.row]];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Cell%ld",indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIColor *colour = [UIColor clearColor];
    NSString *imageString;
    NSString *menuTitle;
    
    if (indexPath.row == 0)
    {
        //F3BB72
        colour = [UIColor colorWithRed:243/255.0f green:187/255.0f blue:114/255.0f alpha:1.0f];
        imageString = [Config people];
        menuTitle = @"PROFILE";
        
        
    }else if (indexPath.row == 1)
    {
        imageString = @"Home";
        menuTitle = @"HOME";
    }else if (indexPath.row == 2)
    {
        imageString = @"Marker";
        menuTitle = @"MAP";
    }else if (indexPath.row == 3)
    {
        imageString = @"Notification";
        menuTitle = @"NOTIFICATIONS";
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    CGFloat height = CGRectGetHeight(tableView.frame) / 5;
    
    if (indexPath.row == 0)
        height = height * 2;
    
    UIButton *icon = [[UIButton alloc] initWithFrame:CGRectMake((150 / 2) - 22.50f, (height / 2) - 22.50f, 45.0f, 45.0f)];
    icon.backgroundColor = colour;
    [icon setImage:[UIImage imageNamed:imageString] forState:UIControlStateNormal];
    icon.layer.cornerRadius = CGRectGetWidth(icon.frame) / 2;
    icon.layer.borderWidth = 1.0f;
    icon.layer.borderColor = [UIColor whiteColor].CGColor;
    icon.clipsToBounds = YES;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.userInteractionEnabled = NO;
    [cell.contentView addSubview:icon];
    
    UILabel *iconTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, icon.frame.origin.y + CGRectGetWidth(icon.frame), 150.0f, 28)];
    iconTitle.text = menuTitle;
    iconTitle.textColor = [UIColor whiteColor];
    iconTitle.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.5f];
    iconTitle.textAlignment = NSTextAlignmentCenter;
    
    [cell.contentView addSubview:iconTitle];
    
    // Configure the cell...
    
    return cell;
}

@end
