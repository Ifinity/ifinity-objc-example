//
//  AreasViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "AreasViewController.h"
#import "ContentViewController.h"
#import <ifinitySDK/IFMContent+helper.h>

@interface AreasViewController ()

@property (nonatomic, strong) NSArray *areas;

@end

@implementation AreasViewController

@synthesize floor;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = [NSString stringWithFormat:@"Floor %@ - Areas", self.floor.label];
    [self fetchAreas];
}

- (void)fetchAreas
{
    [[IFDataManager sharedManager] fetchAreasFromCacheForFloorId:self.floor.remote_id block:^(NSArray *areas) {
        NSLog(@"Fetch areas success");
        self.areas = areas;
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
    return (NSInteger)self.areas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    IFMArea *area = [self.areas objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = area.name;
    
    if([area.contents allObjects].count >= 1){
        IFMContent *content = [area.contents allObjects].firstObject;
        
        if(content && content.type == IFMContentTypeNone){
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = NO;
        }else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        IFMArea *area = [self.areas objectAtIndex:(NSUInteger)indexPath.row];
        
        if([segue.destinationViewController isKindOfClass:[ContentViewController class]]) {
            IFMContent *content = [[area.contents allObjects] firstObject];
            NSURL *url = [NSURL URLWithString:[content getContentURL]];
            [(ContentViewController *)segue.destinationViewController setUrl:url];
        }
    }else if([segue.destinationViewController conformsToProtocol:@protocol(FloorplanChild)]){
        [(id<FloorplanChild>)segue.destinationViewController setFloor:self.floor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
