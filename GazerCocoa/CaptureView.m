//
//  CaptureView.m
//  CaptureLayer
//
//  Created by Bill Dudney on 2/19/08.
//  Copyright 2008 Gala Factory. All rights reserved.
//

#import "CaptureView.h"

@interface CaptureView(Color)
- (CGColorRef)black;
@end

@interface CaptureView (BookStuff)

@property(readonly) CIFilter *filter;
@property(readonly) CABasicAnimation *animation;
@property(readonly) QTCaptureLayer *captureLayer;
@property(readonly) QTCaptureSession *captureSession;

@end

@implementation CaptureView

//START:code.CaptureView.awakeFromNib
- (void)awakeFromNib {
  self.layer = [CALayer layer];
  self.layer.backgroundColor = [self black];
  self.layer.layoutManager = [CAConstraintLayoutManager layoutManager];
  self.wantsLayer = YES;
  [self.layer addSublayer:self.captureLayer]; //<label id="code.CaptureView.addCaptureLayer"/>
}
//END:code.CaptureView.awakeFromNib

//START:code.CaptureView.mouseDown:
- (void)mouseDown:(NSEvent *)event {
  if(self.captureLayer.filters == nil) {
    self.captureLayer.filters = [NSArray arrayWithObject:self.filter];
    [self.captureLayer addAnimation:self.animation
     forKey:@"animateTheFilter"];
  } else {
    [self.captureLayer removeAnimationForKey:@"animateTheFilter"];
    self.captureLayer.filters = nil;
  }
}
//END:code.CaptureView.mouseDown:

@end

@implementation CaptureView (BookStuff)

- (CIFilter *)filter {
  if(nil == filter) {
    filter = [CIFilter filterWithName:@"CIBloom"];
    filter.name = @"captureFilter";
    [filter setDefaults];
  }
  return filter;
}

//START:code.CaptureView.animation
- (CABasicAnimation *)animation {
  if(nil == animation) {
    NSString *keyPath = [NSString stringWithFormat:
                         @"filters.captureFilter.%@", kCIInputRadiusKey];
    animation = [CABasicAnimation animationWithKeyPath:keyPath];
    animation.repeatCount = 1.0e100f;
    animation.duration = 2.0f;
    animation.fromValue = [NSNumber numberWithFloat:1.0f];
    animation.toValue = [NSNumber numberWithFloat:15.0f];
    animation.autoreverses = YES;
  }
  return animation;
}  
//END:code.CaptureView.animation

//START:code.CaptureView.captureSession
- (QTCaptureSession *)captureSession {
  static QTCaptureSession *session = nil;
  if(nil == session) {
    NSError *error = nil;
    session = [[QTCaptureSession alloc] init];
    // Find a video device
    QTCaptureDevice *device = 
    [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    if (device == nil) {
      NSLog (@"trying for a muxed device for video");
      device = [QTCaptureDevice 
                defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
      if (device != nil)
        NSLog (@"got a muxed device for video");
    }
    // still no device?  time to bail
    if (device == nil) {
      error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain
                                          code:QTErrorDeviceNotConnected 
                                      userInfo:nil];
      [[NSAlert alertWithError:error] runModal];
      return nil;
    }
    [device open:&error];
    if(nil != error) {
      [[NSAlert alertWithError:error] runModal];
      return nil;
    }
    // Add a device input for that device to the capture session
    QTCaptureDeviceInput *input = 
    [[QTCaptureDeviceInput alloc] initWithDevice:device];
    [session addInput:input error:&error];
    if(nil != error) {
      [[NSAlert alertWithError:error] runModal];
      return nil;
    }
  }
  return session;
}
//END:code.CaptureView.captureSession

//START:code.CaptureView.captureLayer
- (QTCaptureLayer *)captureLayer {
  if(nil == captureLayer) {
    captureLayer = [QTCaptureLayer layerWithSession:self.captureSession]; //<label id="code.CaptureView.addSessionToLayer"/>
    captureLayer.cornerRadius = 16.0f;
    captureLayer.masksToBounds = YES;
    captureLayer.bounds = CGRectMake(0.0f, 0.0f, 640.0f, 480.0f);
    [captureLayer addConstraint:
     [CAConstraint constraintWithAttribute:kCAConstraintMidX 
                                relativeTo:@"superlayer"
                                 attribute:kCAConstraintMidX]];
    [captureLayer addConstraint:
     [CAConstraint constraintWithAttribute:kCAConstraintMidY 
                                relativeTo:@"superlayer" 
                                 attribute:kCAConstraintMidY]];
    [self.layer addSublayer:captureLayer];
    [captureLayer.session startRunning];//<label id="code.CaptureView.startCapture"/>
  }
  return captureLayer;
}
//END:code.CaptureView.captureLayer
@end

@implementation CaptureView (Color)

- (CGColorSpaceRef)genericRGBSpace {
  static CGColorSpaceRef space = NULL;
  if(NULL == space) {
    space = CGColorSpaceCreateWithName (kCGColorSpaceGenericRGB);
  }
  return space;
}

- (CGColorRef)black {
  static CGColorRef black = NULL;
  if(black == NULL) {
    CGFloat values[4] = {0.0, 0.0, 0.0, 1.0};
    black = CGColorCreate([self genericRGBSpace], values);
  }
  return black;
}

@end
