//
//  CommentTableViewCell.m
//  dROP
//
//  Created by Moses Esan on 07/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "CommentTableViewCell.h"


#define OP_WIDTH 45
#define HEART_WIDTH 35

#define COMMENT_WIDTH WIDTH - (LEFT_PADDING * 2) - OP_WIDTH


@interface CommentTableViewCell()
{
    CGFloat opWidth;
}
@end

@implementation CommentTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        opWidth = 0;
        
        //Left Side - View
        self.line = [[UIView alloc] init];
        self.line.frame = CGRectMake(LEFT_PADDING, TOP_PADDING, OP_WIDTH, 0);
        self.line.backgroundColor = [UIColor clearColor];
        self.line.clipsToBounds = YES;
        [self.contentView addSubview:self.line];
        
        self.imageV = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imageV.frame = CGRectMake(0, 5, HEART_WIDTH, HEART_WIDTH);
        self.imageV.backgroundColor = BAR_TINT_COLOR2;
        self.imageV.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        self.imageV.layer.masksToBounds = YES;
        self.imageV.clipsToBounds = YES;
        [self.imageV setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.imageV.titleLabel.font = LIKES_FONT;
        [self.imageV setTitle:@"OP" forState:UIControlStateNormal];

        [self.line addSubview:self.imageV];
        
        
        _commentText = [[UILabel alloc] initWithFrame:CGRectMake(0, TOP_PADDING, 0, 0)];
        _commentText.backgroundColor = [UIColor clearColor];
        _commentText.numberOfLines = 0;
        _commentText.textColor = TEXT_COLOR;
        _commentText.textAlignment = NSTextAlignmentLeft;
        _commentText.font = TEXT_FONT;
        _commentText.clipsToBounds = YES;
        _commentText.userInteractionEnabled = YES;
        [self.contentView addSubview:_commentText];
        
        _actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING, 0, WIDTH - (LEFT_PADDING + (LEFT_PADDING / 2)), ACTIONS_VIEW_HEIGHT)];
        _actionsView.backgroundColor = [UIColor clearColor];
        _actionsView.clipsToBounds = YES;
        [self.contentView addSubview:_actionsView];
        
        _date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, ACTIONS_VIEW_HEIGHT)];
        _date.backgroundColor = [UIColor clearColor];
        _date.textColor = DATE_COLOR;
        _date.textAlignment = NSTextAlignmentLeft;
        _date.font = DATE_FONT;
        [_actionsView addSubview:_date];
        
        self.smiley = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smiley.frame = CGRectMake((CGRectGetWidth(self.actionsView.frame)) - 60.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
        
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

- (void)setFrameWithObject:(NSDictionary *)commentObject forIndex:(NSInteger)index
{
    NSString *commentText = commentObject[@"text"];
    
    
    //if the user is the owner of the comment
    //and the comment has likes, show the smiley button
    //else hide it
    if ([Config isPostAuthor:commentObject])
    {
        opWidth = OP_WIDTH;
    }
    
    CGFloat commentWidth = WIDTH - (LEFT_PADDING + (LEFT_PADDING / 2)) - opWidth;
    
    
    //Set Label Frame
    CGFloat commentTextHeight = [Config calculateHeightForText:commentText withWidth:commentWidth withFont:TEXT_FONT];
    
    if (commentTextHeight < 35) commentTextHeight = 35;
    
    CGFloat cellHeight = [CommentTableViewCell getCellHeight:commentObject];
    CGRect lineFrame =  self.line.frame;
    lineFrame.size.width = opWidth;
    lineFrame.size.height = cellHeight;
    self.line.frame = lineFrame;
    
    CGRect roundFrame =  self.imageV.frame;
    self.imageV.frame = roundFrame;
    self.imageV.layer.cornerRadius = CGRectGetWidth(self.imageV.frame) / 2;
    
    CGRect labelFrame = self.commentText.frame;
    labelFrame.origin.x = LEFT_PADDING + opWidth;
    labelFrame.size.width = commentWidth;
    labelFrame.size.height = commentTextHeight;
    self.commentText.frame = labelFrame;
    
    //Set Action View Frame
    CGRect frame = self.actionsView.frame;
    frame.origin.y = labelFrame.origin.y + commentTextHeight + 10;
    self.actionsView.frame = frame;
    
    
    //CGFloat postTextHeight = [FlirtTableViewCell getPostTextHeight:postObject];
    //CGFloat cellHeight = [FlirtTableViewCell getCellHeight:postObject];

    [self setValues:commentObject];
}

- (void)setValues:(NSDictionary *)commentObject
{
    NSInteger smileyCount = [commentObject[@"totalLikes"] integerValue];
    
    self.commentText.text = commentObject[@"text"];
    self.date.text = [Config calculateTime:commentObject[@"date"]];
    [self.smiley setTitle:[Config likesCount:smileyCount] forState:UIControlStateNormal];
}

+ (CGFloat)getCellHeight:(NSDictionary *)commentObject
{
    NSString *commentText = commentObject[@"text"];
    
    CGFloat opWidth = 0;

    if ([Config isPostAuthor:commentObject])
        opWidth = OP_WIDTH;
    
   // CGFloat commentWidth = WIDTH - (LEFT_PADDING * 2) - opWidth;
    
    CGFloat commentWidth = WIDTH - (LEFT_PADDING + (LEFT_PADDING / 2)) - opWidth;
    
    CGFloat commentTextHeight = [Config calculateHeightForText:commentText withWidth:commentWidth withFont:TEXT_FONT];
    
    
    if (commentTextHeight < 35) commentTextHeight = 35;
    
    return TOP_PADDING + commentTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 2;
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
