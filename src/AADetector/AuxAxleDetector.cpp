#include "AuxAxleDetector.h"
#include "AAInputs.h"
#include "HanFilter.h"

#include <QtGui>

#include <fstream>
#include <set>
#include <iostream>

Uint16 const  ARR_SIZE = 8192;
Uint8 const  NOISY_ROWS = 3;
Uint8 const  MIN_PIX_REPETITION = 40;
Uint8 const  EDGE_DIFF = 5; //filtering treshold for edge detection
float const  LOCAL_PI = 3.14159265f;

/**
 * @brief AuxAxleDetector::LoadProfileDetails - load image to appropriate data structure
 * @param imageName - file path to image
 *
 * This is QT specific function used for loading test profiles to program
 * In real program image class that owns AuxAxleDetector will supply binary image
 */
void AuxAxleDetector::LoadProfileDetails(std::string const &imageName)
{
    QImage* image = new QImage();
    QImageReader* reader = new QImageReader(imageName.c_str());
    reader->read(image);

//    std::ofstream myfile ("example3.txt");
    if(image && reader)
    {
        std::vector<Uint16>().swap(m_emptySegments);
        m_image.Allocate(image->height(), image->width());

        //if (myfile.is_open())
        //{
            for(int i = 0; i < image->height(); ++i)
            {
                unsigned char *cpy = (unsigned char*) image->scanLine(i);
                for(int j = 0; j < image->width(); ++j)
                {
                    m_image(i,j) = (cpy[j*4])? 1: 0;
                    //std::cout << static_cast<int>(m_imageBin[i*image->width()+j]) << std::endl;
                    //myfile << ((cpy[j*4])? '1': '0');
                }
          //      myfile << '\n';
            }
    }
       // m_image.AssignAllocatedArray(m_imageBin, image->height(), image->width());
    //}
    //myfile.flush();
    //myfile.close();
    delete image;
    delete reader;

}

/**
 * @brief AuxAxleDetector::CountAuxAxles - runs processing code on image
 * @return - number of auxiliary axles found in vehicle profile
 */
Uint32 AuxAxleDetector::CountAuxAxles()
{
    std::vector<Uint8> cropInfo = CropImage();
    Uint32 axleCount = 0;
    if(DetectEdge())
    {
        AxleCandidates auxCandidates;
        FindAxleCandidates(auxCandidates);
        axleCount = DetectAxles(auxCandidates, cropInfo);
    }
    return axleCount;
}

/**
 * @brief AuxAxleDetector::CropImage - crops image to appropriate dimensions
 * @return - information about cropped rows
 *
 * Finds start and end of the vehicle and cuts only fixed lower part of an image
 * in order to decrease processing time
 * NOTE: Lower three rows (especially the lowest) can have increased noise causing
 * over- and underdetecting of lifted axle candidates. If noise is above some fixed
 * treshold whole row is erased and is no longer used in axle detection process
 */
