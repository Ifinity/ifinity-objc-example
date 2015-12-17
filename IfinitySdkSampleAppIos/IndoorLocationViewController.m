//
//  IndoorLocationViewController.m
//  IfinitySdkSampleAppIos
//
//  Created by Ifinity on 24.11.2015.
//  Copyright © 2015 getifinity.com. All rights reserved.
//

#import "IndoorLocationViewController.h"
#import <ifinitySDK/IFPushManager.h>
#import <MapKit/MapKit.h>
#import "UserAnnotation.h"

@interface IndoorLocationViewController () <IFBluetoothManagerDelegate, IFIndoorLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) IFIndoorLocationManager *indoorLocationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UserAnnotation *userAnnotation;

@end

@implementation IndoorLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Indoor Location";
    
    // User annotation will display my current indoor position
    self.userAnnotation = [[UserAnnotation alloc] init];
    [self.mapView addAnnotation:self.userAnnotation];
    
    self.indoorLocationManager = [[IFIndoorLocationManager alloc] init];
    self.indoorLocationManager.delegate = self;
    [[IFLocationManager sharedManager] setZoomFactor:4];
    
    if(self.currentFloor){
        [self updateMap];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // Start looking for beacons around me
    [[IFBluetoothManager sharedManager] startManager];
    [[IFBluetoothManager sharedManager] setDelegate:self];
    [self.indoorLocationManager startUpdatingIndoorLocation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addPush:) name:IFPushManagerNotificationPushAdd object:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop looking for beacons around me
    [[IFBluetoothManager sharedManager] setDelegate:nil];
    [self.indoorLocationManager stopUpdatingIndoorLocation];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IFPushManagerNotificationPushAdd object:nil];
}

- (void)addAreasToMap
{
    NSArray *areas = [self.currentFloor.areas allObjects];
    NSMutableArray *areaPoints;
    int i =0;
    
    for (IFMArea *area in areas) {
        areaPoints = [NSMutableArray arrayWithArray:[area.points allObjects]];
        NSInteger c = [areaPoints count];
        CLLocationCoordinate2D pointsToUse[c];
        i = 0;
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
        [areaPoints sortUsingDescriptors:@[sort]];
        
        for (IFMAreaPoint *areaPoint in areaPoints) {
            CLLocationCoordinate2D c = [[IFLocationManager sharedManager] translateCoordinate:CLLocationCoordinate2DMake([areaPoint.lat doubleValue], [areaPoint.lng doubleValue])];
            pointsToUse[i] = c;
            i++;
        }
        MKPolygon *polygon = [MKPolygon polygonWithCoordinates:pointsToUse count:areaPoints.count];
        polygon.title = @"IFAreasOverlay";
        [self.mapView addOverlay:polygon level:MKOverlayLevelAboveLabels];
    }
}

- (void)addBeaconsToMap
{
    NSArray *beacons = [self.currentFloor.beacons allObjects];
    for (IFMBeacon *beacon in beacons) {
        CLLocationCoordinate2D c = [[IFLocationManager sharedManager] translateCoordinate:beacon.location.coordinate];
        IFBeaconAnnotation *ann = [[IFBeaconAnnotation alloc] initWithCoordinate:c];
        ann.title = beacon.name;
        [self.mapView addAnnotation:ann];
    }
}

- (void)resetMap
{
    [self.indoorLocationManager startCheckingAreasForFloorplan:nil];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    [self.mapView.annotations enumerateObjectsUsingBlock:^(id<MKAnnotation>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![obj isKindOfClass:[UserAnnotation class]]){
            [self.mapView removeAnnotation:obj];
        }
    }];
}

