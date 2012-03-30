//
//  OpenGazerTracker.m
//  blinders
//
//  Created by David Pitman on 11/30/11.
//  Copyright (c) 2011 Lab Cogs Co.. All rights reserved.
//

#import "OpenGazerMonitor.h"
#import <dispatch/dispatch.h>

@implementation OpenGazerMonitor

@synthesize gazePoint;
@synthesize trackerStatus;
@synthesize delegate;

-(id)init{
    self = [super init];
    if(self){
        // Setup the Task Launcher
        _launchCount = 0;
        _terminateTask = NO;
        _appID = [[NSProcessInfo processInfo] globallyUniqueString]; 
        _notificationQueue = [NSNotificationQueue defaultQueue];
        self.trackerStatus = kGazeTrackerUnavailable;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector: @selector(taskTerminated:)
                                                     name:NSTaskDidTerminateNotification
                                                   object:nil];
        
        // Setup all of our Distributed Notification Observers
        NSDistributedNotificationCenter* distCenter = [NSDistributedNotificationCenter defaultCenter];
        [distCenter addObserver:self
                       selector:@selector(gazeTrackerReady:)
                           name:kGazeTrackerReady
                         object:kGazeSenderID];
        [distCenter addObserver:self
                       selector:@selector(gazeTrackerTerminating:)
                           name:kGazeTrackerTerminating
                         object:kGazeSenderID];
        [distCenter addObserver:self
                       selector:@selector(gazeTrackerCalibrationEnded:)
                           name:kGrazeTrackerCalibrationEnded
                         object:kGazeSenderID];
        [distCenter addObserver:self
                       selector:@selector(gazeTrackerBroadcasting:)
                           name:kGazeTrackerPointBroadcastStart
                         object:kGazeSenderID];
        [distCenter addObserver:self
                       selector:@selector(gazePointBroadcasted:)
                           name:kGazePointNotification
                         object:kGazeSenderID];
        [distCenter addObserver:self
                       selector:@selector(gazeTrackerEndingBroadcast:)
                           name:kGazeTrackerPointBroadcastEnd
                         object:kGazeSenderID];
        [distCenter addObserver:self
                       selector:@selector(gazeTrackerError:)
                           name:kGazeTrackerError
                         object:kGazeSenderID];
        
        [self launchTask];
    }
    return self;
}

-(void)terminateTask{
    _terminateTask = YES;
    if(_openGazerTask){
        [_openGazerTask terminate];
    }
}

-(void)launchTask{
    self.trackerStatus = kGazeTrackerUnavailable;
    if(self.delegate != nil){
        [self.delegate gazeTrackerUnavailable];
    }
        
    if(!_terminateTask){ // Try to relaunch the app
    if(_launchCount <= 10){ // Make sure we don't continually try to relaunch if the app is hosed
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0), ^{ // Run on a 
           NSString* openGazerApp = [[NSBundle mainBundle] pathForResource:@"GazerCocoa" ofType:@"app"];
           if(openGazerApp != nil){
               // Add in the actual path to the executable inside the app bundle
               _openGazerTask = [NSTask launchedTaskWithLaunchPath:[openGazerApp stringByAppendingPathComponent:@"Contents/MacOS/og3"] arguments:[NSArray array]];
        _launchCount += 1;
           }else{
               NSLog(@"OpenGazerCocoa not found");
           }
       });
    }
    }
}

-(void)taskTerminated:(NSNotification*) note{
    int status = [[note object] terminationStatus];
    if (status == 0){
        
    }else{
        NSLog(@"OBC Termination: %i", status);
    }
    self.trackerStatus = kGazeTrackerUnavailable;
    if(self.delegate != nil){
        [self.delegate gazeTrackerUnavailable];
    }
    [self launchTask];
    
}

