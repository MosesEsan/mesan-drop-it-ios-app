//
//  PostTextTableViewCell.m
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "PostTextTableViewCell.h"

@interface PostTextTableViewCell()

@end

@implementation PostTextTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        self.postText = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, TOP_PADDING, TEXT_WIDTH, 0)];
        self.postText.backgroundColor = [UIColor clearColor];
        self.postText.numberOfLines = 0;
        self.postText.textColor = TEXT_COLOR;
        self.postText.textAlignment = NSTextAlignmentLeft;
        self.postText.font = TEXT_FONT;
        self.postText.clipsToBounds = YES;
        self.postText.userInteractionEnabled = YES;
        [self.contentView addSubview:self.postText];
        
        self.postImage = [[PFImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH, IMAGEVIEW_HEIGHT)];
        self.postImage.backgroundColor = [UIColor clearColor];
        self.postImage.layer.cornerRadius = 5.0f;
        self.postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        self.postImage.clipsToBounds = YES;
        self.postImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.postImage];
        
        self.actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH + LEFT_PADDING, ACTIONS_VIEW_HEIGHT)];
        self.actionsView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.actionsView];
        
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, ACTIONS_VIEW_HEIGHT)];
        self.date.backgroundColor = [UIColor clearColor];
        self.date.textColor = DATE_COLOR;
        self.date.textAlignment = NSTextAlignmentLeft;
        self.date.font = DATE_FONT;
        [self.actionsView addSubview:self.date];
        
        //self.comments = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.actionsView.frame) - 90, 0, 90, ACTIONS_VIEW_HEIGHT)];
        self.comments = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 90, ACTIONS_VIEW_HEIGHT)];
        self.comments.backgroundColor = [UIColor clearColor];
        self.comments.textColor = DATE_COLOR;
        self.comments.textAlignment = NSTextAlignmentLeft;
        self.comments.font = COMMENTS_FONT;
        [self.actionsView addSubview:self.comments];
        
        self.smiley = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smiley.frame = CGRectMake((CGRectGetWidth(self.actionsView.frame)) - 65.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
        self.smiley.backgroundColor = [UIColor clearColor];
        [self.smiley setImage:[UIImage imageNamed:@"SmileyGray"] forState:UIControlStateNormal];
        [self.smiley setImage:[UIImage imageNamed:@"SmileyBluish"] forState:UIControlStateSelected];
        [self.smiley setImage:[UIImage imageNamed:@"Sad"] forState:UIControlStateHighlighted];
        [self.smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [self.smiley setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
        self.smiley.titleLabel.font = LIKES_FONT;
        self.smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 0);
        self.smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -50, 0, 20);
        
        
        self.smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 15);
        self.smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -65, 0, 35);
        
        [self.actionsView addSubview:self.smiley];
        
        
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