std::vector<Uint8> AuxAxleDetector::CropImage()
{
    Uint16 height = m_image.Rows();
    Uint16 width  = m_image.Cols();
    Uint16 top, firstCol, lastCol;

    //take only lower part of the vehicle for axle detection
    if(height > LOWER_PART)
        top = height-LOWER_PART;
    else
        top = height;

    //find front side of the vehicle
    firstCol = 0;
    Uint16 countFront = 0;

    for(int j = 0; j < width; ++j)
    {
        Uint16 sum = 0;
        for(int i = top; i < height; ++i)
            sum += (m_image(i,j) == 0);
        if (sum > 5)
            ++countFront;
        else
            countFront = 0;
        if (countFront > MIN_PIX_REPETITION)
        {
            firstCol = j - MIN_PIX_REPETITION;
            break;
        }
    }
    //find back side of the vehicle
    lastCol = firstCol;
    Uint16 countBack = 0;
    for(int j = width-1; j > firstCol; --j)
    {
        Uint16 sum = 0;
        for(int i = top; i < height; ++i)
            sum += (!m_image(i,j));
        if (sum > 5)
            ++countBack;
        else
            countBack = 0;
        if (countBack > MIN_PIX_REPETITION)
        {
            lastCol = j + MIN_PIX_REPETITION - 1;
            break;
        }
    }
    //clear vector before using
    std::vector<Uint16>().swap(m_emptySegments);
    //init crop info vector
    std::vector<Uint8> cropInfo(NOISY_ROWS, 0);
    //analyse lower rows for noise
    for(int i = height - NOISY_ROWS; i < height; ++i)
    {
        Uint16 pixFrequency = 0;
        Uint16 start = firstCol, stop = firstCol+1;
        for(int j = firstCol+1; j <= lastCol; ++j)
        {
            stop = j;
            if(m_image(i,j) != m_image(i,j-1))
            {
                ++pixFrequency;
                if((i == height-1) && (stop-start > 30))
                {
                    m_emptySegments.push_back(start);
                    m_emptySegments.push_back(stop-1);
                }
                start = j+1;
            }
        }
        if((i == height-1) && (stop-start > 30))
        {
            m_emptySegments.push_back(start);
            m_emptySegments.push_back(stop);
        }
        if(pixFrequency > 20)
            cropInfo[height - i - 1] = 1;
    }
    Uint8 shift2 = cropInfo[2];
    Uint8 shift3 = cropInfo[2] + cropInfo[1];
    Uint8 decrease = shift3 + cropInfo[0];
    //perform erasing of the noisy rows
    if(shift3)
    {
        for(int n = 0; n < width; ++n)
        {
            if(shift2)
            {
                //cpy row -2 to -3
                m_image(height-3, n) = m_image(height-2, n);
                //m_imageBin[(height-3)*width+n] = m_imageBin[(height-2)*width+n];
            }
            //cpy up one ore two
            //m_imageBin[(height-1-shift3)*width+n] = m_imageBin[(height-1)*width+n];
            m_image(height-1-shift3, n) = m_image(height-1, n);
        }
    }
    if(decrease)
    {
        //shorten image size
        height = height - decrease;
    }
    //perform image redimensioning
    m_image.SetNewOrigin(top, firstCol, height - top, lastCol-firstCol+1);
    //SetNewOrigin(Int32 row, Int32 col, Int32 new_rows, Int32 new_cols);
    return cropInfo;
}

/**
 * @brief AuxAxleDetector::DetectEdge - detecting the bottom part of the vehicle
 * @return true if processing should be continued, false if profile should be discarded
 *
 * Simple detection of the lower part of the vehicle, finds border between white and black
 * pixels, uses filtration if there are small pixelizations around real border
 *
 */
bool AuxAxleDetector::DetectEdge()
{
    Uint16 imHeight = m_image.Rows();
    Uint16 imWidth = m_image.Cols();
	Uint8 const BLOCK_SIZE = 4;

    for(Uint16 j = 0; j < imWidth; ++j)
	{
		bool updated = false;
		for(Uint16 i = imHeight - 1; i >= BLOCK_SIZE; --i)
		{
            if (m_image(i,j) == 0)
			{
				if(!updated)
				{
					updated = true;
					m_vehEdge[j] = imHeight - 1 - i;
                    if(j >= 2)
                    {
                        if (m_vehEdge[j] == m_vehEdge[j-2])
                            m_vehEdge[j-1] = m_vehEdge[j];
                    }
				}
                Uint8 sum = m_image(i, j) + m_image(i-1, j)
                            + m_image(i-2, j) + m_image(i-3, j);
				//if two of four pixels are black
                if(sum <= (BLOCK_SIZE/2))
				{
                    if(m_vehEdge[j] + EDGE_DIFF > (imHeight - 1 - i))
						m_vehEdge[j] = imHeight - 1 - i;
					break;
				}
			}
		}
	}
    m_vehLen = imWidth;
    if(m_vehLen < MIN_ACCEPTED_LEN)
        return false;
    else
        return true;
}


/**
 * @brief AuxAxleDetector::FindPeakCoordinates - detects maxima and minima in filtered edge
 * @param ra - placeholder for real axle candidates coordinates
 * @param aa - placeholder for auxiliary axle candidates coordinates
 */
