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
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.line];
        
        _lineBorder = [CALayer layer];
        _lineBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;//D8D8D8
        [self.line.layer addSublayer:_lineBorder];
        
        
         _bubble = [[UIImageView alloc] init];
        _bubble.clipsToBounds = YES;
        _bubble.layer.cornerRadius =  BUBBLE_FRAME_WIDTH / 2;
        _bubble.layer.borderWidth = 2.5f;
        _bubble.layer.masksToBounds = YES;
        _bubble.backgroundColor = [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
        //[UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.8f];
        //[UIColor whiteColor];
        [self.line addSubview:_bubble];

        
        self.mainContainer = [[UIView alloc] init];
        self.mainContainer.backgroundColor = [UIColor whiteColor];
        self.mainContainer.layer.borderWidth = .4f;
        self.mainContainer.layer.borderColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.6f].CGColor;
        self.mainContainer.layer.cornerRadius = 4.0f;
        self.mainContainer.clipsToBounds = YES;
        [self.contentView addSubview:self.mainContainer];
        
        self.postText = [[UILabel alloc] init];
        self.postText.backgroundColor = [UIColor clearColor];
        self.postText.numberOfLines = 0;
        self.postText.textColor = TEXT_COLOR;
        self.postText.textAlignment = NSTextAlignmentLeft;
        self.postText.font = TEXT_FONT;
        self.postText.clipsToBounds = YES;
        self.postText.userInteractionEnabled = YES;
        /*
        self.postText.attributesText = @{NSForegroundColorAttributeName: TEXT_COLOR, NSFontAttributeName: TEXT_FONT};
        self.postText.attributesHashtag = @{NSForegroundColorAttributeName: BAR_TINT_COLOR2, NSFontAttributeName: TEXT_FONT};
        */
        [self.mainContainer addSubview:self.postText];
    
        
        self.postImage = [[PFImageView alloc] init];
        self.postImage.backgroundColor = [UIColor clearColor];
        self.postImage.layer.cornerRadius = 5.0f;
        self.postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        self.postImage.clipsToBounds = YES;
        self.postImage.contentMode = UIViewContentModeScaleAspectFill;
        self.postImage.userInteractionEnabled = YES;
        [self.mainContainer addSubview:self.postImage];
        
        self.actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING * 3, 0, WIDTH - (LEFT_PADDING * 3), ACTIONS_VIEW_HEIGHT)];
        self.actionsView.backgroundColor = [UIColor clearColor];
        [self.mainContainer addSubview:self.actionsView];
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.frame = CGRectMake(0, ACTIONS_VIEW_HEIGHT - .5f, CGRectGetWidth(self.actionsView.frame), .5f);
       // [self.actionsView.layer addSublayer:_bottomBorder];
        
        
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
        
        self.smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 39, 5.2f, 8);
        self.smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -60, 0, 30);
        
        [self.actionsView addSubview:self.smiley];
        
        
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
