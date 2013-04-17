%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   TranslateToC Implements procedure of saving trained classifier to file,
%   that can be further used in C++ programm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    code = TranslateToC (Learners, Weights, fid)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           Learners  - learners of commitee
%           Weights   - weights of commitee
%           fid       - opened file id (use fopen to make one)
%    Return:
%           code      - equals 1 if everything was alright

function code = TranslateToC (Learners, Weights, fid)

Weights = Weights ./ (sum(abs(Weights)));

fprintf(fid, ' %d\r\n ', length(Weights));

for i = 1 : length(Weights)
  Curr_Result = get_dim_and_tr(Learners{i});
  
  fprintf(fid, ' %f ', Weights(i));
  
  fprintf(fid, ' %d ', length(Curr_Result) / 3);
  
  for j = 1 : length(Curr_Result)
    fprintf(fid, ' %f ', Curr_Result(j));
  end
  
  fprintf(fid, '\r\n');
end

code = 1;