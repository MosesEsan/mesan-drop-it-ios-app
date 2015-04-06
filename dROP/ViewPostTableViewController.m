//
//  ViewPostTableViewController.m
//  dROP
//
//  Created by Moses Esan on 06/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "ViewPostTableViewController.h"
#import "Config.h"
#import <ParseUI/ParseUI.h>
#import "LPlaceholderTextView.h"
#import "UIFont+Montserrat.h"
#import "CommentTableViewCell.h"
#import "MHFacebookImageViewer.h"

#define SUB_CONTAINER_FRAME self.view.bounds

@interface ViewPostTableViewController ()<UITextViewDelegate>
{
    
    LPlaceholderTextView *commentTextView;
    
    CGRect currentPosition;
    
    CGRect defaultTableViewframe;
    CGRect defaultComposeViewframe;
    
    UIView *subviewContainer;
    UIView *composeContainer;
    UIButton *postButton;
    
    NSMutableArray *allComments;
    NSInteger likesCount;
    
    UIAlertView *reportPostAlertView;
}

@property (nonatomic, strong) UILabel *postText;
@property (nonatomic, strong) PFImageView *postImage;
@property (nonatomic, strong) UIView *actionsView;


@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIButton *smiley;
@property (nonatomic, strong) UIButton *likes;
@property (nonatomic, strong) UILabel *comments;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) MCSwipeTableViewCell *cellToDelete;

@end

@implementation ViewPostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Post";
    
    allComments = [[NSMutableArray alloc] init];
    
    //If the user is not the post authour
    //They can report the post
    if (![Config isPostAuthor:_postObject])
    {
        //Report Button
        UIButton *reportButton = [UIButton buttonWithType:UIButtonTypeCustom];
        reportButton.frame = CGRectMake(0, 0, 44, 44);
        reportButton.backgroundColor = [UIColor clearColor];
        [reportButton addTarget:self action:@selector(reportPost:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *reportImageview =
        [Config imageViewFrame:CGRectMake(24.0f, 12.0f, 20, 20)
                     withImage:[UIImage imageNamed:@"Report"]
                     withColor:[UIColor whiteColor]];
        reportImageview.userInteractionEnabled = YES;
        reportImageview.backgroundColor = [UIColor clearColor];
        [reportButton addSubview:reportImageview];
        
        UITapGestureRecognizer *report = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reportPost:)];
        [reportImageview addGestureRecognizer:report];

        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -8;
        [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, [[UIBarButtonItem alloc] initWithCustomView:reportButton], nil]];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:reportButton];
    }
    
    //Main View - Tableview, Textfield etc
    subviewContainer = [[UIView alloc] initWithFrame:SUB_CONTAINER_FRAME];
    subviewContainer.clipsToBounds = YES;
    [self.view addSubview:subviewContainer];
    
    defaultTableViewframe = self.view.frame;
    defaultTableViewframe.size.height = defaultTableViewframe.size.height - 119;
    
    _tableView = [[UITableView alloc] initWithFrame:defaultTableViewframe style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.backgroundColor =
    [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.1];
    [subviewContainer addSubview:_tableView];
    
    defaultComposeViewframe = CGRectMake(0, defaultTableViewframe.size.height, CGRectGetWidth(self.view.frame), 55);
    composeContainer = [[UIView alloc] initWithFrame:defaultComposeViewframe];
    composeContainer.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.4f];

    [subviewContainer addSubview:composeContainer];
    
    // Add the text view
    commentTextView = [[LPlaceholderTextView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(composeContainer.frame) - 85, CGRectGetHeight(composeContainer.frame) - 20)];
    [commentTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
    [commentTextView setReturnKeyType:UIReturnKeyDefault];
    [commentTextView.layer setCornerRadius:3.0f];
    [commentTextView setPlaceholderText:messagePlaceholderText];
    [commentTextView setTextColor:TEXT_COLOR];
    commentTextView.delegate = self;
    [commentTextView setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:13.0f]];
    commentTextView.backgroundColor = [UIColor whiteColor];
    [composeContainer addSubview:commentTextView];
    
    postButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    postButton.frame = CGRectMake(10 + CGRectGetWidth(commentTextView.frame) + 9, 10, 55, CGRectGetHeight(composeContainer.frame) - 20);
    [postButton setTitle:@"Post" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont montserratFontOfSize:15.0f];
    postButton.backgroundColor = BAR_TINT_COLOR2;
    postButton.layer.cornerRadius = 4.0f;
    postButton.enabled = NO;
    [postButton addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [composeContainer addSubview:postButton];
    
    //[UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.8f]; /*#d8d8d8*/
    
    [self.tableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"CommentCell"];
    
    _showCloseButton = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self tableHeader];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_showCloseButton == YES)
    {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(0, 0, 44, 44);
        closeButton.backgroundColor = [UIColor clearColor];
        [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *closeImageview =
        [Config imageViewFrame:CGRectMake(0, 12.0f, 20, 20)
                     withImage:[UIImage imageNamed:@"Close2"]
                     withColor:[UIColor whiteColor]];
        closeImageview.userInteractionEnabled = YES;
        closeImageview.backgroundColor = [UIColor clearColor];
        [closeButton addSubview:closeImageview];
        
        UITapGestureRecognizer *close = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        [closeImageview addGestureRecognizer:close];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    }
        
    [self queryForAllComments];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}


