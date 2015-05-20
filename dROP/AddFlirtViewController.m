//
//  AddFlirtViewController.m
//  Drop It!
//
//  Created by Moses Esan on 15/05/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "AddFlirtViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import "FlirtPickerView.h"

#import "Config.h"
#import "UIFont+Montserrat.h"
#import "DIDataManager.h"
#import <Parse/Parse.h>

#define GENDER_TEXT @"I'm looking at"
#define HAIR_TEXT @"with hair"


const static CGFloat kJVFieldHeight = 64.0f;
const static CGFloat kJVFieldLeftMargin = 15.0f;
const static CGFloat kJVFieldRightMargin = 15.0f;

const static CGFloat kJVFieldFontSize = 18.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 13.0f;



//Y Values
const static CGFloat genderY = 0;
const static CGFloat hairY = kJVFieldHeight + 1;
const static CGFloat locationY = kJVFieldHeight + 1 + kJVFieldHeight + 1;
const static CGFloat flirtY = kJVFieldHeight + 1 + kJVFieldHeight + 1 + kJVFieldHeight + 1;


@interface AddFlirtViewController () <UITextFieldDelegate, UITextViewDelegate, UIPickerViewDataSource,UIPickerViewDelegate>
{
    FlirtPickerView *genderField;
    FlirtPickerView *hairField;
    JVFloatLabeledTextField *locationField;
    JVFloatLabeledTextView *flirtField;
    
    NSArray *componentOptions;
    DIDataManager *shared;
    
    
    int characterCount;
    UILabel *characterCountLabel;
    
    BOOL keyboardVisible;
    CGSize kbSize;
}

@end

@implementation AddFlirtViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.title = NSLocalizedString(@"Floating Label Demo", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
        
    shared = [DIDataManager sharedManager];
    keyboardVisible= NO;
    
    UIBarButtonItem *exitButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                    target:self
                                                                                    action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = exitButtonItem;
    
    // Set the max character count
    characterCount = kMaxCharacterCount;
    
    // Add a character label
    float characterCountLabelWidth = 50.0f;
    characterCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, characterCountLabelWidth, 31)];
    [characterCountLabel setTextAlignment:NSTextAlignmentRight];
    [characterCountLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:14.5f]];
    [characterCountLabel setBackgroundColor:[UIColor clearColor]];
    [characterCountLabel setText:[NSString stringWithFormat:@"%d", characterCount]];
    [characterCountLabel setTextColor:DATE_COLOR];
    
    UIButton *postButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 63, 31)];
    postButton.backgroundColor = [UIColor redColor];
    postButton.layer.cornerRadius = 4.0f;
    [postButton setTitle:@"Flirt" forState:UIControlStateNormal];
    [postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont montserratFontOfSize:15.0f];
    [postButton addTarget:self action:@selector(dropPost:) forControlEvents:UIControlEventTouchUpInside];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:postButton];
    
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -3;
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,
                                                [[UIBarButtonItem alloc] initWithCustomView:postButton],
                                                [[UIBarButtonItem alloc] initWithCustomView:characterCountLabel]];
    
    
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor grayColor]];
#endif
    
    UIColor *floatingLabelColor = [UIColor purpleColor]; //bar_tint_color
    
    genderField = [[FlirtPickerView alloc] initWithFrame:CGRectMake(0, genderY, CGRectGetWidth(self.view.frame) - (kJVFieldLeftMargin + kJVFieldRightMargin), kJVFieldHeight)];
    genderField.placeHolder = GENDER_TEXT;
    genderField.pickerView.dataSource = self;
    genderField.pickerView.delegate = self;
    genderField.textFieldImage.image = [UIImage imageNamed:@"Gender"];
    [self.view addSubview:genderField];
    
    
    
    //Bottom Border
    UIView *div1 = [[UIView alloc] initWithFrame:CGRectMake(0, kJVFieldHeight, CGRectGetWidth(self.view.frame), 1)];
    div1.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    //[self.view addSubview:div1];
    
    //-----------
    
    hairField = [[FlirtPickerView alloc] initWithFrame:CGRectMake(0, hairY, CGRectGetWidth(self.view.frame) - (kJVFieldLeftMargin + kJVFieldRightMargin), kJVFieldHeight)];
    hairField.placeHolder = HAIR_TEXT;
    hairField.pickerView.dataSource = self;
    hairField.pickerView.delegate = self;
    hairField.textFieldImage.image = [UIImage imageNamed:@"Hair"];

    [self.view addSubview:hairField];
    
    UIView *div2 = [[UIView alloc] initWithFrame:CGRectMake(0, hairField.frame.origin.y + kJVFieldHeight, CGRectGetWidth(self.view.frame), 1)];
    div2.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    //[self.view addSubview:div2];
    
    
    [self setPickerOptions];
    
    //-----------
    
    locationField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectMake(kJVFieldLeftMargin, locationY, CGRectGetWidth(self.view.frame) - (kJVFieldLeftMargin + kJVFieldRightMargin), kJVFieldHeight)];
    locationField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    [locationField setReturnKeyType:UIReturnKeyGo];
    locationField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"at location", @"")
                                                                          attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
    locationField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    locationField.floatingLabelTextColor = floatingLabelColor;
    [self.view addSubview:locationField];
    locationField.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *div3 = [[UIView alloc] initWithFrame:CGRectMake(0, locationField.frame.origin.y + kJVFieldHeight, CGRectGetWidth(self.view.frame), 1)];
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    //[self.view addSubview:div3];
    
    //-----------
    
    flirtField = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectMake(kJVFieldLeftMargin, flirtY, CGRectGetWidth(self.view.frame) - (kJVFieldLeftMargin + kJVFieldRightMargin), kJVFieldHeight * 3)];
    flirtField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    [flirtField setReturnKeyType:UIReturnKeyGo];
    flirtField.placeholder = NSLocalizedString(@"Flirt", @"");
    flirtField.placeholderTextColor = [UIColor darkGrayColor];
    flirtField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    flirtField.floatingLabelTextColor = floatingLabelColor;
    flirtField.delegate = self;
    [self.view addSubview:flirtField];
    flirtField.translatesAutoresizingMaskIntoConstraints = NO;
    
    //[genderField becomeFirstResponder];
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

