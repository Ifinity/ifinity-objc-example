//
//  AppDelegate.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 23.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "AppDelegate.h"
#import <ifinitySDK/ifinitySDK.h>
#import <ifinitySDK/IFPushManager.h>

#define GEOS_APP_ID @"43_8jqmibuoltkwkkogsws4ogkkwg4swos0g8ko84k44s4o848o8"
#define GEOS_SECRET @"2b1my6quzs748440gcwcww04os0kw0s480o4cskg488488gc8w"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[IFBluetoothManager sharedManager] setOutsideBeaconName:@"GEOS_OUT"];
    [[IFDataManager sharedManager] setClientID:GEOS_APP_ID secret:GEOS_SECRET];
    
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    [application registerForRemoteNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPush:) name:IFPushManagerNotificationPushAreaBackgroundAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPush:) name:IFPushManagerNotificationPushVenueBackgroundAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPush:) name:IFPushManagerNotificationPushRemoteBackgroundAdd object:nil];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Device token: %@", token);
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Notification

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[IFPushManager sharedManager] addReceiveLocalNotification:notification.userInfo];
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[IFPushManager sharedManager] addReceiveRemoteNotification:userInfo];
    application.applicationIconBadgeNumber = 0;
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSString *str = [NSString stringWithFormat:@"Error: %@", err];
    NSLog(@"Device token error: %@", str);
}

- (void)openPush:(id)sender
{
    NSDictionary *dict = [sender userInfo];
    IFMPush *push = [dict objectForKey:@"push"];
    NSLog(@"Open Push: %@", push.name);
}

- (void)loadDataVenuesSuccess:(void(^)(NSArray *venues))success
{
    [[IFDataManager sharedManager] loadDataForLocation:[[CLLocation alloc] initWithLatitude:52 longitude:21] distance:@1000 withPublicVenues:YES successBlock:^(NSArray *venues) {
        NSLog(@"LoadDataForLocation success.");
        if(success)success(venues);
    } failure:^(NSError *error) {
        NSLog(@"LoadDataForLocation error %@",error);
    }];
}

- (void)showStartViewController
{
    UIViewController *startViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"start"];
    [UIView transitionWithView:self.window
                      duration:0.5
                       options: UIViewAnimationOptionTransitionFlipFromLeft
                    animations: ^{ self.window.rootViewController = startViewController; }
                    completion:nil];
}

@end
