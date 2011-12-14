//
//  LCCalibrationPoint.m
//  blinders
//
//  Created by David Pitman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LCCalibrationPoint.h"

@implementation LCCalibrationPoint
    @synthesize x = _x;
    @synthesize y = _y;

+(id) initWithX:(float)x andY:(float)y{
    LCCalibrationPoint* calPoint = [[LCCalibrationPoint alloc] init];
    calPoint.x = x;
    calPoint.y = y;
    return calPoint;
}

-(CGPoint) pointForScreen:(NSScreen*) screen{
    NSSize screenSize = screen.frame.size;
    return CGPointMake(screenSize.width * _x, screenSize.height - (screenSize.height * _y));
    
}

- (NSString *)description{
    return [NSString stringWithFormat:@"@% x: %f y:%f", [super description], _x, _y];
}

@end
