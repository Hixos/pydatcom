addpath("../output");
close all
clc

if ~exist("datcom", "var")
    datcom = load("for006.mat");
end


conf_base.alpha = 0;
conf_base.beta = 0;
conf_base.mach = 0.5;
conf_base.alt = 1000;
conf_base.delta_yaw = 0;
conf_base.delta_pitch = 0;
conf_base.delta_roll = 0;
conf_base.delta_squeeze = 0;


conf = conf_base;
conf.alpha = datcom.states.alpha;


ca = getcoeff("CA", conf, datcom);
cn = getcoeff("CN", conf, datcom);

alpharad = deg2rad(conf.alpha)';
cd = ca.*cos(alpharad) + cn.*sin(alpharad);
cl = cn.*cos(alpharad) - ca.*sin(alpharad);


CA0 = 0.3778;
CAalpha = 0.0029;
CAdeltap = 0.0045;

CNalpha = 0.4158;
CNdeltap = 0.0557;

CLMalpha = -0.6798;
CLMdeltap = 0.3573;

alphalin = deg2rad(-CLMdeltap*datcom.states.fin2delta1./CLMalpha);


% alphalin = deg2rad(linspace(min(conf.alpha), max(conf.alpha), 100));

calin = CA0 + CAalpha.*abs(rad2deg(alphalin)) + CAdeltap*abs(datcom.states.fin2delta1);
cnlin = CNalpha.*rad2deg(alphalin) + CNdeltap*datcom.states.fin2delta1;

cdlin = calin.*cos(alphalin) + cnlin.*sin(alphalin);
cllin = cnlin.*cos(alphalin) - calin.*sin(alphalin);

tiledlayout(1,2)
nexttile
plot(cd, cl);
grid on
hold on
plot(cdlin, cllin)
xlim([0, max(cd)]);

nexttile
plot(conf.alpha, cl./cd);
grid on
hold on
plot(alphalin, cllin./cdlin)
xlim([0, max(cd)]);
