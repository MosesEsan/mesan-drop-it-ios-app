//
//  ProfileTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 25/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ProfileTableViewCell.h"

#define LEFT_PADDING 16.5f

#define POST_TEXT_WIDTH WIDTH - 16.5f - (LEFT_PADDING * 2)

@implementation ProfileTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.mainContainer = [[UIView alloc] init];
        self.mainContainer.backgroundColor = [UIColor clearColor];
        self.mainContainer.clipsToBounds = YES;
        //self.mainContainer.layer.borderWidth = 0.5f;
        //self.mainContainer.layer.borderColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;
        [self.contentView addSubview:self.mainContainer];
        
        self.line = [[UIView alloc] init];
        self.line.backgroundColor = [UIColor whiteColor];
        [self.mainContainer addSubview:self.line];
        
        self.profilePic = [[UIImageView alloc] initWithFrame:CGRectMake(5, TOP_PADDING, 35.0f, 35.0f)];
        self.profilePic.backgroundColor = [BAR_TINT_COLOR2 colorWithAlphaComponent:0.3];//[UIColor whiteColor];
        self.profilePic.layer.borderWidth = .2f;
        self.profilePic.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.profilePic.contentMode = UIViewContentModeScaleAspectFit;
        self.profilePic.layer.masksToBounds = YES;
        self.profilePic.clipsToBounds = YES;
        self.profilePic.layer.cornerRadius = CGRectGetWidth(self.profilePic.frame) / 2;
        [self.line addSubview:self.profilePic];
        
        
        
        self.postContainer = [[UIView alloc] init];
        self.postContainer.backgroundColor = [UIColor whiteColor];
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
        [self.postContainer addSubview:self.postText];
        
        
        self.postImage = [[PFImageView alloc] init];
        self.postImage.backgroundColor = [UIColor clearColor];
        self.postImage.layer.cornerRadius = 5.0f;
        self.postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        self.postImage.clipsToBounds = YES;
        self.postImage.contentMode = UIViewContentModeScaleAspectFill;
        self.postImage.userInteractionEnabled = YES;
        [self.postContainer addSubview:self.postImage];
        
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
        
        self.bottomBorder = [CALayer layer];
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1].CGColor;
        self.bottomBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.5].CGColor;
        [self.mainContainer.layer addSublayer:self.bottomBorder];
        
    }
    
    return self;
}


- (void)setFrameWithObject:(NSDictionary *)postObject forIndex:(NSInteger)index
{
    
    
    CGFloat mainContainerWidth = WIDTH - (CONTAINER_FRAME_X + (CONTAINER_FRAME_X / 2) + 2);
    CGFloat postContainerWidth = mainContainerWidth - PROFILE_PIC_WIDTH;
    CGFloat labelWidth = postContainerWidth - 8;
    
    CGFloat postTextHeight = [Config calculateHeightForText:postObject[@"text"] withWidth:labelWidth withFont:TEXT_FONT];
    
    CGFloat cellHeight = [Config calculateCellHeight:postObject];
    
    CGRect mainContainerFrame = CGRectMake(CONTAINER_FRAME_X, 0, mainContainerWidth, cellHeight);
    
    CGRect lineFrame = CGRectMake(0, 0, PROFILE_PIC_WIDTH, cellHeight);
    CGRect postContainerFrame = CGRectMake(PROFILE_PIC_WIDTH, 0, postContainerWidth, cellHeight); //1 Added to cover up left border
    
    CGRect labelFrame = CGRectMake(0, TOP_PADDING, labelWidth, postTextHeight);
    CGRect imageFrame = CGRectMake(0, 0, labelWidth, IMAGEVIEW_HEIGHT);
    CGRect actionViewFrame = CGRectMake(0, 0, labelWidth + 8, ACTIONS_VIEW_HEIGHT);
    CGRect smileyFrame = CGRectMake((CGRectGetWidth(actionViewFrame)) - 65.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
    
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
    
    //Set Frames
    self.line.frame = lineFrame;
    
    self.mainContainer.frame = mainContainerFrame;
    self.postContainer.frame = postContainerFrame;
    self.postText.frame = labelFrame;
    self.postImage.frame = imageFrame;
    self.actionsView.frame = actionViewFrame;
    self.smiley.frame = smileyFrame;
    
    if (postObject[@"parseObject"][@"avatar"]){
        self.profilePic.image = [UIImage imageNamed:postObject[@"parseObject"][@"avatar"]];
    }else{
        self.profilePic.image = [UIImage imageNamed:[Config fruits]];
    }
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
