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
#import "ogc.h"

@interface LCCalibrationWindowController : NSWindowController<NSWindowDelegate, LCGazeCalibratorInterface>{
    
    IBOutlet NSWindow* introWindow;
    IBOutlet NSButton* startButton;
    IBOutlet NSView* hostView;
    
    IBOutlet NSWindow* successWindow;
    IBOutlet NSWindow* failureWindow;
    
    NSValue *pv;
    void *gt;
    
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
@property (nonatomic, retain) CALayer* _targetLayer;
@property (nonatomic, retain) NSValue *pv;
@property void *gt;

- (IBAction)startCalibrationAction:(id)sender;
- (IBAction)closeCalibrationAction:(id)sender;

- (void) closeWindows;
-(void)setupHostView;
-(CALayer*)setupFocusTargetLayer:(CALayer*)parentLayer;
-(void)centerAndShowWindow:(NSWindow*)window;
- (void) setupVideoCapture;
@end
