function [h, y] = autoPlotCoeff(coeff, conf, datcom, legend_str, title_str)
    [x, ilabel] = getx(conf);
    confnames = ["Alpha", "Beta", "Mach", "Altitude", "Yaw", "Pitch", ...
          "Roll", "Squeeze"];
    xlabels = ["$\alpha \quad[deg]$", "$\beta \quad[deg]$", "Mach", ...
               "Altitude \quad$[m]$", "$\theta_{yaw} \quad[deg]$", ...
               "$\theta_{pitch} \quad[deg]$", "$\theta_{roll} \quad[deg]$", ...
               "$\theta_{squeeze} \quad[deg]$"];
    if nargin > 3
        [h, ~, y] = plotCoeff(coeff, x, conf, datcom, legend_str);
        legend;
    else
        [h, ~, y] = plotCoeff(coeff, x, conf, datcom);
    end
    
    
    grid on
    xlabel(xlabels{ilabel},'interpreter','latex')
    ylabel(coeff);
    if nargin > 4
        title(title_str); 
    else
        title(sprintf("%s/%s", coeff, confnames{ilabel})); 
    end
end
