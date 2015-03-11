//
//  TimelineTableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 11/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Config.h"
#import "MCSwipeTableViewCell.h"

@interface TimelineTableViewCell : MCSwipeTableViewCell

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) CALayer *lineBorder;
@property (nonatomic, strong) UIImageView *bubble;

@property (nonatomic, strong) UILabel *postText;
@property (nonatomic, strong) PFImageView *postImage;
@property (nonatomic, strong) UIView *actionsView;
@property (nonatomic, strong)CALayer *bottomBorder;

@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIButton *smiley;
@property (nonatomic, strong) UILabel *comments;

@end