void AuxAxleDetector::FindPeakCoordinates(AxleCandidates& ra, AxleCandidates& aa)
{
    float maxCand = m_filteredEdge[0]; //current peak candidate
	Uint16 ind = 0; //index of the current peak candidate
	Uint16 n = 1; //current position in signal
    Uint16 N = m_vehLen;
	std::vector<Uint16> peaks; //peak candidates indices
	while(n < N)
	{
        if(maxCand > m_filteredEdge[n])
		{
			peaks.push_back(ind);
			//find next maxCand
            while((m_filteredEdge[n-1] > m_filteredEdge[n]) && (n < N))
			{
				//do nothing 
				n += 1;
			}
            maxCand = m_filteredEdge[n];
			ind = n;
		}
		else
		{
            maxCand = m_filteredEdge[n];
			ind = n;
		}
		n += 1;
	}

	Uint16 M = peaks.size();
	//for each pair of maxima find minima in between
	
	for(Uint16 i = 1; i < M; ++i)
	{
		Uint16 minLoc = peaks[i-1];
        for(Uint16 j = peaks[i-1] + 1; j <= peaks[i]; ++j)
		{
            if (m_filteredEdge[j] < m_filteredEdge[minLoc])
				minLoc = j;
		}
        Uint16 shift = 1;
		//if there are more minima locations choose central one
        //for(int m = 0; m < 5; ++m)
            //std::cout << m_filteredEdge[minLoc+m] << std::endl;
		while(minLoc + shift < peaks[i])
		{
            if(abs(m_filteredEdge[minLoc] - m_filteredEdge[minLoc + shift]) < 0.0001)
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
        if (m_filteredEdge[newCandidate.lEdge] < m_filteredEdge[newCandidate.rEdge])
		{
			//search smaller value on the right side of the "valley"
            while(m_filteredEdge[newCandidate.lEdge] < m_filteredEdge[newCandidate.rEdge]-1)
				newCandidate.rEdge -= 1;
		}
		//if left peak is higher than right
        else if (m_filteredEdge[newCandidate.lEdge] > m_filteredEdge[newCandidate.rEdge])
		{
			//search smaller value on the left side of the "valley"
            while(m_filteredEdge[newCandidate.lEdge + 1] > m_filteredEdge[newCandidate.rEdge])
				newCandidate.lEdge += 1;
		}
		//if both are equal
		else
		{
			//do nothing
		}

        if(m_filteredEdge[newCandidate.minLoc] > 0.5)
			//this is auxiliary axle candidate
			aa.push_back(newCandidate);
		else
			//this is real axle candidate
			ra.push_back(newCandidate);
	}
}

/**
 * @brief AuxAxleDetector::DetectAxles - performs elimination steps in order to identify auxiliary axes
 * @param aCand - vector of axle candidates
 * @param cropInfo - information about cropped rows
 * @return - number of detected auxiliary axles
 */
Uint32 AuxAxleDetector::DetectAxles(AxleCandidates& aCand, std::vector<Uint8> cropInfo)
{
	ImproveRawAxleCandidates(aCand);

    Uint16 imHeight = m_image.Rows();
    Uint16 imWidth  = m_image.Cols();

    Uint32 totalAuxCount = 0;

	for(AxleCandidates::iterator it = aCand.begin(); it != aCand.end(); ++it)
	{
		Uint8 leftH = m_vehEdge[it->lEdge]; //left edge height
		Uint8 rightH = m_vehEdge[it->rEdge]; //right edge height
        Uint16 cntry = Min(leftH, rightH); //center of the axle candidate
        Uint16 cntrx = it->minLoc; //center of the axle candidate
		Uint8  minPoint = m_vehEdge[cntrx];
        //width of the smaller detected axle candidate radius
		Uint16 axleHWidth = Min(it->rEdge - it->minLoc, it->minLoc - it->lEdge);
        //width of the bigger detected axle candidate radius
		Uint16 axleHWidth2 = Max(it->rEdge - it->minLoc, it->minLoc - it->lEdge);
        //compares detected distances from axle center(minima) to left and right edge
		float hAxleRatio = static_cast<float>(axleHWidth2*100)/static_cast<float>(axleHWidth);

        Uint16 axleHHeight = cntry - minPoint; //half of the axle height
        Uint16 start = cntrx - axleHWidth; //axle most left index
        Uint16 stop  = cntrx + axleHWidth; //axle most right index
        Uint16 blkCont1 = 100, blkCont2 = 100; //black contribution in central and row bellow
        //relative position of an axle in vehicle profile
        Uint32 relPosition = static_cast<float>((cntrx+1)*100)/m_vehLen;

        //check if auxiliary axle has min point at the ground due to cutting
        //of the lowes image row (after noise filtering)
        bool emptyUnderZero = false;
        if((minPoint == 0) && (cropInfo.size() > 0) && (cropInfo[0] != 0))
        {
            for(Uint16 ind = 1; ind < m_emptySegments.size(); ind += 2)
            {
                if((m_emptySegments[ind] > it->rEdge) && (m_emptySegments[ind-1] < it->lEdge))
                {
                    emptyUnderZero = true;
                    break;
                }
            }
        }

        std::set<Uint16> leftDistances, rightDistances;
        //perform some simple checks (FIXED TRESHOLDS)
        if(((m_vehEdge[cntrx] > 0) || emptyUnderZero ) && (abs(leftH-rightH) <= MAX_EDGE_HEIGHT_DIFF) &&
			(axleHWidth > MIN_AXLE_HWIDTH) && (axleHHeight >= MIN_AXLE_HHEIGHT)
			&& (hAxleRatio < 200))
		{
            //additional simple checks (FIXED TRESHOLDS)
            if((cntry < MAX_CNTRY) && ((relPosition > MIN_REL_POS) || (cntrx > MIN_POS_IND)))
			{
				Uint32 areaOver = 0;
				bool error = false;
                //calculate area of axle candidate starting from most left point
                //to most right point, and from min point to center of an axle
				for(Uint16 i = imHeight-1-minPoint; i >= imHeight-1-cntry; --i)
				{
					bool empty = true;
					
					Uint16 areaPart1 = cntrx, areaPart2 = cntrx;
					//find most left position
                    for(Uint16 j = start-1; j <= stop+1; ++j)
					{
                        if(m_image(i,j)==0)
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
                        if(m_image(i,j)==0)
						{
							empty = false;
							areaPart2 = j;
							break;
						}
					}
                    //do not check lower three rows to avoid errors from noise
                    if((i < imHeight-3-minPoint) && ((areaPart1 > cntrx) || (areaPart2 < cntrx)))
                    {
                        //left side of the axle more right than minima
                        //right side of the axle more left than minima
                        error = true;
                        break;
                    }

					rightDistances.insert(areaPart2);
					if(empty)
						error = true;
                    //check if we have detected empty row in axle candidate (not allowed)
					if(error)
					{
						Uint16 maxErrPixels = 2*axleHWidth;
						Uint16 blackPix = imWidth;
						for(Uint16 rowInd = 0; rowInd < imWidth; ++rowInd)
                            blackPix -= (m_image(i,rowInd) != 0);
						if(blackPix < maxErrPixels)
							break;
                        else
                            error = false;

					}
					
					areaOver += areaPart2 - areaPart1 + 1;
                    //calculate percentage of black pixels in row one bellow axle center
					if(i == imHeight-cntry-1)
					{
						Uint16 sum = 0;
						for(Uint16 posInd = areaPart1; posInd <= areaPart2; ++posInd)
                            sum += (m_image(i, posInd) == 0);
                        blkCont1 = sum*50/axleHWidth; // *100/(axleHWidth*2)
					}
                    //calculate percentage of black pixels in central row
					if(i == imHeight-cntry)
					{
						Uint16 sum = 0;
						for(Uint16 posInd = areaPart1; posInd <= areaPart2; ++posInd)
                            sum += (m_image(i, posInd) == 0);
                        blkCont2 = sum*50/axleHWidth; // *100/(axleHWidth*2)
					}

				}
                if(error)//if empty row in axle or strange shape of axle
					continue;

                //projected ellipse are (calculated from detected coordinates)
                float ellipseHArea = 0.5*(static_cast<float>(axleHWidth)-0.5)*axleHHeight*LOCAL_PI;
                //compare real area and projected area
                float ellipseRatio = static_cast<float>(areaOver)/ellipseHArea*100;
                //determine width variability of left and right side
				Uint16 rightVar = rightDistances.size();
				Uint16 leftVar  = leftDistances.size();
				Uint16 sideVar  = Min(leftVar, rightVar);

                if(sideVar == 0) //if side is straight line
                    continue;
                Uint8 cropCountSz = 0;
                for(Uint16 sz = 0; sz < cropInfo.size(); ++sz)
                    cropCountSz += cropInfo[sz];

                //for higher axle candidate use more rigorous constraints
                if(minPoint + cropCountSz > 8)
				{
					if(100.0f*static_cast<float>(sideVar)/
						static_cast<float>(axleHHeight) < 50)
						continue;
                    if(ellipseRatio < 90 || ellipseRatio > 115)
                        continue;
				}
                //final checking
				if((ellipseRatio >= 85) && (ellipseRatio <= 130) && 
					(blkCont1 > 85) && (blkCont2 > 85))
				{
                    //this is (with high probability) auxiliary axle
                    ++totalAuxCount;
				}
			}
		}

	}

    return totalAuxCount;
}


/**
 * @brief AuxAxleDetector::ImproveRawAxleCandidates - perform corrections on candidate
 *                                                    coordinates (using raw edge)
 * @param aCand - list of axle candidates
 */
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

/**
 * @brief AuxAxleDetector::AuxAxleDetector - default constructor
 */
AuxAxleDetector::AuxAxleDetector()
    :m_vehEdge(NULL)
    ,m_filteredEdge(NULL)
    ,m_vehLen(0)
{
    m_vehEdge = new Uint8[ARR_SIZE];
    m_filteredEdge = new float[ARR_SIZE];
}

/**
 * @brief AuxAxleDetector::~AuxAxleDetector - storage cleanup
 */
AuxAxleDetector::~AuxAxleDetector()
{
    if(m_vehEdge != NULL)
        delete[] m_vehEdge;
    if(m_filteredEdge != NULL)
        delete[] m_filteredEdge;
    //std::cout << "Releasing resources" << std::endl;
    //if(m_imageBin != NULL)
      //  delete[] m_imageBin;
}

/**
 * @brief AuxAxleDetector::ImproveAxleCandidates - perform corrections on candidate
 *                                                 coordinates (using filtered edge)
 * @param aCand - list of axle candidates, Hanning filter offset
 */
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
            if(m_vehEdge[j] >= m_vehEdge[left])
				lastLeft = j;
		}
		for(Uint16 j = right; j > middle; --j)
		{
            if(m_vehEdge[j] >= m_vehEdge[right])
				lastRight = j;
		}

		//update coordinates
		it->lEdge = lastLeft + offset;
		it->rEdge = lastRight + offset;
	}
}

