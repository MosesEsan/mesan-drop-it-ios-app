//
//  MapPostViewController.h
//  Drop It!
//
//  Created by Moses Esan on 16/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapPostViewControllerDelegate <NSObject>

- (void)likePost:(UIButton *)sender;
- (void)dislikePost:(NSInteger)tag;
- (void)reportPost:(NSInteger)tag;
- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject;

@end

@interface MapPostViewController : UIViewController

@property (nonatomic) int index;
@property (nonatomic, strong) NSDictionary *postObject;

@property (nonatomic, weak) id<MapPostViewControllerDelegate> delegate;


@end
