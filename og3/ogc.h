//
//  OGc.h
//  og3
//
//  Created by Ryan Kabir on 12/1/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#ifndef og3_OGc_h
#define og3_OGc_h

#include <opencv/highgui.h>
#include "utils.h"
#include "OutputMethods.h"
#include "MainGazeTracker.h"
#include "WindowStore.h"

#include "opencv2/objdetect/objdetect.hpp"
#include "opencv2/imgproc/imgproc.hpp"

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#import <Cocoa/Cocoa.h>
#import "CoreFoundation/CoreFoundation.h"
#import "LCCalibrationWindowController.h"

#define MAIN_WINDOW_NAME "OpenGazer"

void mouseClick(int event, int x, int y, int flags, void* param);

class OGc {

  public:
        MainGazeTracker* gazeTracker;
        cv::CascadeClassifier face_cascade;
        cv::CascadeClassifier eyes_cascade;


      OGc(int argc, char **argv, NSView *view);

      int loadClassifiers();
      void startCalibration();
      void calibrateCallbackWrapper(int state, void*);
      void testCallbackWrapper(int state, void*);
      void savePointsCallbackWrapper(int state, void*);
      void loadPointsCallbackWrapper(int state, void*);
      void clearPointsCallbackWrapper(int state, void*);


      void drawFrame();

      void registerMouseCallbacks();

      void findEyes();

    };


#endif
