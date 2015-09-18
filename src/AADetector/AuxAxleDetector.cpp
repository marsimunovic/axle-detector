#include "AuxAxleDetector.h"
#include "AAInputs.h"
#include "HanFilter.h"

#include <QtGui>

#include <fstream>
#include <set>
#include <iostream>

Uint8 const  NOISY_ROWS = 3;
Uint8 const  MIN_PIX_REPETITION = 30;
Uint8 const  EDGE_DIFF = 5; //filtering treshold for edge detection
float const  LOCAL_PI = 3.14159265f;

void AuxAxleDetector::LoadProfileDetails(std::string const &imageName)
{
    QImage* image = new QImage();
    QImageReader* reader = new QImageReader(imageName.c_str());
    reader->read(image);

    //std::ofstream myfile ("example3.txt");

    m_imageBin = new Uint8[image->byteCount()/4];

    //if (myfile.is_open())
    //{
        for(int i = 0; i < image->height(); ++i)
        {
            unsigned char *cpy = (unsigned char*) image->scanLine(i);
            for(int j = 0; j < image->width(); ++j)
            {
                m_imageBin[i*image->height()+j] = (cpy[j*4])? '1': '0';
                //myfile << ((cpy[j*4])? '1': '0');
            }
            //myfile << '\n';
        }
    m_image.AssignAllocatedArray(m_imageBin, image->height(), image->width());
    delete[] m_imageBin;
    //}
    //myfile.flush();
    //myfile.close();

}


Uint8 AuxAxleDetector::CountAuxiliaryAxles(Array<Uint8>& image)
{
    return 0;
}

Uint32 AuxAxleDetector::NumAuxAxles()
{
    return 0;
}

std::vector<Uint8> AuxAxleDetector::CropImage(Array<Uint8> &image)
{
    Uint16 height = image.Rows();
    Uint16 width  = image.Cols();
    Uint16 top, firstCol, lastCol;

    //split image
    if(height > LOWER_PART)
        top = height-LOWER_PART;
    else
        top = height;

    //find front and back side of the vehicle
    firstCol = 0;
    Uint16 countFront = 0;

    for(int j = 0; j < width; ++j)
    {
        Uint16 sum = 0;
        for(int i = top; j < height; ++i)
            sum += (!image(i,j));
        if (sum > 5)
            ++countFront;
        else
            countFront = 0;
        if (countFront > MIN_PIX_REPETITION)
            firstCol = j - MIN_PIX_REPETITION;
    }

    lastCol = firstCol;
    Uint16 countBack = 0;
    for(int j = width-1; j > firstCol; --j)
    {
        Uint16 sum = 0;
        for(int i = top; j < height; ++i)
            sum += (!image(i,j));
        if (sum > 5)
            ++countBack;
        else
            countBack = 0;
        if (countBack > MIN_PIX_REPETITION)
            lastCol = j + MIN_PIX_REPETITION;
    }

    std::vector<Uint8> cropInfo(3, 0);
    for(int i = height - NOISY_ROWS; i < height; ++i)
    {
        Uint16 pixFrequency = 0;
        for(int j = firstCol+1; j <= lastCol; ++j)
        {
            if(image(i,j) != image(i-1,j))
                ++pixFrequency;
        }
        if(pixFrequency > 20)
            cropInfo[height - i - 1] = 1;
    }
    Uint8 shift2 = cropInfo[0];
    Uint8 shift3 = cropInfo[0] + cropInfo[1];
    Uint8 decrease = shift3 + cropInfo[2];

    if(shift3)
    {
        if(shift2)
        {
            //cpy row -2 to -3
            for(int n = 0; n < width; ++n)
            {

            }
        }
        //cpy up one ore two
    }
    if(decrease)
    {
        //shorten image size
        height = height - decrease;
    }
    return cropInfo;
}

void AuxAxleDetector::DetectEdge(Array<Uint8>& image)
{
	Uint16 imHeight, imWidth;
	Uint8 const BLOCK_SIZE = 4;
	for(Uint16 j = 2; j < imWidth; ++j)
	{
		bool updated = false;
		for(Uint16 i = imHeight - 1; i >= BLOCK_SIZE; --i)
		{
			if (image(i,j) == 0)
			{
				if(!updated)
				{
					updated = true;
					m_vehEdge[j] = imHeight - 1 - i;
					if (m_vehEdge[j] == m_vehEdge[j-2])
						m_vehEdge[j-1] = m_vehEdge[j];
				}
				Uint8 sum = m_vehEdge[i] + m_vehEdge[i-1]
							+ m_vehEdge[i-2] + m_vehEdge[i-3];
				//if two of four pixels are black
				if(sum < (BLOCK_SIZE/2))
				{
					if(m_vehEdge[j] + EDGE_DIFF <= (imHeight - 1 - i))
						m_vehEdge[j] = imHeight - 1 - i;
					break;
				}
			}
		}
	}
}

