//
//  AppDelegate.h
//  og3
//
//  Created by Ryan Kabir on 11/22/11.
//  Copyright (c) 2011 Grow20 Corporation. All rights reserved.
//

#include <opencv/cv.h>
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic) BOOL calibrationFlag;

@end
