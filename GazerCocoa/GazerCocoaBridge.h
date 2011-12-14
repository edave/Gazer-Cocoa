//
//  GazerCocoaBridge.h
//  com.labcogs.gazercocoa
//
//  Created by Ryan Kabir on 12/1/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#ifndef GazerCocoaBridge_com.labcogs.gazercocoa_h
#define GazerCocoaBridge_com.labcogs.gazercocoa_h

#include <opencv/cv.h>

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

class GazerCocoaBridge {

  public:
        MainGazeTracker* gazeTracker;
        cv::CascadeClassifier face_cascade;
        cv::CascadeClassifier eyes_cascade;


      GazerCocoaBridge(int argc, char **argv, NSView *view);

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
