/*
 *  maximize.cpp
 *  
 *
 *  Created by Chaitanya Desai on 3/5/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */
#include <math.h>
#include <sys/types.h>
#include "mex.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	//output 
	double *Energies;
	int *J; // temp arrays to store non-instanced detections
    
	double *I; // final array to return
	int numD, entries;  // number of detections, entries per detection
	double E_max,  j_cent_x, j_cent_y, jmax_cent_x, jmax_cent_y, tmp,
	width_jmax, height_jmax, width_j, height_j, iw, ih, ua, ov; // temp variable to store maximum energy to compare with
	int numClasses=21;
	int first_ui, numUI, j_max, i,j, cls_j, cls_i, cls_j_max, start, stop,d_ij_size;
	double bi[4];
	int spatial[7];
	//input
	
	double *Scores, *Detections, *Loss, *Ws;
	FILE* debug;
	
	
	Detections = mxGetPr( prhs[0]);
	numD = mxGetM( prhs[0]);
	entries = mxGetN( prhs[0]);
	
	//fprintf(debug, "Num D = %d , num entries = %d \n", numD, entries);
	
	//Get the local energies
	Scores = mxGetPr(prhs[1]);	
	d_ij_size=7;
	//copy scores into an energy array that we eventually would like to return
	plhs[0] = mxCreateDoubleMatrix(numD, 1, mxREAL); //mxReal is our data-type
	// Energies that will be returned
	Energies = mxGetPr(plhs[0]);
	
	//get the pairwise weights
	Ws = mxGetPr(prhs[2]);
	
	//get local loss
	Loss = mxGetPr(prhs[3]);
	for (i =0; i < numD; i++)
	{
		Energies[i] = Scores[i];
	}
	//fprintf(debug, "Energies copied\n");
	
	//Allocate memory and assign output pointer for the instanced detections
	plhs[1] = mxCreateDoubleMatrix(numD,1, mxREAL);
	
	// array to store the instanced detections
	I  = mxGetPr(plhs[1]);
	
	// initially nothing is instanced
	for (i=0; i < numD; i++)
		I[i] = 0;
	//fprintf(debug, "I initialized \n");
    
    
	// array to store the uninstanced detections	
	J = (int *)mxCalloc(numD, sizeof(int));
	
	//initially everything is uninstanced
	for (i=0; i < numD; i++ )
		J[i] = 1;
	
	numUI = 0;
	for (j=0; j < numD; j++)
	{
		if (J[j] == 1)
			numUI++;
	}
	
	
	while (numUI > 0)
	{
		
		E_max = -1000000;
		// get the highest scoring un-instanced detection
		for (j = 0; j < numD; j++)
		{
			if (J[j]  == 1 && Energies[j] > E_max)
			{
				j_max = j;
				E_max = Energies[j];
			}
		}
		
		// reward from turning the highest scoring detection on is less that the loss of turning it off
		if (E_max < Loss[1*numD + j_max])
		{
			break;
		}
		
		//fprintf(debug,  "E_max > loss\n");	
        
		// mark this as an instanced detection
		I[j_max] = 1;
		J[j_max] = 0;
		
		numUI = 0;
		for (j=0; j < numD; j++)
		{
			if (J[j] == 1)
				numUI++;
		}
		
		
		cls_j_max = Detections[4*numD + j_max];
		
		
		//get the center of the j_max detection
		jmax_cent_x = Detections[0*numD + j_max] + ( Detections[2*numD + j_max]- Detections[0*numD + j_max])/2 ;
		jmax_cent_y = Detections[1*numD + j_max] + ( Detections[3*numD + j_max]- Detections[1*numD + j_max])/2 ;
		height_jmax = Detections[3*numD + j_max]- Detections[1*numD + j_max]+1;
		width_jmax =  Detections[2*numD + j_max]- Detections[0*numD + j_max]+1;
		

		// update energy of uninstanced detections based on what you have just instanced
		for (j=0; j < numD; j++)
		{
			// if J[j] is not instanced
			if (J[j] == 1)
			{
				// get the class for Detection j
				cls_j = Detections[4*numD + j];
				//fprintf(debug, "cls_j = %d j = %d\n", cls_j, j);
				//fflush(debug);
				start = (cls_j_max - 1)*numClasses*d_ij_size + (cls_j-1)*d_ij_size;
				stop  = start + d_ij_size;				
				
				////fprintf(debug, "start = %d, stop = %d\n", start, stop);
				////fflush(debug);
				//get the center of the j_th detection
				j_cent_x = Detections[0*numD + j] + (Detections[2*numD + j]- Detections[0*numD + j])/2 ;
				j_cent_y = Detections[1*numD + j] + (Detections[3*numD + j]- Detections[1*numD + j])/2 ;
				height_j = Detections[3*numD + j]- Detections[1*numD + j] + 1;
				width_j =  Detections[2*numD + j]- Detections[0*numD + j] + 1;
				
				//get the overlap between j_max and j
				for (i=0;  i< 4; i++)
				{
					bi[i] =0;
				}	
				//fprintf(debug, "bi initialized\n");
				//fflush(debug);
				ov= 0;
				
				if (Detections[0*numD + j_max] >  Detections[0*numD + j])
					bi[0] = Detections[0*numD + j_max];
				else
					bi[0] =  Detections[0*numD + j];
				
				if (Detections[1*numD + j_max] >  Detections[1*numD + j])
					bi[1] = Detections[1*numD + j_max];
				else
					bi[1] =  Detections[1*numD + j];
				
				if (Detections[2*numD + j_max] <  Detections[2*numD + j])
					bi[2] = Detections[2*numD + j_max];
				else
					bi[2] =  Detections[2*numD + j];
				
				if (Detections[3*numD + j_max] <  Detections[3*numD + j])
					bi[3] = Detections[3*numD + j_max];
				else
					bi[3] =  Detections[3*numD + j];
				
				
				
				////fprintf(debug, "bi[0] = %f, bi[1] = %f, bi[2] = %f, bi[3] = %f ", bi[0], bi[1], bi[2], bi[3]);
				////fflush(debug);
				
				iw = bi[2] - bi[0] +1;
				ih = bi[3] - bi[1] +1;
				if (iw > 0 && ih > 0)
				{
					//compute overlap as area of intersection / area of union
					ua =  (Detections[2*numD + j_max]- Detections[0*numD + j_max] +1)*(Detections[3*numD + j_max]- Detections[1*numD + j_max] +1)
					+ (Detections[2*numD + j]- Detections[0*numD + j] +1)*(Detections[3*numD + j]- Detections[1*numD + j] +1)
					- iw*ih;
					//fprintf(debug, "ua = %f\n", ua)	;
					ov = iw*ih/ua;	
					//fprintf(debug, "Overlap(%d, %d) = %f\n", j, j_max, ov);  
					//fflush(debug);
				}
				
				for (i=0; i < 7; i++)
				{
					spatial[i] =0;
				}
				
	
				//on top of 
				if(fabs(jmax_cent_x - j_cent_x)<= width_jmax/2 && fabs(jmax_cent_y - j_cent_y)<= height_jmax/2)     
				{
					spatial[0] = 1;
					//fprintf(debug," j on top of j_max \n");
				}	
				
				//above
				if(j_cent_y < (jmax_cent_y - height_jmax/2) && j_cent_y >= (jmax_cent_y - 1.5*height_jmax) && fabs(jmax_cent_x - j_cent_x)<= width_jmax/2)
				{
					spatial[1] = 1;
					//fprintf(debug,"j above j_max\n");
				}	
				
				//below
				if (j_cent_y > (jmax_cent_y + height_jmax/2) && 
					j_cent_y <= (jmax_cent_y + 1.5*height_jmax) &&
					fabs(jmax_cent_x - j_cent_x)<= width_jmax/2)
                {   
					spatial[2] = 1; 
					//fprintf(debug,"j below j_max\n");
				}	
				
				
				//next to
				if (fabs(jmax_cent_y - j_cent_y) <= height_jmax/2 &&
					fabs(jmax_cent_x - j_cent_x) > width_jmax/2 &&
					fabs(jmax_cent_x - j_cent_x) <= 1.5*width_jmax) 
				{
					spatial[3] = 1;
					//fprintf(debug,"j next to j_max \n");
				}
				
				
				//near relationship
				
                if (fabs(jmax_cent_x - j_cent_x) > width_jmax/2 &&
					fabs(jmax_cent_x - j_cent_x) <= 1.5*width_jmax &&    
					fabs(jmax_cent_y - j_cent_y) > height_jmax/2 &&
					fabs(jmax_cent_y -j_cent_y) <= 1.5*height_jmax)
				{
					spatial[4]=1;
					//fprintf(debug,"j near j_max \n");
				}			
				
				
				// far away     
				if (fabs(jmax_cent_x - j_cent_x) > 1.5*width_jmax ||  fabs(jmax_cent_y - j_cent_y) > 1.5*height_jmax)
                {
                    spatial[5] = 1;
                }
                else {
                    spatial[4] = 1;
                }
				
				
				
				// turn on the overlap bin if required
				if (ov > .5)
					spatial[6]=1;
				
				
				// add the pairwise reward to the overall energy at j	
				tmp=0;
				for (i=0; i < d_ij_size; i++)
				{
				    //printf("spatial[%d]=%d,weight=%g\n",i,spatial[i],Ws[start+i]);
					tmp +=spatial[i]*Ws[start+i];
				}
				Energies[j] +=	tmp;				
				
                
				// ----  reverse the spatial feature ---
				
				start = (cls_j - 1)*numClasses*d_ij_size + (cls_j_max-1)*d_ij_size;
				for (i=0; i < 7; i++)
				{
					spatial[i] =0;
				}
				
				//on top ofj
				if(fabs(j_cent_x - jmax_cent_x)<= width_j/2 && fabs(j_cent_y - jmax_cent_y) <= height_j/2)     
                {
					spatial[0] = 1;
					//fprintf(debug," j_max on top of j \n");
				}	
				
				//above
				if(jmax_cent_y < (j_cent_y - height_j/2) && jmax_cent_y >= (j_cent_y - 1.5*height_j) && 
				   fabs(j_cent_x - jmax_cent_x)<= width_j/2)
				{
					spatial[1] = 1;
					//fprintf(debug,"j_max above j\n");
				}	 
				
				//below
				if (jmax_cent_y > (j_cent_y + height_j/2) &&
					jmax_cent_y <= (j_cent_y + 1.5*height_j) &&
					fabs(j_cent_x - jmax_cent_x)<= width_j/2)
				{   
					spatial[2] = 1; 
					//fprintf(debug,"j_max below j\n");
				}	
				
				//next to
				if (fabs(j_cent_y - jmax_cent_y) <= height_j/2 &&
					fabs(j_cent_x - jmax_cent_x) > width_j/2 &&
					fabs(j_cent_x - jmax_cent_x) <= 1.5*width_j) 
				{
					spatial[3] = 1;
					//fprintf(debug,"j_max next to j\n");
				}
				
				
				
				//near relationship
				if (fabs(j_cent_x - jmax_cent_x) > width_j/2 &&
					fabs(j_cent_x - jmax_cent_x) <= 1.5*width_j &&    
					fabs(j_cent_y - jmax_cent_y) > height_j/2 &&
					fabs(j_cent_y -jmax_cent_y) <= 1.5*height_j)
				{
					spatial[4]=1;
					//fprintf(debug,"j_max near j\n");
				}			
				
                
				// far away     
				if (fabs(j_cent_x - jmax_cent_x) > 1.5*width_j || fabs(j_cent_y - jmax_cent_y) > 1.5*height_j)
                {
                    spatial[5] = 1;
                }
				else {
                    spatial[4] = 1;	 	
                }
				//printf("(%g,%g,%g)\n",j_cent_x,jmax_cent_x,width_j);
				
				// turn on the overlap bin if required
				if (ov > .5)
					spatial[6]=1;
				
				tmp=0;
				for (i=0; i < d_ij_size; i++)
				{
				    //printf("Flipspatial[%d]=%d,weight=%g\n",i,spatial[i],Ws[start+i]);
				    tmp +=spatial[i]*Ws[start+i];
				}
				//printf("adding %f to %d\n", tmp, j);   
				Energies[j] +=	tmp;
				
			}
		}
		
	}
	
	//fclose(debug);
	mxFree(J);
    return;
}

