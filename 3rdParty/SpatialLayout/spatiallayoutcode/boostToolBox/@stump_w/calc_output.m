%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.

function y = calc_output(stump, XData)

y = (XData(stump.t_dim, :) <= stump.threshold) * (stump.signum) + (XData(stump.t_dim, :) > stump.threshold) * (-stump.signum);