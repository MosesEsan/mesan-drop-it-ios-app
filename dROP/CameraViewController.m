//
//  CameraViewController.m
//  dROP
//
//  Created by Moses Esan on 09/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraSessionView.h"

@interface CameraViewController ()<CACameraSessionDelegate>
{
    CameraSessionView *cameraView;
}
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cameraView = [[CameraSessionView alloc] initWithFrame:self.view.frame];
    cameraView.delegate = self;
    [self.view addSubview:cameraView];
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
