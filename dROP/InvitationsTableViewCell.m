//
//  InvitationsTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 22/06/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "InvitationsTableViewCell.h"


#define OP_WIDTH 55
#define HEART_WIDTH 45
#define DATE_WIDTH 75

#define COMMENT_WIDTH WIDTH - (LEFT_PADDING * 2) - OP_WIDTH

#define _PADDING 7.0f

@interface InvitationsTableViewCell()
{
    CGFloat opWidth;
}
@end

@implementation InvitationsTableViewCell

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
        self.line.frame = CGRectMake(_PADDING, TOP_PADDING, OP_WIDTH, 50);
        self.line.backgroundColor = [UIColor clearColor];
        self.line.clipsToBounds = YES;
        [self.contentView addSubview:self.line];
        
        self.imageV = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imageV.frame = CGRectMake(0, 5, HEART_WIDTH, HEART_WIDTH);
        self.imageV.backgroundColor = BAR_TINT_COLOR2;
        self.imageV.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imageV.contentMode = UIViewContentModeScaleAspectFill;
        self.imageV.layer.masksToBounds = YES;
        self.imageV.clipsToBounds = YES;
        [self.imageV setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.imageV.titleLabel.font = LIKES_FONT;
        self.imageV.layer.cornerRadius = CGRectGetWidth(self.imageV.frame) / 2;
        [self.imageV setTitle:@"OP" forState:UIControlStateNormal];
        
        [self.line addSubview:self.imageV];
        
        _username = [[UILabel alloc] initWithFrame:CGRectMake(_PADDING + OP_WIDTH, TOP_PADDING, WIDTH - (_PADDING + LEFT_PADDING) - OP_WIDTH - DATE_WIDTH, 20)];
        _username.backgroundColor = [UIColor clearColor];
        _username.numberOfLines = 0;
        _username.textColor = TEXT_COLOR;
        _username.textAlignment = NSTextAlignmentLeft;
        _username.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0f];;
        _username.clipsToBounds = YES;
        _username.userInteractionEnabled = YES;
        [self.contentView addSubview:_username];
        
        _date = [[UILabel alloc] initWithFrame:CGRectMake(_username.frame.origin.x + CGRectGetWidth(_username.frame), TOP_PADDING, DATE_WIDTH, 20)];
        _date.backgroundColor = [UIColor clearColor];
        _date.textColor = DATE_COLOR;
        _date.textAlignment = NSTextAlignmentRight;
        _date.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
        [self.contentView addSubview:_date];
        
        _lastMessage = [[UILabel alloc] initWithFrame:CGRectMake(_PADDING + OP_WIDTH, _username.frame.origin.y + CGRectGetHeight(_username.frame), WIDTH - (_PADDING + LEFT_PADDING) - OP_WIDTH, 40)];
        _lastMessage.backgroundColor = [UIColor clearColor];
        _lastMessage.numberOfLines = 0;
        _lastMessage.textColor = DATE_COLOR;
        _lastMessage.textAlignment = NSTextAlignmentLeft;
        _lastMessage.font = TEXT_FONT;
        _lastMessage.clipsToBounds = YES;
        _lastMessage.userInteractionEnabled = YES;
        [self.contentView addSubview:_lastMessage];
        
    }
    
    return self;
}

- (void)setValues:(NSDictionary *)conversationObject
{
    [self.imageV setImage:[UIImage imageNamed:@"man3"] forState:UIControlStateNormal];

    self.username.text = conversationObject[@"senderName"];
    self.lastMessage.text = [NSString stringWithFormat:@"'%@'",conversationObject[@"postText"]];
    self.date.text = [Config convertDate:conversationObject[@"date"]];
}

+ (CGFloat)getCellHeight
{
    return 80.0f;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
