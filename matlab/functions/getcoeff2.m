function c = getcoeff2(coeff, conf, datcom)
    state = conf2state(conf);
    stateind = state2index(state, datcom);

    c = squeeze(datcom.coeffs.(coeff)(stateind{:}));
end