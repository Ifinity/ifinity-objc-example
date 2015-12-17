//
//  VenuMapViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 25.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "VenuesMapViewController.h"
#import <MapKit/MapKit.h>
#import <ifinitySDK/ifinitySDK.h>
#import <ifinitySDK/IFPushManager.h>
#import "VenueAnnotation.h"
#import "IndoorLocationViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"

@interface VenuesMapViewController () <MKMapViewDelegate, IFBluetoothManagerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IFMVenue *currentVenue;
@property (nonatomic, strong) IFMFloorplan *currentFloor;

@end

@implementation VenuesMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Venues Map";
}

- (void)viewWillAppear:(BOOL)animated
{
    // Start looking for beacons around me
    [[IFBluetoothManager sharedManager] setDelegate:self];
    [[IFBluetoothManager sharedManager] startManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPush:) name:IFPushManagerNotificationPushAdd object:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[IFBluetoothManager sharedManager] setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFPushManagerNotificationPushAdd object:nil];
}

#pragma mark - Push

- (void)addPush:(id)sender
{
    NSDictionary *dict = [sender userInfo];
    IFMPush *push = [dict objectForKey:@"push"];
    NSLog(@"Venue Map New Push: %@", push.name);
}

#pragma mark - Clear Caches

- (IBAction)clearCaches:(id)sender
{
    [[IFBluetoothManager sharedManager] setDelegate:nil];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [[IFDataManager sharedManager] clearCaches];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadDataVenuesSuccess:^(NSArray *venues) {
        [SVProgressHUD dismiss];
        [[IFBluetoothManager sharedManager] setDelegate:self];
    }];
}

#pragma mark - IFBluetoothManagerDelegate

- (void)manager:(IFBluetoothManager *)manager didDiscoverActiveBeaconsForVenue:(IFMVenue *)venue floorplan:(IFMFloorplan *)floorplan
{
    if(venue == nil)return;
    
    if(venue.type == IFMVenueTypeMap){
        
        NSLog(@"IFMVenueTypeMap %s", __FUNCTION__);
        
        self.currentVenue = venue;
        self.currentFloor = floorplan;
        [[IFBluetoothManager sharedManager] setDelegate:nil];
        [self performSegueWithIdentifier:@"IndoorLocation" sender:self];
        
    }else if(venue.type == IFMVenueTypeBeacon){
        
        NSLog(@"IFMVenueTypeBeacon %s", __FUNCTION__);
        
        if([self.currentVenue.remote_id isEqualToNumber:venue.remote_id])return;

        // Center map to venue center coordinate
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([venue.center_lat doubleValue], [venue.center_lng doubleValue]);
        
        VenueAnnotation *venueAnnotation = [[VenueAnnotation alloc] initWithTitle:venue.name];
        venueAnnotation.coordinate = center;
        [self.mapView addAnnotation:venueAnnotation];
        
        CLLocationDistance distance = 800.0;
        
        MKMapCamera *camera = [MKMapCamera
                               cameraLookingAtCenterCoordinate:center
                               fromEyeCoordinate:center
                               eyeAltitude:distance];
        [self.mapView setCamera:camera animated:NO];
    }
    
    self.currentVenue = venue;
}

- (void)manager:(IFBluetoothManager *)manager didLostAllBeaconsForVenue:(IFMVenue *)venue
{
    self.currentVenue = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)manager:(IFBluetoothManager *)manager didLostAllBeaconsForFloorplan:(IFMFloorplan *)floorplan
{
    self.currentFloor = nil;
    [self.mapView removeAnnotations:self.mapView.annotations];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
    // VenueAnnotation with some nice icon
    if ([annotation isKindOfClass:[VenueAnnotation class]]) {
        static NSString *annotationIdentifier = @"venueIdentifier";
        MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
        return pinView;
    }
    return nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.destinationViewController isKindOfClass:[IndoorLocationViewController class]]) {
        [(IndoorLocationViewController *)segue.destinationViewController setCurrentFloor:self.currentFloor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
