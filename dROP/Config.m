//
//  Config.m
//  dROP
//
//  Created by Moses Esan on 05/03/2015.
//  Copyright (c) 2015 Moses Esan. All rights reserved.
//

#import "Config.h"
#import "TTTTimeIntervalFormatter.h"
#import "Reachability.h"

@implementation Config

+ (NSMutableArray *)introsInfo
{
    NSMutableArray *introsInfo =
    [[NSMutableArray alloc] initWithObjects:
     @{@"title" : @"Be Part Of The Conversation", @"description" : @"Find out what everyone around you is saying.",
       @"image" : @"Time"},
     @{@"title" : @"Join the Conversation", @"description" : @"Join the conversation ANONYMOUSLY. Receive points everytime you add a new post and when your posts are liked.", @"image" : @"Add"},
     @{@"title" : @"Dislike / Report", @"description" : @"Swipe Right to dislike or report a post.", @"image" : @"Dislike"},
     @{@"title" : @"Elevate The Conversation", @"description" : @"Let you voice be heard by leaving comments.", @"image" : @"Comment"},
     @{@"title" : @"Review Your Contribution", @"description" : @"Keep track of your posts, points and know your rank.", @"image" : @"Profile"},
     nil];
    
    return introsInfo;
}

+ (void)updateAvailableLocations:(NSDate *)lastUpdated
{
    //Get the current locations
     NSMutableArray *availableLocations = [[NSUserDefaults standardUserDefaults] objectForKey:@"AvailableLocations"];
    
    //If nil, pass the default and save it
    if (availableLocations == nil)
    {
        availableLocations = [[NSMutableArray alloc] initWithObjects:
                              @[@"Kevin Street", @"53.337296", @"-6.267333", @"8046.72"],
                              @[@"Aungier Street", @"53.337296", @"-6.267333", @"8046.72"],
                              @[@"IT Tallaght", @"53.290947", @"-6.363412", @"8046.72"],
                              nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:availableLocations forKey:@"AvailableLocations"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    //call query to retrieve new ones, if the last updated date is > 60 or its nil
    if (lastUpdated == nil || [Config checkLastUpdated:lastUpdated withMaxDifference:60])
    {
        if ([Config checkInternetConnection])
        {
            dispatch_queue_t locationQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(locationQueue, ^{
                PFQuery *query = [PFQuery queryWithClassName:LOCATIONS_CLASS_NAME];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error) {
                        NSLog(@"error in geo query!"); // todo why is this ever happening?
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([objects count] > 0)
                            {
                                NSMutableArray *availableLocations = [[NSMutableArray alloc] init];
                                
                                for (PFObject *location in objects)
                                {
                                    NSString *college = location[@"college"];
                                    PFGeoPoint *locationGeo = location[@"location"];
                                    NSArray *locationInfo = @[college,
                                                              [NSNumber numberWithDouble:locationGeo.latitude],
                                                              [NSNumber numberWithDouble:locationGeo.longitude],
                                                              location[@"distance"]];
                                    
                                    [availableLocations addObject:locationInfo];
                                }
                                
                                [[NSUserDefaults standardUserDefaults] setObject:availableLocations forKey:@"AvailableLocations"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        });
                    }
                }];
            });
            
        }
    }
}

+ (NSMutableArray *)availableLocations
{
    //Set Default Locations
    NSMutableArray *availableLocations = [[NSUserDefaults standardUserDefaults] objectForKey:@"AvailableLocations"];
    
    return availableLocations;
}

