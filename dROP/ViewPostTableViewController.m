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
    
    BOOL isKeyboardShown;

}

@property (nonatomic, strong) UILabel *postText;
@property (nonatomic, strong) PFImageView *postImage;
@property (nonatomic, strong) UIView *actionsView;


@property (nonatomic, strong) UILabel *date;
@property (nonatomic, strong) UIButton *smiley;
@property (nonatomic, strong) UIButton *likes;
@property (nonatomic, strong) UILabel *comments;

@property (nonatomic, strong) UITableView *tableView;



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
    
    subviewContainer = [[UIView alloc] initWithFrame:self.view.bounds];
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
    postButton.backgroundColor = BAR_TINT_COLOR;
    postButton.layer.cornerRadius = 4.0f;
    postButton.enabled = NO;
    [postButton addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    
    [composeContainer addSubview:postButton];
    
    //[UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.8f]; /*#d8d8d8*/
    
    [self.tableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"CommentCell"];
    
    isKeyboardShown = NO;


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self queryForAllComments];
    
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
    NSInteger likesCount = [_postObject[@"totalLikes"] integerValue];
    NSInteger repliesCount = [_postObject[@"totalReplies"] integerValue];
    NSString *postDate = [Config calculateTime:_postObject[@"date"]];
    

    CGFloat postTextHeight = [self calculateHeightForText:postText withWidth:TEXT_WIDTH withFont:TEXT_FONT];
    CGFloat height;
    
    if (_postObject[@"parseObject"][@"picture"])
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
    
    
    if (_postObject[@"parseObject"][@"picture"])
    {
        //Set Image View Frame
        _postImage = [[PFImageView alloc] initWithFrame:[subViewframes[@"imageFrame"] CGRectValue]];
        _postImage.backgroundColor = [UIColor clearColor];
        _postImage.layer.cornerRadius = 5.0f;
        _postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        _postImage.clipsToBounds = YES;
        _postImage.contentMode = UIViewContentModeScaleAspectFill;
        [headerView addSubview:_postImage];
        
        _postImage.file = _postObject[@"parseObject"][@"picture"];
        [_postImage loadInBackground];
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
    [_smiley setImage:[UIImage imageNamed:@"SmileyGray-Small"] forState:UIControlStateNormal];
    [_smiley setImage:[UIImage imageNamed:@"SmileyBluish-Small"] forState:UIControlStateSelected];
    [_smiley setImage:[UIImage imageNamed:@"Sad-Small"] forState:UIControlStateHighlighted];
    [_smiley setTitleColor:DATE_COLOR forState:UIControlStateNormal];
    [_smiley setTitleColor:BAR_TINT_COLOR forState:UIControlStateSelected];
    _smiley.titleLabel.font = LIKES_FONT;
    _smiley.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _smiley.imageEdgeInsets = UIEdgeInsetsMake(5.2f, 33, 5.2f, 15);
    _smiley.titleEdgeInsets = UIEdgeInsetsMake(2, -65, 0, 35);
    _smiley.tag = self.view.tag;
    [_smiley setTitle:[Config likesCount:likesCount] forState:UIControlStateNormal];
    [_actionsView addSubview:_smiley];
    
    //If the user is not the post authour
    //They can like, dislike and report the post
    if (![Config isPostAuthor:_postObject])
    {
        [_smiley addTarget:_delegate action:@selector(likePost:) forControlEvents:UIControlEventTouchUpInside];
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
    PFObject *commentObject = allComments[indexPath.row];
    NSString *commentText = commentObject[@"text"];
    NSString *commentDate = [Config calculateTime:commentObject.createdAt];
    NSString *cellIdentifier = [NSString stringWithFormat:@"CommentCell%ld",(long)indexPath.row];
    
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    // Configure the cell...
    cell.commentText.text = commentText;
    cell.date.text = commentDate;
    
    //Set Label Frame
    CGFloat postTextHeight = [Config calculateHeightForText:commentText withWidth:TEXT_WIDTH withFont:TEXT_FONT];
    CGRect labelFrame = cell.commentText.frame;
    labelFrame.size.height = postTextHeight;
    cell.commentText.frame = labelFrame;
    
    //Set Action View Frame
    CGRect frame = cell.actionsView.frame;
    frame.origin.y = labelFrame.origin.y + postTextHeight + 10;
    cell.actionsView.frame = frame;
    
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
    
    if (isKeyboardShown == NO)
    {
        //Get and save the current caption location
        currentPosition = subviewContainer.frame;
        
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //Move caption on top of view
        CGFloat newHeight = subviewContainer.frame.size.height - kbSize.height;
        
        CGRect rect = subviewContainer.frame;
        rect.size.height = newHeight; //Set the new Y position
        subviewContainer.frame = rect;
        
        isKeyboardShown = YES;
        
        [self resetSubView];
    }
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Move caption to original position
    subviewContainer.frame = currentPosition;
    
    isKeyboardShown = NO;
    
    [self resetSubView];
}

- (void)addComment:(UIButton *)sender
{
    NSInteger commentLength = [[commentTextView text] length];

    if (commentLength > 0)
    {
        NSString *commenttext = commentTextView.text;
        
        [self resetToDefault];

        NSInteger repliesCount = [_postObject[@"totalReplies"] integerValue];
        repliesCount++;
        [_postObject setValue:[NSNumber numberWithInteger:repliesCount] forKey:@"totalReplies"];
        
        PFObject *parseObject = _postObject[@"parseObject"];
        
        //Create Parse Comment Object
        PFObject *commentObject = [PFObject objectWithClassName:COMMENTS_CLASS_NAME];
        commentObject[@"text"] = commenttext;
        commentObject[@"deviceId"] = [Config deviceId];
        commentObject[@"postId"] = parseObject.objectId;
        
        // Use PFACL to restrict future modifications to this object.
        PFACL *readOnlyACL = [PFACL ACL];
        [readOnlyACL setPublicReadAccess:YES];
        [readOnlyACL setPublicWriteAccess:NO];
        commentObject.ACL = readOnlyACL;
        
        [allComments addObject:commentObject];
        
        //Update main array
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

- (void)queryForAllComments
{
    if ([Config checkInternetConnection])
    {
        dispatch_queue_t commentsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(commentsQueue, ^{
            
            PFObject *parseObject = _postObject[@"parseObject"];
            
            PFQuery *query = [PFQuery queryWithClassName:COMMENTS_CLASS_NAME];
            [query whereKey:@"postId" equalTo:parseObject.objectId];
            [query orderByAscending:@"createdAt"];
            
            // If no objects are loaded in memory, we look to the cache first to fill the table
            // and then subsequently do a query against the network.
            if ([allComments count] == 0)
            {
                query.cachePolicy = kPFCachePolicyCacheThenNetwork;
            }
            query.limit = 20;
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"error in geo query!"); // todo why is this ever happening?
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        allComments = objects.mutableCopy;
                        [_tableView reloadData];
                    });
                }
            }];
            
        });
        
    }else{
        
        [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
    }
}

- (void)resetSubView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    subviewContainer.frame = subviewContainer.frame;
    
    float height = commentTextView.contentSize.height;
    
    //1- set Uitextview new size
    CGRect frame = commentTextView.frame;
    frame.size.height = height; //Give it some padding
    commentTextView.frame = frame;
    
    //2
    frame = composeContainer.frame;
    frame.size.height = 10 + height + 10.0;
    
    //3
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
    
    subviewContainer.frame = subviewContainer.frame;
    
    CGRect tableViewFrame = self.view.frame;
    tableViewFrame.size.height = tableViewFrame.size.height - 119;
    
    _tableView.frame = defaultTableViewframe;
    composeContainer.frame = defaultComposeViewframe;
    commentTextView.frame = CGRectMake(10, 10, CGRectGetWidth(composeContainer.frame) - 85, CGRectGetHeight(composeContainer.frame) - 20);
    
    [UIView commitAnimations];
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
