clc
close all

loaddatcom
conf = conf_base;
conf.beta = datcom.states.beta;
CA_beta_vec = getcoeff("CA", conf, datcom);
P = polyfit(conf.beta, CA_beta_vec, 4);

CA0 = P(end);
CAbeta2 = P(end - 2);
CAbeta4 = P(end - 4);

figure
plotCoeff("CA", datcom.states.beta, conf, datcom);
hold on
plot(datcom.states.beta, CA0 + CAbeta2*(datcom.states.beta.^2) + + CAbeta4*(datcom.states.beta.^4));
plot(datcom.states.beta, polyval(P, datcom.states.beta));
grid on


conf = conf_base;
conf.alpha = datcom.states.alpha;
conf.beta = datcom.states.beta;

[X, Y] = meshgrid(conf.alpha, conf.beta)
Z = getcoeff2("CA", conf, datcom)'

for i = 1:length(datcom.states.alpha)
    CAb = CAbeta2*(datcom.states.beta.^2) + CAbeta4*(datcom.states.beta.^4);
    Z(:,i) = Z(:,i) - CAb';
end
Z

figure
surf(X, Y, Z);
xlabel("Alpha");
ylabel("Beta");

