%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PHOTO POPUP README for WINDOWS
Derek Hoiem (dhoiem@cs.cmu.edu)
7/10/08
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


The photoPopup application was compiled from matlab code using mcc. 
This README is for the Windows version.  I do not guarantee that this
version is identical to that described in the IJCV version (as it
was compiled 2 years later), but it is surely similar enough to refer 
to it by citing:
D. Hoiem, A.A. Efros, and M. Hebert, "Recovering Surface Layout from 
an Image", IJCV, Vol. 75, No. 1, October 2007.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

LICENSE:

Copyright (C) 2005 Derek Hoiem, Carnegie Mellon University

This software is exclusively licensed by Freewebs for commercial use.
According to that agreement, we may continue to make this executable
available for non-commercial use only.  Please contact 
Rob Conway(rconway@andrew.cmu.edu), the Tech Transfer manager,  
with further questions.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

How to RUN:

photoPopupIjcv [fnData] [fnImage] [extSuperpixelImage] [outdir]
fnData: filename for .mat file containing classifier data
fnImage: filename for original RGB image
extSuperpixelImage: filename extension for superpixel image
outdir: directory to output results
 
Example of usage:
./photoPopupIjcv ../data/ijcvClassifier ../images/lakecomo2008.jpg pnm ../results 

Note that the .jpg and .pnm files for this command are included.


Type photoPopupIjcv (no args) to get a message similar to this.  See notes below
on how to get superpixel image.  photoPopup must be run from the same directory, 
or environment variables must be set to allow it to find the .ctf file.  
If the image is in the current directory, it must be preceded by "./".  

Here are the steps that must be performed to run an image:
1) Obtain the image in .ppm format
2) Run the F&H superpixel program: ./segment <imname>.ppm 0.8 100 100


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

How to INSTALL (Windows Only):


Step 1: Copy photoPopupIjcv and photoPopupIjcv.ctf to the directory from which you 
        will run photoPopup.

Step 2:

    Install MCRInstaller.exe

    You should now be able to run from the command prompt.  
    If not, ensure that the following has been added to your path:
	<mcr_root>\<ver>\runtime\win32 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NOTES:  

  Superpixels:
  I use the segmentation code provided by Felzenszwalb and Huttenlocher
  at people.cs.uchicago.edu/~pff/segment/ to create the superpixels in my
  experiments.  The first three arguments (sigma, k, min) that I use are 
  0.8 100 100.  You can also use a different program to create the superpixel
  image.  That image should have a different RGB color for each segment
  without drawn boundaries between segments.  

  Linux:
  A separate executable and separate instructions are available for Linux.



(C) Derek Hoiem, Carnegie Mellon University, University of Illinois 2008
 
