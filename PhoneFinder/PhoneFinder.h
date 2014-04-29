//
//  PhoneFinder.h
//  PhoneFinder
//
//  Created by John Brewer on 4/28/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "PhoneFinderDelegate.h"
#import "CVFRomoHandlerDelegate.h"

@interface PhoneFinder : NSObject<CLLocationManagerDelegate, CVFRomoHandlerDelegate>

@property (nonatomic, weak) NSObject<PhoneFinderDelegate> *delegate;

- (void)findPhone;

@end
