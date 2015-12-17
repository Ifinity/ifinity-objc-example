//
//  PushsViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "PushesViewController.h"
#import <ifinitySDK/ifinitySDK.h>
#import <ifinitySDK/IFPushManager.h>
#import "ContentViewController.h"
#import <ifinitySDK/IFMContent+helper.h>
#import <ifinitySDK/IFMPushLocal.h>

@interface PushesViewController ()

@property (nonatomic, strong) NSArray *pushes;

@end

@implementation PushesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Pushes";
    [self listPushes];
}

- (void)listPushes
{
    self.pushes = [[IFPushManager sharedManager] fetchAll];
    if(self.refreshControl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@",
                                 [formatter stringFromDate:[NSDate date]]];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
        [self.refreshControl endRefreshing];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (NSInteger)self.pushes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell1";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    IFMPush *push = [self.pushes objectAtIndex:(NSUInteger)indexPath.row];
    cell.textLabel.text = push.name;
 
    if(push.type == IFMPushTypeLocal || push.type == IFMPushTypeLocalBackground){
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
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
        IFMPush *push = [self.pushes objectAtIndex:(NSUInteger)indexPath.row];
        
        if([segue.destinationViewController isKindOfClass:[ContentViewController class]]) {
            NSString *url;
            switch (push.type) {
                case IFMPushTypeRemote:
                {
                    if(push.url){
                        url = push.url;
                    }else if(push.content){
                        [(ContentViewController *)segue.destinationViewController setContent:push.content];
                    }
                }
                    break;
                case IFMPushTypeLocal:
                {
                    IFMContent *content = [IFMContent fetchContentWithRemoteID:push.pushLocal.content_id managedObjectContext:nil];
                    url = [content getContentURL];
                }
                    break;
                case IFMPushTypeLocalBackground:
                {
                    IFMContent *content = [IFMContent fetchContentWithRemoteID:push.pushLocal.content_id managedObjectContext:nil];
                    url = [content getContentURL];
                }
                    break;
                    
                default:
                    break;
            }
            
            if(url){
                [(ContentViewController *)segue.destinationViewController setUrl:[NSURL URLWithString:url]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
