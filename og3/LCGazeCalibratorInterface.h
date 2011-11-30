//
//  LCGazeCalibratorInterface.h
//  blinders
//
//  Created by David Pitman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCGazeFoundation.h"

@protocol LCGazeTracker;

@protocol LCGazeCalibratorInterface <NSObject>

// Set/Get the Gaze tracker delegate
@property(retain) id <LCGazeTracker>  trackerDelegate;

// Start the calibration process
-(void) beginCalibration:(CGDirectDisplayID)displayID;

// Finish the calibration process
-(void) finishCalibration:(NSString*)status;

// Go to the next calibration point
-(void) moveToNextPoint:(LCCalibrationPoint*) point;

// Calibration display size
-(float) displaySize;


@end
