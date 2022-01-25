close all
clc

addpath("functions");

loaddatcom

conf_ca0 = conf_base;
conf_ca0.mach = datcom.states.mach;
CA0_mach = getcoeff("CA", conf_ca0, datcom)

[CA0, CAalpha, CAbeta, CAdeltay, CAdeltap, CAdeltar, CAdeltas]  ...
        = interpCoeff("CA", conf_base, datcom, 1)

[CN0, CNalpha, CNbeta, CNdeltay, CNdeltap, CNdeltar, CNdeltas]  ...
        = interpCoeff("CN", conf_base, datcom)
    
[CY0, CYalpha, CYbeta, CYdeltay, CYdeltap, CYdeltar, CYdeltas]  ...
        = interpCoeff("CY", conf_base, datcom)

[CLL0, CLLalpha, CLLbeta, CLLdeltay, CLLdeltap, CLLdeltar, CLLdeltas]  ...
        = interpCoeff("CLL", conf_base, datcom)
    
[CLM0, CLMalpha, CLMbeta, CLMdeltay, CLMdeltap, CLMdeltar, CLMdeltas]  ...
        = interpCoeff("CM", conf_base, datcom)
    
[CLN0, CLNalpha, CLNbeta, CLNdeltay, CLNdeltap, CLNdeltar, CLNdeltas]  ...
        = interpCoeff("CLN", conf_base, datcom)
    
%% Linearized functions
CAfun = @(conf) CA0 + CAalpha.*deg2rad(conf.alpha).^2 + ...
                    CAalpha.*deg2rad(conf.beta).^2 + ...
                    CAdeltay.*deg2rad(conf.beta + conf.delta_yaw).^2 + ...
                    CAdeltap.*deg2rad(conf.alpha + conf.delta_pitch).^2 + ...
                    CAdeltar.*deg2rad(conf.delta_roll).^2 + ...
                    CAdeltas.*deg2rad(conf.delta_squeeze).^2 ;
CAfun2 = @(conf) CA0 + CAalpha.*conf.alpha.^2 + ...
                    CAalpha.*deg2rad(conf.beta).^2 + ...
                    CAdeltay.*deg2rad(conf.delta_yaw).^2 + ...
                    CAdeltap.*deg2rad(conf.delta_pitch).^2 + ...
                    CAdeltar.*deg2rad(conf.delta_roll).^2 + ...
                    CAdeltas.*deg2rad(conf.delta_squeeze).^2 ;
                
CNfun = @(conf) CNalpha.*deg2rad(conf.alpha) + CNdeltap.*deg2rad(conf.delta_pitch);
CYfun = @(conf) CYbeta.*deg2rad(conf.beta) + CYdeltay.*deg2rad(conf.delta_yaw);    

CLLfun = @(conf) CLLdeltar.*deg2rad(conf.delta_roll);    
CLMfun = @(conf) CLMalpha.*deg2rad(conf.alpha) + CLMdeltap.*deg2rad(conf.delta_pitch);
CLNfun = @(conf) CLNbeta.*deg2rad(conf.beta) + CLNdeltay.*deg2rad(conf.delta_yaw); 
%% Plots

conf = conf_base;
% conf.mach = datcom.states.mach;
% conf.alt = datcom.states.altitude;
conf.alpha = datcom.states.alpha;
% conf.alpha = 5;
% conf.beta = 0;
% conf.beta = datcom.states.beta;
% conf.delta_pitch = 10;
% conf.delta_yaw = 0;
% conf.delta_roll = datcom.states.fin2delta1;
% conf.delta_pitch = datcom.states.fin2delta1;
% conf.delta_squeeze = datcom.states.fin2delta1;
% conf.delta_squeeze = 10;
% x = conf.beta;

cc = struct2cell(conf);
for i=1:length(cc)
    if length(cc{i}) > 1
        x = cc{i};
        break;
    end
end

