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
- (NSMutableArray *)getAllPosts;

@end

@protocol MapViewControllerDelegate <NSObject>

- (void)likePost:(UIButton *)sender;
- (void)dislikePost:(NSInteger)tag;
- (void)reportPost:(NSInteger)tag;
- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject;

@end

@interface MapViewController : UIViewController

@property (nonatomic, weak) id<MapViewControllerDataSource> dataSource;
@property (nonatomic, weak) id<MapViewControllerDelegate> delegate;



@end
