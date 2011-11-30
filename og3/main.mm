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

static vector<shared_ptr<AbstractStore> > getStores() {
    vector<shared_ptr<AbstractStore> > stores;

    stores.push_back(shared_ptr<AbstractStore>(new SocketStore()));
    stores.push_back(shared_ptr<AbstractStore>(new StreamStore(cout)));
    stores.push_back(shared_ptr<AbstractStore>
                     ( new WindowStore( WindowPointer::PointerSpec(60, 60, 0, 0, 255),
                                       WindowPointer::PointerSpec(60, 60, 250, 0, 250) ) ) );

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
    Mat frame = gazeTracker->videoinput->frame;
    if( !frame.empty() ) {
        std::vector<cv::Rect> faces;
        cv::Mat frame_gray;
        
        cvtColor(frame, frame_gray, CV_BGR2GRAY);
        equalizeHist( frame_gray, frame_gray );

        face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
        
        for( int i = 0; i < faces.size(); i++ )
        {
            cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
            //ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
            
            cv::Mat faceROI = frame_gray( faces[i] );
            std::vector<cv::Rect> eyes;
            
            //-- In each face, detect eyes
            eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
            
            for( int j = 0; j < eyes.size(); j++ )
            {
                cv::Point center( faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5 );
                int radius = cvRound( (eyes[j].width + eyes[i].height)*0.25 );
                PointTracker &tracker = gazeTracker->tracking->tracker;
                OpenGazer::Point point(center.x, center.y);
                tracker.addtracker(point);
                
                //circle( frame, center, radius, Scalar( 255, 0, 0 ), 4, 8, 0 );
                
            }
        }
        // just for debug
        //imshow( window_name, frame );
        
    }
}

int main(int argc, char **argv) {
    // set the right path so the classifiers can find their data

//    LCCalibrationWindowController *win = [[LCCalibrationWindowController alloc] initWithWindowNibName:@"CalibrationWindow"];
//    [win awakeFromNib];
    
        
    CFBundleRef mainBundle = CFBundleGetMainBundle();
    CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
    char path[PATH_MAX];
    if (!CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8 *)path, PATH_MAX))
    {
        // error!
    }
    CFRelease(resourcesURL);    
    chdir(path);

    gazeTracker = new MainGazeTracker(argc, argv, getStores());

    cvNamedWindow(MAIN_WINDOW_NAME, CV_GUI_EXPANDED);
    cvResizeWindow(MAIN_WINDOW_NAME, 640, 480);

    system("pwd");
    if( !face_cascade.load( face_cascade_name ) ){ printf("\n\n--(!)Error loading face\n"); return -1; };
    if( !eyes_cascade.load( eyes_cascade_name ) ){ printf("\n\n--(!)Error loading eyes\n"); return -1; };
    
//    createButtons();
    registerMouseCallbacks();

    while(1) {
        gazeTracker->doprocessing();

        drawFrame();

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

    cvDestroyWindow(MAIN_WINDOW_NAME);
    delete gazeTracker;
    return 0;
}
