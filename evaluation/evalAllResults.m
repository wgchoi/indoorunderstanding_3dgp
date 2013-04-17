function summary = evalAllResults(xs, annos, orgconf, resconfs, res)

[eval.rec, eval.prec, eval.ap]= evalDetection(annos, xs, resconfs, 0, 0, 1, 1);
summary.alldet = eval;
for i = 1:7
    try
        [eval.rec, eval.prec, eval.ap]= evalDetection(annos, xs, resconfs, i, 0, 0, 1);
        summary.objdet(i) = eval;
    catch
    end
end

[eval.rec, eval.prec, eval.ap]= evalDetection(annos, xs, orgconf, 0, 0, 1, 1);
summary.baseline_alldet = eval;
for i = 1:7
    try
        [eval.rec, eval.prec, eval.ap]= evalDetection(annos, xs, orgconf, i, 0, 0, 1);
        summary.baseline_objdet(i) = eval;
    catch
    end
end

[cls.baseline, cls.reest, cls.gt] = evalClassification(xs ,annos, res);
cls.baseline_mean = sum(cls.baseline == cls.gt) / length(cls.gt);
cls.reest_mean = sum(cls.reest == cls.gt) / length(cls.gt);
summary.cls = cls;


[layout.baseline, layout.reest] = evalLayout(xs, res);
layout.baseline_mean = mean(layout.baseline);
layout.reest_mean = mean(layout.reest);
summary.layout = layout;

end