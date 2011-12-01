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

@interface LCCalibrationWindowController : NSWindowController<NSWindowDelegate, LCGazeCalibratorInterface>{
    
    IBOutlet NSWindow* introWindow;
    IBOutlet NSButton* startButton;
    IBOutlet NSView* hostView;
    
    IBOutlet NSWindow* successWindow;
    IBOutlet NSWindow* failureWindow;
    
    CGDirectDisplayID currentDisplayID;
    LCCalibrationPoint* currentCalibrationPoint;
    CALayer* _targetLayer;
    NSScreen* _screen;
    
    IBOutlet QTCaptureView *mCaptureView;
    
    QTCaptureSession            *mCaptureSession;
    QTCaptureDeviceInput        *mCaptureVideoDeviceInput;
    
    id <LCGazeTracker> _trackerDelegate;
}

@property (nonatomic, retain) IBOutlet NSView* hostView;

- (IBAction)startCalibrationAction:(id)sender;
- (IBAction)closeCalibrationAction:(id)sender;

- (void) closeWindows;
-(void)setupHostView;
-(CALayer*)setupFocusTargetLayer:(CALayer*)parentLayer;
-(void)centerAndShowWindow:(NSWindow*)window;
- (void) setupVideoCapture;
@end
