//
//  LCCalibrationFaceTrackingView.m
//  com.labcogs.gazercocoa
//
//  Created by David Pitman on 12/12/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import "LCCalibrationFaceTrackingView.h"
//#import "LCCalibrationCameraView.h"

@implementation LCCalibrationFaceTrackingView

@synthesize cameraHeight, cameraWidth;

-(void)awakeFromNib{
    _faceRect = NSZeroRect;
    _leftEyePoint = NSZeroRect;
    _rightEyePoint = NSZeroRect;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(faceTrackingNotification:)
                                                 name:@"faceTrackingNotification"
                                               object:nil];
    
    
    [self setWantsLayer:YES];
    
}

- (void)faceTrackingNotification:(NSNotification*)note{
    NSDictionary* userInfo = [note userInfo];
        NSRect newFaceRect = [(NSValue*)[userInfo objectForKey:@"kFaceRect"] rectValue];
        NSRect newEyeLeft = [(NSValue*)[userInfo objectForKey:@"kEyeLeft"] rectValue];
        NSRect newEyeRight = [(NSValue*)[userInfo objectForKey:@"kEyeRight"] rectValue];
    //NSLog(@"new face rect: %f %f %f %f", newEyeLeft.origin.x, newEyeLeft.origin.y, newEyeLeft.size.width, newEyeLeft.size.height);
    if(!NSEqualRects(newFaceRect, NSZeroRect)){
        NSPoint windowPoint = newFaceRect.origin;
        NSRect previewBounds = [self bounds];
        NSRect viewBounds = [self bounds];
        NSSize mySize = previewBounds.size;
        // Adjust for the actual bounds of the video frame within this view
        float heightOffset = (viewBounds.size.height  - mySize.height) / 2.0f;
        float widthOffset =  (viewBounds.size.width - mySize.width) / 2.0f;
        windowPoint.x = windowPoint.x + widthOffset;
        windowPoint.y = windowPoint.y + heightOffset;
        float y = (mySize.height - windowPoint.y)*(mySize.height/self.cameraHeight);
        float x = windowPoint.x * ( mySize.width/self.cameraWidth );
        //NSLog(@"Point: %f %f", x, y);
        windowPoint.x = x;
        windowPoint.y = y;
        newFaceRect.origin = windowPoint;
        newFaceRect.size = NSMakeSize(newFaceRect.size.width* ( mySize.width/self.cameraWidth ), newFaceRect.size.height * (mySize.height/self.cameraHeight));
        _faceRect = newFaceRect;
        if(!NSEqualRects(newEyeLeft, NSZeroRect)){
            newEyeLeft.origin = NSMakePoint(newEyeLeft.origin.x * ( mySize.width/self.cameraWidth ), mySize.height - (newEyeLeft.origin.y*(mySize.height/self.cameraHeight)));
            newEyeLeft.size = NSMakeSize(newEyeLeft.size.width* ( mySize.width/self.cameraWidth ), newEyeLeft.size.height * (mySize.height/self.cameraHeight));
            _leftEyePoint = newEyeLeft;
           // NSLog(@"Left Eye Rect: %f %f %f %f", _leftEyePoint.origin.x, _leftEyePoint.origin.y, _leftEyePoint.size.width, _leftEyePoint.size.height);
            
        }else{
            //_leftEyePoint = NSZeroRect;
        }
        
        
        if(!NSEqualRects(newEyeRight, NSZeroRect)){
            newEyeRight.origin = NSMakePoint(newEyeRight.origin.x * ( mySize.width/self.cameraWidth ), mySize.height - (newEyeRight.origin.y*(mySize.height/self.cameraHeight)));
            newEyeRight.size = NSMakeSize(newEyeRight.size.width* ( mySize.width/self.cameraWidth ), newEyeRight.size.height * (mySize.height/self.cameraHeight));
            _rightEyePoint = newEyeRight;
        }else{
            //_rightEyePoint = NSZeroRect;
        }
        
    }else{
        _faceRect = NSZeroRect;
        _leftEyePoint = NSZeroRect;
        _rightEyePoint = NSZeroRect;
    }
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)aRect{
    [super drawRect:aRect];
    
    if(!NSEqualRects(_faceRect, NSZeroRect)){
        
        //NSLog(@"Drawing Face");
        NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
        //[theContext saveGraphicsState];
        [[NSColor clearColor] setFill];
        
        //NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
        [theContext setCompositingOperation:NSCompositeCopy];
        NSColor* strokeColor = [NSColor greenColor];
        [strokeColor setStroke];

        NSBezierPath* roundedRect = [NSBezierPath bezierPathWithRoundedRect:_faceRect xRadius:2.0 yRadius:2.0];
        [roundedRect setLineWidth:3.0f];
        [roundedRect stroke];
        //[roundedRect fill];
        if(!NSEqualRects(_leftEyePoint, NSZeroRect)){
            //NSLog(@"Drawing Eye Left");
            NSBezierPath* oval = [NSBezierPath bezierPathWithOvalInRect:_leftEyePoint];
            [oval setLineWidth:2.0f];
            [oval stroke];
            
        }
        if(!NSEqualRects(_rightEyePoint, NSZeroRect)){
            //NSLog(@"Drawing Eye Right");
            
            NSBezierPath* oval = [NSBezierPath bezierPathWithOvalInRect:_rightEyePoint];
            [oval setLineWidth:2.0f];
            [oval stroke];
        }
       // [theContext restoreGraphicsState];
    }else{
        //[[NSColor clearColor] setFill];
        //NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
    }
    
}
@end
