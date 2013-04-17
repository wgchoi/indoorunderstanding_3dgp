% Set up global variables used throughout the code
setVOCyear='2012';

% setup svm mex for context rescoring (if it's installed)
if exist('./svm_mex601') > 0
  addpath svm_mex601/bin;
  addpath svm_mex601/matlab;
end

% dataset to use
if exist('setVOCyear') == 1
  VOCyear = setVOCyear;
  clear('setVOCyear');
else
  VOCyear = '2007';
end

% directory for caching models, intermediate data, and results
cachedir = ['data/' VOCyear '_contaminated2/'];

if exist(cachedir) == 0
  unix(['mkdir -p ' cachedir]);
  if exist([cachedir 'learnlog/']) == 0
    unix(['mkdir -p ' cachedir 'learnlog/']);
  end
end

% directory for LARGE temporary files created during training
tmpdir = ['data/' VOCyear '/'];

if exist(tmpdir) == 0
  unix(['mkdir -p ' tmpdir]);
end

% should the tmpdir be cleaned after training a model?
cleantmpdir = true;

% directory with PASCAL VOC development kit and dataset
VOCdevkit = '../VOCdevkit/';
if(~exist(VOCdevkit, 'dir'))
    key = input('VOC is not installed. Do you want to install??', 's');
    if(key == 'y')
        tmp = pwd; 
        cd ..;
        unix('wget http://pascallin.ecs.soton.ac.uk/challenges/VOC/voc2011/VOCdevkit_25-May-2011.tar');
        unix('tar xvf VOCdevkit_25-May-2011.tar; rm VOCdevkit_25-May-2011.tar');
        cd(tmp);
    else
        error('no voc installed');
    end
end
