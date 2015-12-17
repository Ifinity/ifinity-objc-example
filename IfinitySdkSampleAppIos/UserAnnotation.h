//
//  UserAnnotation.h
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 25.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface UserAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end
