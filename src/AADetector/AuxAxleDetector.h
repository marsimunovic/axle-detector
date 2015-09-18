/***************************************************************************************************
* This software module was originally developed by:
*  Marijo Simunovic, Telegra d.o.o.
*
*  
* Abstract:
*   Auxiliary Axle Detector Main Class
*   
***************************************************************************************************/

#ifndef AUXAXLEDETECTOR_H
#define AUXAXLEDETECTOR_H

#include <vector>

#include "general.h"

class AuxAxleDetector
{

//methods
public:
	AuxAxleDetector();
    ~AuxAxleDetector();
    void LoadProfileDetails(std::string const &imageName);
	Uint8 CountAuxiliaryAxles(Array<Uint8>& image);
	Uint32 NumAuxAxles();
//proprietary members
private:
	//Axle Canidate Coordinates
	struct AxleCandidate
	{
		AxleCandidate(Uint16 ledge, Uint16 redge, Uint16 minloc)
			:lEdge(ledge), rEdge(redge), minLoc(minloc){}

		Uint16 lEdge; //left edge coordinate
		Uint16 rEdge; //right edge coordinate
		Uint16 minLoc;//min point coordinate
	};
	typedef std::vector<AxleCandidate> AxleCandidates;
//inner methods
private:
    std::vector<Uint8> CropImage(Array<Uint8>& image);
	void DetectEdge(Array<Uint8>& image);
	void FindPeaksManual(std::vector<float>& filteredEdge, AxleCandidates& ra, AxleCandidates& aa);
	void ImproveAxleCandidates(Uint16 offset, AxleCandidates& aCand);
	void ImproveRawAxleCandidates(AxleCandidates& aCand);
	void FindAxleCandidates(AxleCandidates& auxCandidates);
	Uint32 DetectAxles(Array<Uint8>& image, AxleCandidates& aCand);

//members
private:
	Uint8* m_vehEdge;
	float* m_filteredEdge;
    Uint8* m_imageBin;
    Array<Uint8> m_image;
	Uint32 m_vehLen;

};

#endif
