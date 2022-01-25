function vec = conf2state(conf)

% delta_cmd = M*delta_dflct

M = [   -0.5 0 0.5 0;
        0 0.5 0 -0.5;
        -0.25 -0.25 -0.25 -0.25;
        -0.25 0.25 -0.25 0.25;
     ];

vec = {conf.alpha, conf.mach, conf.beta conf.alt, [], [], [], []};

N = max([length(conf.delta_yaw), length(conf.delta_pitch), length(conf.delta_roll), length(conf.delta_squeeze)]);

for i=1:N
    cmd = [
            conf.delta_yaw(min(i, length(conf.delta_yaw)));
            conf.delta_pitch(min(i, length(conf.delta_pitch)));
            conf.delta_roll(min(i, length(conf.delta_roll)));
            conf.delta_squeeze(min(i, length(conf.delta_squeeze)));
        ];
    dflct = M\cmd;
    for j=1:4
        vec{4 + j} = [vec{4 + j}; dflct(j)];
    end
end

end