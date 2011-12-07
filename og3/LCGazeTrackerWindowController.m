//
//  LCGazeTrackerWindowController.m
//  og3
//
//  Created by David Pitman on 12/7/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import "LCGazeTrackerWindowController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LCGazeTrackerWindowController

- (id)initWithScreen:(NSScreen*)screen{
    self = [super initWithWindowNibName:@"GazeTrackerWindow"];
    if (self) {
        _screen = screen;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Setup the window to float above everything else and not intercept events
    [self.window setBackgroundColor:[NSColor clearColor]];
    [self.window setIgnoresMouseEvents:YES];
    [self.window setHasShadow:NO];
    [self.window setOpaque:NO];
    [self.window setLevel:NSPopUpMenuWindowLevel];
    
    NSRect screenFrame = [_screen frame];
    [self.window setFrame:screenFrame display:NO];
    [self.window setMinSize:screenFrame.size];
    [self.window setMaxSize:screenFrame.size];
    NSView* contentView = [self.window contentView];
    [contentView setFrame:screenFrame];
    
    CALayer* superLayer = [CALayer layer];
    _gazeTargetLayer = [self setupGazeTargetLayer:superLayer];
    [[self.window contentView] setWantsLayer:YES];
    [[self.window contentView] setLayer:superLayer];
    

}


-(CALayer*)setupGazeTargetLayer:(CALayer*)parentLayer{
    CALayer *layer = [CALayer layer];
    NSImage* gazeImage = [NSImage imageNamed:@"gazeTarget"];
    layer.contents = gazeImage;
    layer.frame = CGRectMake(0,0, gazeImage.size.width, gazeImage.size.height);
    layer.position = CGPointMake(_screen.frame.size.width/2.0, _screen.frame.size.height/2.0);
    [parentLayer addSublayer:layer];
    return layer;
}

// Move the gaze estimation target
-(void) moveGazeTarget:(LCGazePoint*) point{
    //NSLog(@"Gaze Point: %@ -> %f, %f", point,  point.x,  point.y);
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.1f] forKey:kCATransactionAnimationDuration];
    _gazeTargetLayer.position = CGPointMake(point.x, point.y);
    [CATransaction commit];
}


@end
