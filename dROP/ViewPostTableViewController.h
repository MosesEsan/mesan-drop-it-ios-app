//
//  ViewPostTableViewController.h
//  dROP
//
//  Created by Moses Esan on 06/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol ViewPostViewControllerDelegate <NSObject>

- (void)likePost:(UIButton *)sender;
- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject;

@end

@interface ViewPostTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *postObject;

@property (nonatomic, weak) id<ViewPostViewControllerDelegate> delegate;

@end
