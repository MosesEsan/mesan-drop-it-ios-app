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
        //self.mainContainer.layer.borderWidth = 0.5f;
        //self.mainContainer.layer.borderColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;
        [self.contentView addSubview:self.mainContainer];
        
        self.line = [[UIView alloc] init];
        self.line.layer.borderWidth = 0.7f;
        [self.mainContainer addSubview:self.line];
        
        self.postContainer = [[UIView alloc] init];
        self.postContainer.backgroundColor = [UIColor whiteColor];
        //self.postContainer.layer.borderWidth = 1.5f;
        //self.postContainer.layer.borderColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.6f].CGColor;
        //self.postContainer.layer.cornerRadius = 4.0f;
        self.postContainer.clipsToBounds = YES;
        [self.mainContainer addSubview:self.postContainer];
        
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
    CGFloat postTextHeight = [Config calculateHeightForText:notificationObject[@"text"] withWidth:WIDTH - 55.5f withFont:TEXT_FONT];
    
    CGFloat cellHeight = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 3;
    
    CGRect mainContainerFrame = CGRectMake(CONTAINER_FRAME_X, 0,
                                           WIDTH - (CONTAINER_FRAME_X + (CONTAINER_FRAME_X / 2) + 2), cellHeight);
    
    CGRect lineFrame = CGRectMake(0, 0, COLOURED_BAR_WIDTH, cellHeight);
    CGRect postContainerFrame = CGRectMake(COLOURED_BAR_WIDTH, 0, CGRectGetWidth(mainContainerFrame) - COLOURED_BAR_WIDTH, cellHeight); //1 Added to cover up left border
    
    CGFloat width = CGRectGetWidth(postContainerFrame) - (8 * 2);
    CGRect labelFrame = CGRectMake(8, TOP_PADDING, width, postTextHeight);
    CGRect actionViewFrame = CGRectMake(8, 0, width + 8, ACTIONS_VIEW_HEIGHT);
    
    CGFloat remainingSpace = CGRectGetWidth(actionViewFrame) / 3;
    
    CGRect dateFrame = CGRectMake(0, 0, remainingSpace, ACTIONS_VIEW_HEIGHT);

    //Set Action View Frame
    actionViewFrame.origin.y = labelFrame.origin.y + postTextHeight + 10;
    
    //Set Frames
    self.line.frame = lineFrame;
    
    self.mainContainer.frame = mainContainerFrame;
    self.postContainer.frame = postContainerFrame;
    self.postText.frame = labelFrame;
    self.actionsView.frame = actionViewFrame;
    self.date.frame = dateFrame;
    
    self.line.backgroundColor = [Config getSideColor:index];
    self.line.layer.borderColor = [Config getSideColor:index].CGColor;
    [self setValues:notificationObject];
}

- (void)setValues:(NSDictionary *)notificationObject
{
    self.postText.text = notificationObject[@"text"];
    self.date.text = [Config calculateTime:notificationObject[@"date"]];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
