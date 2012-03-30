//
//  OpenGazerTracker.h
//  blinders
//
//  Created by David Pitman on 11/30/11.
//  Copyright (c) 2011 Lab Cogs Co.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LCGazeMonitor.h"

@interface OpenGazerMonitor : NSObject<LCGazeMonitor>{
    NSTask* _openGazerTask;
    int _launchCount;
    BOOL _terminateTask;
    NSString* _appID;
    
    NSPoint gazePoint;
    
    NSString* trackerStatus;
    id<LCGazeMonitorDelegate> delegate;
    
    NSNotificationQueue* _notificationQueue;
}

@property(retain) NSString* trackerStatus;

@property NSPoint gazePoint;

-(void)gazeTrackerReady:(NSNotification*)note;

-(void)gazeTrackerTerminating:(NSNotification*)note;

-(void)gazeTrackerCalibrationEnded:(NSNotification*)note;

-(void)gazePointBroadcasted:(NSNotification*)note;

-(void)gazeTrackerBroadcasting:(NSNotification*)note;

-(void)gazeTrackerEndingBroadcast:(NSNotification*)note;

-(void)gazeTrackerError:(NSNotification*)note;

-(void)terminateTask;

-(void)launchTask;

-(void)taskTerminated:(NSNotification*) note;

-(void)statusFromNotification:(NSNotification*)note;

@end
