%   The algorithms developed and implemented by Alexander Vezhnevets aka Vezhnick
%   <a>href="mailto:vezhnick@gmail.com">vezhnick@gmail.com</a>
%
%   Copyright (C) 2005, Vezhnevets Alexander
%   vezhnick@gmail.com
%   
%   This file is part of GML Matlab Toolbox
%   For conditions of distribution and use, see the accompanying License.txt file.
%
%   ModestAdaBoost Implements boosting process based on "Modest AdaBoost"
%   algorithm
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%    [Learners, Weights, final_hyp] = ModestAdaBoost(WeakLrn, Data, Labels,
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
function [Learners, Weights, final_hyp] = ModestAdaBoost(WeakLrn, Data, Labels, Max_Iter, OldW, OldLrn, final_hyp)

global ME_min;

if( nargin < 7)
  alpha = 1;
end

if( nargin == 4)
  Learners = {};
  Weights = [];
  distr = ones(1, size(Data,2)) / size(Data,2);  
  final_hyp = zeros(1, size(Data,2));
elseif( nargin > 5)
  Learners = OldLrn;
  Weights = OldW;
  if(nargin < 7)
    final_hyp = Classify(Learners, Weights, Data);
  end
  distr = exp(- (Labels .* final_hyp));  
  distr = distr / sum(distr);
  
else
  error('Fuck');
end

L = length(Learners);

for It = 1 : Max_Iter
  
  %chose best learner

  nodes = train(WeakLrn, Data, Labels, distr);

  % calc error
  rev_distr = ((1 ./ distr)) / sum ((1 ./ distr));

  for i = 1:length(nodes)
    curr_tr = nodes{i};
    
    step_out = calc_output(curr_tr, Data); 
      
    s1 = sum( (Labels ==  1) .* (step_out) .* distr);
    s2 = sum( (Labels == -1) .* (step_out) .* distr);
      
    s1_rev = sum( (Labels == 1) .* (step_out) .* rev_distr);    
    s2_rev = sum( (Labels == -1) .* (step_out) .* rev_distr);  
    
    Alpha = s1 * (1 - s1_rev) - s2 * (1 - s2_rev);    
   
    
    if(sign(Alpha) ~= sign(s1 - s2) || (s1 + s2) == 0)
      continue;
    end
   
    Weights(end+1) = Alpha;
    
    Learners{end+1} = curr_tr;
    
    final_hyp = final_hyp + step_out .* Alpha;    
  end
  
  Z = sum(abs(Labels .* final_hyp));
  
  if(Z == 0)
    Z = 1;
  end
  
  distr = exp(- 1 * (Labels .* final_hyp) / Z);
  Z = sum(distr);
  distr = distr / Z;  

end
