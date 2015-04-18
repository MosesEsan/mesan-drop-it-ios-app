//
//  MapPostViewController.m
//  Drop It!
//
//  Created by Moses Esan on 16/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "MapPostViewController.h"
#import "Config.h"
#import "UIFont+Montserrat.h"
#import "MHFacebookImageViewer.h"
#import "CommentsTableViewController.h"

#define ADD_BOX_FRAME CGRectMake(10, 20 + 64.0f, ADD_POST_WIDTH, ADD_POST_HEIGHT)
#define HEADER_HEIGHT 45.0f
#define IMAGEVIEW_HEIGHT2 IMAGEVIEW_HEIGHT + 12 + ACTIONS_VIEW_HEIGHT

//#define TOP_PADDING2 TOP_PADDING

@interface MapPostViewController ()
{
    UIButton *_sad;
    UIButton *_smiley;
    UIButton *_report;
    UIButton *totalLikes;
    
    NSInteger likesCount;
}
@end

@implementation MapPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    //Calculate height
    CGFloat boxHeight;
    NSString *postText = _postObject[@"text"];
    likesCount = [_postObject[@"totalLikes"] integerValue];
    NSInteger repliesCount = [_postObject[@"totalReplies"] integerValue];
    NSString *postDate = [Config calculateTime:_postObject[@"date"]];
    
    
    CGFloat postTextHeight = [Config calculateHeightForText:postText withWidth:ADD_POST_WIDTH - 14 withFont:TEXT_FONT];
    
     if (_postObject[@"parseObject"][@"pic"])
     {
         boxHeight = HEADER_HEIGHT + TOP_PADDING + postTextHeight + 7 + IMAGEVIEW_HEIGHT2 + 12 + ACTIONS_VIEW_HEIGHT + 5;
     }else{
         boxHeight = HEADER_HEIGHT + TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 5;
     }
    
    //Set Frame
    CGRect labelFrame = CGRectMake(8, TOP_PADDING, ADD_POST_WIDTH - 14, postTextHeight);
    CGRect imageFrame = CGRectMake(8, 0, ADD_POST_WIDTH - 14, 0);
    CGRect actionViewframe = CGRectMake(8, 0, ADD_POST_WIDTH - 14, ACTIONS_VIEW_HEIGHT);
    
    if (_postObject[@"parseObject"][@"pic"])
    {
        //Set Image View Frame
        imageFrame.origin.y = labelFrame.origin.y + postTextHeight + 7;
        imageFrame.size.height = IMAGEVIEW_HEIGHT2;
        
        //Set Action View Frame
        actionViewframe.origin.y = imageFrame.origin.y + imageFrame.size.height + 10;
    }else{
        
        //Set Image View Frame
        imageFrame.origin.y = 0;
        imageFrame.size.height = 0;
        
        //Set Action View Frame
        actionViewframe.origin.y = labelFrame.origin.y + postTextHeight + 10;
    }
    
    UIView *addDialog = [[UIView alloc] initWithFrame:CGRectMake(10, 20 + 24.0f, ADD_POST_WIDTH, boxHeight)];
    addDialog.backgroundColor = [UIColor whiteColor];
    addDialog.layer.cornerRadius = 6.0f;
    addDialog.clipsToBounds = YES;
    //addDialog.layer.borderWidth = 0.9f;
    //addDialog.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:addDialog];
    
    UIButton *header = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ADD_POST_WIDTH, HEADER_HEIGHT)];
    header.backgroundColor = BAR_TINT_COLOR2;
    [header setTitle:@"Tap Here To Close" forState:UIControlStateNormal];
    [header addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    header.titleLabel.font= [UIFont montserratFontOfSize:15.5f];
    header.titleLabel.textColor = [UIColor whiteColor];
    [addDialog addSubview:header];
    
    UIImageView *closeImageview =
    [Config imageViewFrame:CGRectMake(10.5f, 10.5f, 23, 23)
                 withImage:[UIImage imageNamed:@"Close2"]
                 withColor:[UIColor whiteColor]];
    closeImageview.userInteractionEnabled = YES;
    //[header addSubview:closeImageview];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(header.frame))];
    closeButton.backgroundColor = [UIColor clearColor];
    //[closeButton setImage:[UIImage imageNamed:@"Close"] forState:UIControlStateNormal];
    //[closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 6)];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    //[header addSubview:closeButton];
    
    UIView *_postContainer = [[UIView alloc] init];
    _postContainer.frame = CGRectMake(0, HEADER_HEIGHT, ADD_POST_WIDTH, boxHeight - HEADER_HEIGHT);
    _postContainer.backgroundColor = [UIColor clearColor];
    _postContainer.clipsToBounds = YES;
    [addDialog addSubview:_postContainer];
    UITapGestureRecognizer *viewComments = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewComments:)];
    [_postContainer addGestureRecognizer:viewComments];
    
    UILabel *_postText = [[UILabel alloc] initWithFrame:labelFrame];
    _postText.backgroundColor = [UIColor clearColor];
    _postText.numberOfLines = 0;
    _postText.text = postText;
    _postText.textColor = TEXT_COLOR;
    _postText.textAlignment = NSTextAlignmentLeft;
    _postText.font = TEXT_FONT;
    _postText.clipsToBounds = YES;
    _postText.userInteractionEnabled = YES;
    [_postContainer addSubview:_postText];
    
    PFImageView *_postImage = [[PFImageView alloc] initWithFrame:imageFrame];
    _postImage.backgroundColor = [UIColor clearColor];
    _postImage.layer.cornerRadius = 5.0f;
    _postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
    _postImage.clipsToBounds = YES;
    _postImage.contentMode = UIViewContentModeScaleAspectFill;
    _postImage.userInteractionEnabled = YES;
    [_postContainer addSubview:_postImage];
    
    if (_postObject[@"parseObject"][@"pic"])
    {
        _postImage.file = _postObject[@"parseObject"][@"pic"];
        _postImage.tag = 1;//indexPath.row;
        [_postImage loadInBackground];
        [_postImage setupImageViewerWithPFFile:_postImage.file onOpen:nil onClose:nil];
    }
    
    UIView *_postInfo = [[UIView alloc] initWithFrame:actionViewframe];
    _postInfo.backgroundColor = [UIColor clearColor];
    [_postContainer addSubview:_postInfo];
    
    UILabel *_date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, ACTIONS_VIEW_HEIGHT)];
    _date.backgroundColor = [UIColor clearColor];
    _date.textColor = DATE_COLOR;
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = DATE_FONT;
    _date.text = postDate;
    [_postInfo addSubview:_date];
    
    UILabel *_comments = //[[UILabel alloc] initWithFrame:CGRectMake(75, 0, 90, ACTIONS_VIEW_HEIGHT)];
    [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(actionViewframe) - 90, 0, 90, ACTIONS_VIEW_HEIGHT)];
    _comments.backgroundColor = [UIColor clearColor];
    _comments.textColor = DATE_COLOR;
    _comments.textAlignment = NSTextAlignmentRight;
    _comments.font = COMMENTS_FONT;
    _comments.text = [Config repliesCount:repliesCount];
    [_postInfo addSubview:_comments];
    
    //If the user is not the post authour
    //They can like, dislike and report the post
    //Create the action view
    if (![Config isPostAuthor:_postObject])
    {
        UIView *_actionsView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 120, CGRectGetWidth(self.view.frame), 100)];
        _actionsView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_actionsView];
        
        _sad = [UIButton buttonWithType:UIButtonTypeCustom];
        _sad.frame = CGRectMake(((CGRectGetWidth(_actionsView.frame))/4) - (45/2), 22.5f, 45.0f, 45.0f);
        _sad.backgroundColor = [UIColor whiteColor];
        [_sad setImage:[UIImage imageNamed:@"SadGray"] forState:UIControlStateNormal];
        [_sad setImage:[UIImage imageNamed:@"Sad"] forState:UIControlStateSelected];
        [_sad setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [_sad setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
        _sad.titleLabel.font = LIKES_FONT;
        _sad.layer.cornerRadius = 45 / 2;
        _sad.layer.borderWidth = 2.0f;
        _sad.layer.borderColor = BAR_TINT_COLOR2.CGColor;
        _sad.imageEdgeInsets = UIEdgeInsetsMake(11, 11, 11, 11);
        [_sad addTarget:self action:@selector(dislikePost:) forControlEvents:UIControlEventTouchUpInside];
        _sad.tag = _index;
        [_actionsView addSubview:_sad];
        
        _smiley = [UIButton buttonWithType:UIButtonTypeCustom];
        _smiley.frame = CGRectMake(((CGRectGetWidth(_actionsView.frame))/2) - (65/2), 12.5f, 65.0f, 65.0f);
        _smiley.backgroundColor = [UIColor whiteColor];
        [_smiley setImage:[UIImage imageNamed:@"SmileyGray"] forState:UIControlStateNormal];
        [_smiley setImage:[UIImage imageNamed:@"SmileyBluish"] forState:UIControlStateSelected];
        _smiley.layer.cornerRadius = 65 / 2;
        _smiley.layer.borderWidth = 2.0f;
        _smiley.layer.borderColor = BAR_TINT_COLOR2.CGColor;
        [_smiley addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
        _smiley.tag = _index;
        [_actionsView addSubview:_smiley];
        
        if (![_postObject[@"disliked"] boolValue]){
            //the user has not disliked the post
            _smiley.selected = [_postObject[@"liked"] boolValue];
        }else{
            //the user has disliked the photo
            _smiley.selected = NO;
            _sad.highlighted = [_postObject[@"disliked"] boolValue];
        }
        
        totalLikes = [[UIButton alloc] initWithFrame:CGRectMake(((CGRectGetWidth(_actionsView.frame))/2) - (65/2), 12.5f + 70.0f, 65.0f, 20.0f)];
        totalLikes.backgroundColor = [UIColor clearColor];
        [totalLikes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [totalLikes setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
        totalLikes.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        totalLikes.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:13.0f];
        [totalLikes setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
        [_actionsView addSubview:totalLikes];
        
        _report = [UIButton buttonWithType:UIButtonTypeCustom];
        _report.frame = CGRectMake(CGRectGetWidth(_actionsView.frame) -
                                   (CGRectGetWidth(_actionsView.frame)/4) - (45/2),
                                   22.5f, 45.0f, 45.0f);
        _report.backgroundColor = [UIColor whiteColor];
        [_report setImage:[UIImage imageNamed:@"Report"] forState:UIControlStateNormal];
        [_report setTitleColor:DATE_COLOR forState:UIControlStateNormal];
        [_report setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
        _report.titleLabel.font = LIKES_FONT;
        _report.layer.cornerRadius = 45 / 2;
        _report.layer.borderWidth = 2.0f;
        _report.layer.borderColor = BAR_TINT_COLOR2.CGColor;
        _report.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _report.imageEdgeInsets = UIEdgeInsetsMake(11, 11, 11, 11);
        [_report addTarget:self action:@selector(reportPost:) forControlEvents:UIControlEventTouchUpInside];
        _report.tag = _index;
        [_actionsView addSubview:_report];
    }
}

- (void)viewComments:(UITapGestureRecognizer *)gesture
{
    CommentsTableViewController *viewComments = [[CommentsTableViewController alloc] initWithNibName:nil bundle:nil];
    viewComments.postObject = _postObject;
    viewComments.view.tag = _index;
    viewComments.viewType = HOME;
    viewComments.showCloseButton = YES;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewComments];
    navController.navigationBar.barStyle = BAR_STYLE;
    navController.navigationBar.barTintColor = BAR_TINT_COLOR2;
    navController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    navController.navigationBar.translucent = NO;
    
    [self presentViewController:navController animated:YES completion:nil];
}


- (void)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dislikePost:(UIButton *)sender
{
    //make smiley normal
    _smiley.selected = NO;
    
    //make sender selected
    sender.selected = YES;
    
    //update array and database
    [self.delegate dislikePost:sender.tag];
    
    //decrement total likes
    [totalLikes setTitle:[Config likesCount:likesCount--] forState:UIControlStateNormal];
}

- (void)reportPost:(UIButton *)sender
{
    //update array and database
    [self.delegate reportPost:sender.tag];
    
    //show label
    
    ///close
    [self close:sender];
}

#pragma mark - ViewPostViewControllerDelegate

- (void)likePost:(UIButton *)sender
{
    //figure out the new likes count value
    if (sender.selected == YES) likesCount--;
    else likesCount++;
    
    //make sad normal
    _sad.selected = NO;
    
    //update array and database
    [self.delegate likePost:sender];
    
    //increment or decrement total likes
    [totalLikes setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
}

- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject
{
    [self.delegate updateAllPostsArray:index withPostObject:postObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
