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
#import "DIDataManager.h"
#import <Parse/Parse.h>

#define ADD_BOX_FRAME CGRectMake(0, 0, ADD_POST_WIDTH, ADD_POST_HEIGHT)

@interface AddPostViewController ()<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    int characterCount;
    UILabel *characterCountLabel;
    
    LPlaceholderTextView *messageTextView;
    CALayer *bottomBorder;
    UIView *footer;
    
    UIButton *removePicture;

    DIDataManager *shared;
}

@property (nonatomic, strong) UIImageView *photoPreview;
@property (nonatomic, strong) UIImage *previewPhoto;

@end

@implementation AddPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    shared = [DIDataManager sharedManager];
    
    UIBarButtonItem *exitButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                    target:self
                                                                                    action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = exitButtonItem;
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 32)];
    postButton.backgroundColor = BAR_TINT_COLOR2;
    postButton.layer.cornerRadius = 4.0f;
    [postButton setTitle:@"Drop" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont montserratFontOfSize:15.0f];
    [postButton addTarget:self action:@selector(dropPost:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];

    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                      target:nil action:nil];
    negativeSpacer.width = -3;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,[[UIBarButtonItem alloc] initWithCustomView:postButton]];
    
    
    // Add the text view
    messageTextView = [[LPlaceholderTextView alloc] initWithFrame:CGRectMake(10, 15, ADD_POST_WIDTH - 20, 170)];
    [messageTextView setAutocorrectionType:UITextAutocorrectionTypeYes];
    [messageTextView setReturnKeyType:UIReturnKeyGo];
    //[messageTextView.layer setCornerRadius:kViewRoundedCornerRadius];
    [messageTextView setPlaceholderText:postPlaceholderText];
    [messageTextView setTextColor:TEXT_COLOR];
    messageTextView.delegate = self;
    [messageTextView setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:18.0f]];
    messageTextView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:messageTextView];
    
    bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, messageTextView.frame.origin.y + CGRectGetHeight(messageTextView.frame) + 9, ADD_POST_WIDTH, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithRed:0.906 green:0.906 blue:0.906 alpha:1].CGColor;
    bottomBorder.backgroundColor = [UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:0.5].CGColor;
    [self.view.layer addSublayer:bottomBorder];
    
    footer = [[UIView alloc] initWithFrame:CGRectMake(0, messageTextView.frame.origin.y + CGRectGetHeight(messageTextView.frame) + 10, ADD_POST_WIDTH - 10, 40.0f)];
    footer.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:footer];
    
    UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 0, 50, CGRectGetHeight(footer.frame))];
    cameraButton.backgroundColor = [UIColor clearColor];
    [cameraButton setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
    [cameraButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 7, 13)];
    [cameraButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:cameraButton];
    
    _photoPreview = [[UIImageView alloc] initWithFrame:CGRectMake(55, 5, CGRectGetHeight(footer.frame) - 10, CGRectGetHeight(footer.frame) - 10)];
    _photoPreview.backgroundColor = [UIColor clearColor];
    _photoPreview.layer.cornerRadius = 1.0f;
    _photoPreview.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
    _photoPreview.clipsToBounds = YES;
    _photoPreview.contentMode = UIViewContentModeScaleAspectFill;
    _photoPreview.hidden = YES;
    [footer addSubview:_photoPreview];
    
    removePicture = [[UIButton alloc] initWithFrame:CGRectMake(_photoPreview.frame.origin.x + CGRectGetWidth(_photoPreview.frame) + 10, 10, 100, CGRectGetHeight(footer.frame) - 20)];
    removePicture.backgroundColor = [UIColor clearColor];
    [removePicture setTitle:@"Remove" forState:UIControlStateNormal];
    [removePicture setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    removePicture.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.5f];
    removePicture.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [removePicture addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
    removePicture.hidden = YES;
    [footer addSubview:removePicture];
    
    
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

- (void)setPreviewPhoto:(UIImage *)previewPhoto
{
    if (previewPhoto != nil)
    {
        //show
        self.photoPreview.image = previewPhoto;
        _photoPreview.hidden = NO;
        removePicture.hidden = NO;
    }else{
        //remove
        previewPhoto = nil;
        self.photoPreview.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view
        
        _photoPreview.hidden = YES;
        removePicture.hidden = YES;
        
        [UIView commitAnimations];

    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

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
       // [textView resignFirstResponder];
    
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
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;

    
    CGFloat messageTextViewheight = CGRectGetHeight(self.view.frame) - kbSize.height - 25.0f - 40.0f;
    
    messageTextView.frame = CGRectMake(10, 15, ADD_POST_WIDTH - 20, messageTextViewheight);
    bottomBorder.frame = CGRectMake(0, messageTextView.frame.origin.y + CGRectGetHeight(messageTextView.frame) + 9, ADD_POST_WIDTH, 1.0f);
    footer.frame = CGRectMake(0, messageTextView.frame.origin.y + CGRectGetHeight(messageTextView.frame) + 10, ADD_POST_WIDTH - 10, 40.0f);

    
    // [UIView beginAnimations:nil context:NULL];
    // [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    
    //[UIView commitAnimations];
    
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Move caption to original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
   // addDialog.frame = ADD_BOX_FRAME;
    
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
    dispatch_queue_t addQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(addQueue, ^{
        
        if ([Config checkInternetConnection])
        {
            // 1. Get Users Current Location
            CLLocation *currentLocation = shared.currentLocation;
            CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;
            PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:currentCoordinate.latitude
                                                              longitude:currentCoordinate.longitude];
            
            if (currentLocation != nil)
            {
                // 2.Create Parse Object
                PFObject *postObject = [PFObject objectWithClassName:POSTS_CLASS_NAME];
                postObject[@"text"] = messageTextView.text;
                postObject[@"deviceId"] = [Config deviceId];
                postObject[@"location"] = currentPoint;
                postObject[@"type"] = NEW_POST_TYPE;
                postObject[@"postType"] = POST_TYPE_POST;
                postObject[@"college"] = [Config getClosestLocation:currentLocation];
                postObject[@"avatar"] = [Config people];
                
                if (_previewPhoto != nil)
                {
                    NSData *imageData = UIImagePNGRepresentation(_photoPreview.image);
                    
                    //Create a PFFile
                    NSString *fileName = [NSString stringWithFormat:@"%@.png",[Config deviceId]];
                    postObject[@"pic"] = [PFFile fileWithName:fileName data:imageData];
                }
                
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
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location error"
                                                                    message:@"Unable to determine current location. Please make sure you have enabled location sharing for this app."
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Ok", nil];
                [alertView show];
            }
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Config alertViewWithTitle:@"No Internet Connection" withMessage:nil] show];
            });
        }
    });
}

- (void)addPhoto:(UIButton *)sender
{
    //Create the action sheet
    UIActionSheet* sheet = [[UIActionSheet alloc]
                            initWithTitle:@"What would you like to do?"
                            delegate:self
                            cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                            otherButtonTitles:@"Take Photo", @"Choose From Library", nil];
    
    //Display the action sheet
    [sheet showInView: self.navigationController.view];
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)index
{
    NSString *title = [actionSheet buttonTitleAtIndex:index];

    if ([title isEqualToString:@"Take Photo"])
    {
        /*
        PSSnapViewController *snapViewController = [[PSSnapViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *snapNavigationController = [[UINavigationController alloc] initWithRootViewController:snapViewController ];
        
        [self presentViewController:snapNavigationController animated:YES completion:nil];
        */
        
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                  message:@"Device has no camera"
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK"
                                                        otherButtonTitles: nil];
            
            [myAlertView show];
            
        }else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }else if ([title isEqualToString:@"Choose From Library"]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.previewPhoto = chosenImage;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)removePhoto:(UIButton *)sender
{
    self.previewPhoto = nil;
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
