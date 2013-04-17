// Example.cpp : Defines the entry point for the console application.
//

#include "../BoostedCommittee.h"

#include "stdafx.h"

int main(int argc, char* argv[])
{
  double Sample[25] = { 192.000000, 18, 18, 1.745889, 1.353338, 67.844268, 32.011536, 21.845710, 73.756309, 0.000000, 0.000000, 0.000000, 0.000000, 0.479167, 0.854846, 0, 0.296150, 0.113008, 0.372667, 0.487427, 0.475426, 0.497585, 0.589379, 0.533333, 0.611860};
  CBoostedCommittee Boost;

  //Opening file saved in MATLAB
  FILE *fid = fopen("RealBoost.txt","r");

  //Loading classifier
  Boost.LoadFromFile(fid);

  //Using classifier, the signum of output is the predicted class {-1,+1}
  double Result = Boost.Predict(Sample);

	printf("Result is %f \n", Result);
	return 0;
}

