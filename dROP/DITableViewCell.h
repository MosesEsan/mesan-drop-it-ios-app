//
//  DITableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 20/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Config.h"
#import "MCSwipeTableViewCell.h"

@interface DITableViewCell : MCSwipeTableViewCell

@property (nonatomic, strong) UIView *line;

@property (nonatomic, strong) UIView *mainContainer;

@property (nonatomic, strong) PFImageView *postImage;
@property (nonatomic, strong) UIView *actionsView;
@property (nonatomic, strong) CALayer *bottomBorder;

@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIButton *smiley;
@property (nonatomic, strong) UILabel *comments;

- (void)setFrameWithObject:(NSDictionary *)postObject forIndex:(NSInteger)index;

+ (CGFloat)getPostTextHeight:(NSDictionary *)postObject;
+ (CGFloat)getCellHeight:(NSDictionary *)postObject;

@end
