//
//  JPSThumbnailAnnotationView.h
//  JPSThumbnailAnnotationView
//
//  Created by Jean-Pierre Simard on 4/21/13.
//  Copyright (c) 2013 JP Simard. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "JPSThumbnail.h"

typedef enum {
    JPSThumbnailAnnotationViewAnimationDirectionGrow,
    JPSThumbnailAnnotationViewAnimationDirectionShrink,
} JPSThumbnailAnnotationViewAnimationDirection;

typedef enum {
    JPSThumbnailAnnotationViewStateCollapsed,
    JPSThumbnailAnnotationViewStateExpanded,
    JPSThumbnailAnnotationViewStateAnimating,
} JPSThumbnailAnnotationViewState;

@protocol JPSThumbnailAnnotationViewProtocol <NSObject>

- (void)didSelectAnnotationViewInMap:(MKMapView *)mapView;
- (void)didDeselectAnnotationViewInMap:(MKMapView *)mapView;

@end

@interface JPSThumbnailAnnotationView : MKAnnotationView <JPSThumbnailAnnotationViewProtocol> {
    CAShapeLayer *_shapeLayer;
    CAShapeLayer *_strokeAndShadowLayer;
    UIButton *_disclosureButton;
    JPSThumbnailAnnotationViewState _state;
}

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;


@property (nonatomic, strong) NSDictionary *postObject;
@property (nonatomic) NSInteger index;

@property (nonatomic, strong) ActionBlock disclosureBlock;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;

@end
