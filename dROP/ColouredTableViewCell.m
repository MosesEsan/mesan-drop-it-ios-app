//
//  ColouredTableViewCell.m
//  Drop It!
//
//  Created by Moses Esan on 20/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ColouredTableViewCell.h"

@implementation ColouredTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.mainContainer = [[UIView alloc] init];
        self.mainContainer.backgroundColor = [UIColor whiteColor];
        //self.mainContainer.clipsToBounds = YES;
        [self.contentView addSubview:self.mainContainer];
        
        self.line = [[UIView alloc] init];
        self.line.layer.borderWidth = 0.7f;
        [self.mainContainer addSubview:self.line];
        
        self.postContainer = [[UIView alloc] init];
        self.postContainer.backgroundColor = [UIColor clearColor];
        //self.postContainer.clipsToBounds = YES;
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
        
        
        self.postImage = [[PFImageView alloc] init];
        self.postImage.backgroundColor = [UIColor clearColor];
        self.postImage.layer.cornerRadius = 3.0f;
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
        
        self.comments = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 90, ACTIONS_VIEW_HEIGHT)];
        self.comments.backgroundColor = [UIColor clearColor];
        self.comments.textColor = DATE_COLOR;
        self.comments.textAlignment = NSTextAlignmentCenter;
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
    CGFloat postTextHeight = [ColouredTableViewCell getPostTextHeight:postObject];
    CGFloat cellHeight = [ColouredTableViewCell getCellHeight:postObject];
    
    if (postObject[@"parseObject"][@"pic"])
        cellHeight =  cellHeight + 10 + IMAGEVIEW_HEIGHT;
    
    CGRect mainContainerFrame = CGRectMake(0, 0, WIDTH, cellHeight);
    
    CGRect postContainerFrame = CGRectMake(L_PADDING, 0, CGRectGetWidth(mainContainerFrame) - (L_PADDING + (L_PADDING / 2)), cellHeight);
    CGRect labelFrame = CGRectMake(0, TOP_PADDING, CGRectGetWidth(postContainerFrame), postTextHeight);
    CGRect imageFrame = CGRectMake(0, 0, CGRectGetWidth(postContainerFrame), IMAGEVIEW_HEIGHT);
    
    CGRect actionViewFrame = CGRectMake(0, 0, CGRectGetWidth(postContainerFrame), ACTIONS_VIEW_HEIGHT);
    
    CGFloat remainingSpace = CGRectGetWidth(actionViewFrame) / 3;
    CGRect dateFrame = CGRectMake(0, 0, remainingSpace, ACTIONS_VIEW_HEIGHT);
    CGRect commentsFrame = CGRectMake(remainingSpace, 0, remainingSpace, ACTIONS_VIEW_HEIGHT);
    CGRect smileyFrame = CGRectMake((CGRectGetWidth(actionViewFrame)) - 65.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
    
    if (postObject[@"parseObject"][@"pic"])
    {
        //Set Image View Frame
        imageFrame.origin.y = labelFrame.origin.y + postTextHeight + 7;
        
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
    self.mainContainer.frame = mainContainerFrame;
    self.postContainer.frame = postContainerFrame;
    self.postText.frame = labelFrame;
    self.postImage.frame = imageFrame;
    self.actionsView.frame = actionViewFrame;
    self.date.frame = dateFrame;
    self.comments.frame = commentsFrame;
    self.smiley.frame = smileyFrame;
    
    self.line.backgroundColor = [Config getSideColor:index];
    self.line.layer.borderColor = [Config getSideColor:index].CGColor;
    [self setValues:postObject];
}

- (void)setValues:(NSDictionary *)postObject
{
    NSInteger likesCount = [postObject[@"totalLikes"] integerValue];
    NSInteger repliesCount = [postObject[@"totalReplies"] integerValue];
    
    // Configure the cell...
    self.postText.text = postObject[@"text"];
    self.date.text = [Config calculateTime:postObject[@"date"]];
    self.comments.text = [Config repliesCount:repliesCount];
    [self.smiley setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)getPostTextHeight:(NSDictionary *)postObject
{
    PFObject *parseObject = postObject[@"parseObject"];
    
    NSString *text = [NSString stringWithFormat:@"%@: %@, %@. ?%@",parseObject[@"flirtLocation"], parseObject[@"gender"],parseObject[@"hairColor"], postObject[@"text"]];
    
    return [Config calculateHeightForText:text
                                withWidth:WIDTH - 55.0f
                                 withFont:TEXT_FONT];
}

+ (CGFloat)getCellHeight:(NSDictionary *)postObject
{
    CGFloat postTextHeight = [ColouredTableViewCell getPostTextHeight:postObject];
    
    CGFloat height = TOP_PADDING + postTextHeight + 10 + ACTIONS_VIEW_HEIGHT + 5;
    
    if (postObject[@"parseObject"][@"pic"])
        height += 10 + IMAGEVIEW_HEIGHT;
    
    return height;
}

@end
