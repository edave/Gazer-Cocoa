//
//  AppDelegate.h
//  og3
//
//  Created by Ryan Kabir on 11/22/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#include <opencv/cv.h>
#include <opencv/highgui.h>
#include "utils.h"
#include "OutputMethods.h"
#include "MainGazeTracker.h"
#include "WindowStore.h"

#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#import "ogc.h"

#import "GlobalManager.h"
#import <Cocoa/Cocoa.h>
#import "LCCalibrationWindowController.h"
#import "LCGazeTrackerWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    LCCalibrationWindowController* calibrationWindowController;
    LCGazeTrackerWindowController* gazeWindowController;
    BOOL _runHeadless;
    BOOL gazeTrackingRunning;
    MainGazeTracker *gazeTracker;
    OGc* openGazerCocoa;
    
    NSString* _gazeTrackerStatus;
}

@property (assign) IBOutlet NSWindow *window;

@property BOOL gazeTrackingRunning;

@property BOOL runHeadless;

@property NSString* gazeTrackerStatus;

// Kick off the gaze tracking process
-(void)launchGazeTracking;

// Launch the Calibration GUI and invoke the gaze tracking if needed 
-(void)launchCalibrationGUI;

// Show the Calibration GUI elements
-(void)showCalibration;


// Notifications
-(void)moveCalibrationPoint:(NSNotification*)note;
-(void)calibrationStarted:(NSNotification*)note;
-(void)finishedCalibration:(NSNotification*)note;
-(void)terminationRequested:(NSNotification*)note;
-(void)calibrationStartRequested:(NSNotification*)note;

-(void)toggleGazeTarget:(NSEvent*)hotKeyEvent;

@end
