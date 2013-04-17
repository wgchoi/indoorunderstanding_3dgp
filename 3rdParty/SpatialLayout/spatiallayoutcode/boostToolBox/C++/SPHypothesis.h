// SPHypothesis.h: interface for the CSPHypothesis class.
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_SPHYPOTHESIS_H__ECE6F8CB_75B0_4E7D_A228_5733F90B4B1B__INCLUDED_)
#define AFX_SPHYPOTHESIS_H__ECE6F8CB_75B0_4E7D_A228_5733F90B4B1B__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#include "IWeakHypothesis.h"
#include <vector>

class CSPHypothesis : public IWeakHypothesis  
{
public:
	CSPHypothesis();

	virtual ~CSPHypothesis();

  double Predict(double * in_Sample);

  void   PredictVector(double **in_vSamples, int in_iTotalSamples, double *out_vPredictions);

  bool   LoadFromFile(FILE* in_File);

  bool   LoadFromString(const char* Data);

protected:

  std::vector <int> m_vDims;
  std::vector <double> m_vThresholds;
  std::vector <double> m_vSignums;

};

#endif // !defined(AFX_SPHYPOTHESIS_H__ECE6F8CB_75B0_4E7D_A228_5733F90B4B1B__INCLUDED_)
