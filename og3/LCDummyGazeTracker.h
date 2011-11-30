//
//  LCDummyGazeTracker.h
//  blinders
//
//  Created by David Pitman on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCGazeTracker.h"
#import "LCGazeCalibratorInterface.h"

@interface LCDummyGazeTracker : NSObject<LCGazeTracker>{
    NSArray* calibrationPoints;
    int calibrationIndex;
    NSString* _status;
    id <LCGazeCalibratorInterface> _calibrationInterface;
}

@property(retain) id <LCGazeCalibratorInterface> calibrationInterface;

// Used to iterate through list of calibration points
-(void)calibrateNextPoint;

@end
