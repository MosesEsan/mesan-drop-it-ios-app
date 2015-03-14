//
//  FullScreenViewController.m
//  Drop It!
//
//  Created by Moses Esan on 13/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "FullScreenViewController.h"

@interface FullScreenViewController ()
{
    PFImageView *_postImage;
}

@property (nonatomic, strong) PFFile *file;

@end

@implementation FullScreenViewController


- (id)initWithFile:(PFFile *)file
{
    self = [super init];
    
    if (self)
    {
        _file = file;
    }
   
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _postImage = [[PFImageView alloc] initWithFrame:self.view.bounds];
    _postImage.backgroundColor = [UIColor clearColor];
    _postImage.layer.cornerRadius = 5.0f;
    //_postImage.image = [UIImage imageNamed:@"CoverPhotoPH.JPG"];
    _postImage.clipsToBounds = YES;
    _postImage.contentMode = UIViewContentModeScaleAspectFit;
    _postImage.userInteractionEnabled = YES;
    _postImage.file = _file;
    [self.view addSubview:_postImage];
    
    
    //Nav Bar
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 20 + 64.0f)];
    navBar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navBar];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(20.0f, 20 + 10, 44.0f, 44.0f);
    closeButton.backgroundColor = [UIColor redColor];
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:closeButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_postImage loadInBackground];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
}

- (void)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
