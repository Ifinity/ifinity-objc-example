//
//  AuthorizeViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "AuthorizeViewController.h"
#import <ifinitySDK/ifinitySDK.h>
#import "AppDelegate.h"

@interface AuthorizeViewController ()

@end

@implementation AuthorizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if([[IFDataManager sharedManager] authenticated]){
        [self loadVenues];
    }else{
        [self authorize];
    }
    [super viewDidAppear:animated];
}

- (void)authorize
{
    [[IFDataManager sharedManager] authenticateWithSuccess:^(IFOAuthCredential *credential) {
        [self loadVenues];
    }failure:^(NSError *error) {
        NSLog(@"Invalid authentication with error %@", error);
    }];
}

- (void)loadVenues
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadDataVenuesSuccess:^(NSArray *venues) {
        [self showStartViewController];
    }];
}

- (void)showStartViewController
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showStartViewController];
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
