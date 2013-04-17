%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.

function stump = stump_w


stump.threshold = 0;
stump.signum = 1;
stump.t_dim = 1;

stump=class(stump, 'stump_w') ;
%tr=class(tr, 'threshold_w', learner(idim, odim), learner_w) ;