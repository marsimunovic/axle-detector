#include <iostream>


int main(int argc, char** argv)
{
	
	getImageMatrix(image_list, Xorig, Xbin);
	cropImage(Xbin, Xcrop, CropCount);
	detectEdge(Xcrop, bottom_edge);
	findAxleCandidates(bottom_edge, image_info);
	detectAxle(Xcrop, CropCount, bottom_edge, lifted_axles, output_info);

	return 0;
}