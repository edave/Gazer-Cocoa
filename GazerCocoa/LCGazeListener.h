//
//  GazeListener.h
//  blinders
//
//  Created by David Pitman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCGazeFoundation.h"

@protocol LCGazeTracker;

@protocol LCGazeListener <NSObject>

// Register the gaze tracker
- (void)setGazeTracker:(LCGazeTracker*) tracker;

// Called by the tracker once it has been calibrated
- (void)trackerCalibrationState:(NSString*) calibrationStatus;

// A pushed update of the gaze points (may not be needed?)
- (void)gazeChangedEvent:(LCGazePoint*) gazePoint;

// Called when the GazeTracker has lost the gaze (ie, a "null" gaze)
- (void)gazeLost;

// Called when the GazeTracker has acquired the gaze location
- (void)gazeAcquired;

@end
