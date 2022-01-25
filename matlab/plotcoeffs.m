addpath("../output");
close all

datcom = load("for006.mat");

% conf.alpha = 0;
% conf.beta = 0;
% conf.mach = 0;%datcom.states.mach;
% conf.alt = datcom.states.altitude;
% conf.delta = 0;%datcom.states.fin2delta1;
% 
% figure
% plotAll(conf, "-", datcom, "Mach (deg)", "Derivatives over Mach");

conf.alpha = datcom.states.alpha;
conf.beta = 5;
conf.delta = 0;
conf.mach = 0.5;
conf.alt = 1000;

figure
plotAll(conf, "-", datcom, "Alpha (deg)", "Derivatives over Alpha");

conf.alpha = 5;
conf.beta = datcom.states.beta;
conf.delta = 0;

figure
plotAll(conf, "-", datcom, "Beta (deg)", "Derivatives over Beta");

conf.alpha = 10;
conf.beta = 0;
conf.delta = datcom.states.fin2delta1;

figure
plotAll(conf, "yaw", datcom, "Delta (deg)", "Derivatives over Delta (yaw)");
figure
plotAll(conf, "pitch", datcom, "Delta (deg)", "Derivatives over Delta (pitch)");

figure
plotAll(conf, "roll", datcom, "Delta (deg)", "Derivatives over Delta (roll)");

figure
plotAll(conf, "drag", datcom, "Delta (deg)", "Derivatives over Delta (drag)");

return
figure
tiledlayout(3,1);
nexttile;
easyPlot("CA", {conf.alpha, conf.mach, conf.beta conf.alt, conf.delta, 0, 0, 0}, datcom, "vec", "Delta (deg)", "CA/pitch", "fin1"); 
hold on
easyPlot("CA", {conf.alpha, conf.mach, conf.beta conf.alt, 0, conf.delta, 0, 0}, datcom, "vec", "Delta (deg)", "CA/pitch", "fin2"); 
easyPlot("CA", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, conf.delta, 0}, datcom, "vec", "Delta (deg)", "CA/pitch", "fin3"); 
easyPlot("CA", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, 0, conf.delta}, datcom, "vec", "Delta (deg)", "CA/pitch", "fin4"); 

nexttile;
easyPlot("CN", {conf.alpha, conf.mach, conf.beta conf.alt, conf.delta, 0, 0, 0}, datcom, "vec", "Delta (deg)", "CN/pitch", "fin1"); 
hold on
easyPlot("CN", {conf.alpha, conf.mach, conf.beta conf.alt, 0, conf.delta, 0, 0}, datcom, "vec", "Delta (deg)", "CN/pitch", "fin2"); 
easyPlot("CN", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, conf.delta, 0}, datcom, "vec", "Delta (deg)", "CN/pitch", "fin3"); 
easyPlot("CN", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, 0, conf.delta}, datcom, "vec", "Delta (deg)", "CN/pitch", "fin4"); 

nexttile;
easyPlot("CY", {conf.alpha, conf.mach, conf.beta conf.alt, conf.delta, 0, 0, 0}, datcom, "vec", "Delta (deg)", "CY/pitch", "fin1"); 
hold on
easyPlot("CY", {conf.alpha, conf.mach, conf.beta conf.alt, 0, conf.delta, 0, 0}, datcom, "vec", "Delta (deg)", "CY/pitch", "fin2"); 
easyPlot("CY", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, conf.delta, 0}, datcom, "vec", "Delta (deg)", "CY/pitch", "fin3"); 
easyPlot("CY", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, 0, conf.delta}, datcom, "vec", "Delta (deg)", "CY/pitch", "fin4");

