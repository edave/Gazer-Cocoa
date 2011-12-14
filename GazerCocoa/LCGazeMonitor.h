//
//  LCGazeMonitor.h
//  blinders
//
//  Created by David Pitman on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCGazeFoundation.h"

@protocol LCGazeMonitorDelegate <NSObject>

-(void)gazeTrackerOffline;

-(void)gazeTrackerOnline;

-(void)gazeTrackerUnavailable;

-(void)gazeTrackerError:(NSString*)gazeError;

@optional

-(void)gazePointUpdated:(NSPoint)point;

@end

// A LCGazeMonitor acts as a bridge between its delegate and the LCGazeTracker. It behaves both as an observer and controller to the LCGazeTracker.
@protocol LCGazeMonitor <NSObject>

// The most recent GazePoint from the tracker, returns NULL if no point has been received yet..
@property NSPoint gazePoint;

@property(retain) id<LCGazeMonitorDelegate> delegate;

// Called when the LCGazeMonitor should shut down
-(void)stopMonitoring;

// The LCGazeMonitor will inform the GazeTracker to start a calibration process
-(void)startCalibration;

// The current status of the GazeTracker
-(NSString*)status;


@end
