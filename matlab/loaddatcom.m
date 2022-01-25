if ~exist("datcom", "var")
    datcom = load("../output/for006.mat");
end

conf_base.alpha = 0;
conf_base.beta = 0;
conf_base.mach = 0.5;
conf_base.alt = 1000;
conf_base.delta_yaw = 0;
conf_base.delta_pitch = 0;
conf_base.delta_roll = 0;
conf_base.delta_squeeze = 0;