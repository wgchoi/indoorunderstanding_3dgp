function ct = bbox2ct(bbox)
ct = (bbox(1:2) + bbox(3:4)) ./ 2;
end