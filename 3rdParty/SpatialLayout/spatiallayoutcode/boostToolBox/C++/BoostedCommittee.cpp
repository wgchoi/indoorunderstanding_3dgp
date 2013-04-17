// BoostedCommittee.cpp: implementation of the CBoostedCommittee class.
//
//////////////////////////////////////////////////////////////////////

#include "BoostedCommittee.h"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CBoostedCommittee::CBoostedCommittee()
{

}

CBoostedCommittee::~CBoostedCommittee()
{

}

double CBoostedCommittee::Predict(double * in_Sample)
{
  double final_prediction = 0;
  for (int i = 0; i < m_vWeights.size(); i++)
  {
    final_prediction += m_vWeights[i] * m_vHypotheses[i].Predict(in_Sample);
  }
  return final_prediction;
}

bool CBoostedCommittee::LoadFromFile(FILE* in_File)
{
  int TotalHypothesis;

  if(!fscanf(in_File, "%d", &TotalHypothesis))
    return false;

  m_vHypotheses.resize(TotalHypothesis);
  m_vWeights.resize(TotalHypothesis);

  for (int i = 0; i < TotalHypothesis; i++)
  {
    float WeightsBuff;
    if(!fscanf(in_File, "%f", &WeightsBuff))
      return false;
    m_vWeights[i] = WeightsBuff;
    if(!m_vHypotheses[i].LoadFromFile(in_File))
      return false;
  }
  
  return true;
}

bool CBoostedCommittee::LoadFromString(const char* Data)
{
  int TotalHypothesis;

  if(!sscanf(Data, "%d", &TotalHypothesis))
    return false;

  m_vHypotheses.resize(TotalHypothesis);
  m_vWeights.resize(TotalHypothesis);

  for (int i = 0; i < TotalHypothesis; i++)
  {
    float WeightsBuff;
    if(!sscanf(Data, "%f", &WeightsBuff))
      return false;
    m_vWeights[i] = WeightsBuff;
    if(!m_vHypotheses[i].LoadFromString(Data))
      return false;
  }
  
  return true;
}