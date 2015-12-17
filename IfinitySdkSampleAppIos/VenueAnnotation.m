//
//  VenueAnnotation.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 25.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "VenueAnnotation.h"

@interface VenueAnnotation ()

@property (nonatomic, strong) NSString *name;

@end

@implementation VenueAnnotation

@synthesize coordinate;

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _name = title;
    }
    return self;
}


- (NSString *)subtitle
{
    return nil;
}

- (NSString *)title
{
    return self.name;
}

@end
