% Step1: reading Data from the file

MaxIter = 100; % boosting iterations

% Step2: splitting data to training and control set
TrainData   = XTrain;
TrainLabels = ytrain';

ControlData   = XTest;
ControlLabels = ytest';

% and initializing matrices for storing step error
RAB_control_error = zeros(1, MaxIter);
MAB_control_error = zeros(1, MaxIter);
GAB_control_error = zeros(1, MaxIter);

% Step3: constructing weak learner
weak_learner = tree_node_w(1); % pass the number of tree splits to the constructor

% and initializing learners and weights matices
GLearners = [];
GWeights = [];
RLearners = [];
RWeights = [];
NuLearners = [];
NuWeights = [];

% Step4: iterativly running the training

for lrn_num = 1 : MaxIter

    clc;
    disp(strcat('Boosting step: ', num2str(lrn_num),'/', num2str(MaxIter)));

    %training gentle adaboost
    [GLearners GWeights] = GentleAdaBoost(weak_learner, TrainData, TrainLabels, 1, GWeights, GLearners);

    %evaluating control error
    GControl = sign(Classify(GLearners, GWeights, ControlData));

    GAB_control_error(lrn_num) = GAB_control_error(lrn_num) + sum(GControl ~= ControlLabels) / length(ControlLabels);

    %training real adaboost
    [RLearners RWeights] = RealAdaBoost(weak_learner, TrainData, TrainLabels, 1, RWeights, RLearners);

    %evaluating control error
    RControl = sign(Classify(RLearners, RWeights, ControlData));

    RAB_control_error(lrn_num) = RAB_control_error(lrn_num) + sum(RControl ~= ControlLabels) / length(ControlLabels);

    %training modest adaboost
    [NuLearners NuWeights] = ModestAdaBoost(weak_learner, TrainData, TrainLabels, 1, NuWeights, NuLearners);

    %evaluating control error
    NuControl = sign(Classify(NuLearners, NuWeights, ControlData));

    MAB_control_error(lrn_num) = MAB_control_error(lrn_num) + sum(NuControl ~= ControlLabels) / length(ControlLabels);

end

% Step4: displaying graphs
figure, plot(GAB_control_error);
hold on;
plot(MAB_control_error, 'r');

plot(RAB_control_error, 'g');
hold off;

legend('Gentle AdaBoost', 'Modest AdaBoost', 'Real AdaBoost');
xlabel('Iterations');
ylabel('Test Error');

ResultR = sign(Classify(RLearners, RWeights, ControlData));

ResultG = sign(Classify(GLearners, GWeights, ControlData));

ResultM = sign(Classify(MLearners, MWeights, ControlData));

% Step7: calculating error
ErrorR  = sum(ControlLabels ~= ResultR)

ErrorG  = sum(ControlLabels ~= ResultG)

ErrorM  = sum(ControlLabels ~= ResultM)