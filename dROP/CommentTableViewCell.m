//
//  CommentTableViewCell.m
//  dROP
//
//  Created by Moses Esan on 07/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "CommentTableViewCell.h"


@interface CommentTableViewCell()


@end

@implementation CommentTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        _commentText = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, TOP_PADDING, TEXT_WIDTH, 0)];
        _commentText.backgroundColor = [UIColor clearColor];
        _commentText.numberOfLines = 0;
        _commentText.textColor = TEXT_COLOR;
        _commentText.textAlignment = NSTextAlignmentLeft;
        _commentText.font = TEXT_FONT;
        _commentText.clipsToBounds = YES;
        _commentText.userInteractionEnabled = YES;
        [self.contentView addSubview:_commentText];
        
        _actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH + LEFT_PADDING, ACTIONS_VIEW_HEIGHT)];
        _actionsView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_actionsView];
        
        _date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, ACTIONS_VIEW_HEIGHT)];
        _date.backgroundColor = [UIColor clearColor];
        _date.textColor = DATE_COLOR;
        _date.textAlignment = NSTextAlignmentLeft;
        _date.font = DATE_FONT;
        [_actionsView addSubview:_date];
        
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
        
        self.smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 39, 5.2f, 8);
        self.smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -60, 0, 30);
        _smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 15);
        _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -65, 0, 35);
        
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
