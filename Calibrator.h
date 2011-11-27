#pragma once
#include "utils.h"
#include "TrackingSystem.h"
#include "Containers.h"
#include "GraphicalPointer.h"
#include "FeatureDetector.h"

using std::vector;

class FrameProcessing;

class FrameFunction:
public Containee<FrameProcessing, FrameFunction>
{
    const int &frameno;
    int startframe;
 protected:
    int getFrame() { return frameno - startframe; }
public:
    FrameFunction(const int &frameno): frameno(frameno), startframe(frameno) {}
    virtual void process()=0;
    virtual ~FrameFunction();
};

class FrameProcessing:
public ProcessContainer<FrameProcessing,FrameFunction> {};

class MovingTarget: public FrameFunction {
    shared_ptr<WindowPointer> pointer;
 public:
    MovingTarget(const int &frameno,
		 const vector<OpenGazer::Point>& points,
		 const shared_ptr<WindowPointer> &pointer,
		 int dwelltime=20);
    virtual ~MovingTarget();
    virtual void process();
 protected:
    vector<OpenGazer::Point> points;
    const int dwelltime;
    int getPointNo();
    int getPointFrame();
    bool active();
};

class Calibrator: public MovingTarget {
    static const OpenGazer::Point defaultpointarr[];
    shared_ptr<TrackingSystem> trackingsystem;
    scoped_ptr<FeatureDetector> averageeye;
public:
    static vector<OpenGazer::Point> defaultpoints;
    static vector<OpenGazer::Point> loadpoints(istream& in);
    Calibrator(const int &frameno,
	       const shared_ptr<TrackingSystem> &trackingsystem,
	       const vector<OpenGazer::Point>& points,
	       const shared_ptr<WindowPointer> &pointer,
	       int dwelltime=20);
    virtual ~Calibrator();
    virtual void process();
    static vector<OpenGazer::Point> scaled(const vector<OpenGazer::Point>& points, double x, double y);
};


