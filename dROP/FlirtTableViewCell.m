//
//  FlirtTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 30/04/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "FlirtTableViewCell.h"

#define LEFT_PADDING 16.5f
//48
#define POST_TEXT_WIDTH WIDTH - 16.5f - (LEFT_PADDING * 2)


#define LINE_WIDTH 45

#define HEART_WIDTH L_PADDING * 2 + (L_PADDING / 2)
#define POST_CONTAINER_WIDTH MAIN_CONTAINER_WIDTH - LINE_WIDTH


#define MAIN_WIDTH WIDTH - LINE_WIDTH - 10

@implementation FlirtTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.mainContainer = [[UIView alloc] init];
        self.mainContainer.frame = CGRectMake(0, 0, WIDTH, 0);
        // self.mainContainer.backgroundColor = [UIColor greenColor];
        self.mainContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Hearts2"]];

        self.mainContainer.clipsToBounds = YES;
        [self.contentView addSubview:self.mainContainer];
        
        self.overlay = [[UIView alloc] init];
        self.overlay.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        [self.mainContainer addSubview:self.overlay];
        
        self.whiteOverlay = [[UIView alloc] init];
        self.whiteOverlay.backgroundColor =  [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        [self.mainContainer addSubview:self.whiteOverlay];
        
        
        //Left Side - View
        self.line = [[UIView alloc] init];
        self.line.frame = CGRectMake(0, 0, LINE_WIDTH, 0);
        self.line.backgroundColor = [UIColor clearColor];
        self.line.clipsToBounds = YES;
        [self.mainContainer addSubview:self.line];
        
        self.imageV = [UIButton buttonWithType:UIButtonTypeCustom];
        self.imageV.frame = CGRectMake(L_PADDING, 0, HEART_WIDTH, HEART_WIDTH);
        self.imageV.backgroundColor = [UIColor redColor];
        //[BAR_TINT_COLOR2 colorWithAlphaComponent:0.3];//[UIColor whiteColor];
        //self.profilePic.layer.borderWidth = .2f;
        self.imageV.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imageV.contentMode = UIViewContentModeScaleAspectFit;
        self.imageV.layer.masksToBounds = YES;
        self.imageV.clipsToBounds = YES;
        [self.imageV setImage:[UIImage imageNamed:@"Heart"] forState:UIControlStateNormal];
        self.imageV.imageEdgeInsets = UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
        [self.line addSubview:self.imageV];
        
        
        self.postContainer = [[UIView alloc] init];
        self.postContainer.frame = CGRectMake(LINE_WIDTH, 0, CGRectGetWidth(self.mainContainer.frame) - (LINE_WIDTH + 5), 0);
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
        
        
        self.postImage = [[PFImageView alloc] init];
        self.postImage.frame = CGRectMake(0, 0, CGRectGetWidth(self.postContainer.frame), IMAGEVIEW_HEIGHT);
        self.postImage.backgroundColor = [UIColor clearColor];
        self.postImage.layer.cornerRadius = 3.0f;
        self.postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        self.postImage.clipsToBounds = YES;
        self.postImage.contentMode = UIViewContentModeScaleAspectFill;
        self.postImage.userInteractionEnabled = YES;
        [self.postContainer addSubview:self.postImage];
        
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
        
        self.comments = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, width, ACTIONS_VIEW_HEIGHT)];
        self.comments.backgroundColor = [UIColor clearColor];
        self.comments.textColor = DATE_COLOR;
        self.comments.textAlignment = NSTextAlignmentCenter;
        self.comments.font = COMMENTS_FONT;
        [self.actionsView addSubview:self.comments];
        
        //--
        self.comment = [UIButton buttonWithType:UIButtonTypeCustom];
        self.comment.backgroundColor = [UIColor clearColor];
        [self.comment setImage:[UIImage imageNamed:@"Comment_lighter"] forState:UIControlStateNormal];
        [self.comment setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [self.comment setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        self.comment.titleLabel.font = LIKES_FONT;
        self.comment.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        self.comment.imageEdgeInsets = UIEdgeInsetsMake(6.2f, 41, 6.2f, 8);
        self.comment.titleEdgeInsets = UIEdgeInsetsMake(2, -60, 0, 30);
        
        //[self.actionsView addSubview:self.comment];
        
        //---
        
        self.smiley = [UIButton buttonWithType:UIButtonTypeCustom];
        self.smiley.frame = CGRectMake(CGRectGetWidth(self.actionsView.frame) - 65.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
        self.smiley.backgroundColor = [UIColor clearColor];
        [self.smiley setImage:[UIImage imageNamed:@"Love_lighter"] forState:UIControlStateNormal];
        [self.smiley setImage:[UIImage imageNamed:@"Loved"] forState:UIControlStateSelected];
        [self.smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [self.smiley setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
        
        self.smiley.titleLabel.font = LIKES_FONT;
        self.smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        self.smiley.imageEdgeInsets = UIEdgeInsetsMake(5.0f, 39, 5.0f, 8);
        self.smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -60, 0, 30);
        
        [self.actionsView addSubview:self.smiley];
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1].CGColor;
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.5].CGColor;
        [self.mainContainer.layer addSublayer:self.bottomBorder];
        
    }
    
    return self;
}

