//
//  MapViewController.m
//  Drop It!
//
//  Created by Moses Esan on 15/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import "Config.h"
#import "JPSThumbnail.h"
#import "JPSThumbnailAnnotation.h"
//#import "MapPostViewController.h"
#import "ViewPostTableViewController.h"

//#import "CCMBorderView.h"
//#import "CCMPopupTransitioning.h"



@interface MapViewController () <MKMapViewDelegate, ViewPostViewControllerDelegate>
//MapPostViewControllerDelegate>
{
    BOOL allowPopUp;
}

@property (nonatomic, strong) MKMapView *mapView_;

@end


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.view.backgroundColor = [UIColor purpleColor];
    
    //TitleView
    UILabel *layoutLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 90, 37)];
    layoutLabel.textAlignment = NSTextAlignmentLeft;//NSTextAlignmentCenter;
    layoutLabel.text = @"DropIt";
    layoutLabel.textColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
    layoutLabel.backgroundColor = [UIColor clearColor];
    layoutLabel.textColor = [UIColor whiteColor];
    layoutLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.2f];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:layoutLabel];
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
    self.navigationItem.rightBarButtonItem = close;
    
    self.mapView_ = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mapView_.delegate = self;
    self.mapView_.mapType = MKMapTypeStandard;
    //self.mapView_.showsUserLocation = YES;
    [self.view addSubview:self.mapView_];
    
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(-15, 25, 65, 45);
    closeButton.backgroundColor = [UIColor whiteColor];
    closeButton.layer.borderWidth = 1.3f;
    closeButton.layer.borderColor = BAR_TINT_COLOR2.CGColor;
    closeButton.layer.cornerRadius = 65/3.5;
    
    UIImageView *closeImageview =
    [Config imageViewFrame:CGRectMake(22.5f, 10.0f, 25, 25)
                                         withImage:[UIImage imageNamed:@"Close2"]
                                         withColor:BAR_TINT_COLOR2];
    //closeImageview.backgroundColor = [UIColor redColor];
    
    [closeButton addSubview:closeImageview];
    
    [closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CLLocation *currentLocation = [self.dataSource getUserCurrentLocation];
    CLLocationCoordinate2D currentCoordinate = currentLocation.coordinate;

    NSMutableArray *allPosts = [self.dataSource getAllPosts];
    
    if ([allPosts count] == 0)
    {
        self.mapView_.showsUserLocation = YES;
    }else{
        
        for (int i = 0; i < [allPosts count]; i++)
        {
            NSDictionary *postObject = allPosts[i];
            /*
            // Add an annotation
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.coordinate = CLLocationCoordinate2DMake(postPoint.latitude, postPoint.longitude);
            point.title = @"Test";
            point.subtitle = postObject[@"text"];
            [self.mapView_ addAnnotation:point];
             */
            
            //Only display on map if the post does not belong to the user
            if (![Config isPostAuthor:postObject])
            {
                PFObject *parseObject = postObject[@"parseObject"];
                PFGeoPoint *postPoint = parseObject[@"location"];
                
                JPSThumbnail *thumbnail = [[JPSThumbnail alloc] init];
                thumbnail.image = [UIImage imageNamed:[Config fruits]];
                thumbnail.title = @"";
                thumbnail.subtitle = postObject[@"text"];
                thumbnail.coordinate = CLLocationCoordinate2DMake(postPoint.latitude, postPoint.longitude);
                thumbnail.postObject = postObject;
                thumbnail.index = i;
                thumbnail.disclosureBlock = ^{ NSLog(@"selected Empire"); };
                
                if (parseObject[@"pic"])
                {
                    thumbnail.file = parseObject[@"pic"];
                }
                
                [self.mapView_ addAnnotation:[JPSThumbnailAnnotation annotationWithThumbnail:thumbnail]];
            }
        }
    }
    /*
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView_.annotations)
    {
        NSLog(@"%@",annotation);
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        if (MKMapRectIsNull(zoomRect)) {
            zoomRect = pointRect;
        } else {
            zoomRect = MKMapRectUnion(zoomRect, pointRect);
        }
    }
    
    [self.mapView_ setVisibleMapRect:zoomRect animated:YES];
*/
    
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = currentCoordinate.latitude;
    region.center.longitude = currentCoordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView_ setRegion:region animated: YES];
    
    
    allowPopUp = YES;
}



