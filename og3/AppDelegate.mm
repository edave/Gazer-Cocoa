//
//  AppDelegate.m
//  og3
//
//  Created by Ryan Kabir on 11/22/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#import "AppDelegate.h"

#import "CoreFoundation/CoreFoundation.h"
#import "LCCalibrationPoint.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize gazeTrackingRunning;
@synthesize runHeadless = _runHeadless;
@synthesize gazeTrackerStatus = _gazeTrackerStatus;

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification{
    self.gazeTrackingRunning = NO; // Gaze tracking is not active
    self.gazeTrackerStatus = kGazeTrackerUncalibrated;
    // Whether we should launch the GUI on start
    self.runHeadless = YES; // No, run in background
    #ifdef CONFIGURATION_Debug_GUI
    NSLog(@"Launching with GUI");
        self.runHeadless = NO; // Launch the GUI on start
    #endif

    [[NSApplication sharedApplication] disableRelaunchOnLogin];


    gazeWindowController = [[LCGazeTrackerWindowController alloc] initWithScreen:[NSScreen mainScreen]];
     calibrationWindowController = [[LCCalibrationWindowController alloc] initWithWindowNibName:@"CalibrationWindow"];

    // Local Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveCalibrationPoint:)
                                                 name:@"changeCalibrationTarget"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calibrationClosed:)
                                                 name:kLCGazeCalibrationUIClosed
                                               object:nil];

    // Inter process notifications (Distributed)
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calibrationStarted:)
                                                 name:kGazeTrackerCalibrationStarted
                                               object:kGazeSenderID];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveGazeEstimationTarget:)
                                                 name:kGazePointNotification
                                               object:kGazeSenderID];

     [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedCalibration:)
                                                 name:kGrazeTrackerCalibrationEnded
                                               object:kGazeSenderID];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(terminationRequested:)
                                                            name:kGazeTrackerTerminateRequest
                                                          object:kGazeSenderID];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(calibrationStartRequested:)
                                                            name:kGazeTrackerCalibrationRequestStart
                                                          object:kGazeSenderID];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{  // set the right path so the classifiers can find their data

    // Broadcast to other apps that we're up and running
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGazeTrackerReady
                                                                   object:kGazeSenderID
                                                                 userInfo:[NSDictionary dictionaryWithObject:kGazeTrackerUncalibrated forKey:kGazeTrackerStatusKey]
                                                        deliverImmediately: YES];
    if(!self.runHeadless){
        [self launchCalibrationGUI];
    }
    NSLog(@"OGC finished launching");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification{
    NSLog(@"OGC will terminate");
    // Delist ourself from receiving distributed notifications
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

    // Tell other apps we're shutting down
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGazeTrackerTerminating
                                                                   object:kGazeSenderID
                                                                 userInfo:nil
                                                       deliverImmediately:YES];
}


#pragma mark - OpenCV

#ifdef CONFIGURATION_Debug_OpenCV
    MainGazeTracker *gazeTracker;
// this is only used for debugging
void mouseClick(int event, int x, int y, int flags, void* param) {
    if(event == CV_EVENT_LBUTTONDOWN || event == CV_EVENT_LBUTTONDBLCLK) {
        OpenGazer::Point point(x, y);
        PointTracker &tracker = gazeTracker->tracking->tracker;
        int closest = tracker.getClosestTracker(point);
        int lastPointId;

        if(closest >= 0 && point.distance(tracker.currentpoints[closest]) <= 10) lastPointId = closest;
        else
            lastPointId = -1;

        if(event == CV_EVENT_LBUTTONDOWN) {
            if(lastPointId >= 0) tracker.updatetracker(lastPointId, point);
            else {
                tracker.addtracker(point);
            }
        }
        if(event == CV_EVENT_LBUTTONDBLCLK) {
            if(lastPointId >= 0) tracker.removetracker(lastPointId);
        }
    }
}

#endif

