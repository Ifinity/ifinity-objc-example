//
//  ViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 23.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "VenuesViewController.h"
#import <ifinitySDK/ifinitySDK.h>
#import "FloorsViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface VenuesViewController ()

@property (nonatomic, strong) NSArray *venues;

@end

@implementation VenuesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Venues";
    [self fetchVenues];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[IFBluetoothManager sharedManager] setDelegate:nil];
    [[IFBluetoothManager sharedManager] stopManager];
    [super viewWillAppear:animated];
}

#pragma mark - Clear Caches

- (IBAction)clearCaches:(id)sender
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [[IFDataManager sharedManager] clearCaches];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadDataVenuesSuccess:^(NSArray *venues) {
        [self fetchVenues];
        [SVProgressHUD dismiss];
    }];
}

- (void)fetchVenues
{
    [[IFDataManager sharedManager] fetchVenuesFromCacheWithBlock:^(NSArray *venues) {
        NSLog(@"Fetch venues success.");
        self.venues = venues;
        
        if(self.refreshControl) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM d, h:mm a"];
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                     [formatter stringFromDate:[NSDate date]]];
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
            [self.refreshControl endRefreshing];
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.venues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    IFMVenue *venue = [self.venues objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = venue.name;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        IFMVenue *venue = [self.venues objectAtIndex:(NSUInteger)indexPath.row];
        
        if([segue.destinationViewController isKindOfClass:[FloorsViewController class]]) {
            FloorsViewController *vc = segue.destinationViewController;
            vc.venue = venue;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
