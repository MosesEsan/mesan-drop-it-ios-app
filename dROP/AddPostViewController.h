//
//  AddPostViewController.h
//  dROP
//
//  Created by Moses Esan on 04/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol AddPostViewControllerDataSource <NSObject>

- (CLLocation *)getUserCurrentLocation;

@end

@interface AddPostViewController : UIViewController

@property (nonatomic, weak) id<AddPostViewControllerDataSource> dataSource;


@end
