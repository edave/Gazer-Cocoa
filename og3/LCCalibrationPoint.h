//
//  LCCalibrationPoint.h
//  blinders
//
//  Created by David Pitman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

// A calibration point is a resolution independent point used to calibrate a
// gaze tracker. The point has X/Y float values in [0,1]

#import <Foundation/Foundation.h>

@interface LCCalibrationPoint : NSObject{
    float _x;
    float _y;
}

@property float x;
@property float y;

// These points should be [0,1] representing a ratio of the screen with the origin at top left
+(id) initWithX:(float)x andY:(float)y;

-(CGPoint) pointForScreen:(NSScreen*) screen;

@end
