//
//  CollegeTableViewController.h
//  Drop It!
//
//  Created by Moses Esan on 07/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollegeViewControllerDelegate <NSObject>

- (void)switchCollege;

@end

@interface CollegeTableViewController : UITableViewController

@property (nonatomic, weak) id<CollegeViewControllerDelegate> delegate;

@end
