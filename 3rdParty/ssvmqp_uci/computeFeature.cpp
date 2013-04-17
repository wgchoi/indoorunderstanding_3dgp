/*
 *  computeFeature.cpp
 *  
 *
 *  Created by Chaitanya Desai on 3/6/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <math.h>
#include <sys/types.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//outputs
	double *Feature_pairwise, *Feature_local;
	
	//inputs 
	
	double *Detections; // BBoxes with class labels
	double *Scores; // the detection scores
	
	//other local variables
	int numD; //number of detections 
	int numClasses =21;
	int 	d_ij_size=7;// size of the spatial feature vector
	int i, j, p, cls_i, cls_j,  start, spatial[7];
	double i_cent_x, i_cent_y, j_cent_x, j_cent_y, height_i, width_i, height_j, width_j, ua, ov, iw, ih;
	double bi[4];
	

	Detections = mxGetPr(prhs[0]);
	numD = mxGetM(prhs[0]);
   	Scores = mxGetPr(prhs[1]);
    
    
 
	plhs[0] = mxCreateDoubleMatrix(numClasses*numClasses*d_ij_size, 1, mxREAL);
	Feature_pairwise =mxGetPr(plhs[0]);
	//initialize the pairwise feature to all zeros
	for (i=0; i < numClasses*numClasses*d_ij_size; i++)
	{
		Feature_pairwise[i] = 0;
	}
	
	plhs[1] = mxCreateDoubleMatrix(numClasses*2, 1, mxREAL);
	Feature_local =mxGetPr(plhs[1]);
	//initialize the local feature to all zeros
	for (i=0; i < numClasses*2; i++)
	{
		Feature_local[i]= 0;
	}
	
	
	// loop over all pairs of instanced detections and add the appropriate 
	for (i=0; i < numD; i++)
	{
		
			//get the center of BB i
			i_cent_x = ( Detections[0*numD + i] +  Detections[2*numD + i])/2 ;
			i_cent_y = ( Detections[1*numD + i] +  Detections[3*numD + i])/2;
			height_i = Detections[3*numD + i]- Detections[1*numD + i]+1;
			width_i =  Detections[2*numD + i]- Detections[0*numD + i]+1;

			//get the class for detection i
			cls_i = Detections[4*numD + i];
			for (j=0; j < numD; j++)
			{
				// if j was one of the instanced detections and is not i
				if (j != i)
				{
					//get the center of BB j
					j_cent_x = (Detections[0*numD + j] + Detections[2*numD + j])/2;
					j_cent_y = (Detections[1*numD + j] + Detections[3*numD + j])/2;
					height_j = Detections[3*numD + j]- Detections[1*numD + j]+1;
					width_j =  Detections[2*numD + j]- Detections[0*numD + j]+1;

					//get the class for detection j
					cls_j = Detections[4*numD + j];
					// construct i's spatial feature w.r.t j
					
					//get the overlap between i and j
					for (p=0;  p< 4; p++)
					{
						bi[p] =0;
					}	
		
					ov= 0;
				
					if (Detections[0*numD + i] >  Detections[0*numD + j])
						bi[0] = Detections[0*numD + i];
					else
						bi[0] =  Detections[0*numD + j];
				
					if (Detections[1*numD + i] >  Detections[1*numD + j])
						bi[1] = Detections[1*numD + i];
					else
						bi[1] =  Detections[1*numD + j];
				
					if (Detections[2*numD + i] <  Detections[2*numD + j])
						bi[2] = Detections[2*numD + i];
					else
						bi[2] =  Detections[2*numD + j];
				
					if (Detections[3*numD + i] <  Detections[3*numD + j])
						bi[3] = Detections[3*numD + i];
					else
						bi[3] =  Detections[3*numD + j];
				
		
					
					iw = bi[2] - bi[0] +1;
					ih = bi[3] - bi[1] +1;
					if (iw > 0 && ih > 0)
					{
						//compute overlap as area of intersection / area of union
						ua =  (Detections[2*numD + i]- Detections[0*numD + i] +1)*(Detections[3*numD + i]- Detections[1*numD + i] +1)
							+ (Detections[2*numD + j]- Detections[0*numD + j] +1)*(Detections[3*numD + j]- Detections[1*numD + j] +1)
							- iw*ih;
							//fprintf(debug, "ua = %f\n", ua)	;
						ov = iw*ih/ua;	
						//fprintf(debug, "Overlap(%d, %d) = %f\n", j, i, ov);  
						//fflush(debug);
					}
				
					for (p=0; p < 7; p++)
					{
						spatial[p] =0;
					}
				
				
		
					//on top of 
					if(fabs(i_cent_x - j_cent_x)<= width_i/2 && fabs(i_cent_y - j_cent_y)<= height_i/2)     
					{
						spatial[0] = 1;
						//fprintf(debug," j on top of i \n");
					}	

					//above
					if(j_cent_y < (i_cent_y - height_i/2) && j_cent_y >= (i_cent_y - 1.5*height_i) && fabs(i_cent_x - j_cent_x)<= width_i/2)
					{
						spatial[1] = 1;
						//fprintf(debug,"j above i\n");
					}	
                        
					//below
					if (j_cent_y > (i_cent_y + height_i/2) && 
							j_cent_y <= (i_cent_y + 1.5*height_i) &&
                             fabs(i_cent_x - j_cent_x)<= width_i/2)
					{   
						spatial[2] = 1; 
						//fprintf(debug,"j below i\n");
					}	
                        
                        
					//next to
					if (fabs(i_cent_y - j_cent_y) <= height_i/2 &&
                            fabs(i_cent_x - j_cent_x) > width_i/2 &&
							fabs(i_cent_x - j_cent_x) <= 1.5*width_i) 
					{
						spatial[3] = 1;
						//fprintf(debug,"j next to i \n");
					}
                        
                     
                    
					//near relationship
					if (fabs(i_cent_x - j_cent_x) > width_i/2 &&
                            fabs(i_cent_x - j_cent_x) <= 1.5*width_i &&    
                            fabs(i_cent_y - j_cent_y) > height_i/2 &&
                            fabs(i_cent_y -j_cent_y) <= 1.5*height_i)
					{
								spatial[4]=1;
								//fprintf(debug,"j near i \n");
					}			
                     
                    
					// far away     
					if (fabs(i_cent_x - j_cent_x) > 1.5*width_i || fabs(i_cent_y - j_cent_y) > 1.5*height_i)
                    {
                        spatial[5] = 1;
                    }
                    else{ 
                        spatial[4] = 1;	 	
                    }
						//fprintf(debug, " j far from i \n");
										

					// turn on the overlap bin if required
					if (ov > .5)
						spatial[6]=1;
				
					start =  (cls_i - 1)*numClasses*d_ij_size + (cls_j-1)*d_ij_size;
					// add the spatial term to the pairwise feature in the appropriate slot
					for (p=0; p< d_ij_size; p++)
					{
						Feature_pairwise[start+p] += spatial[p]; 
					}
					
				}
			}
			Feature_local[2*cls_i - 2] += Scores[i];
			Feature_local[2*cls_i -1] += 1;
		
	}
}

