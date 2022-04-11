close all
clc

addpath("functions");

loaddatcom

conf_ca0 = conf_base;
conf_ca0.mach = datcom.states.mach;
CA0_mach = getcoeff("CA", conf_ca0, datcom)

[CA0, CAalpha, CAbeta, CAdeltay, CAdeltap, CAdeltar, CAdeltas]  ...
        = interpCoeff("CA", conf_base, datcom, 2)

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
CAfun2 = @(conf) CA0 + CAalpha.*deg2rad(conf.alpha).^2 + ...
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
% conf.alpha = 0;
conf.beta = 5;
% conf.beta = datcom.states.beta;
% conf.delta_pitch = 0;
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


%% CSV for thesis plots
conf1 = conf_base;
conf1.alpha = datcom.states.alpha;
conf1.beta = 0;


conf2 = conf_base;
conf2.alpha = datcom.states.alpha;
conf2.beta = 5;

alpha_ext = linspace(min(conf1.alpha), max(conf1.alpha), 30);

conf1s = conf1;
conf1s.alpha = alpha_ext;

conf2s = conf2;
conf2s.alpha = alpha_ext;

%% CA
CA_alpha1 = getcoeff("CA", conf1, datcom)';
CA_alpha2 = getcoeff("CA", conf2, datcom)';

t = table(datcom.states.alpha', CA_alpha1', CA_alpha2', 'VariableNames', {'alpha', 'ca_beta0', 'ca_beta5'});
writetable(t, "csv/ca_alpha_datcom.csv");
t = table(alpha_ext', CAfun2(conf1s)', CAfun2(conf2s)', 'VariableNames', {'alpha', 'ca_beta0', 'ca_beta5'});
writetable(t, "csv/ca_alpha_simple.csv");

%% CN
CN_alpha1 = getcoeff("CN", conf1, datcom)';
CN_alpha2 = getcoeff("CN", conf2, datcom)';

t = table(datcom.states.alpha', CN_alpha1', CN_alpha2', 'VariableNames', {'alpha', 'cn_beta0', 'cn_beta5'});
writetable(t, "csv/cn_alpha_datcom.csv");
t = table(alpha_ext', CNfun(conf1s)', CNfun(conf2s)', 'VariableNames', {'alpha', 'cn_beta0', 'cn_beta5'});
writetable(t, "csv/cn_alpha_simple.csv");

%% CLL
CLL_alpha1 = getcoeff("CLL", conf1, datcom)';
CLL_alpha2 = getcoeff("CLL", conf2, datcom)';

t = table(datcom.states.alpha', CLL_alpha1', CLL_alpha2', 'VariableNames', {'alpha', 'cll_beta0', 'cll_beta5'});
writetable(t, "csv/cll_alpha_datcom.csv");
t = table(alpha_ext', elng(alpha_ext, CLLfun(conf1s))', elng(alpha_ext, CLLfun(conf2s))', 'VariableNames', {'alpha', 'cll_beta0', 'cll_beta5'});
writetable(t, "csv/cll_alpha_simple.csv");

%% CLN
CLN_alpha1 = getcoeff("CLN", conf1, datcom)';
CLN_alpha2 = getcoeff("CLN", conf2, datcom)';

t = table(datcom.states.alpha', CLN_alpha1', CLN_alpha2', 'VariableNames', {'alpha', 'cln_beta0', 'cln_beta5'});
writetable(t, "csv/cln_alpha_datcom.csv");
t = table(alpha_ext', elng(alpha_ext, CLNfun(conf1s))', elng(alpha_ext, CLNfun(conf2s))', 'VariableNames', {'alpha', 'cln_beta0', 'cln_beta5'});
writetable(t, "csv/cln_alpha_simple.csv");

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
