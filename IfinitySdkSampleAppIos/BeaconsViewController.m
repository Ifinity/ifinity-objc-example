//
//  BeaconsViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "BeaconsViewController.h"

@interface BeaconsViewController ()

@end

@implementation BeaconsViewController

@synthesize floor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Floor %@ - Beacons", self.floor.label];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)[self.floor.beacons allObjects].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    IFMBeacon *beacon = [[self.floor.beacons allObjects] objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = beacon.name;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
