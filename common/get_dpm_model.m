function w = get_dpm_model(model)

blocks = cell(model.numblocks, 1);

% filters
for i = 1:model.numfilters
  if model.filters(i).flip == 0
    bl = model.filters(i).blocklabel;
    blocks{bl} = model.filters(i).w(:);
  end
end

% offsets
for i = 1:length(model.rules)
  for j = 1:length(model.rules{i})
    bl = model.rules{i}(j).offset.blocklabel;
    blocks{bl} = model.rules{i}(j).offset.w;
  end
end

% deformation models
for i = 1:length(model.rules)
  for j = 1:length(model.rules{i})
    if model.rules{i}(j).type == 'D' && model.rules{i}(j).def.flip == 0
      bl = model.rules{i}(j).def.blocklabel;
      blocks{bl} = model.rules{i}(j).def.w(:);
    end
  end
end

% concatenate
w = [];
for i = 1:model.numblocks
  w = [w; blocks{i}];
end

% sanity check
if sum(model.blocksizes) ~= length(w)
  error('model size error');
end
% 
% % write to modfile
% fid = fopen(modfile, 'wb');
% fwrite(fid, m, 'double');
% fclose(fid);