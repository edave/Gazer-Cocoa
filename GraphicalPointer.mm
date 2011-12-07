#include "GraphicalPointer.h"
#import <Cocoa/Cocoa.h>
#import "LCGazeFoundation.h"

int WindowPointer::windowNumber;

WindowPointer::PointerSpec::PointerSpec(NSView *view, int width, int height, int red, int green, int blue)
: view(view), width(width), height(height), red(red), green(green), blue(blue)
{}

WindowPointer::WindowPointer(const PointerSpec &spec) {
//  printf("this is a window or something");

  // stringstream stream;
  // stream << "Window" << WindowPointer::windowNumber++;
  // name = stream.str();
  // IplImage *image = cvCreateImage(cvSize(spec.width, spec.height), IPL_DEPTH_8U, 3);
  // cvSet(image, cvScalar(0,0,0));
  // cvCircle(image, cvPoint(spec.width/2, spec.height/2), spec.width/2, cvScalar(spec.red, spec.green, spec.blue), CV_FILLED);
  // cvNamedWindow(name.c_str(), CV_WINDOW_AUTOSIZE | CV_GUI_NORMAL);
  // cvShowImage(name.c_str(), image);
}

void WindowPointer::setPosition(int x, int y) {
  // cvMoveWindow(name.c_str(), x, y);
  [[NSNotificationCenter defaultCenter] postNotificationName:@"changeCalibrationTarget"
                                                      object:nil
                                                    userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithPoint:NSMakePoint(x,y)] forKey:@"point"]];
 printf("you wanted me to move it to: %i, %i\n", x, y);
}

// [Dave] Is this the best place to fire off the CalibrationEnded notification? Seems
// brittle, is there a better central place?
void WindowPointer::hide() {
    [[NSDistributedNotificationCenter defaultCenter] 
     postNotificationName:kGrazeTrackerCalibrationEnded
                   object:nil
                 userInfo:nil];
}