-(void)launchGazeTracking{
    if(!self.gazeTrackingRunning);

    self.gazeTrackingRunning = YES;
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
        char path[PATH_MAX];
        if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
        {
            // error!
        }
        CFRelease(resourcesURL);
        chdir(path);
        // end path settings

        openGazerCocoa = new OGc::OGc(0, NULL, calibrationWindowController.hostView);
        int status = openGazerCocoa->loadClassifiers();

        gazeTracker = openGazerCocoa->gazeTracker;
        calibrationWindowController.openGazerCocoaPointer = [NSValue valueWithPointer:openGazerCocoa];




#ifdef CONFIGURATION_Debug_OpenCV
        NSLog(@"\n\n  FYI - OpenCV debug is enabled\n\n");
        cvNamedWindow(MAIN_WINDOW_NAME, CV_GUI_EXPANDED);
        cvResizeWindow(MAIN_WINDOW_NAME, 640, 480);
        //    createButtons();
        cvSetMouseCallback(MAIN_WINDOW_NAME, mouseClick, NULL);
#endif

    gazeTracker->doprocessing();

#ifdef CONFIGURATION_Debug_OpenCV
        openGazerCocoa->drawFrame();
#endif

    // to declare an object Object* blah = &gazeTracker

    GlobalManager *gm = [GlobalManager sharedGlobalManager];
    gm.calibrationFlag = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{ // Run on a background thread - dispatch_get_main_queue()
        int count = 0;
        while(1) {
            gazeTracker->doprocessing();

            #ifdef CONFIGURATION_Debug_OpenCV
                openGazerCocoa->drawFrame();
            #endif

            if (gm.calibrationFlag) {
                gazeTracker->startCalibration();
                gm.calibrationFlag = NO;
            }
            // [RYAN] I think this line inserts a kind of delay into the loop
            // which in turn makes the calibration dot animate at a more human speed.
            // maybe can replace this with [nano]sleep call or something.
            char c = cvWaitKey(33);
            if (count==100) {
                NSLog(@"finding Eyes");
                openGazerCocoa->findEyes();
            }
            count = count + 1;
        }
        self.gazeTrackingRunning = NO;
    });
}

#pragma mark - Calibration

-(void)launchCalibrationGUI{
    NSLog(@"Launch the GUI");
    [self showCalibration];
    [self launchGazeTracking];
}

// [DAVE] This is a hack, doesn't support multiple re-calibration attempts
-(void)showCalibration{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[calibrationWindowController window] makeKeyAndOrderFront:self];
}

#pragma mark - Notifications

-(void)moveGazeEstimationTarget:(NSNotification*)note{
    //NSLog(@"Receive move gaze tracking Point");
    LCGazePoint* point = [[LCGazePoint alloc] init];
    NSDictionary* dict = (NSDictionary*)[note userInfo];
    point.x = [(NSNumber*)[dict objectForKey:kGazePointXKey] floatValue];
    point.y = [(NSNumber*)[dict objectForKey:kGazePointYKey] floatValue];
    [gazeWindowController moveGazeTarget:point];
}

-(void)moveCalibrationPoint:(NSNotification*)note{
    //NSLog(@"Receive move calibration Point");
    NSPoint point = [(NSValue*)[(NSDictionary*)[note userInfo] objectForKey:@"point"] pointValue];
    LCCalibrationPoint* calibrationPoint = [[LCCalibrationPoint alloc] init];
    //NSLog(@"Points: %f %f", point.x, point.y);
    calibrationPoint.x = point.x;
    calibrationPoint.y = point.y;
    [calibrationWindowController moveToNextPoint:calibrationPoint];
}

// The calibration process has started
-(void)calibrationStarted:(NSNotification*)note{
    NSLog(@"Notification :: Calibration Started");
    [gazeWindowController window];
}

// There was a request to show the calibration GUI and such
-(void)calibrationStartRequested:(NSNotification*)note{
    NSLog(@"Notification :: Calibration Requested");
    [self launchCalibrationGUI];
}

// The calibration process ended, wbut we'll still show a GUI with the results
-(void)finishedCalibration:(NSNotification*)note{
    NSLog(@"Notification :: Calibration Finished");
    self.gazeTrackerStatus = kGazeTrackerCalibrated;
    [calibrationWindowController finishCalibration:self.gazeTrackerStatus];
}

// Called when the user closes the calibration interface
-(void) calibrationClosed:(NSNotification*)note{
    NSLog(@"Notification :: Calibration UI Closed");

    // Close the Gaze Target window
    [[gazeWindowController window] close];

    // Resign focus
    //[[NSApplication sharedApplication] hide:self];

    // Send out a note that we've finished calibrating with the current status of the gaze tracker
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGrazeTrackerCalibrationEnded
                                                                   object:kGazeSenderID
                                                                 userInfo:[NSDictionary dictionaryWithObject:self.gazeTrackerStatus forKey:kGazeTrackerStatusKey]
                                                       deliverImmediately:YES];
}

-(void)terminationRequested:(NSNotification*)note{
    NSLog(@"Notification :: Termination requested");
    [[NSApplication sharedApplication] terminate:self];
}

@end
