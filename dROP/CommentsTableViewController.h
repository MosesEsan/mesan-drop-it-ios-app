//
//  CommentsTableViewController.h
//  dROP
//
//  Created by Moses Esan on 06/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


#import "DIDataManager.h"


@interface CommentsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSDictionary *postObject;

@property (nonatomic) BOOL showCloseButton;

@property (nonatomic) ViewType viewType;

@end
