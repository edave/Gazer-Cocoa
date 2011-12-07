//
//  LCCalibrationWindowController.m
//  blinders
//
//  Created by David Pitman on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LCCalibrationWindowController.h"
#import "LCGazeTracker.h"
#import "LCDummyGazeTracker.h"
#import "LCCalibrationCameraView.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalManager.h"

@implementation LCCalibrationWindowController

@synthesize hostView;
@synthesize _targetLayer;
@synthesize openGazerCocoaPointer;
@synthesize gazeTrackerPointer;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    self = [super initWithWindowNibName:windowNibName];
    if (self) {
        //NSLog(@"Initializing Calibration Window Controller");
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _screen = [NSScreen mainScreen];

    [self setupHostView];
    //NSLog(@"Calibration Window Controller :: awakeFromNib");
    NSPanel *panel = (id)[self window];
    [panel setAcceptsMouseMovedEvents:NO];
    [panel setStyleMask:[panel styleMask] ^ NSBorderlessWindowMask];
    //[panel setLevel:NSPopUpMenuWindowLevel];
    [panel setOpaque:NO];
    [panel setMovable:NO];
    [panel setBackgroundColor:[NSColor colorWithCalibratedHue:0.0
                                                   saturation:0.0
                                                   brightness:0.0
                                                        alpha:0.3]];

    // Resize panel
    NSRect screenFrame = [_screen frame];
    [panel setFrame:screenFrame display:NO];
    [panel setMinSize:screenFrame.size];
    [panel setMaxSize:screenFrame.size];
    [panel orderFront:self];

    // Setup calibration target focus layer
    _targetLayer = [self setupFocusTargetLayer:hostView.layer];
   // _gazeTargetLayer = [self setupGazeTargetLayer:hostView.layer];
    
    [self setupVideoCapture];

    [self centerAndShowWindow:introWindow];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(applicationWillResignActive:)
                                                 name: NSApplicationWillResignActiveNotification
                                               object:nil];

}

-(void) setOpenGazerCocoaPointer:(NSValue*)pointerValue{
    [openGazerCocoaPointer release];
    openGazerCocoaPointer = pointerValue;
    [openGazerCocoaPointer retain];
    if(mCaptureView != nil){
        mCaptureView.openGazerCocoaPointer = openGazerCocoaPointer;
    }
}

- (void) setupVideoCapture{
    // Create the capture session
	mCaptureSession = [[QTCaptureSession alloc] init];

    // Connect inputs and outputs to the session
	BOOL success = NO;
	NSError *error;

    // Find a video device
    QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    success = [videoDevice open:&error];


    // If a video input device can't be found or opened, try to find and open a muxed input device
	if (!success) {
		videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
		success = [videoDevice open:&error];

    }

    if (!success) {
        videoDevice = nil;
        // Handle error

    }

    if (videoDevice) {
        //Add the video device to the session as a device input
		mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
		success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
		if (!success) {
			// Handle error
		}

        // Associate the capture view in the UI with the session
        [mCaptureView setCaptureSession:mCaptureSession];
        mCaptureView.cameraHeight = 480.0f;
        mCaptureView.cameraWidth = 640.0f;
        [mCaptureSession startRunning];
	}
}



- (void) closeWindows{
    [introWindow close];
    [successWindow close];
    [failureWindow close];
    [self close];
}

- (void) windowWillClose:(NSNotification*)notification{
    if([notification object] == introWindow){
        [mCaptureSession stopRunning];

        if ([[mCaptureVideoDeviceInput device] isOpen])
            [[mCaptureVideoDeviceInput device] close];
    }
}

- (void)applicationWillResignActive:(NSNotification *)aNotification{
    [self closeWindows];
}


- (IBAction)startCalibrationAction:(id)sender{
    NSLog(@"Start Calibration Action");
    
    _targetLayer.position = CGPointMake(_screen.frame.size.width/2.0, _screen.frame.size.height/2.0);
    [introWindow close];
    [failureWindow close];
//    gt = [pv pointerValue];
//    ogc *t = (ogc *)gt;
//    t->startCalibration();

//    NSApplication *app = [NSApplication sharedApplication];
//    app.delegate.calibrationFlag = YES;
    GlobalManager *gm = [GlobalManager sharedGlobalManager];
    gm.calibrationFlag = YES;
    [self beginCalibration:0];
}

- (IBAction)closeCalibrationAction:(id)sender{
    [self closeWindows];
}

#pragma mark - View


-(void)setupHostView {
    CALayer *layer = [CALayer layer];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat components[4] = {0.0f, 0.0f, 0.0f, 0.4f};
    CGColorRef blackColor = CGColorCreate(colorSpace, components);
    layer.backgroundColor = blackColor;
    [hostView setLayer:layer];
    [hostView setWantsLayer:YES];
    CGColorRelease(blackColor);
    CGColorSpaceRelease(colorSpace);
}

-(CALayer*)setupFocusTargetLayer:(CALayer*)parentLayer{
    CALayer *layer = [CALayer layer];
    NSImage* targetImage = [NSImage imageNamed:@"calibrationTarget"];
    layer.contents = targetImage;
    layer.frame = CGRectMake(0,0, targetImage.size.width, targetImage.size.height);
    layer.hidden = YES;
    layer.position = CGPointMake(_screen.frame.size.width/2.0, _screen.frame.size.height/2.0);
    [parentLayer addSublayer:layer];
    return layer;
}

-(void)centerAndShowWindow:(NSWindow*)window{
    NSRect screenFrame = [_screen frame];
    NSRect windowFrame = [window frame];
    NSPoint location = NSMakePoint((screenFrame.size.width / 2.0) - (windowFrame.size.width / 2.0),
                                   (screenFrame.size.height / 2.0) - (windowFrame.size.height / 2.0));
    [window setFrameOrigin: location];
    [window makeKeyAndOrderFront:self];
}

#pragma mark - GazeCalibratorInterface

@synthesize trackerDelegate = _trackerDelegate;

// Start the calibration process using the given display
-(void) beginCalibration:(CGDirectDisplayID)displayID{
    NSLog(@"Begin Calibration");
    currentDisplayID = displayID;
    _trackerDelegate = [[LCDummyGazeTracker alloc] init];
    if(_targetLayer.hidden){
        _targetLayer.hidden = NO;
    }
    [[NSDistributedNotificationCenter defaultCenter] 
     postNotificationName:kGazeTrackerCalibrationStart 
                   object:kGazeSenderID
                 userInfo:nil];
    
   // [NSThread detachNewThreadSelector:@selector(readyToCalibrate) toTarget:_trackerDelegate withObject:nil];

}

// Finish the calibration process
-(void) finishCalibration:(NSString*)status{
 NSLog(@"\n\n\n\nfinishCalibration called");
//[_targetLayer removeFromSuperlayer];
 if ([status isEqualToString: kGazeTrackerCalibrated]) {
     [self centerAndShowWindow:successWindow];
 
 }else if ([status isEqualToString:  kGazeTrackerNeedsRecalibration]){
     [self centerAndShowWindow:failureWindow];
 
 }
//NSLog(@"Calibration Finished ------------------");
}

// Go to the next calibration point
-(void) moveToNextPoint:(LCCalibrationPoint*) point{
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.5f] forKey:kCATransactionAnimationDuration];
    _targetLayer.position = CGPointMake(point.x, point.y);
    [CATransaction commit];
    //NSLog(@"Calibration Point: %@ -> %f, %f", point,  _targetLayer.position.x,  _targetLayer.position.y);
}

// Calibration display size
-(float) displaySize{
    return 0.0;
}

@end
