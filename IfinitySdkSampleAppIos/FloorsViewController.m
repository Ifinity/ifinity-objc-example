//
//  FloorViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "FloorsViewController.h"
#import "FloorplanChild.h"
#import "ContentViewController.h"
#import <ifinitySDK/IFMContent+helper.h>

@interface FloorsViewController ()

@property (nonatomic, strong) NSArray *floors;

@end

@implementation FloorsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Venue: %@ name: %@", self.venue.remote_id, self.venue.name);
    
    self.title = [NSString stringWithFormat:@"%@ - Floors", self.venue.name];
    [self fetchFloors];
}

- (void)fetchFloors
{
    [[IFDataManager sharedManager] fetchFloorsFromCacheForVenueId:self.venue.remote_id block:^(NSArray *floors) {
        NSLog(@"Fetch floors success");
        self.floors = floors;
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
    return (NSInteger)self.floors.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    IFMFloorplan *floor = [self.floors objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"floor %@", floor.label];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[ContentViewController class]]){
        NSURL *url = [NSURL URLWithString:[self.venue.content getContentURL]];
        [(ContentViewController *)segue.destinationViewController setUrl:url];
    }else if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        IFMFloorplan *floor = [self.floors objectAtIndex:(NSUInteger)indexPath.row];
        
        if([segue.destinationViewController conformsToProtocol:@protocol(FloorplanChild)]) {
            [(id<FloorplanChild>)segue.destinationViewController setFloor:floor];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
