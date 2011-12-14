//
//  LCCalibrationWindowController.h
//  blinders
//
//  Created by David Pitman on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>
#import "LCGazeCalibratorInterface.h"
#import "CaptureView.h"
#import "GazerCocoaBridge.h"


@class LCCalibrationCameraView;
@class LCCalibrationFaceTrackingView;

@interface LCCalibrationWindowController : NSWindowController<NSWindowDelegate, LCGazeCalibratorInterface>{
    
    IBOutlet NSWindow* introWindow;
    IBOutlet NSButton* startButton;
    IBOutlet NSView* hostView;
    
    IBOutlet NSWindow* successWindow;
    IBOutlet NSWindow* failureWindow;
    
    IBOutlet NSTextField* faceTrackingTextField;
    
    NSValue *gazerCocoaBridgePointer;
    void *gazeTrackerPointer;
    
    CGDirectDisplayID currentDisplayID;
    LCCalibrationPoint* currentCalibrationPoint;
    CALayer* _targetLayer;
    NSScreen* _screen;
    
     IBOutlet LCCalibrationFaceTrackingView *faceTrackingView;
    IBOutlet CaptureView* capureView;
    
    QTCaptureSession            *mCaptureSession;
    QTCaptureDeviceInput        *mCaptureVideoDeviceInput;
    
    id <LCGazeTracker> _trackerDelegate;
}

@property (nonatomic, retain) IBOutlet NSView* hostView;
@property (nonatomic, retain) CALayer* _targetLayer;
@property (nonatomic, retain) NSValue *gazerCocoaBridgePointer;
@property void *gazeTrackerPointer;

- (IBAction)startCalibrationAction:(id)sender;
- (IBAction)closeCalibrationAction:(id)sender;

// Close any windows which are open
- (void) closeWindows;

// Setup the view that covers the whole screen
-(void)setupHostView;

// Setup the calibration focus layer and put it in parentLayer
-(CALayer*)setupFocusTargetLayer:(CALayer*)parentLayer;

// Setup the target that shows the estimation of the gaze tracking and put in the parentLayer
-(CALayer*)setupGazeTargetLayer:(CALayer*)parentLayer;

// Show the Calibration Intro window and position in the center of the screen
-(void)centerAndShowWindow:(NSWindow*)window;

// Get the webcam up and running for display in the intro window
- (void) setupVideoCapture;

@end
