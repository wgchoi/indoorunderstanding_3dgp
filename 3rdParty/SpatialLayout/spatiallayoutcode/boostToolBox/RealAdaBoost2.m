%   The algorithms implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   RealAdaBoost Implements boosting process based on "Real AdaBoost"
%   algorithm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    [Learners, Weights, final_hyp] = RealAdaBoost(WeakLrn, Data, Labels,
%    Max_Iter, OldW, OldLrn, final_hyp)
%    ---------------------------------------------------------------------------------
%    Arguments:
%           WeakLrn   - weak learner
%           Data      - training data. Should be DxN matrix, where D is the
%                       dimensionality of data, and N is the number of
%                       training samples.
%           Labels    - training labels. Should be 1xN matrix, where N is
%                       the number of training samples.
%           Max_Iter  - number of iterations
%           OldW      - weights of already built commitee (used for training 
%                       of already built commitee)
%           OldLrn    - learnenrs of already built commitee (used for training 
%                       of already built commitee)
%           final_hyp - output for training data of already built commitee 
%                       (used to speed up training of already built commitee)
%    Return:
%           Learners  - cell array of constructed learners 
%           Weights   - weights of learners
%           final_hyp - output for training data

function [Learners, Weights, final_hyp] = RealAdaBoost2(WeakLrn, Data, Labels, Max_Iter, distr, OldW, OldLrn, final_hyp)

if( nargin <= 5)
  Learners = {};
  Weights = [];
  distr = ones(1,size(Data,2));
  L1=find(Labels>0);
  %distr(L1)=distr(L1)/(2*length(L1));
  L2=find(Labels<0);
  %distr(L2)=distr(L2)/(2*length(L2));
  if ~exist('distr','var')
      distr = ones(1, size(Data,2)) / (2*size(Data,2));
  end
  final_hyp = zeros(1, size(Data,2));
elseif( nargin > 6)
  Learners = OldLrn;
  Weights = OldW;
  if(nargin < 8)
    final_hyp = Classify(Learners, Weights, Data);
  end
  distr = exp(- (Labels .* final_hyp));  
  distr = distr / sum(distr);  
else
  error('Function takes eather 4 or 6 arguments');
end


for It = 1 : Max_Iter
  fprintf(1,'%d...',It);
  %chose best learner
  distr=distr/sum(distr);

  nodes = train2(WeakLrn, Data, Labels, distr);

  %for i = 1:length(nodes)
    curr_tr = nodes;
    step_out = calc_output(curr_tr, Data); 
    step_out = 2*step_out-1;
    ej = (Labels~=step_out);
    epsIt = sum( ej.*distr);
    BetaIt = epsIt/(1-epsIt);
    
    AlphaIt = log(1 / BetaIt);

    Weights(end+1) = AlphaIt;
    
    Learners{end+1} = curr_tr;
  %end
  distr = distr.*((BetaIt*ones(size(ej))).^(ones(size(ej))-ej));
end
