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

function [Learners, Weights, final_hyp] = RealAdaBoostM2(WeakLrn, Data, Labels, Max_Iter, NumClasses)

if( nargin == 5)
  Learners = {};
  classdistr=(2*ones(1,NumClasses)).^(NumClasses-1:-1:0);
  MaxIterPerLevel=250*ones(size(classdistr));%round((Max_Iter/sum(classdistr))*classdistr);
  Weights = zeros(NumClasses,sum(MaxIterPerLevel));
%   distr = ones(1,size(Data,2));
%   L1=find(Labels>0);
%   distr(L1)=distr(L1)/(2*length(L1));
%   L2=find(Labels<0);
%   distr(L2)=distr(L2)/(2*length(L2));
else
  error('Function takes 5 arguments');
end

for n=1:2^NumClasses-1
    binstr=dec2bin(n,NumClasses);
    rankbinstr(n)=NumClasses-sum(binstr)+48*NumClasses;
    distr{n}=zeros(1,size(Data,2));
end
[rankbinstr,schedule]=sort(rankbinstr);

for j=1:NumClasses+1
    indices(j).i=find(Labels==j);
    %Z(j).z=-ones(1,size(Data,2));
    %Z(j).z(indices(j).i)=1;
end
curindex=1;
for i=1:1%length(schedule)
    
    binstr=dec2bin(schedule(i),NumClasses);
    a=find(rankbinstr<rankbinstr(i));
    curlabels=Labels;
    for j=1:NumClasses
        membership(j)=bin2dec(binstr(j));
        if(membership(j))
            curlabels(indices(j).i)=1;
        else
            curlabels(indices(j).i)=-1;
        end
    end
    curlabels(indices(NumClasses+1).i)=-1;
        
    if(isempty(a))
        distr{schedule(i)} = ones(1, size(Data,2));
        x=find(curlabels==1);
        distr{schedule(i)}(x)=distr{schedule(i)}(x)/length(x);
        x=find(curlabels~=1);
        distr{schedule(i)}(x)=distr{schedule(i)}(x)/length(x);
    else
%         for j=1:NumClasses+1
%                 distr{schedule(i)}(indices(j).i)=1/length(indices(j).i);
%         end
        for k=1:length(a)
            for j=1:NumClasses
                if(membership(j))
                    distr{schedule(i)}(indices(j).i)=distr{schedule(i)}(indices(j).i)+distr{schedule(a(k))}(indices(j).i);
                end
            end
            distr{schedule(i)}(indices(NumClasses+1).i)=distr{schedule(i)}(indices(NumClasses+1).i)+distr{schedule(a(k))}(indices(NumClasses+1).i);
        end
    end
    
    for It = 1 : MaxIterPerLevel(rankbinstr(i)+1)
        fprintf(1,'%d...',It);
    %chose best learner
        distr{schedule(i)}=distr{schedule(i)}/sum(distr{schedule(i)});

        nodes = train2(WeakLrn, Data, curlabels, distr{schedule(i)});

        curr_tr = nodes;
        step_out = calc_output(curr_tr, Data); 
        step_out = 2*step_out-1;
        ej = (curlabels~=step_out);
        epsIt = sum( ej.*distr{schedule(i)});
        BetaIt = epsIt/(1-epsIt);

        AlphaIt = log(1 / BetaIt);
        for j=1:NumClasses
            if(membership(j))
                Weights(j,curindex) = AlphaIt;
            else
                Weights(j,curindex) = 0;
            end
        end
        curindex=curindex+1;
        Learners{end+1} = curr_tr;
        distr{schedule(i)} = distr{schedule(i)}.*((BetaIt*ones(size(ej))).^(ones(size(ej))-ej));
    end
end



