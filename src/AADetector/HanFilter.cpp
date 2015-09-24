#include "HanFilter.h"

const float  HAN40[40] = {0.000000, 0.000332, 0.001320, 0.002937, 0.005142, 0.007879, 0.011075,
                          0.014649, 0.018507, 0.022550, 0.026673, 0.030770, 0.034733, 0.038462,
                          0.041858, 0.044834, 0.047313, 0.049230, 0.050537, 0.051199, 0.051199,
                          0.050537, 0.049230, 0.047313, 0.044834, 0.041858, 0.038462, 0.034733,
                          0.030770, 0.026673, 0.022550, 0.018507, 0.014649, 0.011075, 0.007879,
                          0.005142, 0.002937, 0.001320, 0.000332, 0.000000};
const float  HAN30[30] = {0.000000, 0.000806, 0.003187, 0.007031, 0.012159, 0.018331, 0.025258,
                          0.032616, 0.040061, 0.047246, 0.053834, 0.059517, 0.064030, 0.067160,
                          0.068763, 0.068763, 0.067160, 0.064030, 0.059517, 0.053834, 0.047246,
                          0.040061, 0.032616, 0.025258, 0.018331, 0.012159, 0.007031, 0.003187,
                          0.000806, 0.000000};
const float  HAN20[20] = {0.000000, 0.002850, 0.011100, 0.023840, 0.039710, 0.056980, 0.073770,
                          0.088280, 0.098920, 0.104550, 0.104550, 0.098920, 0.088280, 0.073770,
                          0.056980, 0.039710, 0.023840, 0.011100, 0.002850, 0.000000};

/**
 * @brief HanFilter::HanFilter
 */
HanFilter::HanFilter()
	:m_lenIn(0)
	,m_lenOut(0)
	,m_windowSz(0)
    ,m_validIn(false)
    ,m_validOut(false)
	,m_inPtr(NULL)
	,m_outPtr(NULL)
    ,m_hanWin(NULL)
{}

/**
 * @brief HanFilter::SetInputData - attach signal data to filter
 * @param input - signal data inputs
 * @param inputLen - length of an input signal
 * @return -is input initialization successfull
 */
bool HanFilter::SetInputData(const Uint8 *input, Uint16 inputLen)
{
    m_validIn = true;
	m_lenIn = inputLen;
    m_inPtr = input;
	if(inputLen < 400)
	{
		//reset
        m_inPtr = NULL;
		m_lenIn = 0;
        m_validIn = false;
	}
	else if(inputLen < 500)
	{
		m_windowSz = 20;
		m_hanWin = HAN20;
	}
	else if(inputLen < 700)
	{
		m_windowSz = 30;
		m_hanWin = HAN30;
	}
	else 
	{
		m_windowSz = 40;
		m_hanWin = HAN40;
	}
    return m_validIn;
}

/**
 * @brief HanFilter::SetOutputStorage - attach output storage for filter
 * @param output - place where filtered output is stored
 * @param availableLen - available output storage
 * @return - is output initialization successful
 */
bool HanFilter::SetOutputStorage(float *output, Uint16 availableLen)
{
    if((m_validIn) && ((m_lenIn + m_windowSz - 1) <= availableLen))
	{
		m_outPtr = output;
		m_lenOut = availableLen;
        m_validOut = true;
	}
	else
	{
        m_validOut = false;
	}
    return m_validOut;
}

/**
 * @brief HanFilter::IsFilterable - check if everything is ready for filtering
 * @return true if input and output are properly set
 */
bool HanFilter::IsFilterable()
{
    return (m_validIn && m_validOut);
}

/**
 * @brief HanFilter::GetFilterOffset - returns offset of filter (variable size depending on input len)
 * @return - offset
 */
Uint16 HanFilter::GetFilterOffset()
{
	return ((m_windowSz/2) - 1);
}

/**
 * @brief HanFilter::Filter - filter input data with appropriate filter and write result to output
 */
void HanFilter::Filter()
{
	if(IsFilterable())
	{
		Uint16 outInd = 0;
		while(outInd < m_windowSz)
		{
			Uint16 sigInd = outInd;
			float sum = 0;
			for(Uint16 i = 0; i <= outInd; ++i)
				sum += m_hanWin[i]*m_inPtr[sigInd-i];
			m_outPtr[outInd] = sum;
		
			++outInd;
		}
		while(outInd < m_lenIn)
		{
			Uint16 sigInd = outInd;
			float sum = 0;
			for(Uint16 i = 0; i < m_windowSz; ++i)
				sum += m_hanWin[i]*m_inPtr[sigInd-i];
			m_outPtr[outInd] = sum;

			++outInd;
		}
/*		while(outInd < (m_lenIn + m_windowSz - 1))
		{
			Uint16 sigInd = outInd;
			float sum = 0;
			for(Uint16 i = outInd - m_lenIn; i < m_windowSz; ++i)
			{
				sum += m_hanWin[i]*m_inPtr[sigInd-i];
			}
			m_outPtr[outInd] = sum;
			++outInd;
		}
*/
	}
}