figure
tiledlayout(3,1);
nexttile;
easyPlot("CLL", {conf.alpha, conf.mach, conf.beta conf.alt, conf.delta, 0, 0, 0}, datcom, "vec", "Delta (deg)", "CLL/pitch", "fin1"); 
hold on
easyPlot("CLL", {conf.alpha, conf.mach, conf.beta conf.alt, 0, conf.delta, 0, 0}, datcom, "vec", "Delta (deg)", "CLL/pitch", "fin2"); 
easyPlot("CLL", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, conf.delta, 0}, datcom, "vec", "Delta (deg)", "CLL/pitch", "fin3"); 
easyPlot("CLL", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, 0, conf.delta}, datcom, "vec", "Delta (deg)", "CLL/pitch", "fin4"); 

nexttile;
easyPlot("CM", {conf.alpha, conf.mach, conf.beta conf.alt, conf.delta, 0, 0, 0}, datcom, "vec", "Delta (deg)", "CM/pitch", "fin1"); 
hold on
easyPlot("CM", {conf.alpha, conf.mach, conf.beta conf.alt, 0, conf.delta, 0, 0}, datcom, "vec", "Delta (deg)", "CM/pitch", "fin2"); 
easyPlot("CM", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, conf.delta, 0}, datcom, "vec", "Delta (deg)", "CM/pitch", "fin3"); 
easyPlot("CM", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, 0, conf.delta}, datcom, "vec", "Delta (deg)", "CM/pitch", "fin4"); 

nexttile;
easyPlot("CLN", {conf.alpha, conf.mach, conf.beta conf.alt, conf.delta, 0, 0, 0}, datcom, "vec", "Delta (deg)", "CLN/pitch", "fin1"); 
hold on
easyPlot("CLN", {conf.alpha, conf.mach, conf.beta conf.alt, 0, conf.delta, 0, 0}, datcom, "vec", "Delta (deg)", "CLN/pitch", "fin2"); 
easyPlot("CLN", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, conf.delta, 0}, datcom, "vec", "Delta (deg)", "CLN/pitch", "fin3"); 
easyPlot("CLN", {conf.alpha, conf.mach, conf.beta conf.alt, 0, 0, 0, conf.delta}, datcom, "vec", "Delta (deg)", "CLN/pitch", "fin4");


% figure
% tiledlayout(3,1);
% nexttile;
% easyPlot("CAQ", conf, datcom, "pitch", "Delta (deg)", "CAq/pitch"); 
% nexttile;
% easyPlot("CNQ", conf, datcom, "pitch", "Delta (deg)", "CNq/pitch"); 
% nexttile;
% easyPlot("CYP", conf, datcom, "pitch", "Delta (deg)", "CYp/pitch"); 

function plotAll(conf, type, datcom, labelx, titlestr)
t = tiledlayout(2,3);
nexttile;
easyPlot("CA", conf, datcom, type, labelx, "CA"); 
nexttile;
easyPlot("CN", conf, datcom, type, labelx, "CN"); 
nexttile;
easyPlot("CY", conf, datcom, type, labelx, "CY"); 

nexttile;
easyPlot("CLL", conf, datcom, type, labelx, "CLL"); 
nexttile;
easyPlot("CM", conf, datcom, type, labelx, "CLM"); 
nexttile;
easyPlot("CLN", conf, datcom, type, labelx, "CLN"); 

title(t, titlestr);
end

function h = easyPlot(coeff, conf, datcom, type, labelx, titlestr, legend_str)

    if strcmp(type, "pitch")
        v = pitch2state(conf);
        x = v{1} + v{6};
    elseif strcmp(type, "yaw")
        v = yaw2state(conf);
        x = v{3} + v{5};
    elseif strcmp(type, "roll")
        v = roll2state(conf);
        x = v{5};
    elseif strcmp(type, "drag")
        v = squeeze2state(conf);
        x = v{5};
    else
        v = conf2state(conf);
        for i=1:length(v)
            if length(v{i}) > 1
                x = v{i};
                break;
            end
        end
    end
    
    if nargin > 6
        h = plotCoeff(x, coeff, v, datcom, legend_str);
        legend;
    else
        h = plotCoeff(x, coeff, v, datcom);
    end
    grid on
    xlabel(labelx);
    ylabel(coeff);
    title(titlestr); 
end



