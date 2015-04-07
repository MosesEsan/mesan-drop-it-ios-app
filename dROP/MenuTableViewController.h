//
//  MenuTableViewController.h
//  Drop It!
//
//  Created by Moses Esan on 01/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

//@class HomeTableViewController;
#import "HomeTableViewController.h"


@interface MenuTableViewController : UITableViewController

@property (strong, nonatomic) HomeTableViewController *homeTableViewController;

@end
