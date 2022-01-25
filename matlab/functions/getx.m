function [x, i] = getx(conf)
C = struct2cell(conf);
for i = 1:length(C)
    if length(C{i}) > 1
        x = C{i};
        return;
    end
end
end