- (void)tableHeader
{
    NSString *postText = _postObject[@"text"];
    likesCount = [_postObject[@"totalLikes"] integerValue];
    NSInteger repliesCount = [_postObject[@"totalReplies"] integerValue];
    NSString *postDate = [Config calculateTime:_postObject[@"date"]];
    

    CGFloat postTextHeight = [self calculateHeightForText:postText withWidth:TEXT_WIDTH withFont:TEXT_FONT];
    CGFloat height;
    
    if (_postObject[@"parseObject"][@"pic"])
    {
        height = TOP_PADDING + postTextHeight + 10 + IMAGEVIEW_HEIGHT + 12 + ACTIONS_VIEW_HEIGHT + 2;        
    }else{
        height = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 2;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TEXT_WIDTH, height)];
    headerView.backgroundColor = [UIColor whiteColor];

    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, height - 1.0f,
                                    WIDTH, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:1].CGColor;
    [headerView.layer addSublayer:bottomBorder];
    
    //Set Frames
    NSDictionary *subViewframes = [Config subViewFrames:_postObject];
    //_cell.actionsView.frame = [subViewframes[@"actionViewframe"] CGRectValue];
    
    _postText = [[UILabel alloc] initWithFrame:[subViewframes[@"postTextFrame"] CGRectValue]];
    _postText.backgroundColor = [UIColor clearColor];
    _postText.numberOfLines = 0;
    _postText.textColor = TEXT_COLOR;
    _postText.textAlignment = NSTextAlignmentLeft;
    _postText.font = TEXT_FONT;
    _postText.text = postText;
    _postText.clipsToBounds = YES;
    _postText.userInteractionEnabled = YES;
    [headerView addSubview:_postText];
    
    
    if (_postObject[@"parseObject"][@"pic"])
    {
        //Set Image View Frame
        _postImage = [[PFImageView alloc] initWithFrame:[subViewframes[@"imageFrame"] CGRectValue]];
        _postImage.backgroundColor = [UIColor clearColor];
        _postImage.layer.cornerRadius = 5.0f;
        _postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        _postImage.clipsToBounds = YES;
        _postImage.contentMode = UIViewContentModeScaleAspectFill;
        [headerView addSubview:_postImage];
        
        _postImage.file = _postObject[@"parseObject"][@"pic"];
        [_postImage loadInBackground];
        _postImage.tag = 1;//indexPath.row;
        [_postImage setupImageViewerWithPFFile:_postImage.file onOpen:nil onClose:nil];
    }
    
    
    _actionsView = [[UIView alloc] initWithFrame:[subViewframes[@"actionViewframe"] CGRectValue]];
    _actionsView.backgroundColor = [UIColor clearColor];
    [headerView addSubview:_actionsView];

    _date = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, ACTIONS_VIEW_HEIGHT)];
    _date.backgroundColor = [UIColor clearColor];
    _date.textColor = DATE_COLOR;
    _date.textAlignment = NSTextAlignmentLeft;
    _date.font = DATE_FONT;
    _date.text = postDate;
    [_actionsView addSubview:_date];
    
    _comments = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 90, ACTIONS_VIEW_HEIGHT)];
    _comments.backgroundColor = [UIColor clearColor];
    _comments.textColor = DATE_COLOR;
    _comments.textAlignment = NSTextAlignmentLeft;
    _comments.font = COMMENTS_FONT;
    _comments.text = [Config repliesCount:repliesCount];
    [_actionsView addSubview:_comments];
    
    _smiley = [UIButton buttonWithType:UIButtonTypeCustom];
    _smiley.frame = CGRectMake((CGRectGetWidth(_actionsView.frame)) - 65.0f, 0, 65.0f, ACTIONS_VIEW_HEIGHT);
    _smiley.backgroundColor = [UIColor clearColor];
    [_smiley setImage:[UIImage imageNamed:@"SmileyGray"] forState:UIControlStateNormal];
    [_smiley setImage:[UIImage imageNamed:@"SmileyBluish"] forState:UIControlStateSelected];
    [_smiley setImage:[UIImage imageNamed:@"Sad"] forState:UIControlStateHighlighted];
    [_smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
    [_smiley setTitleColor:BAR_TINT_COLOR2 forState:UIControlStateSelected];
    _smiley.titleLabel.font = LIKES_FONT;
    _smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 15);
    _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -65, 0, 35);
    _smiley.tag = self.view.tag;
    [_actionsView addSubview:_smiley];
    
    [_smiley setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
    
    //if the user is the owner of the post
    //and the post has likes, show the smiley button
    //else hide it
    if ([Config isPostAuthor:_postObject])
    {
        if (likesCount > 0) _smiley.hidden = NO;
        else _smiley.hidden = YES;
    }
    
    
    //If the user is not the post authour
    //They can like, dislike and report the post
    if (![Config isPostAuthor:_postObject])
    {
        [_smiley addTarget:self action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (![_postObject[@"disliked"] boolValue]){
        _smiley.selected = [_postObject[@"liked"] boolValue];
    }else{
        _smiley.highlighted = [_postObject[@"disliked"] boolValue];
    }

    self.tableView.tableHeaderView = headerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [allComments count];
}

- (CGFloat)calculateHeightForText:(NSString *)text withWidth:(CGFloat)width withFont:(UIFont *)font
{
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *commentObject = allComments[indexPath.row];
    NSString *commentText = commentObject[@"text"];
    NSInteger smileyCount = [commentObject[@"totalLikes"] integerValue];
    NSString *cellIdentifier = [NSString stringWithFormat:@"CommentCell%ld",(long)indexPath.row];
    
    
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    // Configure the cell...
    cell.commentText.text = commentObject[@"text"];
    cell.date.text = [Config calculateTime:commentObject[@"date"]];
    
    //Set Label Frame
    CGFloat postTextHeight = [Config calculateHeightForText:commentText withWidth:TEXT_WIDTH withFont:TEXT_FONT];
    CGRect labelFrame = cell.commentText.frame;
    labelFrame.size.height = postTextHeight;
    cell.commentText.frame = labelFrame;
    
    //Set Action View Frame
    CGRect frame = cell.actionsView.frame;
    frame.origin.y = labelFrame.origin.y + postTextHeight + 10;
    cell.actionsView.frame = frame;
    
    
    // Configure the cell...
    [cell.smiley setTitle:[Config likesCount:smileyCount] forState:UIControlStateNormal];
    
    //if the user is the owner of the comment
    //and the comment has likes, show the smiley button
    //else hide it
    if ([Config isPostAuthor:commentObject])
    {
        if (smileyCount > 0) cell.smiley.hidden = NO;
        else cell.smiley.hidden = YES;
    }
    
    //If the value for the disliked index is not YES,
    //set the smiley selected state to the value of the liked index
    if (![commentObject[@"disliked"] boolValue]){
        cell.smiley.selected = [commentObject[@"liked"] boolValue];
    }else{
        //else  set the smiley selected state to NO
        //set the smiley highlighted state to the value of the disliked index to indicate the user has disliked the post
        cell.smiley.selected = NO;
        cell.smiley.highlighted = [commentObject[@"disliked"] boolValue];
    }
    
    //If the user is not the comment authour
    //They can like, dislike and report the comment
    if (![Config isPostAuthor:commentObject])
    {
        cell.smiley.tag = indexPath.row;
        [cell.smiley addTarget:self action:@selector(likeComment:) forControlEvents:UIControlEventTouchUpInside];
        
        __weak typeof(cell) weakSelf = cell;
        
        [cell setSwipeGestureWithView:[Config viewWithImageName:@"cross"]
                                color:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                                    
                                    _cellToDelete = weakSelf;
                                    
                                    
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Options?"
                                                                                        message:@"What would you like to do?"
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"Cancel"
                                                                              otherButtonTitles:@"Dislike", @"Report",nil];
                                    [alertView show];
                                }];
    }else if ([Config isPostAuthor:commentObject]){
        
        //If the user is th author of the post
        //allow the user to be able to delete the post
        __weak typeof(cell) weakSelf = cell;
        
        [cell setSwipeGestureWithView:[Config viewWithImageName:@"cross"]
                                color:[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0]
                                 mode:MCSwipeTableViewCellModeExit
                                state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
                                    
                                    _cellToDelete = weakSelf;
                                    
                                    
                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Comment"
                                                                                        message:@"Are yu sure you want to delete this comment?"
                                                                                       delegate:self
                                                                              cancelButtonTitle:@"No"
                                                                              otherButtonTitles:@"Yes",nil];
                                    [alertView show];
                                }];
    }
    

    
    
    cell.tag = indexPath.row;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *commentObject = allComments[indexPath.row];
    NSString *commentText = commentObject[@"text"];
    
    CGFloat postTextHeight = [Config calculateHeightForText:commentText withWidth:TEXT_WIDTH withFont:TEXT_FONT];
    
    return TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT + 2;
}


