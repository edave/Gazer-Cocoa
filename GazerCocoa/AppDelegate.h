//
//  AppDelegate.h
//  com.labcogs.gazercocoa
//
//  Created by Ryan Kabir on 11/22/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//
#import "GazerCocoaBridge.h"

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
    GazerCocoaBridge* gazerCocoaBridge;
    
    NSString* _gazeTrackerStatus;
}

@property (assign) IBOutlet NSWindow *window;

@property BOOL gazeTrackingRunning;

@property BOOL runHeadless;

@property(retain) NSString* gazeTrackerStatus;

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
