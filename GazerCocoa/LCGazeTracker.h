//
//  GazeTracker.h
//  blinders
//
//  Created by David Pitman on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCGazeFoundation.h"

@protocol LCGazeCalibratorInterface;
@protocol LCGazeListener;

@protocol LCGazeTracker <NSObject>

// Used to add a GazeListener that wants to receive updates from the GazeTracker
-(void)registerGazeTrackerListener:(id <LCGazeListener>) gazeListener;

// Used to remove a GazeListener from observing this GazeTracker
-(void)deregisterGazeTrackerListener:(id <LCGazeListener>) gazeListener;

-(LCGazePoint*)currentGazeLocation;

// Set the GazeCalibratorInterface which will be driven by this GazeTracker
-(void)setGazeCalibratorInterface:(id <LCGazeCalibratorInterface>) gazeCalibrator;

// Used by a GazeCalibratorInterface to indicate it is ready to begin calibration
-(void)readyToCalibrate;

// The current status of the Gaze Tracker
-(NSString*)calibrationStatus;

// NOT USED ATM - Used by a GazeCalibratorInterface to indicate that it is now shoing a particular point (allows for non-blocking transitions between points by the GazeCalibratorInterface
-(void)displayingCalibrationPoint:(LCCalibrationPoint*) point;

// Used by a GazeCalibratorInterface to indicate that the calibration has been aborted (and the UI shutdown)
-(void)calibrationAborted;

@end
