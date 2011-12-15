#include <opencv/cv.h>
#include "utils.h"

class FaceDetector {
    CvMemStorage* storage;
    CvHaarClassifierCascade* cascade ;

public:
    static FaceDetector facedetector;
    FaceDetector(char *cascadename="haarcascade_frontalface_alt.xml");
    ~FaceDetector();
    vector<CvRect> detect(const IplImage *img);
};


