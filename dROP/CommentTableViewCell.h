//
//  CommentTableViewCell.h
//  dROP
//
//  Created by Moses Esan on 07/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Config.h"
#import "MCSwipeTableViewCell.h"

@interface CommentTableViewCell : MCSwipeTableViewCell


@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *imageV;


@property (nonatomic, strong) UILabel *commentText;
@property (nonatomic, strong) UIView *actionsView;

@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIButton *smiley;

- (void)setFrameWithObject:(NSDictionary *)commentObject forIndex:(NSInteger)index;

+ (CGFloat)getCellHeight:(NSDictionary *)commentObject;

@end