void AuxAxleDetector::FindPeaksManual(std::vector<float>& filteredEdge, AxleCandidates& ra, AxleCandidates& aa)
{
	float maxCand = filteredEdge[0]; //current peak candidate
	Uint16 ind = 0; //index of the current peak candidate
	Uint16 n = 1; //current position in signal
	Uint16 N = filteredEdge.size();
	std::vector<Uint16> peaks; //peak candidates indices
	while(n < N)
	{
		if(maxCand > filteredEdge[n])
		{
			peaks.push_back(ind);
			//find next maxCand
			while((filteredEdge[n-1] > filteredEdge[n]) && (n < N))
			{
				//do nothing 
				n += 1;
			}
			maxCand = filteredEdge[n];
			ind = n;
		}
		else
		{
			maxCand = filteredEdge[n];
			ind = n;
		}
		n += 1;
	}

	Uint16 M = peaks.size();
	//for each pair of maxima find minima in between
	
	for(Uint16 i = 1; i < M; ++i)
	{
		Uint16 minLoc = peaks[i-1];
		for(Uint16 j = peaks[i-1] + 1; j < peaks[i]; ++j)
		{
			if (filteredEdge[j] < filteredEdge[minLoc])
				minLoc = j;
		}
		Uint16 shift = 1; 
		//if there are more minima locations choose central one
		while(minLoc + shift < peaks[i])
		{
			if(filteredEdge[minLoc] == filteredEdge[minLoc + shift])
				shift += 1;
			else
				break;
		}
		shift /= 2;
		minLoc += shift;

	    //compresses peak values in candidates structures
		//each structure has three points, tyre lowest point and
		//left and right tyre edges
		AxleCandidate newCandidate(peaks[i-1], peaks[i], minLoc);

		//if right peak is higher than left
		if (filteredEdge[newCandidate.lEdge] < filteredEdge[newCandidate.rEdge])
		{
			//search smaller value on the right side of the "valley"
			while(filteredEdge[newCandidate.lEdge] < filteredEdge[newCandidate.rEdge]-1)
				newCandidate.rEdge -= 1;
		}
		//if left peak is higher than right
		else if (filteredEdge[newCandidate.lEdge] > filteredEdge[newCandidate.rEdge])
		{
			//search smaller value on the left side of the "valley"
			while(filteredEdge[newCandidate.lEdge + 1] > filteredEdge[newCandidate.rEdge])
				newCandidate.lEdge += 1;
		}
		//if both are equal
		else
		{
			//do nothing
		}

		if(filteredEdge[newCandidate.minLoc] > 0.5)
			//this is auxiliary axle candidate
			aa.push_back(newCandidate);
		else
			//this is real axle candidate
			ra.push_back(newCandidate);
	}
}

