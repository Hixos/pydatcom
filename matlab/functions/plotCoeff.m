function [h, x, y] = plotCoeff(c, x, conf, datcom, legend)
    y = getcoeff(c, conf, datcom);
    if nargin > 4
       h =  plot(x, y, 'DisplayName', legend);
    else
       h = plot(x, y);
    end
end