- (void)setPickerOptions
{
    componentOptions = @[@[GENDER_TEXT, @"Male", @"Female"],
                         @[HAIR_TEXT, @"Blonde", @"Brunette", @"Black"]];
    
    [genderField.pickerView reloadAllComponents];
}

//Pickerview Delegate and Datasource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel *)view;
    
    // Reuse the label if possible, otherwise create and configure a new one
    if ((pickerLabel == nil) || ([pickerLabel class] != [UILabel class]))
    {
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - (kJVFieldLeftMargin + kJVFieldRightMargin), kJVFieldHeight);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.backgroundColor = [UIColor clearColor];
        pickerLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:19.0f];
    }
    
    //pickerLabel.textColor = [UIColor brownColor];
    
    NSInteger index;
    
    if (pickerView == genderField.pickerView) index = 0;
    else index = 1;
    
    NSString *text = componentOptions[index][row];
    
    
    
    pickerLabel.text = text;
    
    return pickerLabel;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Handle the selection
    
    NSInteger index;
    
    if (pickerView == genderField.pickerView){
        
        index = 0;
        [genderField.textField setText:componentOptions[index][row]];
        
    }else {
        index = 1;
        [hairField.textField setText:componentOptions[index][row]];
    }
    
    [hairField becomeFirstResponder];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger index;
    
    if (pickerView == genderField.pickerView) index = 0;
    else index = 1;
    
    return [componentOptions[index] count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSInteger index;
    
    if (pickerView == genderField.pickerView) index = 0;
    else index = 1;
    
    return componentOptions[index][row];
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/*
 // tell the picker the title for a given component
 - (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
 {
 return _options[row];
 }
 */
// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return CGRectGetWidth(self.view.frame);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//--- others

- (void)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropPost:(UIButton *)sender
{
    
    // Resign first responder to dismiss the keyboard and capture in-flight autocorrect suggestions
   // [messageTextView resignFirstResponder];
    
    //NSInteger row = [genderField.pickerView selectedRowInComponent:0];
    NSString *genderText = genderField.textField.text;
    //componentOptions[0][row];
    
    NSInteger genderLength = [genderText length];
    
    if ([genderText isEqualToString:GENDER_TEXT]) genderLength = 0;
    
    //row = [hairField.pickerView selectedRowInComponent:0];
    NSString *hairText = hairField.textField.text;
    //componentOptions[1][row];
    
    NSInteger hairLength = [hairText length];

    if ([hairText isEqualToString:HAIR_TEXT]) hairLength = 0;
    
    NSInteger locationLength = [[locationField text] length];
    NSInteger flirtLength = [[flirtField text] length];
    
    
    if (flirtLength > kMaxCharacterCount)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Flirt cannot be longer than %d characters",kMaxCharacterCount]
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Ok", nil];
        [alertView show];
        
        //[messageTextView becomeFirstResponder];
        return;
    }else if (genderLength > 0 && hairLength > 0 && locationLength > 0 && flirtLength > 0){
        
        //Call Drop Post Method
        [self dropPost];
        
    }else{
        
        //[messageTextView becomeFirstResponder];
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
                postObject[@"text"] = flirtField.text;
                postObject[@"deviceId"] = [Config deviceId];
                postObject[@"location"] = currentPoint;
                postObject[@"type"] = NEW_POST_TYPE;
                postObject[@"postType"] = POST_TYPE_FLIRT;
                postObject[@"college"] = [Config getClosestLocation:currentLocation];
                postObject[@"avatar"] = [Config people];
                
                postObject[@"flirtLocation"] = locationField.text;
                postObject[@"gender"] = genderField.textField.text;
                postObject[@"hairColor"] = hairField.textField.text;

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
                            
                            //[Config incrementUserPoints];
                            
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



#pragma mark - UITextView Delegate Methods
-(void)textViewDidEndEditing:(UITextView *)textView {
    
    
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView
{
    //Has Focus
    //If the keyyboard is already visible, move up the frame
    if (keyboardVisible)
        [self moveFrameUp];

    return YES;
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

#pragma mark - UITextView Delegate Methods
- (void)keyboardWillShow:(NSNotification *)aNotification
{
    keyboardVisible = YES;
    
    NSDictionary* info = [aNotification userInfo];
    kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    if ([flirtField isFirstResponder]) {
        [self moveFrameUp];
        
    }else {
        
        
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    keyboardVisible = NO;

    //Move caption to original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    // addDialog.frame = ADD_BOX_FRAME;
    //gender field
    CGRect frame = genderField.frame;
    frame.origin.y = genderY;
    genderField.frame = frame;
    
    //hair field
    frame = hairField.frame;
    frame.origin.y = hairY;
    hairField.frame = frame;
    
    //location field
    frame = locationField.frame;
    frame.origin.y = locationY;
    locationField.frame = frame;
    
    //flirt field
    frame = flirtField.frame;
    frame.origin.y = flirtY;
    flirtField.frame = frame;
    
    [UIView commitAnimations];
    
}

- (void)moveFrameUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    //gender field
    CGRect frame = genderField.frame;
    frame.origin.y = (64.0f + genderY) - kbSize.height;
    genderField.frame = frame;
    
    //hair field
    frame = hairField.frame;
    frame.origin.y = (64.0f + hairY) - kbSize.height;
    hairField.frame = frame;
    
    //location field
    frame = locationField.frame;
    frame.origin.y = (64.0f + locationY) - kbSize.height;
    locationField.frame = frame;
    
    //flirt field
    frame = flirtField.frame;
    frame.origin.y = (64.0f + flirtY) - kbSize.height;
    flirtField.frame = frame;
    
    [UIView commitAnimations];
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
