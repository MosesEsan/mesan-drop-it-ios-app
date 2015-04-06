//
//  MenuTableViewController.m
//  Drop It!
//
//  Created by Moses Esan on 01/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "MenuTableViewController.h"


#import "AppDelegate.h"
#import "MSViewControllerSlidingPanel.h"

#import "Config.h"

@interface MenuTableViewController ()
{
    NSArray *colours;
}
@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
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
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Screen height / numner of rows
    
    return HEIGHT / 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell%ld",indexPath.row]];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Cell%ld",indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIColor *colour;
    NSString *imageString;
    NSString *menuTitle;
    
    if (indexPath.row == 0)
    {
        
        
        //F3BB72
        colour = [UIColor colorWithRed:243/255.0f green:187/255.0f blue:114/255.0f alpha:1.0f];
        imageString = @"User";
        menuTitle = @"PROFILE";
        
        
    }else if (indexPath.row == 1)
    {
        //CDB5A3
        colour = BAR_TINT_COLOR2;
        //[UIColor colorWithRed:205/255.0f green:181/255.0f blue:163/255.0f alpha:1.0f];
        imageString = @"Home";
        menuTitle = @"HOME";
    }else if (indexPath.row == 2)
    {
        //5D9EA1
        colour = //[UIColor colorWithRed:93/255.0f green:158/255.0f blue:161/255.0f alpha:1.0f];
        [UIColor colorWithRed:252/255.0f green:135/255.0f blue:13/255.0f alpha:1.0f];
        imageString = @"Articles";
        menuTitle = @"ARTICLE";
    }else if (indexPath.row == 3)
    {
        //C2606F
        colour =  [UIColor colorWithRed:236/255.0f green:86/255.0f blue:78/255.0f alpha:1.0f];

        //[UIColor colorWithRed:194/255.0f green:96/255.0f blue:111/255.0f alpha:1.0f];
        imageString = @"Events";
        menuTitle = @"EVENTS";
        
    }else if (indexPath.row == 4)
    {
        //FF85A7
        colour = [UIColor colorWithRed:255/255.0f green:133/255.0f blue:167/255.0f alpha:1.0f];
        imageString = @"Marker";
        menuTitle = @"MAP";
    }
    
    cell.backgroundColor = colour;
    
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((150 / 2) - 15.0f, ((HEIGHT / 5) / 2) - 15.0f, 30.0f, 30.0f)];
    icon.backgroundColor = [UIColor clearColor];
    icon.image = [UIImage imageNamed:imageString];
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
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    

    /*
    if (indexPath.row == 0)
    {
        //Profile
    }else if (indexPath.row == 1)
    {
        //home
        [[self slidingPanelController] setDelegate:appDelegate.homeTableViewController];
        [[self slidingPanelController] setCenterViewController:appDelegate.homeNavigationController];
    }else if (indexPath.row == 2)
    {
        //article
        [[self slidingPanelController] setDelegate:appDelegate.articlesTableViewController];
        [[self slidingPanelController] setCenterViewController:appDelegate.articlesNavigationController];
    }else if (indexPath.row == 3)
    {
        //Events
        [[self slidingPanelController] setDelegate:appDelegate.eventsViewController];
        [[self slidingPanelController] setCenterViewController:appDelegate.eventsNavigationController];
    }else if (indexPath.row == 4)
    {
        //Map
    }
    */
    
    [[self slidingPanelController] closePanel];

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
