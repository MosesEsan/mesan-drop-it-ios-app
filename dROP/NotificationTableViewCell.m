//
//  NotificationTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 15/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "NotificationTableViewCell.h"


#define LEFT_PADDING 16.5f
//48
#define POST_TEXT_WIDTH WIDTH - 16.5f - (LEFT_PADDING * 2)


#define ICON_WIDTH 45

#define HEART_WIDTH L_PADDING * 2 + (L_PADDING / 2)
#define POST_CONTAINER_WIDTH MAIN_CONTAINER_WIDTH - LINE_WIDTH


#define MAIN_WIDTH WIDTH - ICON_WIDTH - 10

@implementation NotificationTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.mainContainer = [[UIView alloc] init];
        self.mainContainer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0);
        self.mainContainer.backgroundColor =  [UIColor whiteColor];
        self.mainContainer.clipsToBounds = YES;
        [self.contentView addSubview:self.mainContainer];
        
        //Left Side - View
        self.line = [[UIView alloc] init];
        self.line.frame = CGRectMake(0, 0, ICON_WIDTH, 0);
        self.line.backgroundColor = [UIColor clearColor];
        self.line.clipsToBounds = YES;
        [self.mainContainer addSubview:self.line];
        
        self.imageV = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imageV.frame = CGRectMake(L_PADDING, 0, HEART_WIDTH, HEART_WIDTH);
        //[BAR_TINT_COLOR2 colorWithAlphaComponent:0.3];//[UIColor whiteColor];
        self.imageV.layer.borderWidth = 1.0f;
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        self.imageV.layer.masksToBounds = YES;
        self.imageV.clipsToBounds = YES;
        self.imageV.imageEdgeInsets = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
        [self.line addSubview:self.imageV];
        
        self.postContainer = [[UIView alloc] init];
        self.postContainer.frame = CGRectMake(ICON_WIDTH, 0, CGRectGetWidth(self.mainContainer.frame) - (ICON_WIDTH + 10), 0);
        self.postContainer.backgroundColor = [UIColor clearColor];
        self.postContainer.clipsToBounds = YES;
        [self.mainContainer addSubview:self.postContainer];
        
        self.postText = [[TTTAttributedLabel alloc] init];
        self.postText.frame = CGRectMake(0, TOP_PADDING, CGRectGetWidth(self.postContainer.frame), 0);
        self.postText.backgroundColor = [UIColor clearColor];
        self.postText.numberOfLines = 0;
        self.postText.textColor = TEXT_COLOR;
        self.postText.textAlignment = NSTextAlignmentLeft;
        self.postText.font = TEXT_FONT;
        self.postText.clipsToBounds = YES;
        self.postText.userInteractionEnabled = YES;
        [self.postContainer addSubview:self.postText];
        
        self.actionsView = [[UIView alloc] init];
        self.actionsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.postContainer.frame), ACTIONS_VIEW_HEIGHT);
        self.actionsView.backgroundColor = [UIColor clearColor];
        [self.postContainer addSubview:self.actionsView];
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.frame = CGRectMake(0, ACTIONS_VIEW_HEIGHT - .5f, CGRectGetWidth(self.actionsView.frame), .5f);
        // [self.actionsView.layer addSublayer:self.bottomBorder];
        
        CGFloat postw = CGRectGetWidth(self.postContainer.frame);
        CGFloat width = postw / 3;
        
        self.date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, ACTIONS_VIEW_HEIGHT)];
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
    CGFloat postTextHeight = [NotificationTableViewCell getPostTextHeight:notificationObject];
    CGFloat cellHeight = [NotificationTableViewCell getCellHeight:notificationObject];
    
    CGRect mainContainerFrame =  self.mainContainer.frame;
    mainContainerFrame.size.height = cellHeight;
    self.mainContainer.frame = mainContainerFrame;
    
    CGRect lineFrame =  self.line.frame;
    lineFrame.size.height = cellHeight;
    self.line.frame = lineFrame;
    
    CGRect roundFrame =  self.imageV.frame;
    roundFrame.origin.y = (cellHeight / 2) - (HEART_WIDTH / 2);
    self.imageV.frame = roundFrame;
    self.imageV.layer.cornerRadius = CGRectGetWidth(self.imageV.frame) / 2;
    
    NSArray *typeInfo = [Config getNotificationTypeInfo:notificationObject];
    [self.imageV setImage:[UIImage imageNamed:typeInfo[0]] forState:UIControlStateNormal];
    self.imageV.layer.borderColor = [typeInfo[1] CGColor];

    
    CGRect postContainerFrame =  self.postContainer.frame;
    postContainerFrame.size.height = cellHeight;
    self.postContainer.frame = postContainerFrame;
    
    CGRect labelFrame =  self.postText.frame;
    labelFrame.size.height = postTextHeight;
    self.postText.frame = labelFrame;
    
    // NSLog(@"Main container width is %f - Postcontainer width is %f",CGRectGetWidth(mainContainerFrame),CGRectGetWidth(postContainerFrame));
    
    
    CGRect actionViewFrame = self.actionsView.frame;
    actionViewFrame.origin.y = labelFrame.origin.y + postTextHeight + 10;
    self.actionsView.frame = actionViewFrame;
    
    [self setValues:notificationObject];
}

- (void)setValues:(NSDictionary *)notificationObject
{
    self.date.text = [Config calculateTime:notificationObject[@"date"]];
    
    //PFObject *parseObject = notificationObject[@"parseObject"];
    
    NSString *text = [NSString stringWithFormat:@"%@ \"%@\"",[Config getNotificationText:notificationObject], notificationObject[@"text"]];
    
    [self.postText setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:[Config getNotificationText:notificationObject] options:NSCaseInsensitiveSearch];
        NSRange colouredRange = [[mutableAttributedString string] rangeOfString:[NSString stringWithFormat:@"\"%@\"", notificationObject[@"text"]]
                                                                        options:NSCaseInsensitiveSearch];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-DemiBold" size:14.0f];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


//---

+ (CGFloat)getPostTextHeight:(NSDictionary *)notificationObject
{
    PFObject *parseObject = notificationObject[@"parseObject"];
    
   NSString *text = [NSString stringWithFormat:@"%@ \"%@\"",[Config getNotificationText:notificationObject], notificationObject[@"text"]];
    
    return [Config calculateHeightForText:text
                                withWidth:MAIN_WIDTH
                                 withFont:TEXT_FONT];
}

+ (CGFloat)getCellHeight:(NSDictionary *)postObject
{
    CGFloat postTextHeight = [NotificationTableViewCell getPostTextHeight:postObject];
    
    return TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 3;
}


@end


