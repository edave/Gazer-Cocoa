#pragma once
#include <opencv/highgui.h>
#include "Containers.h"
#include <string>
#include <sstream>

/* represents the pointer as a small window and moves that window */
class WindowPointer {

public:
struct PointerSpec {
	int width, height;
  int red, green, blue;
  PointerSpec(int width, int height, int red, int green, int blue);
};

private:
	string name;

public:
	static int windowNumber;

	WindowPointer(const PointerSpec &pointerspec);
	void setPosition(int x, int y);
};