#pragma mark - UITextView Delegate Methods
-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // if the user clicked the return key
    if ([text isEqualToString: @"\n"]) {
        // Hide the keyboard
        [textView resignFirstResponder];
        
        return NO ;
    }
    
    return YES ;
}

- (void)textViewDidChange:(UITextView *)textView
{

    NSInteger commentLength = [[textView text] length];

    if (commentLength <= 0) postButton.enabled = NO;
    else if (commentLength > 0)
    {
        postButton.enabled = YES;
        
        [self resetSubView];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    //Get and save the current caption location
    currentPosition = subviewContainer.frame;
    
    NSDictionary* info = [aNotification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect rect = SUB_CONTAINER_FRAME;
    rect.size.height = SUB_CONTAINER_FRAME.size.height - kbSize.height + 64.0f; //Add 64.0f to accomodate for the navigationbar
    subviewContainer.frame = rect;
    
    [self resetSubView];
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Move caption to original position
    subviewContainer.frame = currentPosition;
    
    [self resetSubView];
}

- (void)resetSubView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    subviewContainer.frame = subviewContainer.frame;
    
    //Get the contentsize of the UITextview
    float height = commentTextView.contentSize.height;
    
    //1- set UITextview new size
    CGRect frame = commentTextView.frame;
    frame.size.height = height;
    commentTextView.frame = frame;
    
    //2 - Set The Compose Container
    frame = composeContainer.frame;
    frame.size.height = 10 + height + 10.0; //Padding (10) at top and bottom
    
    //3 - Set Tableview Frame
    CGRect tableViewFrame = _tableView.frame;
    tableViewFrame.size.height = subviewContainer.frame.size.height - 64.0f - frame.size.height;
    _tableView.frame = tableViewFrame;
    
    frame.origin.y = tableViewFrame.size.height;
    composeContainer.frame = frame;
    
    [UIView commitAnimations];
}

- (void)resetToDefault
{
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [commentTextView resignFirstResponder];
    
    commentTextView.text = @"";
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    subviewContainer.frame = SUB_CONTAINER_FRAME;
    
    CGRect tableViewFrame = self.view.frame;
    tableViewFrame.size.height = tableViewFrame.size.height - 119;
    
    _tableView.frame = defaultTableViewframe;
    composeContainer.frame = defaultComposeViewframe;
    commentTextView.frame = CGRectMake(10, 10, CGRectGetWidth(composeContainer.frame) - 85, CGRectGetHeight(composeContainer.frame) - 20);
    
    [UIView commitAnimations];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView == reportPostAlertView)
    {
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Cancel"])
        {
            //do nothing
        }else{
            
            //update array and database
            [self.delegate reportPost:self.view.tag];
            
            ///close
            [self.navigationController popViewControllerAnimated:TRUE];
        }
    }else{
        
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Dislike"]) {
            
            [_cellToDelete swipeToOriginWithCompletion:^{
                [self dislikeComment:_cellToDelete.tag];
                _cellToDelete = nil;
            }];
            
        }else if([title isEqualToString:@"Report"]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report Post"
                                                                message:@"Please tell us what is wrong with ths post."
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Offensive content", @"Spam", @"Other", nil];
            [alertView show];
        }else if([title isEqualToString:@"Offensive content"] ||
                 [title isEqualToString:@"Spam"] ||
                 [title isEqualToString:@"Other"])
        {
            [self reportComment:_cellToDelete.tag];
            [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
        }else if([title isEqualToString:@"Yes"]) {
            [self deleteComment:_cellToDelete.tag];
            [self.tableView deleteRowsAtIndexPaths:@[[self.tableView indexPathForCell:_cellToDelete]] withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [_cellToDelete swipeToOriginWithCompletion:^{
            }];
            
            _cellToDelete = nil;
        }
    }
}

- (void)close:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}







