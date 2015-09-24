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
    /*------------------------------------------------------*/
    // QT specific methods - DO NOT USE IN IMPLEMENTATION!  //
    /*------------------------------------------------------*/
    void LoadProfileDetails(std::string const &imageName);
    Uint32 CountAuxAxles();
    /*------------------------------------------------------*/
    //              End of QT specific methods              //
    /*------------------------------------------------------*/
    Uint32 CountAuxAxles(Array<Uint8>& image);
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
    inline bool IsBlackPix(Uint16 row, Uint16 col);
    inline bool IsWhitePix(Uint16 row, Uint16 col);
    std::vector<Uint8> CropImage();
    bool DetectEdge();
    void FindAxleCandidates(AxleCandidates& auxCandidates);
    void FindPeakCoordinates(AxleCandidates& ra, AxleCandidates& aa);
    void ImproveAxleCandidates(Uint16 offset, AxleCandidates& aCand);
    void ImproveRawAxleCandidates(AxleCandidates& aCand);
    Uint32 DetectAxles(AxleCandidates& aCand, std::vector<Uint8> cropInfo);

//members
private:
    bool   m_cleanImage;
    Uint32 m_vehLen;
	Uint8* m_vehEdge;
	float* m_filteredEdge;
    std::vector<Uint16> m_emptySegments;
    Array<Uint8> m_image;
};

#endif
