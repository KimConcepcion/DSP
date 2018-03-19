
clear; close all; clc

file = load('vejecelle_data.mat');
fs = file.fs;
x = file.vejecelle_data;

x_ubelastet = x(1:1000);
x_belastet = x(1000:2500);
N_ubelastet = length(x_ubelastet);
N_belastet = length(x_belastet);

%%  Opgave 1 - Dataanalyse

%   Beregninger for ubelastet målinger:
x_mid_ubelastet = sum(x_ubelastet)/N_ubelastet;
x_var_ubelastet = sum((x_ubelastet-x_mid_ubelastet).^2)/N_ubelastet;
x_stdaflg_ubelastet = sqrt(x_var_ubelastet);

%   Beregninger for belastet målinger:
x_mid_belastet = sum(x_belastet)/N_belastet;
x_var_belastet = sum((x_belastet-x_mid_belastet).^2)/N_belastet;
x_stdaflg_belastet = sqrt(x_var_belastet);

%   ----- Plot af vejecelle data -----
figure('name', 'Vejecelle_data figur')
plot(x)
title('Vejecelle input fra sensor med støj'), grid

%   Histogrammer

x_ubelastet = x_mid_ubelastet + x_stdaflg_ubelastet*rand(1, N_ubelastet);
x_belastet = x_mid_belastet + x_stdaflg_belastet*rand(1, N_belastet);
Nbins = 25;

figure('name', 'Histogram for ubelastet måling') 
h1 = histogram(x_ubelastet, Nbins);
title('Histogram for rand')
grid

figure('name', 'Histogram for ubelastet måling') 
h2 = histogram(x_belastet, Nbins);
title('Histogram for rand')
grid
%%  Opgave 2 - Design af Midlingsfilter


%%  Opgave 3 - Systemovervejelser

