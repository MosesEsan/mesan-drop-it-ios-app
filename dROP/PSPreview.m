//
//  PSPreview.m
//  DIImageView
//
//  Created by Daniel Inoa Llenas on 8/18/14.
//  Copyright (c) 2014 Daniel Inoa Llenas. All rights reserved.
//

#import "PSPreview.h"
#import "DIImageView.h"
#import "UIImage+ImageEffects.h"
#import "UIFont+Montserrat.h"

#define SCREEN_RECT [[UIScreen mainScreen] bounds]


@interface PSPreview ()
{
    CGRect currentPosition;
    
    UIButton *boxesInfo;
}

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) DIImageView *imageView;

@end

@implementation PSPreview

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super initWithNibName:nil bundle:nil];
    
    if(self) {
        self.image = image;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //self.imageView.backgroundColor = [UIColor blackColor];
    
    UIBarButtonItem *exitButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                    target:self
                                                                                    action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = exitButtonItem;
    
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self
                                                                                    action:@selector(addSnapToBox:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    
    //self.navigationItem.title = @"Tap to add caption";
    
    _imageView = [[DIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(SCREEN_RECT), CGRectGetHeight(SCREEN_RECT))];
    [_imageView setImage:self.image];
    [self.view addSubview:_imageView];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
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

- (void)keyboardWillShow:(NSNotification*)aNotification
{
    //Get and save the current caption location
    currentPosition = _imageView.caption.frame;
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Move caption on top of view
    CGFloat newY = CGRectGetHeight(self.view.frame) - kbSize.height - CGRectGetHeight(_imageView.caption.frame);
    
   // [UIView beginAnimations:nil context:NULL];
   // [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = _imageView.caption.frame;
    rect.origin.y = newY; //Set the new Y position
    _imageView.caption.frame = rect;
    
    //[UIView commitAnimations];
    
    //disable drag
    [_imageView disableDrag];
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    //Move caption to original position
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    _imageView.caption.frame = currentPosition;
    
    [UIView commitAnimations];
    
    //Enable drag
    [_imageView enableDrag];
}



#pragma mark -
- (void)close:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

/*
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
*/



@end