// When a map annotation point is added, zoom to it (1500 range)
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];
    id <MKAnnotation> mp = [annotationView annotation];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance
    ([mp coordinate], 1800, 1800);
    [mv setRegion:region animated:YES];
    //[mv selectAnnotation:mp animated:YES];
   // [mv deselectAnnotation:mp animated:YES];
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"selected");
    //NSMutableArray *allPosts = [self.dataSource getAllPosts];
    
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)])
    {
        JPSThumbnailAnnotationView *mapView_ = (JPSThumbnailAnnotationView *)view;
        
        /*
        MapPostViewController *mapPost = [[MapPostViewController alloc] initWithNibName:nil bundle:nil];
        mapPost.postObject = mapView_.postObject;
        mapPost.index = mapView_.index;
        mapPost.delegate = self;
        CCMPopupTransitioning *popup = [CCMPopupTransitioning sharedInstance];
        popup.destinationBounds = [[UIScreen mainScreen] bounds];
        popup.presentedController = mapPost;
        
        popup.backgroundViewColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        popup.backgroundViewAlpha = 3.0f;
        popup.presentingController = self;
        popup.dismissableByTouchingBackground = YES;
        */
        
        ViewPostTableViewController *viewPost = [[ViewPostTableViewController alloc] initWithNibName:nil bundle:nil];
        viewPost.postObject = mapView_.postObject;
        viewPost.delegate = self;
        viewPost.view.tag = mapView_.index;
        viewPost.showCloseButton = YES;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewPost];
        navController.navigationBar.barStyle = BAR_STYLE;
        navController.navigationBar.barTintColor = BAR_TINT_COLOR2;
        navController.navigationBar.tintColor = [UIColor colorWithRed:235/255.0f green:237/255.0f blue:236/255.0f alpha:1.0f];
        navController.navigationBar.translucent = NO;
        
        [self presentViewController:navController animated:YES completion:nil];
        
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didSelectAnnotationViewInMap:mapView];
        
        id <MKAnnotation> mp = [view annotation];
        [mapView deselectAnnotation:mp animated:YES];
    }

}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    NSLog(@"deselected");
    if ([view conformsToProtocol:@protocol(JPSThumbnailAnnotationViewProtocol)]) {
        [((NSObject<JPSThumbnailAnnotationViewProtocol> *)view) didDeselectAnnotationViewInMap:mapView];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation conformsToProtocol:@protocol(JPSThumbnailAnnotationProtocol)]) {
        return [((NSObject<JPSThumbnailAnnotationProtocol> *)annotation) annotationViewInMap:mapView];
    }
    return nil;
}
/*
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    // If it's the user location, just return nil.
    // Let the system handle user location annotations.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *pinIdentifier = @"AnnotationIdentifier";
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinIdentifier];
        if (!annotationView)
        {
            // If an existing pin view was not available, create one.
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinIdentifier];
            //annotationView.canShowCallout = YES;
            annotationView.calloutOffset = CGPointMake(0, 92);
            annotationView.frame = CGRectMake(0, 0, 40, 40);
            
            UIImageView *annotationImageView = [Config imageViewFrame:annotationView.frame
                                                            withImage:[UIImage imageNamed:[NSString stringWithFormat:@"Speech"]] withColor:[Config getBubbleColor]];
            annotationImageView.userInteractionEnabled = YES;
            [annotationView addSubview:annotationImageView];
            
        } else {
            
            annotationView.annotation = annotation;
        
        }
        
        return annotationView;
    }
    

    return nil;
}
*/



- (void)close:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MapPostViewControllerDelegate

- (void)dislikePost:(NSInteger)tag
{
    [self.delegate dislikePost:tag];
}

- (void)reportPost:(NSInteger)tag
{
    [self.delegate reportPost:tag];
}


#pragma mark - ViewPostViewControllerDelegate

- (void)likePost:(UIButton *)sender
{
    //update array and database
    [self.delegate likePost:sender];
}

- (void)updateAllPostsArray:(NSInteger)index withPostObject:(NSDictionary *)postObject
{
    [self.delegate updateAllPostsArray:index withPostObject:postObject];
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
