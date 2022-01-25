close all
clc

addpath("functions");

loaddatcom

secondaryVar = "mach";

conf_base_sec = conf_base;
conf_base_sec.(secondaryVar) = datcom.states.(secondaryVar);


conf = conf_base_sec;
conf.alpha = datcom.states.alpha;
figure
plotAll(conf, datcom, secondaryVar);


conf = conf_base_sec;
conf.beta = datcom.states.beta;
figure
plotAll(conf, datcom, secondaryVar);


conf = conf_base_sec;
conf.delta_pitch = datcom.states.fin2delta1;
figure
plotAll(conf, datcom, secondaryVar);

conf = conf_base_sec;
conf.delta_roll = datcom.states.fin2delta1;
figure
plotAll(conf, datcom, secondaryVar);


conf = conf_base_sec;
conf.delta_squeeze = datcom.states.fin2delta1;
figure
plotAll(conf, datcom, secondaryVar);

function plotAll(conf, datcom, secondaryVar)
tiledlayout(2,3);

if nargin < 3
nexttile
autoPlotCoeff("CA", conf, datcom);
nexttile
autoPlotCoeff("CN", conf, datcom);
nexttile
autoPlotCoeff("CY", conf, datcom);

nexttile
autoPlotCoeff("CLL", conf, datcom);
nexttile
autoPlotCoeff("CM", conf, datcom);
nexttile
autoPlotCoeff("CLN", conf, datcom);
else
nexttile
secondaryPlot("CA", conf, datcom, secondaryVar);
nexttile
secondaryPlot("CN", conf, datcom, secondaryVar);
nexttile
secondaryPlot("CY", conf, datcom, secondaryVar);

nexttile
secondaryPlot("CLL", conf, datcom, secondaryVar);
nexttile
secondaryPlot("CM", conf, datcom, secondaryVar);
nexttile
secondaryPlot("CLN", conf, datcom, secondaryVar);
end

end

function secondaryPlot(coeff, conf, datcom, secondaryVar)
    varname = secondaryVar;
    v2 = conf.(secondaryVar);
    for i=1:length(v2)
        newconf = conf;
        newconf.(secondaryVar) = v2(i);
        legend_str = sprintf("%s = %.2f", varname, v2(i));
        
        autoPlotCoeff(coeff, newconf, datcom, legend_str);
        hold on
    end
end