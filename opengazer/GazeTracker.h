#pragma once
#include "utils.h"
#include "GaussianProcess.mm"

typedef MeanAdjustedGaussianProcess<SharedImage> ImProcess;

struct Targets {
    vector<OpenGazer::Point> targets;

    Targets(void) {};
    Targets(vector<OpenGazer::Point> const& targets): targets(targets) {}
    int getCurrentTarget(OpenGazer::Point point);
};

struct CalTarget {
    OpenGazer::Point point;
    SharedImage image, origimage;

    CalTarget();
    CalTarget(OpenGazer::Point point, const IplImage* image, const IplImage* origimage);

    void save(CvFileStorage* out, const char* name=NULL);
    void load(CvFileStorage* in, CvFileNode *node);
};

struct TrackerOutput {
    OpenGazer::Point gazepoint;
    OpenGazer::Point target;
    int targetid;

    TrackerOutput(OpenGazer::Point gazepoint, OpenGazer::Point target, int targetid);
};

class GazeTracker {
    scoped_ptr<ImProcess> gpx, gpy;
    vector<CalTarget> caltargets;
    scoped_ptr<Targets> targets;
    
    static double imagedistance(const IplImage *im1, const IplImage *im2);
    static double covariancefunction(const SharedImage& im1, 
				     const SharedImage& im2);

    void updateGPs(void);

public:
    TrackerOutput output;

    GazeTracker(): targets(new Targets), 
	output(OpenGazer::Point(0,0), OpenGazer::Point(0,0), -1) {}

    bool isActive() { return gpx.get() && gpy.get(); }

    void clear();
    void addExemplar(OpenGazer::Point point, 
		     const IplImage *eyefloat, const IplImage *eyegrey);
    void draw(IplImage *canvas, int eyedx, int eyedy);
    void save(void);
    void save(CvFileStorage *out, const char *name);
    void load(void);
    void load(CvFileStorage *in, CvFileNode *node);
    void update(const IplImage *image);
    int getTargetId(OpenGazer::Point point);
    OpenGazer::Point getTarget(int id);
};
