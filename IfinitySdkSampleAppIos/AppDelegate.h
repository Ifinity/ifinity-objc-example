//
//  AppDelegate.h
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 23.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)showStartViewController;
- (void)loadDataVenuesSuccess:(void(^)(NSArray *venues))success;

@end

