//
//  PostTextPhotoTableViewCell.h
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>
#import "Config.h"

@interface PostTextPhotoTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *postText;
@property (nonatomic, strong) PFImageView *postImage;
@property (nonatomic, strong) UIView *actionsView;

@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIButton *smiley;
//@property (nonatomic, strong) UIButton *likes;
@property (nonatomic, strong) UILabel *comments;

@end
