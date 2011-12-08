//
//  AppDelegate.m
//  og3
//
//  Created by Ryan Kabir on 11/22/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#import "AppDelegate.hpp"

#import "CoreFoundation/CoreFoundation.h"
#import "LCCalibrationPoint.h"

@implementation AppDelegate

@synthesize window = _window;

-(void)applicationWillFinishLaunching:(NSNotification*)aNotification{
    [[NSApplication sharedApplication] disableRelaunchOnLogin];
    gazeWindowController = [[LCGazeTrackerWindowController alloc] initWithScreen:[NSScreen mainScreen]];
     calibrationWindowController = [[LCCalibrationWindowController alloc] initWithWindowNibName:@"CalibrationWindow"];
    [self showCalibration];

    // Local Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveCalibrationPoint:)
                                                 name:@"changeCalibrationTarget"
                                               object:nil];

    // Inter process notifications (Distributed)
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calibrationStarted:)
                                                 name:kGazeTrackerCalibrationStart
                                               object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveGazeEstimationTarget:)
                                                 name:kGazePointNotification
                                               object:nil];

     [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedCalibration:)
                                                 name:kGrazeTrackerCalibrationEnded
                                               object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(terminationRequested:)
                                                            name:kGazeTrackerTerminateRequest
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                        selector:@selector(calibrationStartRequested:)
                                                            name:kGazeTrackerCalibrationStart
                                                          object:nil];
}


// this is out here, so that for debugging, mouseClick will work (click handler
// for the cvwin)
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


// set this to true for debugging with a cvwin
bool debug = FALSE;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{  // set the right path so the classifiers can find their data
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

    OGc* openGazerCocoa = new OGc::OGc(0, NULL, calibrationWindowController.hostView);
    int status = openGazerCocoa->loadClassifiers();

    gazeTracker = openGazerCocoa->gazeTracker;
    calibrationWindowController.openGazerCocoaPointer = [NSValue valueWithPointer:openGazerCocoa];

    if(debug) {
        NSLog(@"\n\n\n\n   FYI - debug is enabled\n\n");
      cvNamedWindow(MAIN_WINDOW_NAME, CV_GUI_EXPANDED);
      cvResizeWindow(MAIN_WINDOW_NAME, 640, 480);
      //    createButtons();
      cvSetMouseCallback(MAIN_WINDOW_NAME, mouseClick, NULL);
    }

    gazeTracker->doprocessing();

    if(debug) {
      openGazerCocoa->drawFrame();
    }

    // to declare an object Object* blah = &gazeTracker

    GlobalManager *gm = [GlobalManager sharedGlobalManager];
    gm.calibrationFlag = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{ // Run on a background thread - dispatch_get_main_queue()
        int count = 0;
        while(1) {
          gazeTracker->doprocessing();
          if(debug) {
            openGazerCocoa->drawFrame();
          }

          if (gm.calibrationFlag) {
              gazeTracker->startCalibration();
              gm.calibrationFlag = NO;
          }
          // [RYAN] I think this line inserts a kind of delay into the loop
          // which in turn makes the calibration dot animate at a more human speed.
          // maybe can replace this with [nano]sleep call or something.
          char c = cvWaitKey(33);
          if (count==100) {
              openGazerCocoa->findEyes();
          }
          count = count + 1;
    }
    });

    // Broadcast to other apps that we're up and running
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGazeTrackerReady
                                                                   object:kGazeSenderID
                                                                 userInfo:[NSDictionary dictionaryWithObject:kGazeTrackerUncalibrated forKey:kGazeTrackerStatusKey]
                                                        deliverImmediately: YES];
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

#pragma mark - Calibration
// [DAVE] This is a hack, doesn't support multiple re-calibration attempts
-(void)showCalibration{
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

-(void)calibrationStarted:(NSNotification*)note{
    //NSLog(@"Calibration Started");
    [gazeWindowController window];
}

-(void)calibrationStartRequested:(NSNotification*)note{
    [self showCalibration];
}

-(void)finishedCalibration:(NSNotification*)note{
    NSLog(@"\n\n\n\n\n      finishedCalibration");
    [calibrationWindowController finishCalibration:kGazeTrackerCalibrated];
}

-(void)terminationRequested:(NSNotification*)note{
    [self terminate];
}

@end
