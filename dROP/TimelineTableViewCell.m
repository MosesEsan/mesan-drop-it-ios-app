//
//  TimelineTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 11/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "TimelineTableViewCell.h"


#define LEFT_PADDING 16.5f

#define POST_TEXT_WIDTH WIDTH - 16.5f - (LEFT_PADDING * 2)

@implementation TimelineTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        _line = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, LEFT_PADDING, 0)];
        _line.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_line];
        
        _lineBorder = [CALayer layer];
        _lineBorder.frame = CGRectMake(LEFT_PADDING - 1, 0, 2.0, 0);
        _lineBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;
        [_line.layer addSublayer:_lineBorder];
        
        
         _bubble = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, (LEFT_PADDING * 2) - 10, (LEFT_PADDING * 2) - 10)];
        _bubble.backgroundColor = [UIColor purpleColor];
        _bubble.layer.cornerRadius = _bubble.frame.size.width / 2;
        //_bubble.layer.borderWidth = 4.0f;
        //_bubble.layer.borderColor = [UIColor whiteColor].CGColor;//_lineBorder.backgroundColor;
        [_line addSubview:_bubble];
        
        
        _postText = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING * 2, TOP_PADDING, TEXT_WIDTH - LEFT_PADDING, 0)];
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
        
        _actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING * 3, 0, WIDTH - (LEFT_PADDING * 3), ACTIONS_VIEW_HEIGHT)];

        
        _actionsView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_actionsView];
        
        _bottomBorder = [CALayer layer];
        _bottomBorder.frame = CGRectMake(0, ACTIONS_VIEW_HEIGHT - .5f, CGRectGetWidth(_actionsView.frame), .5f);
        [_actionsView.layer addSublayer:_bottomBorder];
        
        
        _date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, ACTIONS_VIEW_HEIGHT)];
        _date.backgroundColor = [UIColor clearColor];
        _date.textColor = DATE_COLOR;
        _date.textAlignment = NSTextAlignmentLeft;
        _date.font = DATE_FONT;
        [_actionsView addSubview:_date];
        
        //_comments = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_actionsView.frame) - 90, 0, 90, ACTIONS_VIEW_HEIGHT)];
        _comments = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 90, ACTIONS_VIEW_HEIGHT)];
        _comments.backgroundColor = [UIColor clearColor];
        _comments.textColor = DATE_COLOR;
        _comments.textAlignment = NSTextAlignmentLeft;
        _comments.font = COMMENTS_FONT;
        [_actionsView addSubview:_comments];
        
        _smiley = [UIButton buttonWithType:UIButtonTypeCustom];
        _smiley.frame = CGRectMake((CGRectGetWidth(_actionsView.frame)) - 65.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
        _smiley.backgroundColor = [UIColor clearColor];
        [_smiley setImage:[UIImage imageNamed:@"SmileyGray-Small"] forState:UIControlStateNormal];
        [_smiley setImage:[UIImage imageNamed:@"SmileyBluish-Small"] forState:UIControlStateSelected];
        [_smiley setImage:[UIImage imageNamed:@"Sad-Small"] forState:UIControlStateHighlighted];
        [_smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [_smiley setTitleColor:BAR_TINT_COLOR forState:UIControlStateSelected];
        _smiley.titleLabel.font = LIKES_FONT;
        _smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 0);
        _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -50, 0, 20);
        
        _smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 15);
        _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -65, 0, 35);
        
        [_actionsView addSubview:_smiley];
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
