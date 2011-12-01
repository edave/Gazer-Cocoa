//
//  ogc.mm
//  og3
//
//  Created by Ryan Kabir on 12/1/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#import "ogc.h"

using namespace std;
using namespace cv;

static vector<shared_ptr<AbstractStore> > getStores(NSView *theView) {
    vector<shared_ptr<AbstractStore> > stores;

    stores.push_back(shared_ptr<AbstractStore>(new SocketStore()));
    stores.push_back(shared_ptr<AbstractStore>(new StreamStore(cout)));
    //    stores.push_back(shared_ptr<AbstractStore>
    //                     ( new WindowStore( WindowPointer::PointerSpec(theView, 60, 60, 0, 0, 255),
    //                                       WindowPointer::PointerSpec(theView, 60, 60, 250, 0, 250) ) ) );

    return stores;
}

ogc::ogc(int argc, char **argv, NSView *view):
  gazeTracker(new MainGazeTracker(argc, argv, getStores(view), view))
    {
}

int ogc::loadClassifiers() {
    String face_cascade_name = "haarcascade_frontalface_alt.xml";
    String eyes_cascade_name = "haarcascade_eye_tree_eyeglasses.xml";
    string window_name = "Capture - Face detection";

    RNG rng(12345);

    if( !face_cascade.load( face_cascade_name ) ){ printf("\n\n--(!)Error loading face\n"); return -1; };
    if( !eyes_cascade.load( eyes_cascade_name ) ){ printf("\n\n--(!)Error loading eyes\n"); return -1; };

}

// Redundant work to wrap the buttons
// TODO: Abstract this using macros
void ogc::calibrateCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->startCalibration();
    }
}

void ogc::testCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->startTesting();
    }
}

void ogc::savePointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->savepoints();
    }
}

void ogc::loadPointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->loadpoints();
    }
}

void ogc::clearPointsCallbackWrapper(int state, void*) {
    if(state == -1) {       // for push buttons
        gazeTracker->clearpoints();
    }
}

void ogc::drawFrame() {
    cvShowImage(MAIN_WINDOW_NAME, gazeTracker->canvas.get());
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

void ogc::registerMouseCallbacks() {
    cvSetMouseCallback(MAIN_WINDOW_NAME, mouseClick, NULL);
}

string window_name = "Capture - Face detection";

CascadeClassifier face_cascade;
CascadeClassifier eyes_cascade;
RNG rng(12345);

void ogc::findEyes() {

    PointTracker &tracker = gazeTracker->tracking->tracker;
    std::vector<cv::Point> all_eyes;

    int points_added = 0;
    srand(time(NULL));
    while(points_added < 12) {

        gazeTracker->doprocessing();
        drawFrame();

        Mat frame = gazeTracker->videoinput->frame;
        if( !frame.empty() ) {
            std::vector<cv::Rect> faces;
            cv::Mat frame_gray;

            cvtColor(frame, frame_gray, CV_BGR2GRAY);
            equalizeHist( frame_gray, frame_gray );

            face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );

            if(faces.size()==1)
            {
                int i = 0;
                cv::Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
                //ellipse( frame, center, cv::Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );

                cv::Mat faceROI = frame_gray( faces[i] );
                std::vector<cv::Rect> eyes;

                //-- In each face, detect eyes
                eyes_cascade.detectMultiScale( faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(30, 30) );

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

                    printf("\n left eye width: %d", eyes[left].width);
                    printf("\n right eye width: %d", eyes[right].width);

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
                    tracker.addtracker(right_point);
                    points_added = points_added + 2;

                    //                    for( int j = 0; j < eyes.size(); j++ )
                    //                    {
                    //                        tracker.addtracker(addPoint);
                    //                        all_eyes.push_back(center);
                    //                        int radius = cvRound( (eyes[j].width + eyes[i].height)*0.25 );
                    //                        circle( frame, center, radius, Scalar( 255, 0, 0 ), 4, 8, 0 );
                    //                    }
                }

            }
            // just for debug
            //imshow( window_name, frame );

        }
    }
}
//    int eye_one_x = 0;
//    int eye_one_y = 0;
//    int eye_two_x = 0;
//    int eye_two_y = 0;
//
//    int sum_one = 0;
//    int sum_two = 0;
//    int count_one = 0;
//    int count_two = 0;
//
//    cv::Point eyeOne = all_eyes[0];
//    cv::Point eyeTwo = all_eyes[1];
//
//    eye_one_x = eyeOne.x;
//    eye_one_y = eyeOne.y;
//    eye_two_x = eyeTwo.x;
//    eye_two_y = eyeTwo.y;
//    OpenGazer::Point first_point(eyeOne.x-50, eyeOne.y);
//    OpenGazer::Point second_point(eyeTwo.x+50, eyeTwo.y);
//
//    tracker.addtracker(first_point);
//    tracker.addtracker(second_point);
//
//    for(int k=2; k<all_eyes.size() ; k++) {
//        cv::Point anEye = all_eyes[k];
//        int x = anEye.x;
//        int y = anEye.y;
////        OpenGazer::Point a_point(x, y);
////        tracker.addtracker(a_point);
//        if ( (x/eye_one_x < 1.10 || x/eye_one_x > 0.90) && (y/eye_one_y < 1.10 || y/eye_one_y > 0.90)) {
//            eye_one_x = (eye_one_x + x) / 2;
//            eye_one_y = (eye_one_y + y) / 2;
//        }
//        else {
//            eye_two_x = (eye_two_x + x) / 2;
//            eye_two_y = (eye_two_y + y) / 2;
//        }
//    }
//
//
//    OpenGazer::Point point_a(eye_one_x+50, eye_one_y);
//    tracker.addtracker(point_a);
//    OpenGazer::Point point_b(eye_one_x-50, eye_one_y);
//    tracker.addtracker(point_b);
////    OpenGazer::Point point2(eye_two_x, eye_two_y);
////    tracker.addtracker(point2);
