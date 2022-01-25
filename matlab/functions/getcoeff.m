function c = getcoeff(coeff, conf, datcom)
    state = conf2state(conf);
    stateind = state2index(state, datcom);

    c = squeeze(datcom.coeffs.(coeff)(stateind{:}));
    if length(size(c)) >= 2 && sum(size(c) > 1) > 1
        c = ndiag(c);
    end
end