- (void)setFrameWithObject:(NSDictionary *)postObject forIndex:(NSInteger)index
{
    CGFloat postTextHeight = [FlirtTableViewCell getPostTextHeight:postObject];
    CGFloat cellHeight = [FlirtTableViewCell getCellHeight:postObject];
    
    CGRect mainContainerFrame =  self.mainContainer.frame;
    mainContainerFrame.size.height = cellHeight;
    self.mainContainer.frame = mainContainerFrame;
    self.overlay.frame = mainContainerFrame;
    self.whiteOverlay.frame = mainContainerFrame;

    CGRect lineFrame =  self.line.frame;
    lineFrame.size.height = cellHeight;
    self.line.frame = lineFrame;
    
    CGRect roundFrame =  self.imageV.frame;
    roundFrame.origin.y = (cellHeight / 2) - (HEART_WIDTH / 2);
    self.imageV.frame = roundFrame;
    self.imageV.layer.cornerRadius = CGRectGetWidth(self.imageV.frame) / 2;
    
    CGRect postContainerFrame =  self.postContainer.frame;
    postContainerFrame.size.height = cellHeight;
    self.postContainer.frame = postContainerFrame;
    
    CGRect labelFrame =  self.postText.frame;
    labelFrame.size.height = postTextHeight;
    self.postText.frame = labelFrame;

   // NSLog(@"Main container width is %f - Postcontainer width is %f",CGRectGetWidth(mainContainerFrame),CGRectGetWidth(postContainerFrame));

    
    CGRect actionViewFrame = self.actionsView.frame;
    CGRect imageFrame = self.postImage.frame;
    
    if (postObject[@"parseObject"][@"pic"])
    {
        //Set Image View Frame
        imageFrame.origin.y = labelFrame.origin.y + postTextHeight + 7;
        imageFrame.size.height = IMAGEVIEW_HEIGHT;
        
        //Set Action View Frame
        actionViewFrame.origin.y = imageFrame.origin.y + imageFrame.size.height + 10;
    }else{
        
        //Set Image View Frame
        imageFrame.origin.y = 0;
        imageFrame.size.height = 0;
        
        //Set Action View Frame
        actionViewFrame.origin.y = labelFrame.origin.y + postTextHeight + 10;
    }
    
    self.postImage.frame = imageFrame;
    self.actionsView.frame = actionViewFrame;

    [self setValues:postObject];
}

- (void)setValues:(NSDictionary *)postObject
{
    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    NSInteger repliesCount = [postObject[@"totalReplies"] integerValue];
    
    self.date.text = [Config calculateTime:postObject[@"date"]];
    self.comments.text = [Config repliesCount:repliesCount];
    [self.comment setTitle:[Config likesCount:repliesCount] forState:UIControlStateNormal];
    [self.smiley setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
    
    PFObject *parseObject = postObject[@"parseObject"];
    
    NSString *text = [NSString stringWithFormat:@"%@: %@, %@. %@",parseObject[@"flirtLocation"], parseObject[@"gender"],parseObject[@"hairColor"], postObject[@"text"]];
    
    [self.postText setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:parseObject[@"flirtLocation"] options:NSCaseInsensitiveSearch];

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

+ (CGFloat)getPostTextHeight:(NSDictionary *)postObject
{
    PFObject *parseObject = postObject[@"parseObject"];
    
    NSString *text = [NSString stringWithFormat:@"%@:  %@, %@. %@",parseObject[@"flirtLocation"], parseObject[@"gender"],parseObject[@"hairColor"], postObject[@"text"]];
    
    return [Config calculateHeightForText:text
                                withWidth:MAIN_WIDTH
                                 withFont:TEXT_FONT];
}

+ (CGFloat)getCellHeight:(NSDictionary *)postObject
{
    CGFloat postTextHeight = [FlirtTableViewCell getPostTextHeight:postObject];
    
    return TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 3;
}


@end
