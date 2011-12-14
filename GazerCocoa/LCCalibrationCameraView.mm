//
//  LCCalibrationCameraView.m
//  com.labcogs.gazercocoa
//
//  Created by David Pitman on 12/4/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import "LCCalibrationCameraView.h"

@implementation LCCalibrationCameraView
@synthesize openGazerCocoaPointer, cameraHeight, cameraWidth;

#ifdef CONFIGURATION_Debug_OpenCV
- (void) mouseDown:(NSEvent*) evt
{
//    NSLog(@"In Window: %f %f", [evt locationInWindow].x, [evt locationInWindow].y);
    NSPoint windowPoint = [self convertPoint:[evt locationInWindow] fromView:nil];
    NSRect previewBounds = [self previewBounds];
    NSRect viewBounds = [self bounds];
    NSSize mySize = previewBounds.size;
//    NSLog(@"Points: %f %f", windowPoint.x, windowPoint.y);
    
    // Adjust for the actual bounds of the video frame within this view
    float heightOffset = (viewBounds.size.height  - mySize.height) / 2.0f;
    float widthOffset =  (viewBounds.size.width - mySize.width) / 2.0f;
//    NSLog(@"Offset: %f %f", widthOffset, heightOffset);
    windowPoint.x = windowPoint.x - widthOffset;
    windowPoint.y = windowPoint.y - heightOffset;
//    NSLog(@"Adj Points: %f %f", windowPoint.x, windowPoint.y);
//    NSLog(@"View Bounds: %f %f %f %f", viewBounds.origin.x, viewBounds.origin.y, viewBounds.size.width, viewBounds.size.height);
//    NSLog(@"Preview Bounds: %f %f %f %f", previewBounds.origin.x, previewBounds.origin.y, previewBounds.size.width, previewBounds.size.height);
    if(NSPointInRect(windowPoint, previewBounds)){
//        NSLog(@"--------");
//        NSLog(@"Camera: %f %f", self.cameraWidth, self.cameraHeight);
    float y = ((mySize.height - windowPoint.y)/mySize.height)*self.cameraHeight;
    float x = ((windowPoint.x) / mySize.width)*self.cameraWidth;
        NSLog(@"Final Point: %f %f", x, y);
    OpenGazer::Point point(x, y);
    GazerCocoaBridge* openGazerCocoa = (GazerCocoaBridge*)[openGazerCocoaPointer pointerValue];
    PointTracker &tracker = openGazerCocoa->gazeTracker->tracking->tracker;
    int closest = tracker.getClosestTracker(point);
    int lastPointId;
    
    if(closest >= 0 && point.distance(tracker.currentpoints[closest]) <= 10) lastPointId = closest;
    else
        lastPointId = -1;
    
   if(lastPointId >= 0) tracker.updatetracker(lastPointId, point);
        else {
            tracker.addtracker(point);
    }
    }
//    if(event == CV_EVENT_LBUTTONDBLCLK) {
//        if(lastPointId >= 0) tracker.removetracker(lastPointId);
//    }

}
#endif

@end
