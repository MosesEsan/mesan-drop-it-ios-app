//
//  IntroView.h
//  ABCIntroView
//
//  Created by Adam Cooper on 2/4/15.
//  Copyright (c) 2015 Adam Cooper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+Montserrat.h"

@protocol ABCIntroViewDelegate <NSObject>

- (void)onDoneButtonPressed;

@end

@protocol ABCIntroViewDatasource <NSObject>

- (NSDictionary *)detailsForIndex:(NSInteger)index;

@end


@interface ABCIntroView : UIViewController

//Customization
@property (nonatomic)  NSInteger noOfPages;

@property (strong,nonatomic)  UIFont *headerFont;
@property (strong, nonatomic)  UIFont *descriptionFont;

@property (strong, nonatomic)  UIFont *buttonFont;
@property (strong, nonatomic)  NSString *buttonText;
@property (strong, nonatomic)  UIColor *buttonColor;

@property (strong, nonatomic)  UIImage *backgroundImage;


//Delegate
@property id<ABCIntroViewDelegate> delegate;

//Datasource

@property id <ABCIntroViewDatasource> datasource;
@end
