// IWeakHypothesis.h: interface for the IWeakHypothesis class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_IWEAKHYPOTHESIS_H__BEFE8AF2_DE45_4A36_AC22_525366B77ED0__INCLUDED_)
#define AFX_IWEAKHYPOTHESIS_H__BEFE8AF2_DE45_4A36_AC22_525366B77ED0__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

class IWeakHypothesis  
{
public:

//	virtual ~IWeakHypothesis() = 0;

  virtual double Predict(double * in_Sample) = 0;

  virtual void   PredictVector(double **in_vSamples, int in_iTotalSamples, double *out_vPredictions) = 0;

};

#endif // !defined(AFX_IWEAKHYPOTHESIS_H__BEFE8AF2_DE45_4A36_AC22_525366B77ED0__INCLUDED_)
