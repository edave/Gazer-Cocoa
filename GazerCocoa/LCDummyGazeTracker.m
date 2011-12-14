//
//  LCDummyGazeTracker.m
//  blinders
//
//  Created by David Pitman on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LCDummyGazeTracker.h"

@implementation LCDummyGazeTracker
@synthesize calibrationInterface = _calibrationInterface;

-(id) init{
    self = [super init];
    if(self){
        _status = kGazeTrackerUncalibrated;
        calibrationIndex = 0;
        calibrationPoints = [NSArray arrayWithObjects:[LCCalibrationPoint initWithX:0.05 andY:0.05],
                             [LCCalibrationPoint initWithX:0.95 andY:0.05],
                             [LCCalibrationPoint initWithX:0.95 andY:0.95],
                             [LCCalibrationPoint initWithX:0.05 andY:0.95],
                             nil];
    }
    return self;
}

-(void)registerGazeTrackerListener:(id <LCGazeListener>) gazeListener{
    NSLog(@"GazeListener registered");
}

-(void)deregisterGazeTrackerListener:(id <LCGazeListener>) gazeListener{
    NSLog(@"GazeListener deregistered");
}

-(LCGazePoint*)currentGazeLocation{
    LCGazePoint* newPoint = [[LCGazePoint alloc] init];
    newPoint.x = 128.0;
    newPoint.y = 128.0;
    newPoint.precision = 10.0;
    return newPoint;
}

-(void)setGazeCalibratorInterface:(id <LCGazeCalibratorInterface>) gazeCalibrator{
    self.calibrationInterface = gazeCalibrator;
}

-(void)readyToCalibrate{
    NSLog(@"Dummy Gaze Tracker :: Ready to calibrate");
    [self calibrateNextPoint];
}

-(void)displayingCalibrationPoint:(LCCalibrationPoint*) point{
    NSLog(@"Dummy Gaze Tracker :: Displaying Calibration Point");
    [self calibrateNextPoint];
}

-(void)calibrationAborted{
    NSLog(@"Dummy Gaze Tracker :: Calibration Aborted");
    calibrationIndex = 0;
}

-(NSString*)calibrationStatus{
    return _status;
}

-(void)calibrateNextPoint{
    [NSThread sleepForTimeInterval:1.0];
    if(calibrationIndex < [calibrationPoints count]){
        [self.calibrationInterface moveToNextPoint:[calibrationPoints objectAtIndex:calibrationIndex]];
        NSLog(@"Calibration index: %i", calibrationIndex);
        calibrationIndex = calibrationIndex + 1;
        [self calibrateNextPoint];
    }else{
        calibrationIndex = 0;
        _status = kGazeTrackerCalibrated;
        [self.calibrationInterface finishCalibration:_status];
    }
}

@end
