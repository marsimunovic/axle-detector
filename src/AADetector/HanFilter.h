#ifndef HANFILTER_H
#define HANFILTER_H

#include "general.h"

class HanFilter
{
public:
	HanFilter();
	bool IsFilterable();
    bool SetInputData(Uint8 const* input, Uint16 inputLen);
	bool SetOutputStorage(float *output, Uint16 availableLen);
	void Filter();
	Uint16 GetFilterOffset();
private:
    Uint16 m_lenIn;    //len of signal input
	Uint16 m_lenOut;   //len of available outstorage
	Uint16 m_windowSz; //size of Hanning window
    bool   m_validIn;   //signal filterable?
    bool   m_validOut;

    Uint8 const* m_inPtr;  //signal input
	float* m_outPtr; //filter output
	float const* m_hanWin; //han window coeff
};

#endif//HANFILTER_H
