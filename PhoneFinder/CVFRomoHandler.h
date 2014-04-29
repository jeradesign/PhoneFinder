//
//  CVFRomoHandler.h
//  WristVision
//
//  Created by John Brewer on 12/26/13.
//  Copyright (c) 2013 Jera Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RMCore/RMCore.h>

@interface CVFRomoHandler : NSObject<RMCoreDelegate>

- (void)move:(float)seconds;
- (void)rotate:(float)angle;

@end
