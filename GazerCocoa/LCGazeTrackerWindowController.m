//
//  LCGazeTrackerWindowController.m
//  com.labcogs.gazercocoa
//
//  Created by David Pitman on 12/7/11.
//  Copyright (c) 2011 Lab Cogs Co. All rights reserved.
//

#import "LCGazeTrackerWindowController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LCGazeTrackerWindowController

@synthesize isActive = _isActive;
@synthesize trackHotspot = _trackHotspot;

- (id)initWithScreen:(NSScreen*)screen{
    self = [super initWithWindowNibName:@"GazeTrackerWindow"];
    if (self) {
        _screen = screen;
        NSRect screenFrame = [screen frame];
        _screenDiagonal = (pow(screenFrame.size.height,2) + pow(screenFrame.size.width,2)) / 2.0f;
        _hotspotPoint = [[LCCalibrationPoint alloc] init];
        _hotspotPoint.x = 0.0f;
        _hotspotPoint.y = 0.0f;
        _isActive = NO;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    //NSLog(@"GazeTrackerWindowController :: awakeFromNib");
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
    if(_trackHotspot){
        _gazeTargetLayer.opacity = [self opacityFromHotspot];
    }else{
        _gazeTargetLayer.opacity = 1.0;
    }
    [CATransaction commit];
}

-(void) show:(BOOL)show{
    if(show != self.isActive){
        self.isActive = show;
        if(_isActive){
            [[NSDistributedNotificationCenter defaultCenter] addObserver:self
                                                                selector:@selector(moveGazeEstimationTarget:)
                                                                    name:kGazePointNotification
                                                                  object:kGazeSenderID];
            [[self window] makeKeyAndOrderFront:self];
            
        }else{
            [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
            [[self window] close];
        }
    }
        
}


-(void)moveGazeEstimationTarget:(NSNotification*)note{
    //NSLog(@"Receive move gaze tracking Point");
    LCGazePoint* point = [[LCGazePoint alloc] init];
    NSDictionary* dict = (NSDictionary*)[note userInfo];
    point.x = [(NSNumber*)[dict objectForKey:kGazePointXKey] floatValue];
    point.y = [(NSNumber*)[dict objectForKey:kGazePointYKey] floatValue];
    if(point.x != NAN && point.y != NAN){
        _currentGazePoint = point;
        [self moveGazeTarget:point];
    }
}

-(float)opacityFromHotspot{
    float distRatio = (pow(_hotspotPoint.x - _currentGazePoint.x, 2) + pow(_hotspotPoint.y - _currentGazePoint.y, 2)) / _screenDiagonal;
    return 0.1f + distRatio * 0.5;
}

-(void) setHotspot:(LCCalibrationPoint*) point{
    _hotspotPoint = point;
    if(_trackHotspot){
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.1f] forKey:kCATransactionAnimationDuration];
        _gazeTargetLayer.opacity = [self opacityFromHotspot];
        [CATransaction commit];
    }
}


@end
