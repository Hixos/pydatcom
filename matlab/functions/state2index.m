function [ind] = state2index(state, datcom)

ind = {};
statevec_cell = struct2cell(datcom.states);

for i=1:length(state)
    s = state{i};
    v = zeros(size(s));
    for j=1:length(s)
        [~, v(j)] = min(abs(statevec_cell{i} - s(j)));
    end
    ind{i} = v;
end
end

