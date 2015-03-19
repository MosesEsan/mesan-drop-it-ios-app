//
//  InfoViewController.m
//  dROP
//
//  Created by Moses Esan on 09/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "InfoViewController.h"
#import "Config.h"
#import "UIFont+Montserrat.h"

@interface InfoViewController ()<UIScrollViewDelegate>
{
    UIScrollView *infoScrollView;
    UIPageControl *pageControl;
}

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.cornerRadius = 8.0f;
    self.view.clipsToBounds = YES;
    
    //self.view.layer.borderWidth = 0.1f;
    self.view.layer.borderColor = [UIColor colorWithRed:129/255.0f green:129/255.0f blue:129/255.0f alpha:1.0f].CGColor;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, INFO_VIEW_WIDTH, 50.0f)];
    header.backgroundColor = BAR_TINT_COLOR2;
    //[UIColor colorWithRed:216/255.0f green:216/255.0f blue:216/255.0f alpha:.8f];
    [self.view addSubview:header];
    
    UILabel *headerText = [[UILabel alloc] initWithFrame:header.bounds];
    headerText.font = [UIFont montserratFontOfSize:18.0f];
    headerText.text = @"Points Intro";
    headerText.textColor = [UIColor whiteColor];
    headerText.textAlignment = NSTextAlignmentCenter;
    [header addSubview:headerText];
    
    // Add the text view
    infoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(8, 50, INFO_VIEW_WIDTH - 16, INFO_VIEW_HEIGHT - 120 - 20)];
    infoScrollView.backgroundColor = [UIColor clearColor];
    infoScrollView.pagingEnabled = YES;
    infoScrollView.showsHorizontalScrollIndicator = NO;
    infoScrollView.delegate = self;
    [self.view addSubview:infoScrollView];
    
    [self createSubViews];
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(8 + 7, infoScrollView.frame.origin.y + CGRectGetHeight(infoScrollView.frame), INFO_VIEW_WIDTH, 20)];
    pageControl.numberOfPages = NUMBER_OF_PAGES;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = BAR_TINT_COLOR2;
    pageControl.pageIndicatorTintColor = DATE_COLOR;
    [self.view addSubview:pageControl];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, INFO_VIEW_HEIGHT - 70, INFO_VIEW_WIDTH, 70.0f)];
    footer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:footer];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(10, 10, CGRectGetWidth(footer.frame) - 20, CGRectGetHeight(footer.frame) - 20);
    closeButton.backgroundColor = BAR_TINT_COLOR2;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont montserratFontOfSize:18.0f];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:closeButton];
}


- (void)createSubViews
{
    UILabel *pointsIntro = [[UILabel alloc] initWithFrame:infoScrollView.bounds];
    pointsIntro.backgroundColor = [UIColor clearColor];
    pointsIntro.text = POINTS_INTRO_TEXT;
    pointsIntro.numberOfLines = 0;
    pointsIntro.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15.5f];
    pointsIntro.textColor = TEXT_COLOR;
    pointsIntro.textAlignment = NSTextAlignmentCenter;
    [infoScrollView addSubview:pointsIntro];
    
    UILabel *pointsBreakdown = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(infoScrollView.frame), 0, CGRectGetWidth(infoScrollView.frame), CGRectGetHeight(infoScrollView.bounds))];
    pointsBreakdown.backgroundColor = [UIColor clearColor];
    pointsBreakdown.text = POINTS_BREAKDOWN_TEXT;
    pointsBreakdown.numberOfLines = 0;
    pointsBreakdown.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15.5f];
    pointsBreakdown.textColor = TEXT_COLOR;
    pointsBreakdown.textAlignment = NSTextAlignmentCenter;
    [infoScrollView addSubview:pointsBreakdown];
    
    UILabel *rewardsBreakdown = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(infoScrollView.frame) * 2, 0, CGRectGetWidth(infoScrollView.frame), CGRectGetHeight(infoScrollView.bounds))];
    rewardsBreakdown.backgroundColor = [UIColor clearColor];
    rewardsBreakdown.numberOfLines = 0;
    rewardsBreakdown.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15.5f];
    rewardsBreakdown.textColor = TEXT_COLOR;
    rewardsBreakdown.textAlignment = NSTextAlignmentCenter;
    [infoScrollView addSubview:rewardsBreakdown];
    
    NSMutableArray *rewards = [Config rewards];
    
    NSString *rewardsText = @"";
    
    for (int i = 0; i < 3; i++)
    {
        NSMutableArray *rewardInfo = rewards[i];
        
        rewardsText = [NSString stringWithFormat:@"%@%@ \r %@ \r \r",rewardsText,rewardInfo[0],rewardInfo[1]];
    }
    
    rewardsBreakdown.text = rewardsText;
    
    
    UILabel *rewardsBreakdown2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(infoScrollView.frame) * 3, 0, CGRectGetWidth(infoScrollView.frame), CGRectGetHeight(infoScrollView.bounds))];
    rewardsBreakdown2.backgroundColor = [UIColor clearColor];
    rewardsBreakdown2.numberOfLines = 0;
    rewardsBreakdown2.font = [UIFont fontWithName:@"AvenirNext-Regular" size:15.5f];
    rewardsBreakdown2.textColor = TEXT_COLOR;
    rewardsBreakdown2.textAlignment = NSTextAlignmentCenter;
    [infoScrollView addSubview:rewardsBreakdown2];
    
    rewardsText = @"";
    
    for (int i = 3; i < [rewards count]; i++)
    {
        NSMutableArray *rewardInfo = rewards[i];
        
        rewardsText = [NSString stringWithFormat:@"%@%@ \r %@ \r \r",rewardsText,rewardInfo[0],rewardInfo[1]];
    }
    
    rewardsBreakdown2.text = rewardsText;

    [infoScrollView setContentSize:CGSizeMake(CGRectGetWidth(infoScrollView.frame) * NUMBER_OF_PAGES, CGRectGetHeight(infoScrollView.bounds))];
    
}

- (void)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = infoScrollView.frame.size.width;
    int page = floor((infoScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
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