#pragma mark - Main Methods
//Retrieve Comments
- (void)queryForAllComments
{
    dispatch_queue_t commentsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(commentsQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            PFObject *parseObject = _postObject[@"parseObject"];
            
            PFQuery *query = [PFQuery queryWithClassName:COMMENTS_CLASS_NAME];
            [query whereKey:@"postId" equalTo:parseObject.objectId];
            [query orderByAscending:@"createdAt"];
            /*
             // If no objects are loaded in memory, we look to the cache first to fill the table
             // and then subsequently do a query against the network.
             if ([allComments count] == 0)
             {
             query.cachePolicy = kPFCachePolicyCacheThenNetwork;
             }
             */
            query.limit = 20;
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    
                    NSMutableArray *filteredComments = [Config filterComments:objects];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        allComments = filteredComments;
                        [_tableView reloadData];
                    });
                }
            }];
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
            });
        }
    });
}

//Add New Comment
- (void)addComment:(UIButton *)sender
{
    NSInteger commentLength = [[commentTextView text] length];
    
    if (commentLength > 0)
    {
        NSString *commenttext = commentTextView.text;
        
        [self resetToDefault];
        
        NSInteger repliesCount = [_postObject[@"totalReplies"] integerValue];
        repliesCount++;
        
        PFObject *parseObject = _postObject[@"parseObject"];
        
        //Create Parse Comment Object
        PFObject *commentObject = [PFObject objectWithClassName:COMMENTS_CLASS_NAME];
        commentObject[@"text"] = commenttext;
        commentObject[@"deviceId"] = [Config deviceId];
        commentObject[@"postId"] = parseObject.objectId;
        commentObject[@"post"] = parseObject;
        
        // Use PFACL to restrict future modifications to this object.
        PFACL *readOnlyACL = [PFACL ACL];
        [readOnlyACL setPublicReadAccess:YES];
        [readOnlyACL setPublicWriteAccess:YES];
        commentObject.ACL = readOnlyACL;
        
        NSDictionary *comments = [Config createCommentObject:commentObject];
        [allComments addObject:comments];
        
        //Update main array with new replies count value
        [_postObject setValue:[NSNumber numberWithInteger:repliesCount] forKey:@"totalReplies"];
        [_delegate updateAllPostsArray:self.view.tag withPostObject:_postObject];
        
        [_tableView reloadData];
        
        [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"Couldn't save!");
                NSLog(@"%@", error);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error userInfo][@"error"]
                                                                    message:nil
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Ok", nil];
                [alertView show];
                return;
            }
            if (succeeded) {
                NSLog(@"Successfully saved!");
                NSLog(@"%@", commentObject);
                
                [parseObject addUniqueObject:commentObject.objectId forKey:@"replies"];
                [parseObject saveInBackground];
            } else {
                NSLog(@"Failed to save.");
            }
        }];
        
    }else{
        //Do nothing
    }
}

