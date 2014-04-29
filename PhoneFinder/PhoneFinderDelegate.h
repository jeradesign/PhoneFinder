//
//  PhoneFinderDelegate.h
//  PhoneFinder
//
//  Created by John Brewer on 4/28/14.
//  Copyright (c) 2014 Jera Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhoneFinderDelegate <NSObject>

-(void) reportRSSI:(NSInteger)rssi;
-(void) reportError:(NSString*)message;

@end
