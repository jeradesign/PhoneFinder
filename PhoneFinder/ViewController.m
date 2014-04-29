//
//  ViewController.m
//  PhoneFinder
//
//  Created by John Brewer on 4/28/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () {
    CLLocationManager *_locationManager;
    CLBeaconRegion *_region;
    NSUUID *_uuid;
}
@property (weak, nonatomic) IBOutlet UITextView *logView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    _uuid = [[NSUUID alloc] initWithUUIDString:@"585F99B8-440D-4BB4-89A8-DA12C7EAF678"];
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"phone"];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)goAction:(id)sender {
    self.logView.text = @"Going!\n";
    [_locationManager startRangingBeaconsInRegion:_region];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
#pragma unused(manager)
#pragma unused(region)
    for (CLBeacon *beacon in beacons) {
        [self log:[NSString stringWithFormat:@"rssi: %ld", (long)(beacon.rssi)]];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    [self log:error.description];
}

#pragma mark - Logging

- (void)log:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.logView.text = [NSString stringWithFormat:@"%@%@\n", self.logView.text, message];
        [self.logView scrollRangeToVisible:NSMakeRange([self.logView.text length], 0)];
    });
//    if (self.logView.contentSize.height > self.logView.frame.size.height) {
//        CGPoint offset = CGPointMake(0, self.logView.contentSize.height - self.logView.frame.size.height);
//        [self.logView setContentOffset:offset animated:YES];
//    }
}

@end