//Like Post
- (void)likePost:(UIButton *)sender
{
    //figure out the new likes count value
    if (sender.selected == YES) likesCount--;
    else likesCount++;
    
    [self.delegate likePost:sender];
    
    //increment or decrement total likes
    [sender setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
}

//Report Post
- (void)reportPost:(id)sender
{
    reportPostAlertView = [[UIAlertView alloc] initWithTitle:@"Report Post"
                                                        message:@"Please tell us what is wrong with ths post."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Offensive content", @"Spam", @"Other", nil];
    [reportPostAlertView show];
}

//Like Comment
- (void)likeComment:(UIButton *)sender
{
    //Get the comment object
    NSDictionary *commentObject = allComments[sender.tag];
    
    //Get the current liked value and the current total likes
    BOOL selected = [commentObject[@"liked"] boolValue];
    NSInteger smileyCount = [commentObject[@"totalLikes"] integerValue];
    
    //change the buttons state
    sender.selected = !selected;
    
    //Update the comment object liked and disliked value
    [commentObject setValue:[NSNumber numberWithBool:!selected] forKey:@"liked"];
    [commentObject setValue:[NSNumber numberWithBool:NO] forKey:@"disliked"];
    
    //get the Parse Object
    PFObject *parseObject = commentObject[@"parseObject"];
    
    //If the current liked value is NO, which means the user is liking the comment
    if (selected == NO)
    {
        //increment the total likes count
        smileyCount++;
        
        //Add the users device Id to the parse object likes array and remove it (if it exist)
        //from the disliked array
        [parseObject addUniqueObject:[Config deviceId] forKey:@"likes"];
        [parseObject removeObject:[Config deviceId] forKey:@"dislikes"];
        
        //Set the type of update that is being carried out
        parseObject[@"type"] = LIKE_POST_TYPE;
        
    }else if (selected == YES){
        //If the current liked value is YES, which means the user is unliking the comment
        
        //decrement the total likes count
        smileyCount--;
        
        //Unlike Post
        [parseObject removeObject:[Config deviceId] forKey:@"likes"];
        
        //Set the type of update that is being carried out
        parseObject[@"type"] = UNLIKE_POST_TYPE;
    }
    
    //Update the value of the likes count
    [commentObject setValue:[NSNumber numberWithInteger:smileyCount] forKey:@"totalLikes"];
    
    //Replace the comment object with the modified comment object
    allComments[sender.tag] = commentObject;
    
    //Reload the table to reflect the changes
    [self.tableView reloadData];
    
    //Save the parse object
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            sender.selected = selected; //return it to its previous state
            //sort out the count
        }
    }];
}