-(void)statusFromNotification:(NSNotification*)note{
    NSString* status = (NSString*)[(NSDictionary*)[note userInfo] objectForKey:kGazeTrackerStatusKey];
    if(status != nil){
        self.trackerStatus = [NSString stringWithString: status];
        NSLog(@"Notification :: GazeTracker Status: %@", self.trackerStatus);
        if(self.delegate != nil){
            if([self.trackerStatus isEqualToString:kGazeTrackerUncalibrated] ||
               [self.trackerStatus isEqualToString:kGazeTrackerNeedsRecalibration]){
                [self.delegate gazeTrackerOffline];
            }else if([self.trackerStatus isEqualToString:kGazeTrackerCalibrated]){
                [self.delegate gazeTrackerOnline];
            }else{
                [self.delegate gazeTrackerError:self.trackerStatus];
            }
            
        }
    }
}

-(void)dealloc{
    [self terminateTask];
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
                                          
#pragma mark - Notifications
                                          
-(void)gazeTrackerReady:(NSNotification*)note{
    NSLog(@"Gaze Tracker Ready");
    [self statusFromNotification:note];
}

-(void)gazeTrackerTerminating:(NSNotification*)note{
    NSLog(@"Gaze Tracker Terminating");
    if(self.delegate){
        [self.delegate gazeTrackerUnavailable];
    }
    [self launchTask];
}

-(void)gazeTrackerCalibrationEnded:(NSNotification*)note{
    [self statusFromNotification:note];
}

-(void)gazePointBroadcasted:(NSNotification*)note{
    NSDictionary* userInfo = [note userInfo];
    NSPoint point;
    point.x = [(NSNumber*)[userInfo objectForKey:kGazePointXKey] floatValue];
    point.y = [(NSNumber*)[userInfo objectForKey:kGazePointYKey] floatValue];
    
    //NSLog(@"GazePoint: %f %f", point.x, point.y);
    self.gazePoint = point;
    NSNotification* pointNotification = [NSNotification notificationWithName:kBlindersGazeTrackerPoint
                                                                      object:nil
                                                                    userInfo:[NSDictionary dictionaryWithObject:[NSValue valueWithPoint:point] forKey:kBlindersGazeTrackerPoint]];
    [_notificationQueue enqueueNotification:pointNotification postingStyle:NSPostASAP];
}

-(void)gazeTrackerBroadcasting:(NSNotification*)note{
    if(self.delegate != nil){
        [self.delegate gazeTrackerOnline];
    }
}

-(void)gazeTrackerEndingBroadcast:(NSNotification*)note{
    if(self.delegate != nil){
        [self.delegate gazeTrackerOffline];
    }
}

-(void)gazeTrackerError:(NSNotification*)note{
    [self statusFromNotification:note];
}

-(void) applicationWillTerminate:(NSNotification*)notification{
    [self terminateTask];
}


#pragma mark - LCGazeMonitor
-(void)stopMonitoring{
    NSLog(@"Stop Monitoring");
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGazeTrackerTerminateRequest 
                                                                   object:kGazeSenderID
                                                                 userInfo:[NSDictionary dictionaryWithObject:_appID forKey:kGazeListenerAppUIDKey]
     deliverImmediately:YES];
    [self terminateTask];
}

-(void)startCalibration{
    NSLog(@"Starting Calibration");
    if(self.delegate != nil){
        [self.delegate gazeTrackerCalibrating];
    }
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGazeTrackerCalibrationRequestStart 
                                                        object:kGazeSenderID
                                                      userInfo:nil
                                                    deliverImmediately:YES];
}

-(void)stopCalibration{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kGazeTrackerCalibrationAbort 
                                                                   object:kGazeSenderID
                                                                 userInfo:nil
     deliverImmediately:YES];
    if(self.delegate != nil){
        [self.delegate gazeTrackerOffline];
    }
}

-(NSString*)status{
    return [NSString stringWithString:self.trackerStatus];
}

-(void)shutdown{
    [self terminateTask];
}
    
@end
