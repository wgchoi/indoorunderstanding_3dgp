function rect = bbox2rect(bbox)
rect = bbox;
rect(3:4) = rect(3:4) - rect(1:2) + 1;
end