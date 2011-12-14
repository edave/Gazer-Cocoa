//
//  LCCalibrationFaceTrackingView.h
//  com.labcogs.gazercocoa
//
//  Created by David Pitman on 12/12/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//@class LCCalibrationCameraView;

@interface LCCalibrationFaceTrackingView : NSView{
    float cameraWidth;
    float cameraHeight;
    NSRect _leftEyePoint;
    NSRect _rightEyePoint;
    NSRect _faceRect;
   //LCCalibrationCameraView* _cameraView;
}

@property float cameraWidth;
@property float cameraHeight;
//@property(retain) LCCalibrationCameraView* cameraView;

- (void)faceTrackingNotification:(NSNotification*)note;


@end
