//
//  main.m
//  og3
//
//  Created by Ryan Kabir on 11/22/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#include <opencv/highgui.h>
#include "utils.h"
#include "OutputMethods.h"
#include "MainGazeTracker.h"
#include "WindowStore.h"

#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include <iostream>
#include <stdio.h>

#import <Cocoa/Cocoa.h>
#include "CoreFoundation/CoreFoundation.h"

#include "LCCalibrationWindowController.h"

//int main(int argc, char *argv[])
//{
//    return NSApplicationMain(argc, (const char **)argv);
//}

#define MAIN_WINDOW_NAME "OpenGazer"

using namespace std;
using namespace cv;

MainGazeTracker* gazeTracker;

static vector<shared_ptr<AbstractStore> > getStores(NSView *theView) {
    vector<shared_ptr<AbstractStore> > stores;

    stores.push_back(shared_ptr<AbstractStore>(new SocketStore()));
    stores.push_back(shared_ptr<AbstractStore>(new StreamStore(cout)));
    stores.push_back(shared_ptr<AbstractStore>
                     ( new WindowStore( WindowPointer::PointerSpec(theView, 60, 60, 0, 0, 255),
                                       WindowPointer::PointerSpec(theView, 60, 60, 250, 0, 250) ) ) );

    return stores;
}

// Redundant work to wrap the buttons
// TODO: Abstract this using macros
void calibrateCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->startCalibration();
    }
}

void testCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->startTesting();
    }
}

void savePointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->savepoints();
    }
}

void loadPointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->loadpoints();
    }
}

void clearPointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->clearpoints();
    }
}

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

//void createButtons() {
//    //Create the buttons
//    //These don't work - they fail to connect the signal
//    //See https://code.ros.org/trac/opencv/ticket/786
//    cvCreateButton("Calibrate", calibrateCallbackWrapper);
//    cvCreateButton("Test", testCallbackWrapper);
//    cvCreateButton("Save Points", savePointsCallbackWrapper);
//    cvCreateButton("Load Points", loadPointsCallbackWrapper);
//    cvCreateButton("Clear Points", clearPointsCallbackWrapper);
//}

void registerMouseCallbacks() {
    cvSetMouseCallback(MAIN_WINDOW_NAME, mouseClick, NULL);
}

String face_cascade_name = "haarcascade_frontalface_alt.xml";
String eyes_cascade_name = "haarcascade_eye_tree_eyeglasses.xml";
string window_name = "Capture - Face detection";

CascadeClassifier face_cascade;
CascadeClassifier eyes_cascade;
RNG rng(12345);


void drawFrame() {
    cvShowImage(MAIN_WINDOW_NAME, gazeTracker->canvas.get());
}

int main(int argc, char **argv) {
    // set the right path so the classifiers can find their data
    [NSApplication sharedApplication];
    LCCalibrationWindowController *win = [[LCCalibrationWindowController alloc] initWithWindowNibName:@"CalibrationWindow"];
    [win awakeFromNib];

    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
    {
        // error!
    }
    CFRelease(resourcesURL);
    chdir(path);

    gazeTracker = new MainGazeTracker(argc, argv, getStores(win.hostView), win.hostView);

//    cvNamedWindow(MAIN_WINDOW_NAME, CV_GUI_EXPANDED);
//    cvResizeWindow(MAIN_WINDOW_NAME, 640, 480);

    if( !face_cascade.load( face_cascade_name ) ){ printf("\n\n--(!)Error loading face\n"); return -1; };
    if( !eyes_cascade.load( eyes_cascade_name ) ){ printf("\n\n--(!)Error loading eyes\n"); return -1; };

//    createButtons();
    registerMouseCallbacks();

    while(1) {
        gazeTracker->doprocessing();

//        drawFrame();

        char c = cvWaitKey(33);
        switch(c) {
            case 'c':
                gazeTracker->startCalibration();
                break;
            case 't':
                gazeTracker->startTesting();
                break;
            case 's':
                gazeTracker->savepoints();
                break;
            case 'l':
                gazeTracker->loadpoints();
                break;
            case 'x':
                gazeTracker->clearpoints();
                break;
            default:
                break;
        }

        if(c == 27) break;
    }

//    cvDestroyWindow(MAIN_WINDOW_NAME);
    delete gazeTracker;
    return 0;
}
