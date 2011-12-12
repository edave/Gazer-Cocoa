//
//  OGc.mm
//  og3
//
//  Created by Ryan Kabir on 12/1/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import "OGc.h"
#import <Cocoa/Cocoa.h>

using namespace std;
using namespace cv;

static vector<shared_ptr<AbstractStore> > getStores(NSView *theView) {
    vector<shared_ptr<AbstractStore> > stores;

    stores.push_back(shared_ptr<AbstractStore>(new SocketStore()));
    stores.push_back(shared_ptr<AbstractStore>(new StreamStore(cout)));
    return stores;
}
OGc *g;
OGc::OGc(int argc, char **argv, NSView *view):
  gazeTracker(new MainGazeTracker(argc, argv, getStores(view), view))
    {
}

int OGc::loadClassifiers() {
    String face_cascade_name = "haarcascade_frontalface_alt.xml";
    String eyes_cascade_name = "haarcascade_eye_tree_eyeglasses.xml";
    string window_name = "Capture - Face detection";

    RNG rng(12345);

    if( !face_cascade.load( face_cascade_name ) ){ printf("\n\n--(!)Error loading face\n"); return -1; };
    if( !eyes_cascade.load( eyes_cascade_name ) ){ printf("\n\n--(!)Error loading eyes\n"); return -1; };
    return 0;
}

void OGc::startCalibration() {
    gazeTracker->startCalibration();
}

// Redundant work to wrap the buttons
// TODO: Abstract this using macros
void OGc::calibrateCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->startCalibration();
    }
}

void OGc::testCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->startTesting();
    }
}

void OGc::savePointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->savepoints();
    }
}

void OGc::loadPointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->loadpoints();
    }
}

void OGc::clearPointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->clearpoints();
    }
}

void OGc::drawFrame() {
    cvShowImage(MAIN_WINDOW_NAME, gazeTracker->canvas.get());
}

string window_name = "Capture - Face detection";

CascadeClassifier face_cascade;
CascadeClassifier eyes_cascade;
RNG rng(12345);

NSNotificationQueue* queue = [NSNotificationQueue defaultQueue];

void OGc::findEyes() {
    PointTracker &tracker = gazeTracker->tracking->tracker;
    std::vector<cv::Point> all_eyes;

    int points_added = 0;
    srand(time(NULL));
    while(points_added < 12) {

        gazeTracker->doprocessing();
        //drawFrame();
        NSMutableDictionary* faceNoteInfo = [NSMutableDictionary dictionary];
        NSRect faceRect = NSZeroRect;
        NSRect eyeLeft = NSZeroRect;
        NSRect eyeRight = NSZeroRect;
        Mat frame = gazeTracker->videoinput->frame;
        if( !frame.empty() ) {
            std::vector<cv::Rect> faces;
            cv::Mat frame_gray;
            cvtColor(frame, frame_gray, CV_BGR2GRAY);
            equalizeHist( frame_gray, frame_gray );

            face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );

            
            if(faces.size()>=1) {
                int i = 0;
                cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
                //ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
                
                
                cv::Mat faceROI = frame_gray( faces[i] );
                std::vector<cv::Rect> eyes;

                //-- In each face, detect eyes
                eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );
                faceRect = NSMakeRect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
                
                if(eyes.size()==2) {
                    int left, right;
                    //printf("\n two eyes \n");
                    if (eyes[0].x < eyes[1].x) {
                        left = 0;
                        right = 1;
                    }
                    else {
                        left = 1;
                        right = 0;
                    }

                    cv::Point left_eye( faces[i].x + eyes[left].x + eyes[left].width*0.5, faces[i].y + eyes[left].y + eyes[left].height*0.5 );
                    cv::Point right_eye( faces[i].x + eyes[right].x + eyes[right].width*0.5, faces[i].y + eyes[right].y + eyes[right].height*0.5 );
                    
                    eyeLeft = NSMakeRect(faces[i].x + eyes[left].x, faces[i].y + eyes[left].y, eyes[left].width, eyes[left].height);
                    eyeRight = NSMakeRect(faces[i].x + eyes[right].x, faces[i].y + eyes[right].y, eyes[right].width, eyes[right].height);

                    // printf("\n left eye width: %d", eyes[left].width);
                    // printf("\n right eye width: %d", eyes[right].width);

                    int xoffset = 0;
                    int yoffset = 0;
                    if (points_added == 0) {
                        xoffset = 25;
                    }
                    else if (points_added == 2) {
                        xoffset = -25;
                    }
                    else if (points_added == 4) {
                        yoffset = 25;
                    }
                    else if (points_added == 6) {
                        yoffset = -25;
                    }
                    else if (points_added == 8) {
                        xoffset = 40;
                        yoffset = 40;
                    }
                    else if (points_added == 10) {
                        xoffset = -40;
                        yoffset = -40;
                    }
                    else {
                        int sign = rand() % 2;
                        if(sign==0) {
                            sign = -1;
                        }
                        int rand_num1 = rand() % 50 + 1;
                        int rand_num2 = rand() % 50 + 1;
                        xoffset = rand_num1 * sign;
                        yoffset = rand_num2 * sign;
                    }

                    OpenGazer::Point left_point(left_eye.x-xoffset, left_eye.y+yoffset);
                    OpenGazer::Point right_point(right_eye.x+xoffset, left_eye.y+yoffset);
                    tracker.addtracker(left_point);
                    gazeTracker->doprocessing();
                    tracker.addtracker(right_point);
                    points_added = points_added + 2;
                }
                else {
                #ifdef CONFIGURATION_Debug_GUI
                  NSLog(@"didn't find 2 eyes");
                #endif
                }
            }
            else {
            #ifdef CONFIGURATION_Debug_GUI
              NSLog(@"didn't find 1 face");
            #endif
            }
//            [faceNoteInfo setObject:[NSValue valueWithRect:faceRect] forKey:@"kFaceRect"];
//            [faceNoteInfo setObject:[NSValue valueWithRect:eyeLeft] forKey:@"kEyeLeft"];
//            [faceNoteInfo setObject:[NSValue valueWithRect:eyeRight] forKey:@"kEyeRight"];
            
            NSNotification* faceNotification = [NSNotification notificationWithName:@"faceTrackingNotification"
                                                                             object:nil 
                                                                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRect:faceRect], @"kFaceRect",
                                                                                     [NSValue valueWithRect:eyeLeft],@"kEyeLeft",
                                                [NSValue valueWithRect:eyeRight], @"kEyeRight", nil]];
            [queue enqueueNotification:faceNotification postingStyle: NSPostNow];
            //[[NSNotificationCenter defaultCenter] postNotification:faceNotification];
            // just for debug
            //imshow( window_name, frame );
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.labcogs.ogc.enableCalibration"
                                                        object:nil
                                                      userInfo:nil];
    //NSLog(@"All points collected");
}