Uint32 AuxAxleDetector::DetectAxles(Array<Uint8>& image, AxleCandidates& aCand)
{
	ImproveRawAxleCandidates(aCand);

	Uint16 imHeight, imWidth;
	Uint8  cropCount;

	for(AxleCandidates::iterator it = aCand.begin(); it != aCand.end(); ++it)
	{
		Uint8 leftH = m_vehEdge[it->lEdge]; //left edge height
		Uint8 rightH = m_vehEdge[it->rEdge]; //right edge height
		Uint16 cntry = Min(leftH, rightH);
		Uint16 cntrx = it->minLoc;
		Uint8  minPoint = m_vehEdge[cntrx];
		Uint16 axleHWidth = Min(it->rEdge - it->minLoc, it->minLoc - it->lEdge);
		Uint16 axleHWidth2 = Max(it->rEdge - it->minLoc, it->minLoc - it->lEdge);
		float hAxleRatio = static_cast<float>(axleHWidth2*100)/static_cast<float>(axleHWidth);
		Uint16 axleHHeight = cntry - minPoint;
		Uint16 start = cntrx - axleHWidth;
		Uint16 stop  = cntrx + axleHWidth;
		Uint16 realW1Pct = 100; //percentage of black picksels in the central row of aux axle
		Uint16 realW2Pct = 100; //percentage of black picksels in bellow the central row of aux axle

		Uint16 relPosition = static_cast<Uint16>(cntrx*100/m_vehLen);


		std::set<Uint16> leftDistances, rightDistances;
		if((m_vehEdge[cntrx] > 0) && (abs(leftH-rightH) <= MAX_EDGE_HEIGHT_DIFF) &&
			(axleHWidth > MIN_AXLE_HWIDTH) && (axleHHeight >= MIN_AXLE_HHEIGHT)
			&& (hAxleRatio < 200))
		{
            if((cntry < MAX_CNTRY) && ((relPosition > 20) || (cntrx > MIN_POS_IND)))
			{
				Uint32 areaOver = 0;
				bool error = false;
				Uint16 blkCont1 = 100, blkCont2 = 100; //black contribution in central and row bellow
				for(Uint16 i = imHeight-1-minPoint; i >= imHeight-1-cntry; --i)
				{
					bool empty = true;
					
					Uint16 areaPart1 = cntrx, areaPart2 = cntrx;
					//find most left position
					for(Uint16 j = start-1; j < stop+1; ++j)
					{
						if(image(i,j)==0)
						{
							empty = false;
							areaPart1 = j;
							break;
						}
					}
					leftDistances.insert(areaPart1);
					if(empty)
						error = true;
					empty = true;
					//find most right position
					for(Uint16 j = stop+1; j >= start-1; --j)
					{
						if(image(i,j)==0)
						{
							empty = false;
							areaPart2 = j;
							break;
						}
					}
					rightDistances.insert(areaPart2);
					if(empty)
						error = true;
					if(error)
					{
						Uint16 maxErrPixels = 2*axleHWidth;
						Uint16 blackPix = imWidth;
						for(Uint16 rowInd = 0; rowInd < imWidth; ++rowInd)
							blackPix -= image(i,rowInd);
						if(blackPix < maxErrPixels)
							break;

					}
					
					areaOver += areaPart2 - areaPart1 + 1;
					if(i == imHeight-cntry-1)
					{
						Uint16 sum = 0;
						for(Uint16 posInd = areaPart1; posInd <= areaPart2; ++posInd)
							sum += image(i, posInd);
						blkCont1 = sum;
					}
					if(i == imHeight-cntry)
					{
						Uint16 sum = 0;
						for(Uint16 posInd = areaPart1; posInd <= areaPart2; ++posInd)
							sum += image(i, posInd);
						blkCont2 = sum;
					}

				}
				if(error)//if empty row in axle
					continue;

				float ellipseHArea = 0.5*(axleHWidth-0.5)*axleHHeight*LOCAL_PI;
				float ellipseRatio = static_cast<float>(areaOver)/ellipseHArea;
				Uint16 rightVar = rightDistances.size();
				Uint16 leftVar  = leftDistances.size();
				Uint16 sideVar  = Min(leftVar, rightVar);
				if(minPoint + cropCount > 8)
				{
					if(100.0f*static_cast<float>(sideVar)/
						static_cast<float>(axleHHeight) < 50)
						continue;
				}
				if((ellipseRatio >= 85) && (ellipseRatio <= 130) && 
					(blkCont1 > 85) && (blkCont2 > 85))
				{
					std::cout << "Found lifted axle" << std::endl;
				}
			}
		}

	}

	return 0;
}

