========================================================================
Spatial Pyramid Code
Created by Joe Tighe (jtighe@cs.unc.edu) and Svetlana Lazebnik (lazebnik@cs.unc.edu)
1/17/2009

This MATLAB code implements spatial pyramid computation and matching as 
described in the following paper:

S. Lazebnik, C. Schmid, and J. Ponce, ``Beyond Bags of Features: Spatial 
Pyramid Matching for Recognizing Natural Scene Categories,'' CVPR 2006.

========================================================================

2/29/2012:
-Updated sift normalization. Previous update normalized sift across all values causeing 
 sift descriptors in flat regions to effectly be noise.(see sp_gen_sift.m for details)

9/3/2010:
-Upadated sift generation to allow for fast generation of sift descriptor
 at every pixel (see sp_gen_sift.m for details).
-Added progress bars for user feedback
-Slight change to interface to allow for clearner code. See Example.m for usage.


The main function to build the spatial pyramid is BuildPyramid.
For further information on Buildpyramid and other functions discussed in 
this file refer to comments in the .m files or look at Example.m.
(The images/ directory contains a few sample images that are used by 
Example.m to compute spatial pyramids and their histogram intersection
matrix.)

BuildPyramid first extracts SIFT descriptors on a regular grid from each 
image. It then runs k-means to find the dictionary. Each sift descriptor 
is given a texton label corresponding to the closest dictionary codeword. 
Finally, the spatial pyramid is generated from these labels.

Each of these steps are split up into individual functions and can be called 
independently, provided the data from the previous step is stored in the 
correct location. The functions are as follows:

GenerateSiftDescriptors
CalculateDictionary
BuildHistograms
CompilePyramid

If you wish to use one of these functions without first running the previous 
step, you will need to provide the appropriate data files. They should be in 
the dataBaseDir with the same relative path as the image they correspond to. 
Their file names should be the same as the image they correspond to with the 
appropriate suffix appended to the end. For instance if you call 
CalculateDictionary with featureSuffix = ‘_sift.mat’ CalculateDictionary will 
look for the data file ‘dataBaseDir/im1_sift.mat’ for the image file 
‘imageBaseDir/im1.jpg’.

There are two different types of data files (feature lists and texton indices). 
Each must be formatted correctly to work with the functions provided.

features:
    data: NxM matrix of image features where N is the number of features in the image 
        and M is the feature vector size
    x: Nx1 vector of image x coordinates where N is the number of features in the image
    y: Nx1 vector of image y coordinates where N is the number of features in the image
    wid: width of the image
    hgt: height of the image

texton_ind: 
    data: Nx1 vector of texton indices corresponding to the appropriate dictionary bin 
        for each feature of the image where N is the number of features in the image
    x: Nx1 vector of image x coordinates where N is the number of features in the image
    y: Nx1 vector of image y coordinates where N is the number of features in the image
    wid: width of the image
    hgt: height of the image

NOTE: This code does not include functionality for SVM classification, though it
does include functions for computing the histogram intersection kernel matrix
(hist_isect.m and hist_isect_c.c). For classification, we have used the svm_v0.55
MATLAB toolbox: 

http://theoval.sys.uea.ac.uk/~gcc/svm/toolbox

However, any other SVM package (and kernels other than histogram intersection) 
can be adapted.
