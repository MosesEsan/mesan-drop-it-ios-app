//
//  NotificationTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 15/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "NotificationTableViewCell.h"

#define LEFT_PADDING 16.5f

#define POST_TEXT_WIDTH WIDTH - 16.5f - (LEFT_PADDING * 2)

@implementation NotificationTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.mainContainer = [[UIView alloc] init];
        self.mainContainer.backgroundColor = [UIColor whiteColor];
        self.mainContainer.clipsToBounds = YES;
        [self.contentView addSubview:self.mainContainer];
        
        self.type = [[UIImageView alloc] init];
        self.type.layer.borderWidth = 0.7f;
        self.type.backgroundColor = [UIColor purpleColor];
        
        self.postContainer = [[UIView alloc] init];
        self.postContainer.backgroundColor = [UIColor clearColor];
        self.postContainer.clipsToBounds = YES;
        [self.mainContainer addSubview:self.postContainer];
        
        self.postText = [[TTTAttributedLabel alloc] init];
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
        [self.postContainer addSubview:self.postText];
        
        self.actionsView = [[UIView alloc] initWithFrame:CGRectMake(LEFT_PADDING * 3, 0, WIDTH - (LEFT_PADDING * 3), ACTIONS_VIEW_HEIGHT)];
        self.actionsView.backgroundColor = [UIColor clearColor];
        [self.postContainer addSubview:self.actionsView];
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.frame = CGRectMake(0, ACTIONS_VIEW_HEIGHT - .5f, CGRectGetWidth(self.actionsView.frame), .5f);
        // [self.actionsView.layer addSublayer:self.bottomBorder];
        
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, ACTIONS_VIEW_HEIGHT)];
        self.date.backgroundColor = [UIColor clearColor];
        self.date.textColor = DATE_COLOR;
        self.date.textAlignment = NSTextAlignmentLeft;
        self.date.font = DATE_FONT;
        [self.actionsView addSubview:self.date];
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1].CGColor;
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.5].CGColor;
        [self.mainContainer.layer addSublayer:self.bottomBorder];
    }
    
    return self;
}

- (void)setFrameWithObject:(NSDictionary *)notificationObject forIndex:(NSInteger)index
{
    CGFloat postContainerWidth = [NotificationTableViewCell getPostContainerWidth:notificationObject];
    CGFloat notificationTextHeight = [NotificationTableViewCell getnotificationTextHeight:notificationObject];
    CGFloat cellHeight = [NotificationTableViewCell getCellHeight:notificationObject];

    CGRect mainContainerFrame = CGRectMake(0, 0, WIDTH, cellHeight);
    CGRect lineFrame = CGRectMake(CONTAINER_FRAME_X + 5, (cellHeight - TYPE_WIDTH) / 2, TYPE_WIDTH, TYPE_WIDTH);
    CGRect postContainerFrame = CGRectMake(CONTAINER_FRAME_X + 5 + TYPE_WIDTH, 0, postContainerWidth, cellHeight);
    
    CGFloat width = CGRectGetWidth(postContainerFrame) - 12;
    CGRect labelFrame = CGRectMake(12, NOTIFICATION_PADDING, width, notificationTextHeight);
    CGRect actionViewFrame = CGRectMake(12, labelFrame.origin.y + notificationTextHeight + 2, width, 20);
    CGRect dateFrame = CGRectMake(0, 0, CGRectGetWidth(actionViewFrame) / 3, 20);

    self.type = [Config getNotificationType:notificationObject withFrame:lineFrame];
    [self.mainContainer addSubview:self.type];
    
    //Set Frames
    self.mainContainer.frame = mainContainerFrame;
    self.postContainer.frame = postContainerFrame;
    self.postText.frame = labelFrame;
    self.actionsView.frame = actionViewFrame;
    self.date.frame = dateFrame;
    
    [self setValues:notificationObject];
}

- (void)setValues:(NSDictionary *)notificationObject
{
    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    NSString *text = [NSString stringWithFormat:@"%@ \"%@\"",[Config getNotificationText:notificationObject], notificationObject[@"text"]];

    //self.postText.text = text;
    
    [self.postText setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:[Config getNotificationText:notificationObject] options:NSCaseInsensitiveSearch];
        NSRange colouredRange = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"\"%@\"", notificationObject[@"text"]]
                                                                        options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:13.5f];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            //[mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName
              //                              value:(id)[DATE_COLOR CGColor]
                //                            range:colouredRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    self.date.text = [Config calculateTime:notificationObject[@"date"]];
}

+ (CGFloat)getPostContainerWidth:(NSDictionary *)notificationObject
{
    return  WIDTH - CONTAINER_FRAME_X - 5 - TYPE_WIDTH - 9;
}

+ (CGFloat)getnotificationTextHeight:(NSDictionary *)notificationObject
{
    CGFloat postContainerWidth = [self getPostContainerWidth:notificationObject];
    
    NSString *text = [NSString stringWithFormat:@"%@ \"%@\"",[Config getNotificationText:notificationObject], notificationObject[@"text"]];
    
    return [Config calculateHeightForText:text
                                withWidth:postContainerWidth
                                 withFont:TEXT_FONT];
}

+ (CGFloat)getCellHeight:(NSDictionary *)notificationObject
{
    CGFloat notificationTextHeight = [self getnotificationTextHeight:notificationObject];
    
    return NOTIFICATION_PADDING + notificationTextHeight + 2 + 20 + NOTIFICATION_PADDING;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