+ (void)updateRewards:(NSDate *)lastUpdated
{
    //Get the current locations
    NSMutableArray *rewards = [[NSUserDefaults standardUserDefaults] objectForKey:@"Rewards"];
    
    //If nil, pass the default and save it
    if (rewards == nil)
    {
        rewards = [[NSMutableArray alloc] initWithObjects:
                              @[@"50 Points", @"€5 Mobile Phone Credit"],
                              @[@"100 Points", @"€10 Mobile Phone Credit"],
                              @[@"200 Points", @"€25 Cinema Gift Card "],
                              @[@"300 Points", @"€30 Leap Card Top Up"],
                              @[@"400 Points", @"TBC"],
                              @[@"500 Points", @"TBC"],
                              nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:rewards forKey:@"Rewards"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //call query to retrieve new ones, if the last updated date is > 1440 (1 Day) or its nil
    if (lastUpdated == nil || [Config checkLastUpdated:lastUpdated withMaxDifference:1440])
    {
        if ([Config checkInternetConnection])
        {
            dispatch_queue_t rewardsQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(rewardsQueue, ^{
                PFQuery *query = [PFQuery queryWithClassName:REWARDS_CLASS_NAME];
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error) {
                        NSLog(@"error in geo query!"); // todo why is this ever happening?
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([objects count] > 0)
                            {
                                NSMutableArray *rewards = [[NSMutableArray alloc] init];
                                
                                for (PFObject *location in objects)
                                {
                                    NSString *points = [NSString stringWithFormat:@"%@ Points",location[@"points"]];
                                    NSString *reward = location[@"reward"];
                                    NSArray *pointInfo = @[points,reward];
                                    
                                    [rewards addObject:pointInfo];
                                }
                                
                                [[NSUserDefaults standardUserDefaults] setObject:rewards forKey:@"Rewards"];
                                [[NSUserDefaults standardUserDefaults] synchronize];
                            }
                        });
                    }
                }];
            });
        }
    }
}

+ (NSMutableArray *)rewards
{
    //Set Default Locations
    NSMutableArray *availableLocations = [[NSUserDefaults standardUserDefaults] objectForKey:@"Rewards"];
    
    return availableLocations;
}

+ (NSString *)calculateTime:(id)time
{
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    
    NSTimeInterval timeInterval = [time timeIntervalSinceNow];
    NSString *date  = [timeIntervalFormatter stringForTimeInterval:timeInterval];
    
    return date;
}


+ (NSMutableArray *)filterPosts:(NSArray *)postObject
{
    NSMutableArray *newPosts = [[NSMutableArray alloc] init];
    
    for (PFObject *post in postObject)
    {
        //if the user has not reported this message or this message has less than 5 reports
        if (![Config getReportStatus:post])
        {
            [newPosts addObject:[Config createPostObject:post]];
        }
    }
    
    return newPosts;
}

+ (NSMutableDictionary *)createPostObject:(PFObject *)parseObject
{
    NSString *postText = parseObject[@"text"];
    NSInteger likesCount = [parseObject[@"likes"] count];
    NSInteger repliesCount = [parseObject[@"replies"] count];
    BOOL liked = [Config getLikeStatus:parseObject];
    BOOL disliked = [Config getDisLikeStatus:parseObject];
    
    NSDictionary *postObject = @{
                                 @"text" : postText,
                                 @"liked" : [NSNumber numberWithBool:liked],
                                 @"disliked" : [NSNumber numberWithBool:disliked],
                                 @"totalLikes" : [NSNumber numberWithInteger:likesCount],
                                 @"totalReplies" : [NSNumber numberWithInteger:repliesCount],
                                 @"date" : parseObject.createdAt,
                                 @"parseObject" : parseObject
                                 };
    
    return postObject.mutableCopy;
}

