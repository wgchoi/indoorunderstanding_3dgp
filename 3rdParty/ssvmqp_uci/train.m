


global ids numClasses d_ij_size h l;


% load 'trainval' image set
ids=textread(sprintf(VOCopts.imgsetpath,'trainval'),'%s');

 
numClasses = 21;

considerIDS = 1:numel(ids);

d_ij_size = 7;

%pairwise weights
W_s  = ones(numClasses^2*d_ij_size, 1);
%unary weights
W_a = ones(numClasses*2, 1);

%constraints that will form the cutting planes
Constraints = zeros(length(W_s) + length(W_a), 10000, 'single');

Margins = zeros(1, 10000, 'single');
IDS = zeros(1, 10000, 'single');

max_iter = 500;
any_addition=1;
iter=1;

trigger=1;
low_bound= 0;

cache.xc = [];
C = 1.0;
n=0;

w=[W_s;W_a];
cost = w'*w*.5;

cache =[];
isDone= 0;
MAX_CON =  10000;
old=0;

h =0; 
l =0;

while (iter < max_iter && trigger)
    datestr(now)
    any_addition = 0;


    trigger=0;

    for id = considerIDS

        [H_wo X_wo m]  = find_MVC(W_s, W_a, numClasses,id);
        
        %if this constraint is the MVC for this image
        isMVC = 1;
        check_labels = find(IDS(1, 1:n) ==id);
        score = m-w'*X_wo;
        
        for ii=1:numel(check_labels)
            label_ii = check_labels(ii);
            if (m-w'*Constraints(:, label_ii) > score)
                isMVC=0;
                break;
            end
        end
       
        if isMVC ==1
            cost = cost + C*max(0, m - w'*X_wo);
            %add only if this is a hard constraint
            if (m - w'*X_wo) >= -0.001
                n=n+1;
                Constraints(:, n) = X_wo;
                Margins(n) = m;
                IDS(n) = id;
                any_addition=1;

                if n > MAX_CON
                    'n > MAX_CON'
                    [slacks I_ids] = sort((Margins(:,n)  - w'*Constraints(:, 1:n)), 'descend');
                    J = I_ids(1:MAX_CON);
                    n = length(J);
                    Constraints(:, 1:n) = Constraints(:, J);
                    Margins(:, 1:n) = Margins(:, J);
                    IDS(:, 1:n) = IDS(:, J);

                end

            end
        end
        [cost low_bound];

        if 1 - low_bound/cost > .01
            % Call QP
            %if mod(iter, 10) == 1
            % [cost low_bound]
            %end
            [w,cache]= lsvmopt(Constraints(:,1:n),Margins(1:n), IDS(1:n) ,C, 0.01,[]);

            % Prune working set
            I = find(cache.sv > 0);
           
            n = length(I);
            Constraints(:,1:n) = Constraints(:,I);

            Margins(:,1:n) = Margins(:,I);
            IDS(:,1:n) = IDS(:,I);
           
            % Update parameters
            W_s  = w(1:length(W_s));
            W_a  = w(length(W_s)+1:end);
            
            %reset the running estimate on upper bund
            cost = w'*w*0.5;
            low_bound = cache.lb;
            trigger = 1;
        end

    end

    iter = iter +1
    
    save('wts_trainval', 'w');
    trigger
    %exist
end
'converged'
keyboard

