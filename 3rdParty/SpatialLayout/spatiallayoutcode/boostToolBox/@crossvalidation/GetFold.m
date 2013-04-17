%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   GetFold returns Nth fold
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    [Data, Labels] = GetFold(this, N)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           this     - crossvalidation object
%           N        - number of fold
%    Return:
%           Data     - fold N data
%           Labels   - fold N labels

function [Data, Labels] = GetFold(this, N)

Data = [];
Labels = [];

if(N > this.folds)
  error('N > total folds');
end

Data   = cat(2, Data, this.CrossDataSets{N}{1,1});
Labels = cat(2, Labels, this.CrossLabelsSets{N}{1,1});
