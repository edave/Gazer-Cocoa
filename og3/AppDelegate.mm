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
    [[calibrationWindowController window] makeKeyAndOrderFront:self];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(calibrationStarted:)
                                                 name:kGazeTrackerCalibrationStart
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveCalibrationPoint:)
                                                 name:@"changeCalibrationTarget"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveGazeEstimationTarget:)
                                                 name:kGazePointNotification
                                               object:nil];

     [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(finishedCalibration:)
                                                 name:kGrazeTrackerCalibrationEnded
                                               object:nil];
}

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
    // NSArray *args = [[NSProcessInfo processInfo] arguments];
    //int count = [args count];

    
    OGc* openGazerCocoa = new OGc::OGc(0, NULL, calibrationWindowController.hostView);
    int status = openGazerCocoa->loadClassifiers();
    if (status==0) {
        NSLog(@"\n\n\n\n Loaded classifiers fine");
    }
    else {
        NSLog(@"\n\n\n\n Didn't load the classifiers");
    }

    MainGazeTracker *gazeTracker = openGazerCocoa->gazeTracker;
//    new MainGazeTracker(argc, argv, getStores(win.hostView), win.hostView);

    calibrationWindowController.openGazerCocoaPointer = [NSValue valueWithPointer:openGazerCocoa];

//    cvNamedWindow(MAIN_WINDOW_NAME, CV_GUI_EXPANDED);
//    cvResizeWindow(MAIN_WINDOW_NAME, 640, 480);

    //    createButtons();
//    openGazerCocoa->registerMouseCallbacks();

    gazeTracker->doprocessing();
//    openGazerCocoa->drawFrame();

//    findEyes();

    // to declare an object Object* blah = &gazeTracker


    GlobalManager *gm = [GlobalManager sharedGlobalManager];
    gm.calibrationFlag = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0), ^{ // Run on a background thread - dispatch_get_main_queue()
        while(1){
        gazeTracker->doprocessing();

//        openGazerCocoa->drawFrame();
        if (gm.calibrationFlag) {
            gazeTracker->startCalibration();
            gm.calibrationFlag = NO;
        }
            // [RYAN] I think this line inserts a kind of delay into the loop
            // which in turn makes the calibration dot animate at a more human speed.
            // maybe can replace this with [nano]sleep call or something.
            char c = cvWaitKey(33);
//        switch(c) {
//            case 'c':
//                gazeTracker->startCalibration();
//                break;
//            case 't':
//                gazeTracker->startTesting();
//                break;
//            case 's':
//                gazeTracker->savepoints();
//                break;
//            case 'l':
//                gazeTracker->loadpoints();
//                break;
//            case 'x':
//                gazeTracker->clearpoints();
//                break;
//            case 'r':
//                openGazerCocoa->findEyes();
//                break;
//            default:
//                break;
//        }
//
//        if(c == 27) break;
    }
    });

}

#pragma mark - Notifications

-(void)moveGazeEstimationTarget:(NSNotification*)note{
    //NSLog(@"Receive move gaze tracking Point");
    LCGazePoint* point = (LCGazePoint*)[(NSDictionary*)[note userInfo] objectForKey:kGazePointKey];
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

-(void)finishedCalibration:(NSNotification*)note{
    NSLog(@"\n\n\n\n\n      finishedCalibration");
    [calibrationWindowController finishCalibration:kGazeTrackerCalibrated];
}

@end
