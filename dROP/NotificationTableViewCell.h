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

#import "TTTAttributedLabel.h"


#define NOTIFICATION_PADDING 6
#define TYPE_WIDTH 20


@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *type;

@property (nonatomic, strong) UIView *mainContainer;
@property (nonatomic, strong) UIView *postContainer;

@property (nonatomic, strong) TTTAttributedLabel *postText;
@property (nonatomic, strong) UIView *actionsView;
@property (nonatomic, strong) CALayer *bottomBorder;

@property (nonatomic, strong) UILabel *date;

- (void)setFrameWithObject:(NSDictionary *)notificationObject forIndex:(NSInteger)index;
+ (CGFloat)getCellHeight:(NSDictionary *)notificationObject;


@end
