//
//  VenueAnnotation.h
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 25.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface VenueAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

- (instancetype)initWithTitle:(NSString *)title;

@end
