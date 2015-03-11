//
//  AddPostViewController.m
//  dROP
//
//  Created by Moses Esan on 04/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "AddPostViewController.h"
#import "Config.h"
#import "UIFont+Montserrat.h"
#import "LPlaceholderTextView.h"
#import <Parse/Parse.h>
#import "CameraViewController.h"

@interface AddPostViewController ()<UITextViewDelegate>
{
    int characterCount;
    UILabel *characterCountLabel;
    
    LPlaceholderTextView *messageTextView;
    UIImageView *photoPreview;
    
    CGRect currentPosition;

}

@end

@implementation AddPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = 8.0f;
    self.view.clipsToBounds = YES;
    
    //self.view.layer.borderWidth = 0.1f;
    self.view.layer.borderColor = [UIColor colorWithRed:129/255.0f green:129/255.0f blue:129/255.0f alpha:1.0f].CGColor;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ADD_POST_WIDTH, 40.0f)];
    header.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.8f];
    [self.view addSubview:header];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(header.frame))];
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton setImage:[UIImage imageNamed:@"Close-Small"] forState:UIControlStateNormal];
    [closeButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 20)];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeButton];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(header.frame)- 80, 0, 80, CGRectGetHeight(header.frame))];
    postButton.backgroundColor = BAR_TINT_COLOR;
    [postButton setTitle:@"Drop" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont montserratFontOfSize:17.0f];
    [postButton addTarget:self action:@selector(dropPost:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:postButton];
    
    // Add the text view
    messageTextView = [[LPlaceholderTextView alloc] initWithFrame:CGRectMake(4, 40, ADD_POST_WIDTH - 8, 170)];
    [messageTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
    [messageTextView setReturnKeyType:UIReturnKeyGo];
    [messageTextView.layer setCornerRadius:kViewRoundedCornerRadius];
    [messageTextView setPlaceholderText:postPlaceholderText];
    [messageTextView setTextColor:TEXT_COLOR];
    messageTextView.delegate = self;
    [messageTextView setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:15.0f]];
    [self.view addSubview:messageTextView];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, ADD_POST_HEIGHT - 40, ADD_POST_WIDTH, 40.0f)];
    footer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:footer];
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, CGRectGetHeight(footer.frame))];
    cameraButton.backgroundColor = [UIColor clearColor];
    [cameraButton setImage:[UIImage imageNamed:@"Camera-Small"] forState:UIControlStateNormal];
    [cameraButton setImageEdgeInsets:UIEdgeInsetsMake(11, 10, 8, 18)];
    [cameraButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    //[footer addSubview:cameraButton];
    
    photoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(55, 10, CGRectGetHeight(footer.frame) - 20, CGRectGetHeight(footer.frame) - 20)];
    photoPreview.backgroundColor = [UIColor clearColor];
    photoPreview.layer.cornerRadius = 1.0f;
    photoPreview.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
    photoPreview.clipsToBounds = YES;
    photoPreview.contentMode = UIViewContentModeScaleAspectFill;
    //[footer addSubview:photoPreview];
    
    // Set the max character count
    characterCount = kMaxCharacterCount;
    
    // Add a character label
    float characterCountLabelWidth = 50.0f;
    characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(footer.frame)-characterCountLabelWidth - 10, 0, characterCountLabelWidth, CGRectGetHeight(footer.frame))];
    [characterCountLabel setTextAlignment:NSTextAlignmentRight];
    [characterCountLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14.5f]];
    [characterCountLabel setBackgroundColor:[UIColor clearColor]];
    [characterCountLabel setText:[NSString stringWithFormat:@"%d", characterCount]];
    [characterCountLabel setTextColor:DATE_COLOR];
    [footer addSubview:characterCountLabel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [messageTextView becomeFirstResponder];
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

- (void)textViewDidChange:(UITextView *)textView {
    // Update the character count
    characterCount = kMaxCharacterCount - [[textView text] length];
    [characterCountLabel setText:[NSString stringWithFormat:@"%d", characterCount]];
    
    // Check if the count is over the limit
    if(characterCount < 0) {
        // Change the color
        [characterCountLabel setTextColor:[UIColor redColor]];
    }
    else if(characterCount < 20) {
        // Change the color to orange
        [characterCountLabel setTextColor:[UIColor orangeColor]];
    }
    else {
        // Set normal color
        [characterCountLabel setTextColor:DATE_COLOR];
    }
}

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    //Get and save the current caption location
    currentPosition = self.view.frame;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat newY = [[UIScreen mainScreen] bounds].size.height - kbSize.height - ADD_POST_HEIGHT - 15;

    
    // [UIView beginAnimations:nil context:NULL];
    // [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    rect.origin.y = newY; //Set the new Y position
    self.view.frame = rect;
    
    //[UIView commitAnimations];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Move caption to original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    self.view.frame = currentPosition;
    
    [UIView commitAnimations];
    
}

- (void)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropPost:(UIButton *)sender
{
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
    [messageTextView resignFirstResponder];
    
    NSInteger postLength = [[messageTextView text] length];
    
    if (postLength > kMaxCharacterCount)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Post cannot be longer than %d characters",kMaxCharacterCount]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        
        [messageTextView becomeFirstResponder];
        return;
    }else if (postLength > 0){
        
        //Call Drop Post Method
        [self dropPost];
        
    }else{
        [messageTextView becomeFirstResponder];
        return;
    }
}

- (void)dropPost
{
    if ([Config checkInternetConnection])
    {
        dispatch_queue_t addQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(addQueue, ^{
            
            // 1. Get Users Current Location
            CLLocation *currentLocation = [self.dataSource getUserCurrentLocation];
            CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
            PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                              longitude:currentCoordinate.longitude];
            
            if (currentLocation != nil)
            {
                // 2.Create Parse Objec
                PFObject *postObject = [PFObject objectWithClassName:POSTS_CLASS_NAME];
                postObject[@"text"] = messageTextView.text;
                postObject[@"deviceId"] = [Config deviceId];
                postObject[@"location"] = currentPoint;
                postObject[@"type"] = NEW_POST_TYPE;
                
                // Use PFACL to restrict future modifications to this object.
                PFACL *readOnlyACL = [PFACL ACL];
                [readOnlyACL setPublicReadAccess:YES];
                [readOnlyACL setPublicWriteAccess:YES];
                postObject.ACL = readOnlyACL;
                
                [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
                        NSLog(@"%@", postObject);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [Config incrementUserPoints];
                            
                            //Create Notification Object
                            NSDictionary * dict =[NSDictionary dictionaryWithObject:postObject forKey:@"newObject"];
                            NSNotification * notification =[[ NSNotification alloc]
                                                            initWithName:NEW_POST_NOTIFICATION object:nil userInfo:dict];
                            
                            //Post Notification
                            [[NSNotificationCenter defaultCenter] postNotification:notification];
                            
                        });
                        
                    } else {
                        NSLog(@"Failed to save.");
                    }
                }];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                //Display error message
            }
        });
    }else{
        
        [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
    }
    
}

- (void)addPhoto:(UIButton *)sender
{
    //CameraViewController *cameraviewController = [[CameraViewController alloc] initWithNibName:nil bundle:nil];
    
    //[self presentViewController:cameraviewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didCaptureImage:(UIImage *)image {
    //Use the image that is received
    
    //create a pffile
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
