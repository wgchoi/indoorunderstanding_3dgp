function bbox = rect2bbox(rect)
bbox = rect;
bbox(3:4) = bbox(3:4) + bbox(1:2) - 1;
end