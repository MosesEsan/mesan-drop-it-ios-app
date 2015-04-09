//
//  HomeTableViewController.h
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapViewController.h"
#import "CollegeTableViewController.h"


@interface HomeTableViewController : UITableViewController <MapViewControllerDataSource, MapViewControllerDelegate, CollegeViewControllerDelegate>


@end
