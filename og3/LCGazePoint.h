//
//  LCGazePoint.h
//  blinders
//
//  Created by David Pitman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCGazePoint : NSObject{
    float _precision;
    float _x;
    float _y;
}

// The estimated precision of the gaze point
@property float precision;

@property float x;

@property float y;

@end
