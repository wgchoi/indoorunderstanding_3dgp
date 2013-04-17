%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   crossvalidation Implements the constructor for crossvalidation class
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    this = crossvalidation(folds)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           folds - number of cross-validation folds
%    Return:
%           this - object of crossvalidation class
function this = crossvalidation(folds)

if( folds == 1)
  error('folds should be >= 2');
end

this.folds = folds;

this.CrossDataSets   = cell(folds, 1);
this.CrossLabelsSets = cell(folds, 1);

this=class(this, 'crossvalidation') ;