void AuxAxleDetector::ImproveRawAxleCandidates(AxleCandidates& aCand)
{
	for(AxleCandidates::iterator it = aCand.begin(); it != aCand.end(); ++it)
	{
		AxleCandidate cand = *it;
		//centering minima
		Uint8 cntEq = 0;
		//count number of equal values in the neigborhood of minima
		for(Uint16 i = cand.minLoc - 5; i < cand.minLoc + 5; ++i)
		{
			if(m_vehEdge[i] == m_vehEdge[cand.minLoc])
				cntEq++;
		}
		//if at least half of the neigboring samples are equal to minima refine centering
		if(cntEq > 6)
		{
			std::vector<Uint16> flatMinimaLoc;
			for(Uint16 i = cand.lEdge + 1; i < cand.rEdge; ++i)
			{
				if(m_vehEdge[i] == m_vehEdge[cand.minLoc])
					flatMinimaLoc.push_back(i);
			}
			//choose central value of all locations that have same height as minima
			Uint16 newMinInd = (flatMinimaLoc.size() + 1)/2;
			cand.minLoc = flatMinimaLoc[newMinInd];
		}

		Uint16 leftHW  = cand.minLoc - cand.lEdge; //left half width of the candidate
		Uint16 rightHW = cand.rEdge - cand.rEdge; //rigth half width of the candidate
		Uint8 reqMin   = m_vehEdge[cand.minLoc] + MIN_AXLE_HHEIGHT; //min required height of the edge

		Uint8 peakLeft  = m_vehEdge[cand.lEdge];
		Uint8 peakRight = m_vehEdge[cand.rEdge];

		if(leftHW > rightHW)
		{
			//left end is farther
			Uint16 cntr = 0; //equal value counter
			//begin little right from right edge symmetric point on the left hand side
			Uint16 prev = m_vehEdge[cand.minLoc - rightHW + 2];
			Uint16 ind2 = 0, ind3 = 0;
			for(Uint16 i = cand.minLoc - rightHW + 1; i >= cand.lEdge; --i)
			{
				if(m_vehEdge[i] == prev)
					cntr += 1;
				else
					cntr = 0;
				prev = m_vehEdge[i];
				if((ind2 == 0) && (abs(static_cast<long>(m_vehEdge[i] - peakLeft)) == 2))
					ind2 = i;
				if((ind3 == 0) && (abs(static_cast<long>(m_vehEdge[i] - peakLeft)) == 3))
					ind3 = i;

				if((m_vehEdge[i] >= peakLeft) || ((cntr >= 3) && (m_vehEdge[i] > reqMin)))
				{
					if(cand.lEdge == i)
					{
						if((ind3 != 0) && (ind3 - i > 10) && (m_vehEdge[ind3] > reqMin))
							i = ind3;
						if((ind2 != 0) && (ind2 - i > 5) && (m_vehEdge[ind2] > reqMin))
							i = ind2;
					}
					cand.lEdge = i;
					break;
				}
			}
			while((cand.lEdge <= cand.rEdge) && (m_vehEdge[cand.lEdge] <= m_vehEdge[cand.rEdge - 1]))
				cand.rEdge = cand.rEdge - 1;
		}
		else if(rightHW > leftHW)
		{
			//rightt end is farther
			Uint16 cntr = 0; //equal value counter
			//begin little left from left edge symmetric point on the right hand side
			Uint16 prev = m_vehEdge[cand.minLoc +leftHW - 2];
			Uint16 ind2 = 0;
			for(Uint16 i = cand.minLoc + leftHW - 1; i <= cand.rEdge; ++i)
			{
				if(m_vehEdge[i] == prev)
					cntr += 1;
				else
					cntr = 0;

				prev = m_vehEdge[i];
				if((ind2 == 0) && (abs(static_cast<long>(m_vehEdge[i] - peakRight)) == 2))
					ind2 = i;
				
				if((m_vehEdge[i] >= peakRight) || ((cntr >= 3) && (m_vehEdge[i] > reqMin)))
				{
					if(cand.rEdge == i)
					{
						if((ind2 != 0) && (ind2 - i > 5) && (m_vehEdge[ind2] > reqMin))
							i = ind2;
					}
					cand.rEdge = i;
					break;
				}
			}
			while((cand.lEdge <= cand.rEdge) && (m_vehEdge[cand.lEdge+1] >= m_vehEdge[cand.rEdge]))
				cand.lEdge = cand.lEdge + 1;
		}
		else
		{//do nothing
		}
		*it = cand; //update changes
	}
}

AuxAxleDetector::AuxAxleDetector()
    :m_vehEdge(NULL)
    ,m_filteredEdge(NULL)
    ,m_imageBin(NULL)
    ,m_vehLen(0)
{
    m_vehEdge = new Uint8[8192];
    m_filteredEdge = new float[8192];
}


AuxAxleDetector::~AuxAxleDetector()
{
    if(m_vehEdge != NULL)
        delete[] m_vehEdge;
    if(m_filteredEdge != NULL)
        delete[] m_filteredEdge;
}


void AuxAxleDetector::ImproveAxleCandidates(Uint16 offset, AxleCandidates& aCand)
{
	for(AxleCandidates::iterator it = aCand.begin(); it != aCand.end(); ++it)
	{
		Int16 left = it->lEdge - offset;
		Int16 right = it->rEdge - offset;
		Int16 middle = it->minLoc - offset;
		//check if coordinates become negative after this
		if ((left < 0) || (middle < 0) || (right < 0))
			continue;


		//check if same or higher edge nearer to the minLoc
		Uint16 lastLeft = left, lastRight = right;
		for(Uint16 j = left; j < middle; ++j)
		{
			if(m_vehEdge[j] > m_vehEdge[left])
				lastLeft = j;
		}
		for(Uint16 j = right; j > middle; --j)
		{
			if(m_vehEdge[j] > m_vehEdge[right])
				lastRight = j;
		}

		//update coordinates
		it->lEdge = lastLeft + offset;
		it->rEdge = lastRight + offset;
	}
}

