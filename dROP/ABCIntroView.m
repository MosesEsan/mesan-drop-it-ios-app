//
//  IntroView.m
//  DrawPad
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import "ABCIntroView.h"

#define HEADER_FONT [UIFont montserratFontOfSize:20.0f]
#define DESCRIPTION_FONT [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f]

#define BUTTON_FONT [UIFont fontWithName:@"AvenirNext-Bold" size:15.0f]
#define BUTTON_TEXT @"Done"
#define BUTTON_COLOR [UIColor colorWithRed:68/255.0f green:183/255.0f blue:199/255.0f alpha:1.0f]

#define BACKGROUND_IMAGE [UIImage imageNamed:@"Blue-Blurry-Desktop-Background.jpg"]

#define NO_OF_PAGES 5

@interface ABCIntroView () <UIScrollViewDelegate>

@property (strong, nonatomic)  UIScrollView *scrollView;
@property (strong, nonatomic)  UIPageControl *pageControl;
@property UIButton *doneButton;

@end


@implementation ABCIntroView

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = self.backgroundImage;
    [self.view addSubview:backgroundImageView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*.8, self.view.frame.size.width, 10)];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self.view addSubview:self.pageControl];
    
    
    for (int i = 0; i < self.noOfPages; i++)
    {
        NSDictionary *introInfo = [self.datasource detailsForIndex:i];
        
        [self createViewForIndex:i
                       withTitle:introInfo[@"title"]
                 withDescription:introInfo[@"description"]
                       withImage:introInfo[@"image"]];
    }
    
    //Done Button
    self.doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.85, self.view.frame.size.width*.8, 60)];
    [self.doneButton setTintColor:[UIColor whiteColor]];
    [self.doneButton setTitle:self.buttonText forState:UIControlStateNormal];
    [self.doneButton.titleLabel setFont:self.buttonFont];
    self.doneButton.backgroundColor = self.buttonColor;
    //self.doneButton.layer.borderColor = [UIColor colorWithRed:0.153 green:0.533 blue:0.796 alpha:1.000].CGColor;
    [self.doneButton addTarget:self action:@selector(onFinishedIntroButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.doneButton.layer.borderWidth =.5;
    self.doneButton.layer.cornerRadius = 7;
    [self.view addSubview:self.doneButton];
    
    self.pageControl.numberOfPages = self.noOfPages;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width* self.noOfPages, self.scrollView.frame.size.height);
    
    //This is the starting point of the ScrollView
    CGPoint scrollPoint = CGPointMake(0, 0);
    [self.scrollView setContentOffset:scrollPoint animated:YES];
}

- (void)onFinishedIntroButtonPressed:(id)sender {
    [self.delegate onDoneButtonPressed];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = CGRectGetWidth(self.view.bounds);
    CGFloat pageFraction = self.scrollView.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
}

-(void)createViewForIndex:(NSInteger)index
                withTitle:(NSString *)title
          withDescription:(NSString *)description
                withImage:(NSString *)image
{
    CGFloat originWidth = self.view.frame.size.width;
    CGFloat originHeight = self.view.frame.size.height;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(originWidth*index, 0, originWidth, originHeight)];

    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height*.05, self.view.frame.size.width*.8, 60)];
    titleLabel.center = CGPointMake(self.view.center.x, self.view.frame.size.height*.1);
    titleLabel.text = title;
    titleLabel.font = self.headerFont;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment =  NSTextAlignmentCenter;
    titleLabel.numberOfLines = 0;
    [view addSubview:titleLabel];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.1, self.view.frame.size.width*.8, self.view.frame.size.width)];
    imageview.contentMode = UIViewContentModeScaleAspectFit;
    imageview.image = [UIImage imageNamed:image];
    [view addSubview:imageview];
    
    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*.1, self.view.frame.size.height*.7, self.view.frame.size.width*.8, 60)];
    descriptionLabel.text = description;
    descriptionLabel.font = self.descriptionFont;
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment =  NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    [descriptionLabel sizeToFit];
    [view addSubview:descriptionLabel];
    
    CGPoint labelCenter = CGPointMake(self.view.center.x, self.view.frame.size.height*.7);
    descriptionLabel.center = labelCenter;
    
    [self.scrollView addSubview:view];
}

#pragma mark - getters

- (UIFont *)headerFont
{
    if (_headerFont == nil) return HEADER_FONT;
    else return _headerFont;
}

- (UIFont *)descriptionFont
{
    if (_descriptionFont == nil) return DESCRIPTION_FONT;
    else return _descriptionFont;
}

- (UIFont *)buttonFont
{
    if (_buttonFont == nil) return BUTTON_FONT;
    else return _buttonFont;
}

- (NSString *)buttonText
{
    if (_buttonText == nil) return BUTTON_TEXT;
    else return _buttonText;
}

- (UIColor *)buttonColor
{
    if (_buttonColor == nil) return BUTTON_COLOR;
    else return _buttonColor;
}

- (UIImage *)backgroundImage
{
    if (_backgroundImage == nil) return BACKGROUND_IMAGE;
    else return _backgroundImage;
}

- (NSInteger)noOfPages
{
    if (!_noOfPages) return NO_OF_PAGES;
    else return _noOfPages;
}



@end