#include "Calibrator.h"

Calibrator::~Calibrator() {
#ifdef DEBUG
    cout << "Destroying calibrator" << endl;
#endif
}

FrameFunction::~FrameFunction() {
#ifdef DEBUG
    cout << "Destroying framefunction" << endl;
#endif
}

MovingTarget::MovingTarget(const int &frameno,
         const vector<OpenGazer::Point>& points,
         const shared_ptr<WindowPointer> &pointer,
         int dwelltime):
    FrameFunction(frameno),
    points(points), dwelltime(dwelltime), pointer(pointer)
{
};

MovingTarget::~MovingTarget() {
    int id = getFrame() / dwelltime;
}

void MovingTarget::process() {
    if (active()) {
  int id = getPointNo();
  if (getPointFrame() == 1)
      pointer->setPosition(points[id].x, points[id].y);
    }
    else
  detach();
}

bool MovingTarget::active() {
    return getPointNo() < (int) points.size();
}

void MovingTarget::killPoint() {
    pointer->hide();
}

int MovingTarget::getPointNo() {
    return getFrame() / dwelltime;
}

int MovingTarget::getPointFrame() {
    return getFrame() % dwelltime;
}

Calibrator::Calibrator(const int &framecount,
           const shared_ptr<TrackingSystem> &trackingsystem,
           const vector<OpenGazer::Point>& points,
           const shared_ptr<WindowPointer> &pointer,
           int dwelltime):
    MovingTarget(framecount, points, pointer, dwelltime),
    trackingsystem(trackingsystem)
{
    trackingsystem->gazetracker.clear();
    // todo: remove all calibration points
}


void Calibrator::process() {
  if (active()) {
    int id = getPointNo();
    int frame = getPointFrame();
    if (frame == 1) // start
      averageeye.reset(new FeatureDetector(EyeExtractor::eyesize));
    if (frame >= dwelltime/2) // middle
        averageeye->addSample(trackingsystem->eyex.eyefloat.get());
    if (frame == dwelltime-1) { // end
        trackingsystem->gazetracker.
      addExemplar(points[id], averageeye->getMean().get(),
            trackingsystem->eyex.eyegrey.get());
    }
    MovingTarget::process();
  } else {
    MovingTarget::process();
    MovingTarget::killPoint();
  }
}

const OpenGazer::Point Calibrator::defaultpointarr[] = {OpenGazer::Point(0.5, 0.5), 
    OpenGazer::Point(0.1, 0.5), OpenGazer::Point(0.9, 0.5),
    OpenGazer::Point(0.5, 0.1), OpenGazer::Point(0.5, 0.9), 
    OpenGazer::Point(0.1, 0.1), OpenGazer::Point(0.1, 0.9), 
    OpenGazer::Point(0.9, 0.9), OpenGazer::Point(0.9, 0.1), 
//    OpenGazer::Point(0.33, 0.33), OpenGazer::Point(0.33, 0.66), 
//    OpenGazer::Point(0.66, 0.66), OpenGazer::Point(0.66, 0.33),
//    OpenGazer::Point(0.05, 0.5), OpenGazer::Point(0.95, 0.5),
//    OpenGazer::Point(0.5, 0.05), OpenGazer::Point(0.5, 0.95), 
//    OpenGazer::Point(0.05, 0.05), OpenGazer::Point(0.05, 0.95), 
//    OpenGazer::Point(0.95, 0.95), OpenGazer::Point(0.95, 0.05), 
//    OpenGazer::Point(0.25, 0.25), OpenGazer::Point(0.25, 0.75), 
    OpenGazer::Point(0.75, 0.75), OpenGazer::Point(0.75, 0.25)};

vector<OpenGazer::Point>
Calibrator::defaultpoints(Calibrator::defaultpointarr,
        Calibrator::defaultpointarr+
        (sizeof(Calibrator::defaultpointarr) /
         sizeof(Calibrator::defaultpointarr[0])));

vector<OpenGazer::Point> Calibrator::loadpoints(istream& in) {
  vector<OpenGazer::Point> result;

  for(;;) {
    double x, y;
    in >> x >> y;
    if (in.rdstate()) break; // break if any error
    result.push_back(OpenGazer::Point(x, y));
  }

  // [RYAN]: ignoring the istream, which probably is null or something
  // return result;
  return Calibrator::defaultpoints;
}

vector<OpenGazer::Point> Calibrator::scaled(const vector<OpenGazer::Point> &points,
              double x, double y)
{
//     double dx = x > y ? (x-y)/2 : 0.0;
//     double dy = y > x ? (y-x)/2 : 0.0;
//     double scale = x > y ? y : x;

  vector<OpenGazer::Point> result;

  xforeach(iter, points)
    result.push_back(OpenGazer::Point(iter->x * x, iter->y * y));
//  result.push_back(OpenGazer::Point(iter->x * scale + dx, iter->y * scale + dy));

  return result;
}