+ (BOOL)isPostAuthor:(NSDictionary *)postObject
{
    PFObject *parseObject = postObject[@"parseObject"];
    
    if ([parseObject[@"deviceId"] isEqualToString:[Config deviceId]])
    {
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)getLikeStatus:(PFObject *)postObject
{
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    
    if (postObject[@"likes"] != nil)
    {
        NSMutableArray *likes = postObject[@"likes"];
        
        for (NSInteger i = 0; i < ([likes count]); i++)
        {
            NSString *stringToCheck = (NSString *)[likes objectAtIndex:i];
            
            if ([stringToCheck isEqualToString:[identifierForVendor UUIDString]]) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)getDisLikeStatus:(PFObject *)postObject
{
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    
    if (postObject[@"dislikes"] != nil)
    {
        NSMutableArray *dislikes = postObject[@"dislikes"];
        
        for (NSInteger i = 0; i < ([dislikes count]); i++)
        {
            NSString *stringToCheck = (NSString *)[dislikes objectAtIndex:i];
            
            if ([stringToCheck isEqualToString:[identifierForVendor UUIDString]]) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (BOOL)getReportStatus:(PFObject *)postObject
{
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    
    if (postObject[@"reports"] != nil)
    {
        NSMutableArray *reports = postObject[@"reports"];
        
        if ([reports count] >= 5)
        {
            return YES;
        }else{
            for (NSInteger i = 0; i < ([reports count]); i++)
            {
                NSString *stringToCheck = (NSString *)[reports objectAtIndex:i];
                
                if ([stringToCheck isEqualToString:[identifierForVendor UUIDString]]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}


+ (CGFloat)calculateHeightForText:(NSString *)text withWidth:(CGFloat)width withFont:(UIFont *)font
{
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [text boundingRectWithSize:constraint
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:font}
                                            context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

+ (BOOL)checkAddPermission:(CLLocation *)currentLocation
{
    //Get the current location
    BOOL isAllowedToAdd = NO;
    
    for (NSInteger i = 0; i < [[Config availableLocations] count]; i++)
    {
        //Create a cllocation object
        CLLocation *availablePoint = [[CLLocation alloc] initWithLatitude:[[Config availableLocations][i][1] floatValue]
                                                                longitude:[[Config availableLocations][i][2] floatValue]];
        
        CLLocationDistance delta = [currentLocation distanceFromLocation:availablePoint];
        
        if (delta != 0 && delta <= [[Config availableLocations][i][3] floatValue])
        {
            isAllowedToAdd = YES;
            
            //NSString *college = [NSString stringWithFormat:@"%@",availableLocations[i][0]];
            // NSLog(college);
            i = [[Config availableLocations] count];
        }
    }
    
    return isAllowedToAdd;
}

+ (BOOL)getClosestLocation:(CLLocation *)currentLocation
{
    //Get the current location
    BOOL isAllowedToAdd = NO;
    
    for (NSInteger i = 0; i < [[Config availableLocations] count]; i++)
    {
        //Create a cllocation object
        CLLocation *availablePoint = [[CLLocation alloc] initWithLatitude:[[Config availableLocations][i][1] floatValue]
                                                                longitude:[[Config availableLocations][i][2] floatValue]];
        
        CLLocationDistance delta = [currentLocation distanceFromLocation:availablePoint];
        
        //If the user distance from the main location is less than or equal to the allowed distance
        if (delta != 0 && delta <= [[Config availableLocations][i][3] floatValue])
        {
            isAllowedToAdd = YES;
            
            //NSString *college = [NSString stringWithFormat:@"%@",availableLocations[i][0]];
            // NSLog(college);
            i = [[Config availableLocations] count];
        }
    }
    
    return isAllowedToAdd;
}


+ (NSString *)deviceId
{
    NSUUID *identifierForVendor = [[UIDevice currentDevice] identifierForVendor];
    
    return [identifierForVendor UUIDString];

}

+ (NSString *)likesCount:(NSInteger)likesCount
{
    if (likesCount > 0)
        return [NSString stringWithFormat:@"%ld",(long)likesCount];
    else
        return [NSString stringWithFormat:@""];
}

+ (NSString *)repliesCount:(NSInteger)repliesCount
{
    if (repliesCount > 0)
        return [NSString stringWithFormat:@"%ld cmts",repliesCount];
    else
        return [NSString stringWithFormat:@""];
}

+ (NSDictionary *)subViewFrames:(NSDictionary *)postObject
{
    CGFloat postTextHeight = [Config calculateHeightForText:postObject[@"text"] withWidth:TEXT_WIDTH withFont:TEXT_FONT];

    //Set Label Frame
    CGRect labelFrame = CGRectMake(LEFT_PADDING, TOP_PADDING, TEXT_WIDTH, 0);
    labelFrame.size.height = postTextHeight;
    
    CGRect imageFrame = CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH, IMAGEVIEW_HEIGHT);
    CGRect actionViewframe = CGRectMake(LEFT_PADDING, 0, TEXT_WIDTH + LEFT_PADDING, ACTIONS_VIEW_HEIGHT);
    
    if (postObject[@"parseObject"][@"pic"])
    {
        //Set Image View Frame
        imageFrame.origin.y = labelFrame.origin.y + postTextHeight + 5;
        imageFrame.size.height = IMAGEVIEW_HEIGHT;
        
        //Set Action View Frame
        actionViewframe.origin.y = imageFrame.origin.y + imageFrame.size.height + 10;
    }else{
        
        //Set Image View Frame
        imageFrame.origin.y = 0;
        imageFrame.size.height = 0;
        
        //Set Action View Frame
        actionViewframe.origin.y = labelFrame.origin.y + postTextHeight + 10;
    }
    
    NSDictionary *subViewframes =   @{
                                      @"postTextFrame" : [NSValue valueWithCGRect:labelFrame],
                                      @"imageFrame" : [NSValue valueWithCGRect:imageFrame],
                                      @"actionViewframe" : [NSValue valueWithCGRect:actionViewframe]
                                      };
    
    return subViewframes;
}

+ (NSDictionary *)subViewFrames2:(NSDictionary *)postObject
{
    CGFloat postTextHeight = [Config calculateHeightForText:postObject[@"text"] withWidth:WIDTH - 55.5f withFont:TEXT_FONT];
    
    CGFloat cellHeight = TOP_PADDING + postTextHeight + 12 + ACTIONS_VIEW_HEIGHT;

    if (postObject[@"parseObject"][@"pic"])
        cellHeight =  cellHeight + 10 + IMAGEVIEW_HEIGHT;
    
    CGRect lineFrame = CGRectMake(0, 0, 33, cellHeight);
    CGRect lineBorderFrame = CGRectMake(LEFT_PADDING - 1, 0, 2.0, cellHeight);

    
    CGFloat y = (cellHeight / 2) - (14/2);
    CGRect bubbleFrame = CGRectMake((33/2) - (14/2), y, 14, 14);
    
    CGRect triangleFrame = CGRectMake(26, (cellHeight / 2) - (20/2), 10, 20);

    
    //Set container Frame
    CGRect containerFrame = CGRectMake(lineFrame.origin.x + CGRectGetWidth(lineFrame),
                                       0,
                                       WIDTH - 41.5f,
                                       cellHeight);
    
    
    CGRect labelFrame = CGRectMake(8, TOP_PADDING, CGRectGetWidth(containerFrame) - 14, postTextHeight);
    CGRect imageFrame = CGRectMake(8, 0, CGRectGetWidth(containerFrame) - 14, IMAGEVIEW_HEIGHT);
    CGRect actionViewframe = CGRectMake(8, 0, CGRectGetWidth(containerFrame) - 8, ACTIONS_VIEW_HEIGHT);
    
    if (postObject[@"parseObject"][@"pic"])
    {
        //Set Image View Frame
        imageFrame.origin.y = labelFrame.origin.y + postTextHeight + 5;
        imageFrame.size.height = IMAGEVIEW_HEIGHT;
        
        //Set Action View Frame
        actionViewframe.origin.y = imageFrame.origin.y + imageFrame.size.height + 10;
    }else{
        
        //Set Image View Frame
        imageFrame.origin.y = 0;
        imageFrame.size.height = 0;
        
        //Set Action View Frame
        actionViewframe.origin.y = labelFrame.origin.y + postTextHeight + 10;
    }
    
    NSDictionary *subViewframes =   @{
                                      @"lineFrame" : [NSValue valueWithCGRect:lineFrame],
                                      @"lineBorderFrame" : [NSValue valueWithCGRect:lineBorderFrame],
                                      @"bubbleFrame" : [NSValue valueWithCGRect:bubbleFrame],
                                      @"triangleFrame" : [NSValue valueWithCGRect:triangleFrame],
                                      @"containerFrame" : [NSValue valueWithCGRect:containerFrame],
                                      @"postTextFrame" : [NSValue valueWithCGRect:labelFrame],
                                      @"imageFrame" : [NSValue valueWithCGRect:imageFrame],
                                      @"actionViewframe" : [NSValue valueWithCGRect:actionViewframe]
                                      };
    
    return subViewframes;
}

+ (void)incrementUserPoints
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"Points"])
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Points"];
    }else{
        //Else, update the current value
        NSInteger currentPoints = [[NSUserDefaults standardUserDefaults] integerForKey:@"Points"];
        currentPoints++;
        
        [[NSUserDefaults standardUserDefaults] setInteger:currentPoints forKey:@"Points"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)updateUserPoints:(NSInteger)points
{
    [[NSUserDefaults standardUserDefaults] setInteger:points forKey:@"Points"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return [Config userPoints];
}

+ (NSDictionary *)userPoints
{
    NSInteger points;
    NSString *rank;
    
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"Points"])
    {
        points = 0;
    }else{
        points = [[NSUserDefaults standardUserDefaults] integerForKey:@"Points"];
    }
    
    rank = [Config rankForPoints:points];
    
    NSDictionary *result = @{@"Points" : [NSNumber numberWithInteger:points],
                             @"Rank" : rank
                             };
    
    return result;
}

+ (NSString *)rankForPoints:(NSInteger)points
{
    NSString *rank;
    
    if (points < 50) rank = @"NOVICE";
    else if (points < 100)  rank = @"APPRENTICE";
    else if (points < 200)  rank = @"INTERMEDIATE";
    else if (points < 300)  rank = @"REGULAR";
    else if (points < 400)  rank = @"EXPERT";
    else if (points < 500)  rank = @"ADVANCED";
    else if (points >= 500)  rank = @"MASTER";
    
    return rank;
}

+ (BOOL)checkLastUpdated:(NSDate *)lastUpdated withMaxDifference:(NSInteger)maxDifference
{
    BOOL refresh = NO;
    
    //Check Album Last Updated Date
    NSDateComponents *conversionInfo;
    NSInteger lastUpdatedDayDiff = 1;
    NSInteger lastUpdatedMinsDiff;
    
    if (lastUpdated != nil)
    {
        // Get the system calendar
        // Get conversion to months, days, hours, minutes
        NSCalendar *sysCalendar = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
        
        //Check  Last Updated Date
        conversionInfo = [sysCalendar components:unitFlags fromDate:[NSDate date]  toDate:lastUpdated  options:0];
        lastUpdatedDayDiff = [conversionInfo day];
        lastUpdatedMinsDiff = abs([conversionInfo minute]);
    }
    
    //If the time difference is a day ago or 30 minutes ago
    if (lastUpdatedDayDiff > 0 || lastUpdatedMinsDiff >= maxDifference)
        refresh = YES;
    
    return refresh;
}

#pragma mark - Reachability/Internet Connection
+ (BOOL)checkInternetConnection
{
    BOOL isAvailable;
    
    Reachability *reachability = [Reachability reachabilityWithHostName: @"www.apple.com"];
    
    if ([reachability currentReachabilityStatus] == ReachableViaWiFi
        ||
        [reachability currentReachabilityStatus] == ReachableViaWWAN)
    {
        NSError *error = nil;
        NSHTTPURLResponse *responseCode = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.google.com"]] returningResponse:&responseCode error:&error];
        
        if (responseData != nil)
            isAvailable = YES;
        else
            isAvailable = NO;
    }else{
        isAvailable = NO;
    }
    
    return isAvailable;
}

+ (UIAlertView *)alertViewWithTitle:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Ok", nil];
    
    return alertView;
}

+ (NSArray *)colours
{
    NSArray *colours =
    @[
    [UIColor colorWithRed:163/255.0f green:77/255.0f blue:60/255.0f alpha:1.0f],
    [UIColor colorWithRed:233/255.0f green:115/255.0f blue:91/255.0f alpha:1.0f],
    [UIColor colorWithRed:100/255.0f green:153/255.0f blue:112/255.0f alpha:1.0f],
    [UIColor colorWithRed:253/255.0f green:208/255.0f blue:68/255.0f alpha:1.0f],
    [UIColor colorWithRed:49/255.0f green:148/255.0f blue:207/255.0f alpha:1.0f],
    [UIColor colorWithRed:100/255.0f green:185/255.0f blue:99/255.0f alpha:1.0f],
    [UIColor colorWithRed:71/255.0f green:157/255.0f blue:200/255.0f alpha:1.0f],
    [UIColor colorWithRed:243/255.0f green:137/255.0f blue:120/255.0f alpha:1.0f],
    [UIColor colorWithRed:62/255.0f green:159/255.0f blue:211/255.0f alpha:1.0f],
    [UIColor colorWithRed:252/255.0f green:203/255.0f blue:131/255.0f alpha:1.0f],
    [UIColor colorWithRed:224/255.0f green:133/255.0f blue:105/255.0f alpha:1.0f],
    [UIColor colorWithRed:166/255.0f green:238/255.0f blue:152/255.0f alpha:1.0f],
    [UIColor colorWithRed:160/255.0f green:241/255.0f blue:247/255.0f alpha:1.0f],
    [UIColor colorWithRed:192/255.0f green:91/255.0f blue:105/255.0f alpha:1.0f],
    [UIColor colorWithRed:209/255.0f green:12/255.0f blue:81/255.0f alpha:1.0f],
    [UIColor colorWithRed:159/255.0f green:1/255.0f blue:117/255.0f alpha:1.0f],
    [UIColor colorWithRed:239/255.0f green:22/255.0f blue:46/255.0f alpha:1.0f],
    [UIColor colorWithRed:159/255.0f green:1/255.0f blue:117/255.0f alpha:1.0f],
    [UIColor colorWithRed:220/255.0f green:131/255.0f blue:169/255.0f alpha:1.0f]
    ];
    
    return colours;
}


+ (NSMutableArray *) generateRandomNumbers:(NSInteger)total withMin:(NSInteger)min withMax:(NSInteger)max
{
    NSInteger lastGenerated = -1;
    NSMutableArray *generatedNumbers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < total; i++)
    {
        BOOL done = NO; //Set the done value to NO
        
        while (done == NO)
        {
            int randNum = rand() % ((max - min) + min); //generate a random number.
            
            //Check if the number has been previously generated
            BOOL found = [generatedNumbers containsObject:[NSNumber numberWithInt: randNum]];
            
            //If the number is not the last number generated and is not in the generate numbers array
            //Add it to the array
            if(randNum != lastGenerated &&  found == NO)
            {
                lastGenerated = randNum;
                [generatedNumbers addObject:[NSNumber numberWithInt: randNum]];
                done = YES; //set the done value to YES to indicate that the while loop can be exited
            }
        }
    }
    
    return generatedNumbers;
}

+ (UIColor *)getBubbleColor
{
    NSArray *colours = [Config colours];
    
    NSInteger max = [colours count];
    NSInteger min = 0;
    
    int randNum = rand() % ((max - min) + min); //generate a random number.
    
    //Get color
    UIColor *randomColor = colours[randNum];
    
    return randomColor;
}


@end