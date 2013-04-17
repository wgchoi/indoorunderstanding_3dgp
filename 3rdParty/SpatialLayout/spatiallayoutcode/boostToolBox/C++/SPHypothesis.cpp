// SPHypothesis.cpp: implementation of the CSPHypothesis class.
//
//////////////////////////////////////////////////////////////////////

#include "SPHypothesis.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CSPHypothesis::CSPHypothesis()
{

}

CSPHypothesis::~CSPHypothesis()
{

}


double CSPHypothesis::Predict(double * in_Sample)
{  
  for (int i = 0; i < m_vDims.size(); i++)
  {
    if(!(m_vSignums[i] * in_Sample[m_vDims[i]] > m_vSignums[i] * m_vThresholds[i]))
      return 0;
  }
  return 1;
}


void CSPHypothesis::PredictVector(double **in_vSamples, int in_iTotalSamples, double *out_vPredictions)
{
  for(int n = 0; n < in_iTotalSamples; n++)
  {
    out_vPredictions[n] = Predict(in_vSamples[n]);
  }

}

bool CSPHypothesis::LoadFromFile(FILE* in_File)
{
  int N;
  if(!fscanf(in_File, "%d", &N))
    return false;

  m_vThresholds.resize(N);
  m_vSignums.resize(N);
  m_vDims.resize(N);

  for (int i = 0; i < N; i++)
  {
    float DimBuffer,
          ThreshBuff,
          SignumBuff;
    if(!fscanf(in_File, "%f %f %f", &DimBuffer, &ThreshBuff, &SignumBuff))
      return false;
    m_vDims[i] = (int) DimBuffer - 1;
    m_vThresholds[i] = ThreshBuff;
    m_vSignums[i] = SignumBuff;
  }

  return true;
}

bool CSPHypothesis::LoadFromString(const char* Data)
{
  int N;
  if(!sscanf(Data, "%d", &N))
    return false;

  m_vThresholds.resize(N);
  m_vSignums.resize(N);
  m_vDims.resize(N);

  for (int i = 0; i < N; i++)
  {
    float DimBuffer,
          ThreshBuff,
          SignumBuff;
    if(!sscanf(Data, "%f %f %f", &DimBuffer, &ThreshBuff, &SignumBuff))
      return false;
    m_vDims[i] = (int) DimBuffer - 1;
    m_vThresholds[i] = ThreshBuff;
    m_vSignums[i] = SignumBuff;
  }

  return true;
}