figure
tiledlayout(2,3);
nexttile
autoPlotCoeff("CA", conf, datcom, "Datcom", "CA");
hold on
plot(x, elng(x, CAfun2(conf)), "DisplayName", "Linearization");
plot(x, elng(x, CAfun(conf)), "DisplayName", "Linearization + base angle");

nexttile
autoPlotCoeff("CN", conf, datcom, "Datcom", "CN");
hold on
plot(x, elng(x, CNfun(conf)), "DisplayName", "Linearization");

nexttile
autoPlotCoeff("CY", conf, datcom, "Datcom", "CY");
hold on
plot(x, elng(x, CYfun(conf)), "DisplayName", "Linearization");

nexttile
autoPlotCoeff("CLL", conf, datcom, "Datcom", "CLL");
hold on
plot(x, elng(x, CLLfun(conf)), "DisplayName", "Linearization");

nexttile
autoPlotCoeff("CM", conf, datcom, "Datcom", "CM");
hold on
plot(x, elng(x, CLMfun(conf)), "DisplayName", "Linearization");

nexttile
autoPlotCoeff("CLN", conf, datcom, "Datcom", "CLN");
hold on
plot(x, elng(x, CLNfun(conf)), "DisplayName", "Linearization");


figure

alphatrim = -CLMdeltap*datcom.states.fin2delta1./CLMalpha;

plot(datcom.states.fin2delta1, alphatrim);
grid on




% figure
% tiledlayout(1,2);
% 
% nexttile
% conf = conf_base;
% conf.alpha = datcom.states.alpha;
% autoPlotCoeff("CA", conf, datcom, "Datcom", "CA");
% 
% nexttile
% conf = conf_base;
% conf.beta = datcom.states.beta;
% autoPlotCoeff("CA", x*189, conf, datcom, "Beta [deg]", "CA", "Datcom");
% xlim([min(datcom.states.alpha), max(datcom.states.alpha)]);

function ve = elng(x, v)
    if length(v) == 1
        ve = ones(size(x))*v;
    else
        ve = v;
    end
end


function [CX0, CXalpha, CXbeta, CXdeltay, CXdeltap, CXdeltar, CXdeltas]  ...
        = interpCoeff(coeff, conf_base, datcom, order)
    if nargin < 4 
        order = 1;
    end
    if order == 1
        fun = @fitHalf;
    else
        fun = @fitParab;
    end
    
    conf = conf_base;
    conf.alpha = datcom.states.alpha;
    [CX0, CXalpha] = fun(coeff, deg2rad(conf.alpha), conf, datcom);

    conf = conf_base;
    conf.beta = datcom.states.beta;
    [~, CXbeta] = fun(coeff, deg2rad(conf.beta), conf, datcom);

    conf = conf_base;
    conf.delta_yaw = datcom.states.fin2delta1;
    [~, CXdeltay] = fun(coeff, deg2rad(conf.delta_yaw), conf, datcom);

    conf = conf_base;
    conf.delta_pitch = datcom.states.fin2delta1;
    [~, CXdeltap] = fun(coeff, deg2rad(conf.delta_pitch), conf, datcom);

    conf = conf_base;
    conf.delta_roll = datcom.states.fin2delta1;
    [~, CXdeltar] = fun(coeff, deg2rad(conf.delta_roll), conf, datcom);

    conf = conf_base;
    conf.delta_squeeze = datcom.states.fin2delta1;
    [~, CXdeltas] = fun(coeff, deg2rad(conf.delta_squeeze), conf, datcom);
end


function [c, a] = fitParab(coeff, x, conf, datcom)
    y = getcoeff(coeff, conf, datcom);
    
    p = polyfit(x, y, 2);
    
    a = p(1);
    c = p(3);
end

function [b, a] = fitHalf(coeff, x, conf, datcom)
    y = getcoeff(coeff, conf, datcom);
    h = ceil(length(y)/2);
    p = polyfit(x(h:end), y(h:end), 1);
    
    a = p(1);
    b = p(2);
end