- (void)updateMap
{
    // remove old overlay and annotation
    [self resetMap];
    
    [[IFLocationManager sharedManager] setTranslationCoordinate:CLLocationCoordinate2DMake([[self.currentFloor.venue center_lat] doubleValue], [[self.currentFloor.venue center_lng] doubleValue])];
    
    // Center map to floor center coordinate
    CLLocationCoordinate2D center = [[IFLocationManager sharedManager] translateCoordinate:[self.currentFloor center]];
    CLLocationDistance distance = 1200.0;
    
    MKMapCamera *camera = [MKMapCamera
                           cameraLookingAtCenterCoordinate:center
                           fromEyeCoordinate:center
                           eyeAltitude:distance];
    [self.mapView setCamera:camera animated:NO];
    
    // Set user coordinate
    self.userAnnotation.coordinate = center;
    
    // Add support new floorplan overlay
    IFTileOverlay *overlay = [[IFTileOverlay alloc] init];
    overlay.mapURL = self.currentFloor.map_id;
    overlay.status = [self.currentFloor.tileStatus integerValue];
    [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    
    // We can display all the area on the map right away
    [self addAreasToMap];
    
    // We can display all the beacons on the map right away
    [self addBeaconsToMap];
    
    // start checking area in floorplan
    [self.indoorLocationManager startCheckingAreasForFloorplan:self.currentFloor];
}

#pragma mark - Push

- (void)addPush:(id)sender
{
    NSDictionary *dict = [sender userInfo];
    IFMPush *push = [dict objectForKey:@"push"];
    NSLog(@"Indoor Location New Push: %@", push.name);
}

#pragma mark - IFBluetoothManagerDelegate

- (void)manager:(IFBluetoothManager *)manager didDiscoverActiveBeaconsForVenue:(IFMVenue *)venue floorplan:(IFMFloorplan *)floorplan
{
    if(venue == nil)return;
    
    if(venue.type == IFMVenueTypeMap){
        if(self.currentFloor && ![self.currentFloor.venue_id isEqualToNumber:venue.remote_id]){
            [self manager:manager didLostAllBeaconsForVenue:self.currentFloor.venue];
        }else if(self.currentFloor == nil || ![self.currentFloor.remote_id isEqualToNumber:floorplan.remote_id]){
            self.currentFloor = floorplan;
            [self updateMap];
        }
    }
}

- (void)manager:(IFBluetoothManager *)manager didLostAllBeaconsForVenue:(IFMVenue *)venue
{
    self.currentFloor = nil;
    [[IFBluetoothManager sharedManager] setDelegate:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)manager:(IFBluetoothManager *)manager didLostAllBeaconsForFloorplan:(IFMFloorplan *)floorplan
{
    
}

#pragma mark - IFIndoorLocationManagerDelegate

- (void)manager:(IFIndoorLocationManager *)manager didUpdateIndoorLocation:(CLLocation *)location
{
    // User position has changed
    CLLocationCoordinate2D c = [[IFLocationManager sharedManager] translateCoordinate:location.coordinate];
    self.userAnnotation.coordinate = c;
    
    //NSLog(@"lat: %f lng: %f annotations: %i", c.latitude, c.longitude, self.mapView.annotations.count);
}

- (void)manager:(IFIndoorLocationManager *)manager didEnterArea:(IFMArea *)area
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)manager:(IFIndoorLocationManager *)manager didExitArea:(IFMArea *)area
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay> )overlay
{
    if ([overlay isKindOfClass:[IFTileOverlay class]]) {
        return [[IFTileOverlayRenderer alloc] initWithOverlay:overlay];
    }else if ([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonRenderer *polygonView = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [UIColor clearColor];
        
        float randomRed = arc4random() % 255;
        float randomGreen = arc4random() % 255;
        float randomBlue = arc4random() % 255;
        
        polygonView.fillColor = [[UIColor colorWithRed:randomRed / 255.0f green:randomGreen / 255.0f blue:randomBlue / 255.0f alpha:1.0f] colorWithAlphaComponent:0.5f];
        return polygonView;
    }
    return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation> )annotation
{
    // UserAnnotation with some nice icon
    if ([annotation isKindOfClass:[UserAnnotation class]]) {
        static NSString *annotationUserReuseIdentifier = @"IFUser";
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationUserReuseIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationUserReuseIdentifier];
        }
        annotationView.image = [UIImage imageNamed:@"ico_you"];
        annotationView.centerOffset = CGPointMake(0, 0);
        annotationView.annotation = annotation;
        return annotationView;
    }
    
    // IFBeaconAnnotation with some nice icon
    if ([annotation isKindOfClass:[IFBeaconAnnotation class]]) {
        static NSString *annotationUserReuseIdentifier = @"IFBeacon";
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationUserReuseIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationUserReuseIdentifier];
        }
        annotationView.image = [UIImage imageNamed:@"ico_beacon"];
        annotationView.centerOffset = CGPointMake(0, 0);
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