/**
 * @brief AuxAxleDetector::FindAxleCandidates - finds auxiliary axle candidates using filtered edge
 * @param auxCandidates - placeholder for candidates
 */
void AuxAxleDetector::FindAxleCandidates(AxleCandidates& auxCandidates)
{
    if (m_vehEdge==NULL)
		return;

	//perform low pass filtering of the vehicle bottom edge
	HanFilter hf;
    std::vector<Uint8> tmpEdge;
    for(Uint16 i = 0; i < m_vehLen; ++i)
    {
        tmpEdge.push_back(m_vehEdge[i]);
    }
    hf.SetInputData(&m_vehEdge[0], m_vehLen);
    //std::vector<float> filteredEdge(ARR_SIZE, 0.0f);
    hf.SetOutputStorage(&m_filteredEdge[0], ARR_SIZE);
    if(hf.IsFilterable())
        hf.Filter();
    else
        return;

    Uint16 offset = hf.GetFilterOffset();
	if(offset == 0) // input is to small for processing
		return;
	
	AxleCandidates raCand; //real axle candidates
	AxleCandidates aaCand; //auxiliary axle candidates
    FindPeakCoordinates(raCand, aaCand);

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

    for(AxleCandidates::const_iterator it = aaCand.begin(); it != aaCand.end(); ++it)
	{
		Uint16 indLeft = it->lEdge;
		Uint16 indRight = it->rEdge;
		Uint16 indMin = it->minLoc;

		if ((indRight - indLeft) < MIN_TYRE_WIDTH)
			continue; //candidate width too narrow
        if (m_filteredEdge[indMin] > MAX_LIFTED_HEIGHT)
			continue; //candidate position too high
		
        float leftH  = m_filteredEdge[indLeft] - m_filteredEdge[indMin];
        float rightH = m_filteredEdge[indRight] - m_filteredEdge[indMin];
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

        float widthPercentage = (m_filteredEdge[indMin] > 10.0f)? WIDTH_PERCENTAGE2 : WIDTH_PERCENTAGE;
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
