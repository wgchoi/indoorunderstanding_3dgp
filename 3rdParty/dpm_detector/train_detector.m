function train_detector(cls)
if(cls == 1)
	pose_train('sofa', 8, 2, '', true);
elseif(cls == 2)
	pose_train('table', 8, 2, '', true);
elseif(cls == 3)
	pose_train('chair', 8, 1, '', true);
elseif(cls == 4)
	pose_train('diningtable', 8, 2, '', true);
end
end
