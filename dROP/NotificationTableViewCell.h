//
//  NotificationTableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 15/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DITableViewCell.h"

#import "TTTAttributedLabel.h"

@interface NotificationTableViewCell : DITableViewCell

@property (nonatomic, strong) UIView *postContainer;
@property (nonatomic, strong) UIButton *imageV;
@property (nonatomic, strong) TTTAttributedLabel *postText;

@property (nonatomic, strong) UIButton *comment;


@end

