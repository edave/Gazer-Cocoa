//
//  LCCalibrationView.h
//  blinders
//
//  Created by David Pitman on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LCCalibrationView : NSView{
    NSImage* _targetImage;
    NSPoint _targetCoordinates;
}

@property(retain) NSImage* targetImage;
@property NSPoint targetCoordinates;

@end
