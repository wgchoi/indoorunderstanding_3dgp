FullData   = [XTrain XTest];
FullLabels = [ytrain' ytest'];

MaxIter = 100; % boosting iterations
CrossValidationFold = 5; % number of cross-validation folds

weak_learner = tree_node_w(2); % constructing weak learner

% initializing matrices for storing step error
RAB_control_error = zeros(1, MaxIter);
MAB_control_error = zeros(1, MaxIter);
GAB_control_error = zeros(1, MaxIter);

% constructing object for cross-validation
CrossValid = crossvalidation(CrossValidationFold); 

% initializing it with data
CrossValid = Initialize(CrossValid, FullData, FullLabels);

NuWeights = [];

% for all folds
for n = 1 : CrossValidationFold    
    TrainData = [];
    TrainLabels = [];
    ControlData = [];
    ControlLabels = [];
    
    % getting current fold
    [ControlData ControlLabels] = GetFold(CrossValid, n);
    
    % concatinating other folds into the training set
    for k = 1:CrossValidationFold
        if(k ~= n)
            [TrainData TrainLabels] = CatFold(CrossValid, TrainData, TrainLabels, k); 
        end
    end
  
    GLearners = [];
    GWeights = [];
    RLearners = [];
    RWeights = [];
    NuLearners = [];
    NuWeights = [];
    
    %training and storing the error for each step
    for lrn_num = 1 : MaxIter

        clc;
        disp(strcat('Cross-validation step: ',num2str(n), '/', num2str(CrossValidationFold), '. Boosting step: ', num2str(lrn_num),'/', num2str(MaxIter)));
 
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
end

%saving results
%save(strcat(name,'_result'),'RAB_control_error', 'MAB_control_error', 'CrossValidationFold', 'MaxIter', 'name', 'CrossValid');

% displaying graphs
figure, plot(GAB_control_error / CrossValidationFold );
hold on;
plot(MAB_control_error / CrossValidationFold , 'r');

plot(RAB_control_error / CrossValidationFold, 'g');
hold off;

legend('Gentle AdaBoost', 'Modest AdaBoost', 'Real AdaBoost');
title(strcat(num2str(CrossValidationFold), ' fold cross-validation'));
xlabel('Iterations');
ylabel('Test Error');