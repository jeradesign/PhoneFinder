//
//  PhoneFinder.m
//  PhoneFinder
//
//  Created by John Brewer on 4/28/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import "PhoneFinder.h"
#import "CVFRomoHandler.h"

#define INVALID_RSSI -10000

@interface PhoneFinder() {
    CLLocationManager *_locationManager;
    CLBeaconRegion *_region;
    NSUUID *_uuid;
    CVFRomoHandler *_romoHandler;
    NSInteger _lastRSSI;
    NSInteger _lastAverage;
    NSInteger _beforeAverage;
    SEL _nextAction;
    int _direction;
}

@end

@implementation PhoneFinder

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _lastRSSI = INVALID_RSSI;
    _lastAverage = INVALID_RSSI;
    _uuid = [[NSUUID alloc] initWithUUIDString:@"585F99B8-440D-4BB4-89A8-DA12C7EAF678"];
    _region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"phone"];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    [_locationManager startRangingBeaconsInRegion:_region];
    _romoHandler = [[CVFRomoHandler alloc] init];
    _romoHandler.delegate = self;
    
    return self;
}

- (void)findPhone {
    [self logMessage:@"findPhone"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(startSearch) withObject:nil afterDelay:3.0];
    });
}

- (void)startSearch {
    [self logMessage:@"startSearch"];
    _nextAction = @selector(waitBeforeCheckDirection);
    _beforeAverage = _lastAverage;
    [_romoHandler move:[self durationForRSSI:_lastAverage]];
}

- (void)waitBeforeCheckDirection {
    [self logMessage:@"waitBeforeCheckDirection"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(checkDirection) withObject:nil afterDelay:3.0];
    });
}

- (void)checkDirection {
    [self logMessage:@"checkDirection"];
    if (_lastAverage > _beforeAverage) {
        [self logMessage:@"forward"];
        _direction = 1;
    } else {
        [self logMessage:@"backwards"];
        _direction = -1;
    }
    [self procedeUntilOvershoot];
}

- (void)procedeUntilOvershoot {
    [self logMessage:@"procedeUntilOvershoot"];
    _nextAction = @selector(waitBeforeCheckOvershoot);
    _beforeAverage = _lastAverage;
    [_romoHandler move:[self durationForRSSI:_lastAverage] * _direction];
}

- (void)waitBeforeCheckOvershoot {
    [self logMessage:@"waitBeforeCheckDirection"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(checkOvershoot) withObject:nil afterDelay:3.0];
    });
}

- (void)checkOvershoot {
    [self logMessage:@"checkOvershoot"];
    if (_lastAverage < _beforeAverage) {
        [self overshot];
    } else {
        [self procedeUntilOvershoot];
    }
}

- (void)overshot {
    [self logMessage:@"overshot"];
    _nextAction = @selector(turnComplete);
    [_romoHandler rotate:90];
}

- (void)turnComplete {
    [self findPhone];
}

- (void)stop {
    [self logMessage:@"stop"];
    [_locationManager stopRangingBeaconsInRegion:_region];
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
#pragma unused(manager)
#pragma unused(region)
    //    if (beacons.count) {
    //        CLBeacon *beacon = beacons[0];
    //        _logView.text = [NSString stringWithFormat:@"rssi: %ld", (long)(beacon.rssi)];
    //    }

    NSInteger bestRSSI = INVALID_RSSI;
    CLBeacon *bestBeacon = nil;
    for (CLBeacon *beacon in beacons) {
        if (bestBeacon == nil && beacon != nil) {
            bestBeacon = beacon;
            continue;
        }
        NSInteger currRSSI = beacon.rssi;
        if (currRSSI == 0) {
            currRSSI = INVALID_RSSI;
        }
        if (currRSSI > bestRSSI) {
            bestBeacon = beacon;
            bestRSSI = currRSSI;
        }
    }
    if (bestBeacon != nil) {
        [self processBeacon:bestBeacon];
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"%@", error);
}

#pragma mark - CVFRomoHandlerDelegate methods

- (void)doneMoving {
    [self.delegate reportError:@"doneMoving"];
    [self performSelector:_nextAction withObject:nil];
}

#pragma mark -

- (void)processBeacon:(CLBeacon*)beacon {
    NSLog(@"UUID: %@, RSSI: %ld", [beacon.proximityUUID UUIDString], (long)(beacon.rssi));
    [self.delegate reportRSSI:beacon.rssi];
    
    NSInteger average = (beacon.rssi + _lastRSSI) / 2;
    if (average < _lastAverage) {
        NSLog(@"%ld < %ld", (long)average, (long)_lastAverage);
        [self movingAwayFromBeacon];
    }
    _lastRSSI = beacon.rssi;
    _lastAverage = average;
}

- (void)movingAwayFromBeacon {
//    [self.delegate reportError:@"Moving away from beacon"];
}

- (void)logMessage:(NSString*)message {
    [self.delegate reportError:message];
}

- (float)durationForRSSI:(NSInteger)rssi {
    if (rssi < -60) {
        return 1.0;
    } else if (rssi <- 30) {
        return 0.5;
    } else {
        return 0.5;
    }
}

@end
