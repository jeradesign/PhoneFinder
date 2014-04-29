//
//  CVFRomoHandler.m
//  WristVision
//
//  Created by John Brewer on 12/26/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import "CVFRomoHandler.h"
#import <RMCore/RMCore.h>

@interface CVFRomoHandler() {
    RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *_robot;
    BOOL _moving;
    BOOL _turnMode;
}

@end

@implementation CVFRomoHandler

- (instancetype)init
{
    self = [super init];
    if (self !=nil) {
        [RMCore setDelegate:self];
    }
    return self;
}

#pragma mark - Romo delegate methods

- (void)robotDidConnect:(RMCoreRobot *)robot
{
    [self logMessage:@"robotDidConnect:"];
    // Currently the only kind of robot is Romo3, so this is just future-proofing
    if (robot.isDrivable && robot.isHeadTiltable && robot.isLEDEquipped) {
        _robot = (RMCoreRobot<HeadTiltProtocol, DriveProtocol, LEDProtocol> *) robot;
        [_robot tiltToAngle:100.0 completion:^(BOOL success) {
            [self logMessage:[NSString stringWithFormat: @"tiltToAngle:completion: %d", success]];
            (void) success;
            _moving = false;
        }];
    }
}

- (void)robotDidDisconnect:(RMCoreRobot *)robot
{
    [self logMessage:@"robotDidDisconnect:"];
    if (robot == _robot) {
        _robot = nil;
    }
}

#pragma mark - Motion implementation

- (void)move:(float)distance
{
    [self logMessage:[NSString stringWithFormat:@"move:%f", distance]];
    if (_moving) {
        [self logMessage:@"move: returning"];
        return;
    }
    _moving = YES;
    
    dispatch_queue_t high_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(high_queue, ^{
        if (distance > 0) {
            [_robot driveForwardWithSpeed:1.0];
        } else {
            [_robot driveBackwardWithSpeed:1.0];
        }
    });
    
    distance = fabsf(distance);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(distance * NSEC_PER_SEC));
    dispatch_after(popTime, high_queue, ^(void){
        [self logMessage:@"stopping"];
        [_robot stopDriving];
        _moving = NO;
        [self.delegate doneMoving];
    });
}

- (void)rotate:(float)angle
{
    if (_moving) {
        [self logMessage:@"rotate: returning"];
        return;
    }
    [self logMessage:[NSString stringWithFormat:@"rotate:%f", angle]];
    _moving = YES;
    [_robot turnByAngle:angle withRadius:0 completion:^(BOOL success, float heading){
        (void)success;
        (void)heading;
        _moving = NO;
        [self.delegate doneMoving];
    }];
}

- (void)logMessage:(NSString *)message
{
    NSLog(@"%@", message);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"CVFRomoHandler: %@", message);
//        g_label.text = message;
    });
}

@end
