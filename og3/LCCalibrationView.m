//
//  LCCalibrationView.m
//  blinders
//
//  Created by David Pitman on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LCCalibrationView.h"

@implementation LCCalibrationView

@synthesize targetImage = _targetImage;
@synthesize targetCoordinates = _targetCoordinates;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.targetImage = [NSImage imageNamed:@"calibrationTarget"];
        self.targetCoordinates = NSZeroPoint;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSColor* fillColor = [NSColor colorWithCalibratedHue:0.0
											  saturation:0.0
											  brightness:0.0
												   alpha:0.3];
	[fillColor setFill];
    NSRectFillUsingOperation(dirtyRect, NSCompositeSourceOver);
    [_targetImage compositeToPoint:self.targetCoordinates operation:NSCompositeSourceOver];
}

- (void)keyDown:(NSEvent *)theEvent {
    //NSLog([theEvent description]);
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

@end
