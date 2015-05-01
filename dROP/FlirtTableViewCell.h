//
//  FlirtTableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 30/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DITableViewCell.h"

#import "TTTAttributedLabel.h"

@interface FlirtTableViewCell : DITableViewCell

@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, strong) UIView *postContainer;
@property (nonatomic, strong) UIView *overlay2;
@property (nonatomic, strong) UIButton *imageV;
@property (nonatomic, strong) TTTAttributedLabel *postText;

@end

