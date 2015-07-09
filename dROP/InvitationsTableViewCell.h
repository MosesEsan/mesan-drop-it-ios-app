//
//  InvitationsTableViewCell.h
//  Drop It!
//
//  Created by Moses Esan on 22/06/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Config.h"
#import "MCSwipeTableViewCell.h"

@interface InvitationsTableViewCell :  MCSwipeTableViewCell


@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *imageV;


@property (nonatomic, strong) UILabel *username;
@property (nonatomic, strong) UILabel *lastMessage;

@property (nonatomic, strong) UILabel *date;

- (void)setValues:(NSDictionary *)conversationObject;

+ (CGFloat)getCellHeight;

@end
