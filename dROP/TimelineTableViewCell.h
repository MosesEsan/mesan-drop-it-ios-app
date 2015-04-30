//
//  TimelineTableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 11/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DITableViewCell.h"

@interface TimelineTableViewCell : DITableViewCell

@property (nonatomic, strong) CALayer *lineBorder;
@property (nonatomic, strong) UIImageView *bubble;

@property (nonatomic, strong) UIImageView *triangle;
@property (nonatomic, strong) UILabel *postText;
@end
