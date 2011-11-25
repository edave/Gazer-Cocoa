#include "utils.h"

void convert(const OpenGazer::Point& point, CvPoint2D32f& p) {
    p.x = point.x;
    p.y = point.y;
}

ostream& operator<< (ostream& out, const OpenGazer::Point& p) {
    out << p.x << " " << p.y << endl;
    return out;
}

istream& operator>> (istream& in, OpenGazer::Point& p) {
    in >> p.x >> p.y;
    return in;
}

void OpenGazer::Point::operator=(CvPoint2D32f const& point) {
    x = point.x; 
    y = point.y;
}

void OpenGazer::Point::operator=(CvPoint const& point) {
    x = point.x; 
    y = point.y;
}


double OpenGazer::Point::distance(OpenGazer::Point other) const {
    return fabs(other.x - x) + fabs(other.y - y);
}

OpenGazer::Point OpenGazer::Point::operator+(const OpenGazer::Point &other) const {
    return OpenGazer::Point(x + other.x, y + other.y);
}
    
OpenGazer::Point OpenGazer::Point::operator-(const OpenGazer::Point &other) const {
    return OpenGazer::Point(x - other.x, y - other.y);
}
    
void OpenGazer::Point::save(CvFileStorage *out, const char* name) const {
    cvStartWriteStruct(out, name, CV_NODE_MAP);
    cvWriteReal(out, "x", x);
    cvWriteReal(out, "y", y);
    cvEndWriteStruct(out);
}

void OpenGazer::Point::load(CvFileStorage *in, CvFileNode *node) {
    x = cvReadRealByName(in, node, "x");
    y = cvReadRealByName(in, node, "y");
}

CvPoint OpenGazer::Point::cvpoint(void) const {
    return cvPoint(cvRound(x), cvRound(y));
}

CvPoint2D32f OpenGazer::Point::cvpoint32(void) const {
    return cvPoint2D32f(x, y);
}

int OpenGazer::Point::closestPoint(const vector<OpenGazer::Point> &points) const {
    if (points.empty())
	return -1;

    vector<double> distances(points.size());

    // To avoid dependencies on sigc++ just for this, we are doing this manually
    // transform(points.begin(), points.end(), distances.begin(), sigc::mem_fun(*this, &OpenGazer::Point::distance));
    vector<OpenGazer::Point>::const_iterator first = points.begin();
    vector<OpenGazer::Point>::const_iterator last = points.end();
    vector<double>::iterator result = distances.begin();
    while (first != last)
     *result++ = distance(*first++);  // or: *result++=binary_op(*first1++,*first2++);

   return min_element(distances.begin(), distances.end()) - distances.begin();
}
