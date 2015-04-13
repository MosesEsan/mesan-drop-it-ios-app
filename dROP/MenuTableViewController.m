//
//  MenuTableViewController.m
//  Drop It!
//
//  Created by Moses Esan on 01/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "MenuTableViewController.h"
#import "HomeTableViewController.h"
#import "ProfileViewController.h"
#import "MapViewController.h"
#import "CollegeTableViewController.h"
#import "Config.h"

#define TABLEVIEW_HEIGHT HEIGHT - 70

@interface MenuTableViewController ()
{
    NSArray *colours;
}


@property (strong, nonatomic) ProfileViewController *profileViewController;
@property (strong, nonatomic) MapViewController *mapViewController;

@property (strong, nonatomic) CollegeTableViewController *collegeViewController;


@property (strong, readwrite, nonatomic) UIViewController *currentViewController;


@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    
    //_homeTableViewController = [[HomeTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _profileViewController = [[ProfileViewController alloc] initWithNibName:nil bundle:nil];
    
    _mapViewController = [[MapViewController alloc] initWithNibName:nil bundle:nil];
    _mapViewController.dataSource = _homeTableViewController;
    
    
    _collegeViewController = [[CollegeTableViewController alloc] initWithStyle:UITableViewStylePlain];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.frame = CGRectMake(0, 0, (self.view.frame.size.width / 2) - 20, CGRectGetHeight(self.view.frame) - 70);
}

- (void)setHomeTableViewController:(HomeTableViewController *)homeTableViewController
{
    _currentViewController = homeTableViewController;
    _homeTableViewController = (HomeTableViewController *)_currentViewController;
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
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGRectGetHeight(tableView.frame) / 5;
    
    if (indexPath.row == 0)
        return height * 2;
    
    return height;
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
        imageString = @"University";
        menuTitle = @"COLLEGES";
    }else if (indexPath.row == 3)
    {
        imageString = @"Marker";
        menuTitle = @"MAP";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *newContentViewController;
    
    if (indexPath.row == 0){
        newContentViewController = _profileViewController;
    }else if (indexPath.row == 1){
        newContentViewController = _homeTableViewController;
    }else if (indexPath.row == 2){
        _collegeViewController.delegate = _homeTableViewController;
        
        newContentViewController = _collegeViewController;
        
    }else if (indexPath.row == 3){
        newContentViewController = _mapViewController;
    }
    
    if (newContentViewController != _currentViewController)
    {
        
        if (indexPath.row == 3)
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
