#include "GraphicalPointer.h"

int WindowPointer::windowNumber;

WindowPointer::PointerSpec::PointerSpec(NSView *view, int width, int height, int red, int green, int blue)
: view(view), width(width), height(height), red(red), green(green), blue(blue)
{}

WindowPointer::WindowPointer(const PointerSpec &spec) {
  printf("this is a window or something");
  NSScreen *_screen = [NSScreen mainScreen];
  layer = [CALayer layer];
  NSImage* targetImage = [NSImage imageNamed:@"calibrationTarget"];
  layer.contents = targetImage;
  layer.frame = CGRectMake(128,128, targetImage.size.width, targetImage.size.height);
  // layer.hidden = YES;
  layer.position = CGPointMake(_screen.frame.size.width/4.0, _screen.frame.size.height/4.0);
  [spec.view.layer addSublayer:layer];
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
  layer.position = CGPointMake(x, y);

  printf("you wanted me to move it to: %i, %i\n", x, y);
}

void WindowPointer::hide() {
  layer.hidden = YES;
}
