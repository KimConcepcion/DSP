
clear; close all; clc

file = load('vejecelle_data.mat');
fs = file.fs;
x = file.vejecelle_data;

x_ubelastet = x(1:1000);
x_belastet = x(1000:2500);
N_ubelastet = length(x_ubelastet);
N_belastet = length(x_belastet);

%%  Opgave 1 - Dataanalyse

%   ----- Plot af vejecelle data -----
figure('name', 'Vejecelle_data figur')
plot(x)
title('Vejecelle input fra sensor med støj'), grid minor

%   Beregninger for ubelastet målinger:
x_mid_ubelastet = sum(x_ubelastet)/N_ubelastet;
x_var_ubelastet = sum((x_ubelastet-x_mid_ubelastet).^2)/N_ubelastet;
x_stdaflg_ubelastet = sqrt(x_var_ubelastet);

%   Beregninger for belastet målinger:
x_mid_belastet = sum(x_belastet)/N_belastet;
x_var_belastet = sum((x_belastet-x_mid_belastet).^2)/N_belastet;
x_stdaflg_belastet = sqrt(x_var_belastet);

%   Histogrammer
x_ubelastet = x_mid_ubelastet + x_stdaflg_ubelastet*randn(1, N_ubelastet);
x_belastet = x_mid_belastet + x_stdaflg_belastet*randn(1, N_belastet);
Nbins = 25;

figure('name', 'Histogram for ubelastet måling') 
h1 = histogram(x_ubelastet, Nbins);
title('Histogram for ubelastet måling')
grid minor

figure('name', 'Histogram for belastet måling') 
h2 = histogram(x_belastet, Nbins);
title('Histogram for belastet måling')
grid minor

%   Effektspekter
X_ubelastet = fft(x_ubelastet);
P_ubelastet = X_ubelastet.*conj(X_ubelastet);

X_belastet = fft(x_belastet);
P_belastet = X_belastet.*conj(X_belastet);

figure('name', 'Hvidstøj')
subplot(211)
plot(x_ubelastet)
grid minor, title('Plot af ubelastet målinger')
subplot(212)
plot(x_belastet)
grid minor, title('Plot af ubelastet målinger')

%   Ser bort fra DC offset
figure('name', 'Effektspektrum, hvidstøj')
subplot(211)
plot(1:N_ubelastet-1, P_ubelastet(2:end))
grid minor, title('Effektspektrum for ubelastet målinger')
subplot(212)
plot(1:N_belastet-1, P_belastet(2:end))
grid minor, title('Effektspektrum for belastet målinger')

%   Afstand mellem bit niveauer i gram
%   Den mindste forskel mellem bitniveauer er 1 ift. aflæsning.

%%  Opgave 2 - Design af Midlingsfilter

%   MA filter
M1 = 10;
M2 = 50;
M3 = 100;

hMA1 = 1/M1*ones(1, M1);
hMA2 = 1/M2*ones(1, M2);
hMA3 = 1/M3*ones(1, M3);

yMA1 = filter(hMA1, 1,  x);
yMA2 = filter(hMA2, 1,  x);
yMA3 = filter(hMA3, 1,  x);

figure
plot(x), hold on
plot(yMA1, 'r'), grid minor

figure
plot(x), hold on
plot(yMA2, 'r'), grid minor

figure
plot(x), hold on
plot(yMA3, 'r'), grid minor

%   Eksponentielt midlingsfilter
alpha_1 = 2/(M1+1);
alpha_2 = 2/(M2+1);
alpha_3 = 2/(M3+1);

a1 = (1-(1-alpha_1));
a2 = (1-(1-alpha_2));
a3 = (1-(1-alpha_3));

yEXP1 = filter(a1, 1, x);
yEXP2 = filter(a2, 1, x);
yEXP3 = filter(a3, 1, x);

figure
plot(x), hold on
plot(yEXP1, 'r'), grid minor

figure
plot(x), hold on
plot(yEXP2, 'r'), grid minor

figure
plot(x), hold on
plot(yEXP3, 'r'), grid minor
%%  Opgave 3 - Systemovervejelser