//Dislike Comment
- (void)dislikeComment:(NSInteger)tag
{
    //Get the comment object
    NSDictionary *commentObject = allComments[tag];
        
    //Get the current dislike value
    BOOL highlighted = [commentObject[@"disliked"] boolValue];
    
    //Update the comment object disliked value
    [commentObject setValue:[NSNumber numberWithBool:!highlighted] forKey:@"disliked"];
    
    //get the Parse Object
    PFObject *parseObject = commentObject[@"parseObject"];
    
    //If the current dislike value is NO, which means the user is disliking the comment
    if (highlighted == NO)
    {
        //Add the users device Id to the parse object dislikes array and remove it (if it exist)
        //from the likes array
        [parseObject addUniqueObject:[Config deviceId] forKey:@"dislikes"];
        [parseObject removeObject:[Config deviceId] forKey:@"likes"];
        
        //Set the type of update that is being carried out
        parseObject[@"type"] = DISLIKE_POST_TYPE;
        
        //If user had previously liked this comment
        //decrement the likes number
        BOOL liked = [commentObject[@"liked"] boolValue];
        if(liked == YES)
        {
            //decrement the total likes count
            NSInteger smileyCount = [commentObject[@"totalLikes"] integerValue];
            smileyCount--;
            //Update the value of the likes count
            [commentObject setValue:[NSNumber numberWithInteger:smileyCount] forKey:@"totalLikes"];
        }
        
        //Update the comment object liked value
        [commentObject setValue:[NSNumber numberWithBool:NO] forKey:@"liked"];
    }

    //Replace the comment object with the modified comment object
    allComments[tag] = commentObject;
    
    //Reload the table to reflect the changes
    [self.tableView reloadData];
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            NSLog(@"Notdisliked");
        /****attn*/
        if(error){
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            //sort out the count
        }
    }];
}

//Report Comment
- (void)reportComment:(NSInteger)tag
{
    //Get the comment object
    NSDictionary *commentObject = allComments[tag];
    
    //get the Parse Object and Report Post
    PFObject *parseObject = commentObject[@"parseObject"];
    
    //Add the users device Id to the parse object reports array
    [parseObject addUniqueObject:[Config deviceId] forKey:@"reports"];
    
    //Set the type of update that is being carried out
    parseObject[@"type"] = REPORT_POST_TYPE;
    
    [parseObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error)
            //_cellToDelete.highlighted = highlighted; //return it to its previous state
            NSLog(@"NotReported");
        /****attn*/
    }];
    
    //Remove the comment object from the array
    [allComments removeObjectAtIndex:tag];
}

//Delete Comment
- (void)deleteComment:(NSInteger)tag
{
    //Get the comment object
    NSDictionary *commentObject = allComments[tag];
    
    //get the Parse Object
    PFObject *parseObject = commentObject[@"parseObject"];
    
    //remove the comment object id from the post replies array
    PFObject *postParseObject = _postObject[@"parseObject"];
    
    [postParseObject removeObject:parseObject.objectId forKey:@"replies"];
    [postParseObject saveInBackground];
    
    //Delete the parse object from the datastore
    [parseObject deleteInBackground];
    
    //Remove the comment object from the array
    [allComments removeObjectAtIndex:tag];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
