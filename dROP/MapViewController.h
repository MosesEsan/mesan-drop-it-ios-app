//
//  MapViewController.h
//  Drop It!
//
//  Created by Moses Esan on 15/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@protocol MapViewControllerDataSource <NSObject>

- (CLLocation *)getUserCurrentLocation;

@end


@interface MapViewController : UIViewController

@property (nonatomic, weak) id<MapViewControllerDataSource> dataSource;


@end