void AuxAxleDetector::FindAxleCandidates(AxleCandidates& auxCandidates)
{
    if (m_vehEdge==NULL)
		return;

	std::vector<float> filteredEdge;
	//perform low pass filtering of the vehicle bottom edge
	HanFilter hf;
    hf.SetInputData(&m_vehEdge[0], m_vehLen);
	Uint16 offset = 0;
	if(offset == 0) // input is to small for processing
		return;
	
	AxleCandidates raCand; //real axle candidates
	AxleCandidates aaCand; //auxiliary axle candidates
	FindPeaksManual(filteredEdge, raCand, aaCand);

	ImproveAxleCandidates(offset, raCand);
	ImproveAxleCandidates(offset, aaCand);

	Uint16 AxleHalfWidth1 = 0, AxleHalfWidth2 = 0; //two biggest axle halfwidth values
	for(AxleCandidates::const_iterator it = raCand.begin(); it != raCand.end(); ++it)
	{
		Uint16 AxleHalfW = Min(it->minLoc - it->lEdge, it->rEdge - it->minLoc);
		//if new axle halfwidth greater than biggest update both
		if(AxleHalfW > AxleHalfWidth1)
		{
			AxleHalfWidth2 = AxleHalfWidth1;
			AxleHalfWidth1 = AxleHalfW;
		}
		//if new axle halfwidth greater is bigger than second by size update only one
		else if(AxleHalfW > AxleHalfWidth2)
		{
			AxleHalfWidth2 = AxleHalfW;
		}
		else
		{//do nothing
		}
	}

	if(AxleHalfWidth1 == 0 || AxleHalfWidth2 == 0)
		return;

	for(AxleCandidates::const_iterator it = aaCand.begin(); it != raCand.end(); ++it)
	{
		Uint16 indLeft = it->lEdge;
		Uint16 indRight = it->rEdge;
		Uint16 indMin = it->minLoc;

		if ((indRight - indLeft) < MIN_TYRE_WIDTH)
			continue; //candidate width too narrow
		if (filteredEdge[indMin] > MAX_LIFTED_HEIGHT)
			continue; //candidate position too high
		
		float leftH  = filteredEdge[indLeft] - filteredEdge[indMin];
		float rightH = filteredEdge[indRight] - filteredEdge[indMin];
		float smallerEdge = Min(leftH, rightH);

		if(smallerEdge < MIN_TYRE_RADIUS)
			continue; //candidate too small to be tyre

		float biggerEdge = Max(leftH, rightH);

		float edgeRatio = biggerEdge/smallerEdge;
		if(edgeRatio > MAX_EDGE_HEIGHT_RATIO)
			continue; //candidate edge heights too disproportional

		//calculate half of the axle candidate radius
		Uint16 halfRadius = Min(indMin - indLeft, indRight - indMin);
		bool checker = false;

		float axleRatio = static_cast<float>(AxleHalfWidth1)/static_cast<float>(AxleHalfWidth2);

		float widthPercentage = (filteredEdge[indMin] > 10.0f)? WIDTH_PERCENTAGE2 : WIDTH_PERCENTAGE;
		if(axleRatio >= MAIN_AXLE_RATIO)
		{
			//there is a big difference between two greatest vehicle axles
			//first, compare with smaller real axle
			Uint16 greaterRadius = Max(halfRadius, AxleHalfWidth2);
			Uint16 smallerRadius = Min(halfRadius, AxleHalfWidth2);
			if(smallerRadius > (greaterRadius*widthPercentage))
				checker = true;
		}
		//compare with bigger real axle
		Uint16 greaterRadius = Max(halfRadius, AxleHalfWidth1);
		Uint16 smallerRadius = Min(halfRadius, AxleHalfWidth1);
		if(smallerRadius > (greaterRadius*widthPercentage))
			checker = true;
		
		if(!checker)
			continue; //if not commensurable with either of two real axles

		AxleCandidate axleC(indLeft-offset, indRight-offset, indMin-offset);
		auxCandidates.push_back(axleC);
	}
}
