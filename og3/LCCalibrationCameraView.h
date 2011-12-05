//
//  LCCalibrationCameraView.h
//  og3
//
//  Created by David Pitman on 12/4/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import "ogc.h"
#import <Cocoa/Cocoa.h>

@interface LCCalibrationCameraView : QTCaptureView{
    NSValue *openGazerCocoaPointer;
    float cameraWidth;
    float cameraHeight;
}

@property float cameraWidth;
@property float cameraHeight;
@property NSValue *openGazerCocoaPointer;

@end
