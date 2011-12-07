//
// LCGazeFoundation.h
// blinders
//
// Created by David Pitman on 11/22/11.
// Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LCGazePoint.h"
#import "LCCalibrationPoint.h"

// Distributed Notification Center Notifications
#define kGazeTrackerReady @"kLCGazeTrackerReady"
#define kGazeTrackerTerminating @"kLCGazeTrackerTerminating"
#define kGazeTrackerTerminateRequest @"kLCGazeTrackerTerminateRequest"
#define kGazeTrackerCalibrationStart @"kLCGazeTrackerCalibrationStart"
#define kGrazeTrackerCalibrationEnded @"kLCGrazeTrackerCalibrationEnded"
#define kGazeTrackerCalibrationAbort @"kLCGazeTrackerCalibrationAbort"
#define kGazeTrackerPointBroadcastStart @"kLCGazeTrackerPointBroadcastStart"
#define kGazePointNotification @"kLCGazePointNotification"
#define kGazeTrackerPointBroadcastEnd @"kLCGazeTrackerPointBroadcastEnd"
#define kGazeTrackerError @"kLCGazeTrackerError"

// Notification Keys
#define kGazeListenerAppUIDKey @"kLCGazeListenerAppUIDKey"
#define kGazeTrackerStatusKey @"kLCGazeTrackerStatusKey"
#define kGazePointKey @"kLCGazePointKey"
#define kGazePointXKey @"kLCGazePointXKey"
#define kGazePointYKey @"kLCGazePointYKey"
#define kGazePointTimestampKey @"kLCGazePointTimestampKey"

// Notification Values
#define kGazeTrackerUnavailable @"kLCGazeTrackerUnavailable" // There's no connection to the gaze tracker
#define kGazeTrackerUncalibrated @"kLCGazeTrackerUncalibrated" // Initial state, no calibrations attempted
#define kGazeTrackerCalibrated @"kLCGazeTrackerCalibrated" // Tracker is calibrated
#define kGazeTrackerNeedsRecalibration @"kLCGazeTrackerNeedsRecalibration" // Tracker needs to be recalibrated
#define kGazeTrackerNoVideo @"kLCGazeTrackerNoVideo" // Tracker cannot obtain a video stream
#define kGazeTrackerUserLost @"kLCGazeTrackerUserLost"
#define kGazeTrackerUserFound @"kLCGazeTrackerUserFound"