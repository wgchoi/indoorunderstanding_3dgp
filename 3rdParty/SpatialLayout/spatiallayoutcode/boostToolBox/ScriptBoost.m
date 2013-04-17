% Step1: reading Data from the file
%file_data = load('Diabetes.txt');
%Data = file_data(:,1:end-1)';
%Labels = file_data(:, end)';
%Labels = Labels*2 - 1;

MaxIter = 100; % boosting iterations

TrainData   = XTrain;
TrainLabels = ytrain';

%ControlData   = XTest;
%ControlLabels = ytest';

% Step3: constructing weak learner
weak_learner = tree_node_w(3); % pass the number of tree splits to the constructor

% Step4: training with Gentle AdaBoost
[GLearners GWeights] = GentleAdaBoost(weak_learner, TrainData, TrainLabels, MaxIter);

% Step5: training with Modest AdaBoost
[MLearners MWeights] = ModestAdaBoost(weak_learner, TrainData, TrainLabels, MaxIter);

% Step6: evaluating on control set
%ResultG = sign(Classify(GLearners, GWeights, ControlData));

%ResultM = sign(Classify(MLearners, MWeights, ControlData));

% Step7: calculating error
%ErrorG  = sum(ControlLabels ~= ResultG)

%ErrorM  = sum(ControlLabels ~= ResultM)

save GTraining500_3L_100I_cruise GLearners GWeights
save MTraining500_3L_100I_cruise MLearners MWeights