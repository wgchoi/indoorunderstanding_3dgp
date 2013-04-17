current = pwd;

cd (vocdevkit_root);
VOCinit;

cd (current);


numClasses = length(VOCopts.classes);
CLASSES = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];

global ids d_ij_size Detections Scores;


% load 'test' image set
ids=textread(sprintf(VOCopts.imgsetpath,'test'),'%s');

numClasses = numClasses+1;

considerIDS = 1:length(ids) ;

d_ij_size = 7;

load wts_trainval

W_s  = ones(numClasses^2*d_ij_size, 1);
W_a = ones(numClasses*2, 1);

W_s = w(1:length(W_s));
W_a = w(length(W_s)+1:end);


%create files tow h
for clsID=1:20
    cls = VOCopts.classes{clsID};
    fid_context{clsID} = fopen(sprintf(VOCopts.detrespath,'context_d' ,cls),'w');
end

for i_id=considerIDS
        rec=PASreadrecord(sprintf(VOCopts.annopath,ids{i_id}));
        I=imread(sprintf(VOCopts.imgpath,ids{i_id})); 
        %load the precmputed cached variables Detections and Scores 
        %that represent the bounding boxes and the unary scores for this
        %test image respectively.
        
        % Detections(i, :) = [x1 y1 x2 y2 clsID]
        % S(i) = score of the local model on the ith detection
        
        load(strcat('../CACHED_DATA_TEST/', ids{i_id}));
        if(mod(i_id, 100) == 0)
            i_id
        end

        [E H_wo_gr]  = find_MVC_test(W_s, W_a, numClasses);

        TP = find(H_wo_gr == 1);

        nDet = size(Detections, 1);
    
        ptr = nDet;
        while length(find(Detections(ptr, :)>0)) == 0
            ptr = ptr-1;
        end
        nDet = ptr;
    
        for d=1:nDet
            fprintf(fid_context{Detections(d, 5)}, '%s %f %f %f %f %f\n',ids{i_id}, E(d),Detections(d, 1:4));
        end
   
end

AP_B = 0;
AP_GNM = 0;
AP_M2 = 0;

for clsID=1:20
    cls=VOCopts.classes{clsID};
    figure

    [recall_base ,prec_base, ap_base ,gt, npos]=VOCevaldet( VOCopts,'context_d',cls,true, 'r');  % compute and display PR

    saveas(gcf, strcat('results/testCD/', cls, '_', '.jpg'));
    close(gcf);
end


