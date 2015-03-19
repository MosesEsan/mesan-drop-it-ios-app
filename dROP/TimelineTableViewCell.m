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
        self.backgroundColor = [UIColor clearColor];
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_line];
        
        _lineBorder = [CALayer layer];
        _lineBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;//D8D8D8
        [_line.layer addSublayer:_lineBorder];
        
        
         _bubble = [[UIImageView alloc] init];
        _bubble.clipsToBounds = YES;
        _bubble.layer.cornerRadius =  BUBBLE_FRAME_WIDTH / 2;
        _bubble.layer.borderWidth = 2.5f;
        _bubble.layer.masksToBounds = YES;
        _bubble.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
        //[UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.8f];
        //[UIColor whiteColor];
        [_line addSubview:_bubble];

        
        _postContainer = [[UIView alloc] init];
        _postContainer.backgroundColor = [UIColor whiteColor];
        _postContainer.layer.borderWidth = .4f;
        _postContainer.layer.borderColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.6f].CGColor;
        _postContainer.layer.cornerRadius = 4.0f;
        _postContainer.clipsToBounds = YES;
        [self.contentView addSubview:_postContainer];
        
        _postText = [[UILabel alloc] init];
        _postText.backgroundColor = [UIColor clearColor];
        _postText.numberOfLines = 0;
        _postText.textColor = TEXT_COLOR;
        _postText.textAlignment = NSTextAlignmentLeft;
        _postText.font = TEXT_FONT;
        _postText.clipsToBounds = YES;
        _postText.userInteractionEnabled = YES;
        /*
        _postText.attributesText = @{NSForegroundColorAttributeName: TEXT_COLOR, NSFontAttributeName: TEXT_FONT};
        _postText.attributesHashtag = @{NSForegroundColorAttributeName: BAR_TINT_COLOR2, NSFontAttributeName: TEXT_FONT};
        */
        [_postContainer addSubview:_postText];
    
        
        _postImage = [[PFImageView alloc] init];
        _postImage.backgroundColor = [UIColor clearColor];
        _postImage.layer.cornerRadius = 5.0f;
        _postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        _postImage.clipsToBounds = YES;
        _postImage.contentMode = UIViewContentModeScaleAspectFill;
        _postImage.userInteractionEnabled = YES;
        [_postContainer addSubview:_postImage];
        
        _actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING * 3, 0, WIDTH - (LEFT_PADDING * 3), ACTIONS_VIEW_HEIGHT)];
        _actionsView.backgroundColor = [UIColor clearColor];
        [_postContainer addSubview:_actionsView];
        
        _bottomBorder = [CALayer layer];
        _bottomBorder.frame = CGRectMake(0, ACTIONS_VIEW_HEIGHT - .5f, CGRectGetWidth(_actionsView.frame), .5f);
       // [_actionsView.layer addSublayer:_bottomBorder];
        
        
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
        [_smiley setImage:[UIImage imageNamed:@"SmileyGray"] forState:UIControlStateNormal];
        [_smiley setImage:[UIImage imageNamed:@"SmileyBluish"] forState:UIControlStateSelected];
        [_smiley setImage:[UIImage imageNamed:@"Sad"] forState:UIControlStateHighlighted];
        [_smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [_smiley setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
        _smiley.titleLabel.font = LIKES_FONT;
        _smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        _smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 39, 5.2f, 8);
        _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -60, 0, 30);
        
        [_actionsView addSubview:_smiley];
        
        
        _triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 10, 20)];
        _triangle.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_triangle];
        
        CAShapeLayer *mask = [[CAShapeLayer alloc] init];
        mask.frame = _triangle.layer.bounds;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, nil, 0, 0);
        CGPathAddLineToPoint(path, nil, 0, 10.0f);
        CGPathAddLineToPoint(path, nil, 10, 0.0f);
        CGPathAddLineToPoint(path, nil, 10.0f, 20.0f);
        CGPathAddLineToPoint(path, nil, 0.0f, 10.0f);
        CGPathCloseSubpath(path);
        mask.path = path;
        CGPathRelease(path);
        
        _triangle.layer.mask = mask;
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
