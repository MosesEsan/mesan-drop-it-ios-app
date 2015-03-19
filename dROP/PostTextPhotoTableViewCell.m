//
//  PostTextPhotoTableViewCell.m
//  dROP
//
//  Created by Moses Esan on 03/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "PostTextPhotoTableViewCell.h"

@implementation PostTextPhotoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _postText = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, TOP_PADDING, TEXT_WIDTH, 0)];
        _postText.backgroundColor = [UIColor clearColor];
        _postText.numberOfLines = 0;
        _postText.textColor = TEXT_COLOR;
        _postText.textAlignment = NSTextAlignmentLeft;
        _postText.font = TEXT_FONT;
        _postText.clipsToBounds = YES;
        _postText.userInteractionEnabled = YES;
        [self.contentView addSubview:_postText];
        
        _postImage = [[PFImageView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH, IMAGEVIEW_HEIGHT)];
        _postImage.backgroundColor = [UIColor clearColor];
        _postImage.layer.cornerRadius = 5.0f;
        _postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        _postImage.clipsToBounds = YES;
        _postImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_postImage];
        
        _actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH, ACTIONS_VIEW_HEIGHT)];
        _actionsView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_actionsView];
        
        _date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, ACTIONS_VIEW_HEIGHT)];
        _date.backgroundColor = [UIColor clearColor];
        _date.textColor = DATE_COLOR;
        _date.textAlignment = NSTextAlignmentLeft;
        _date.font = DATE_FONT;
        [_actionsView addSubview:_date];
        
        /*
         _likes = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_actionsView.frame) - ACTIONS_VIEW_HEIGHT - 35 + 5, 0, 35, ACTIONS_VIEW_HEIGHT)];
         _likes.backgroundColor = [UIColor clearColor];
         [_likes setTitleColor:DATE_COLOR forState:UIControlStateNormal];
         [_likes setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
         _likes.titleLabel.textAlignment = NSTextAlignmentRight;
         _likes.titleLabel.font = LIKES_FONT;
         _likes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
         
         [_actionsView addSubview:_likes];
         */
        
        _smiley = [UIButton buttonWithType:UIButtonTypeCustom];
        _smiley.frame = CGRectMake((CGRectGetWidth(_actionsView.frame)) - 50.0f, 0, 50.0f, ACTIONS_VIEW_HEIGHT);
        _smiley.backgroundColor = [UIColor clearColor];
        [_smiley setImage:[UIImage imageNamed:@"SmileyGray"] forState:UIControlStateNormal];
        [_smiley setImage:[UIImage imageNamed:@"SmileyBluish"] forState:UIControlStateSelected];
        [_smiley setImage:[UIImage imageNamed:@"Sad"] forState:UIControlStateHighlighted];
        [_smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [_smiley setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
        _smiley.titleLabel.font = LIKES_FONT;
        _smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _smiley.imageEdgeInsets = UIEdgeInsetsMake(5, 33, 5, 0);
        _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -50, 0, 20);
        [_actionsView addSubview:_smiley];
        
        //_comments = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_actionsView.frame) - 90, 0, 90, ACTIONS_VIEW_HEIGHT)];
        _comments = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 90, ACTIONS_VIEW_HEIGHT)];
        _comments.backgroundColor = [UIColor clearColor];
        _comments.textColor = DATE_COLOR;
        _comments.textAlignment = NSTextAlignmentLeft;
        _comments.font = COMMENTS_FONT;
        [_actionsView addSubview:_comments];
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
