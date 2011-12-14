//
//  CaptureView.h
//  CaptureLayer
//
//  Created by Bill Dudney on 2/19/08.
//  Copyright 2008 Gala Factory. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h>

@interface CaptureView : NSView {
  QTCaptureLayer *captureLayer;
  CIFilter *filter;
  CABasicAnimation *animation;
}

@end
