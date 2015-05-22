//
//  CollegeTableViewController.m
//  Drop It!
//
//  Created by Moses Esan on 07/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "CollegeTableViewController.h"
#import "Config.h"
#import "RESideMenu.h"


@interface CollegeTableViewController ()
{
    NSDictionary *availableLocations;
}
@end

@implementation CollegeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.title = @"Colleges";
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 10.0f)];
    tableHeader.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = tableHeader;
    
    availableLocations = [Config availableLocations];
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
    
    return [availableLocations count] + 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    // Configure the cell...
    
    NSString *name;
    
    if (indexPath.row == 0){
        name = @"None";
        
        if ([[Config college] isEqualToString:ALL_COLLEGES])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        
        //Get all the keys
        NSArray *keys = [availableLocations allKeys];
        //Get the Key for the row
        id aKey = [keys objectAtIndex:indexPath.row - 1];
        NSDictionary *locationInfo = [availableLocations objectForKey:aKey];
        
        name = locationInfo[@"Name"];
        
        if ([[Config college] isEqualToString:name])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = name;
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.textColor = TEXT_COLOR;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.5f];
   
    /*
    UIImage *cellImage = [UIImage imageNamed:@"placeholder.jpg"];
    cell.imageView.image = cellImage;
    
    //Resize Imageview
    CGFloat widthScale = 40 / cellImage.size.width;
    CGFloat heightScale = 40 / cellImage.size.height;
    cell.imageView.transform = CGAffineTransformMakeScale(widthScale, heightScale);
        
    // Rounded Rect for cell image
    CALayer *cellImageLayer = cell.imageView.layer;
    [cellImageLayer setCornerRadius:30];
    [cellImageLayer setMasksToBounds:YES];
    
    if(availableLocations[indexPath.row - 1][@"Logo"] != [NSNull null])
    {
        PFFile *logo = availableLocations[indexPath.row][@"Logo"];
        
        PFImageView *image = [[PFImageView alloc] init];
        image.file = logo;
        [image loadInBackground:^(UIImage *image, NSError *error) {
            cell.imageView.image = image;
        }];
    }
    */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *college;
    
    if (indexPath.row == 0){
        college = ALL_COLLEGES;
    }else{
        //Get all the keys
        NSArray *keys = [availableLocations allKeys];
        //Get the Key for the row
        id aKey = [keys objectAtIndex:indexPath.row - 1];
        NSDictionary *locationInfo = [availableLocations objectForKey:aKey];
        
        college = locationInfo[@"Name"];
    }
    
    BOOL success = [Config setCollege:college];
    
    if (success) {
        [self.delegate switchCollege];
        [self.tableView reloadData];
    }
}

- (void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
