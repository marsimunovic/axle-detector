#ifndef HANFILTER_H
#define HANFILTER_H

#include "general.h"

class HanFilter
{
public:
	HanFilter();
	bool IsFilterable();
	bool SetInputData(Uint8* input, Uint16 inputLen);
	bool SetOutputStorage(float *output, Uint16 availableLen);
	void Filter();
	Uint16 GetFilterOffset();
private:
	Uint16 m_lenIn;    //
	Uint16 m_lenOut;   //len of available outstorage
	Uint16 m_windowSz; //size of Hanning window
	bool   m_valid;   //signal filterable?
	
	Uint8* m_inPtr;  //signal input
	float* m_outPtr; //filter output
	float const* m_hanWin; //han window coeff
};

#endif//HANFILTER_H