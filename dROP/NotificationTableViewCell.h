//
//  NotificationTableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 15/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Config.h"

@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UIView *postContainer;

@property (nonatomic, strong) UILabel *postText;
@property (nonatomic, strong) UIView *actionsView;
@property (nonatomic, strong) CALayer *bottomBorder;

@property (nonatomic, strong) UILabel *date;

- (void)setFrameWithObject:(NSDictionary *)notificationObject forIndex:(NSInteger)index;



@end
