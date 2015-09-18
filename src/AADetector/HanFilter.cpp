#include "HanFilter.h"

const float  HAN40[40] = {};
const float  HAN30[30] = {};
const float  HAN20[20] = {};

HanFilter::HanFilter()
	:m_lenIn(0)
	,m_lenOut(0)
	,m_windowSz(0)
	,m_valid(false)
	,m_inPtr(NULL)
	,m_outPtr(NULL)
    ,m_hanWin(NULL)
{}

bool HanFilter::SetInputData(Uint8* input, Uint16 inputLen)
{
	m_valid = true;
	m_lenIn = inputLen;
    m_inPtr = input;
	if(inputLen < 400)
	{
		//reset
        m_inPtr = NULL;
		m_lenIn = 0;
		m_valid = false;
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
	return m_valid;
}

bool HanFilter::SetOutputStorage(float *output, Uint16 availableLen)
{
	if((m_valid) && ((m_lenIn + m_windowSz - 1) <= m_lenOut))
	{
		m_outPtr = output;
		m_lenOut = availableLen;
	}
	else
	{
		m_valid = false;
	}
	return m_valid;
}

bool HanFilter::IsFilterable()
{
	return m_valid;
}

Uint16 HanFilter::GetFilterOffset()
{
	return ((m_windowSz/2) - 1);
}

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
		while(outInd < (m_lenIn + m_windowSz - 1))
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
	}
}
