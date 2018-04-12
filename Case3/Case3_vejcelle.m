
%   Caseprojekt 3: midling af sensordata
%   Team 4: Lasse A. Frederiksen, Kim C. Nielsen og Mads Villadsen
%   Dato: 13-04-2018

clear; close all; clc;

file = load('vejecelle_data.mat');
fs = file.fs;                       %   Indl�sning af samplerate
x = file.vejecelle_data;            %   Indl�sning af data fra vejecelle
N = length(x);                      %   L�ngde af data fra vejecelle
n = 0:N-1;

x_ubelastet_data = x(1:1000);       %   Ubelastet data fra vejecelle
x_belastet_data = x(1000:2500);     %   Belastet data fra vejecelle
N_ubelastet_data = length(x_ubelastet_data); %   L�ngde af ubelastet data
N_belastet_data = length(x_belastet_data);   %   L�ngde af belastet data

%%  Opgave 1 - Dataanalyse

%   ----- Plot af vejecelle data -----
figure('name', 'Vejecelle_data')
plot(x)
title('Vejecelle input fra sensor med st�j'), grid minor

%   1. Beregning af middelv�rdi, spredning og varians af ubelastet og
%   belastet (med lod p�) tilstand

%   Beregninger for ubelastet m�linger:
x_mid_ubelastet = sum(x_ubelastet_data)/N_ubelastet_data;
x_var_ubelastet = sum((x_ubelastet_data-x_mid_ubelastet).^2)/...
    N_ubelastet_data;
x_stdaflg_ubelastet = sqrt(x_var_ubelastet);
%   Beregninger for belastet m�linger:
x_mid_belastet = sum(x_belastet_data)/N_belastet_data;
x_var_belastet = sum((x_belastet_data-x_mid_belastet).^2)/N_belastet_data;
x_stdaflg_belastet = sqrt(x_var_belastet);

%  2. Plot histogrammer for de to tilstande
Nbins = 30;
x_ubelastet = x_mid_ubelastet + x_stdaflg_ubelastet*randn(1,...
    N_ubelastet_data);
x_belastet = x_mid_belastet + x_stdaflg_belastet*randn(1, N_belastet_data);

figure('name', 'Histogrammer')
subplot(1, 2, 1)
histogram(x_ubelastet_data);
title('Histogram for ubelastet m�ling'), grid minor
subplot(1, 2, 2)
histogram(x_belastet_data);
title('Histogram for belastet m�ling'), grid minor

%   3. Plot effektspektre for de to tilstande. Ligner det hvidst�j?
X_ubelastet = fft(x_ubelastet_data);
P_ubelastet = X_ubelastet.*conj(X_ubelastet);
X_belastet = fft(x_belastet_data);
P_belastet = X_belastet.*conj(X_belastet);

%   Ser bort fra DC offset, hvorfor der startes fra 1 og ikke 0 og fra 2
%   p� den horisontale akse. DC offsettet ses ogs� bort fra ifm. de
%   matricer som angiver den ubelastede og den belastede effekt, hvorfor
%   begge matricer g�r fra 2 til enden af hver matrice.
figure('name', 'Effektspektrum, hvidst�j')
subplot(2, 1, 1), plot(1:N_ubelastet_data-1, P_ubelastet(2:end))
grid minor, title('Effektspektrum for ubelastet m�linger')
subplot(2, 1, 2), plot(1:N_belastet_data-1, P_belastet(2:end))
grid minor, title('Effektspektrum for belastet m�linger')

%   4. Hvad er afstanden imellem bit-niveauer i gram? (dvs. v�rdi af LSB) 
%   Den mindste forskel mellem bitniveauer er 1 ift. afl�sning. Dette ses
%   ogs� beskrevet og indikeret i journalen som dokumenterer dette matlab
%   script.

%%  ##### Opgave 2 - Design af Midlingsfilter #####

%%  Delopgave 1
%   1. Pr�v med f.eks. et midlingsfilter med 10, 50, 100
%   filterkoefficienter(tappe) - plot histogrammer og m�l variansen/st�j
%   effekten.

%   Antal filterkoefficienter
M1 = 10;
M2 = 50;
M3 = 100;

hMA1 = 1/M1*ones(1, M1);      %   MA midlingsfilter, M=10   
hMA2 = 1/M2*ones(1, M2);      %   MA midlingsfilter, M=50  
hMA3 = 1/M3*ones(1, M3);      %   MA midlingsfilter, M=100  
yMA1 = filter(hMA1, 1, x);
yMA2 = filter(hMA2, 1, x);   
yMA3 = filter(hMA3, 1, x);

%   ----- St�jeffekt og reduktion for belastet og ubelastet -----
midling(hMA1, x_ubelastet_data, M1, N_ubelastet_data, '#Ubelastet');
midling(hMA2, x_ubelastet_data, M2, N_ubelastet_data, '#Ubelastet');
damping_ubelastet=midling(hMA3, x_ubelastet_data, M3, N_ubelastet_data,...
    '#Ubelastet');

midling(hMA1, x_belastet_data, M1, N_belastet_data, '#Belastet');
midling(hMA2, x_belastet_data, M2, N_belastet_data, '#Belastet');
damping_belastet=midling(hMA3, x_belastet_data, M3, N_belastet_data,...
    '#Belastet');

hMA1_step_resp = filter(hMA1, 1, ones(1, 2*M1));    %   steprespons, M=10
hMA2_step_resp = filter(hMA2, 1, ones(1, 2*M2));    %   steprespons, M=50
hMA3_step_resp = filter(hMA3, 1, ones(1, 2*M3));    %   steprespons, M=100

%   ----- Plot af impulsrespons og stepresons -----
figure('name', 'Impulsrepons og steprespons for MA filter')
subplot(3, 2, 1)
stem(0:M1-1, hMA1), title('Impulsrespons for M=10'), grid minor
ylim([0 0.15])
subplot(3, 2, 2)
stem(0:2*M1-1, hMA1_step_resp), title('Steprespons for M=10'), grid minor
ylim([0 1.2])
subplot(3, 2, 3)
stem(0:M2-1, hMA2), title('Impulsrespons for M=50'), grid minor
ylim([0 0.03])
subplot(3, 2, 4)
stem(0:2*M2-1, hMA2_step_resp), title('Steprespons for M=50'), grid minor
subplot(3, 2, 5)
stem(0:M3-1, hMA3), title('Impulsrespons for M=100'), grid minor
ylim([0 0.02])
subplot(3, 2, 6)
stem(0:2*M3-1, hMA3_step_resp), title('Steprespons for M=100'), grid minor


%   ----- Plot af MA filter ift. data fra vejecelle, ubelastet -----
figure('name', 'MA midlingsfiltre')
plot(x), hold on
plot(yMA1, 'r', 'linewidth', 1) 
plot(yMA2, 'g', 'linewidth', 2) 
plot(yMA3, 'c',  'linewidth', 3) 
grid minor, ylim([1000 1530])
legend('inputsignal', 'M=10', 'M=50', 'M=100'), title('MA filtre')

%   Ubelastet data filtrering  
yMA1_ubelastet = filter(hMA1, 1, x_ubelastet_data);
yMA2_ubelastet = filter(hMA2, 1, x_ubelastet_data);   
yMA3_ubelastet = filter(hMA3, 1, x_ubelastet_data);
%   Belastet data filtrering  
yMA1_belastet = filter(hMA1, 1, x_belastet_data);
yMA2_belastet = filter(hMA2, 1, x_belastet_data);   
yMA3_belastet = filter(hMA3, 1, x_belastet_data);

%   ----- Historgram for MA filtre, ubelastet -----
figure('name', 'Histogrammer for MA filtre, ubelastet')
subplot(1, 3, 1), histogram(yMA1_ubelastet);
title('MA filter, M=10'), grid minor, axis([1000 1200 0 720])
subplot(1, 3, 2), histogram(yMA2_ubelastet);
title('MA filter, M=50'), grid minor, axis([900 1200 0 920])
subplot(1, 3, 3), histogram(yMA3_ubelastet);
title('MA filter, M=100'), grid minor, axis([900 1200 0 920])

%   ----- Historgram for MA filtre, belastet -----
figure('name', 'Histogrammer for MA filtre, belastet')
subplot(1, 3, 1), histogram(yMA1_belastet);
title('MA filter, M=10'), grid minor, axis([1300 1460 0 1030])
subplot(1, 3, 2), histogram(yMA2_belastet);
title('MA filter, M=50'), grid minor, axis([1300 1490 0 1320])
subplot(1, 3, 3), histogram(yMA3_belastet);
title('MA filter, M=100'), grid minor, axis([1300 1490 0 1320])

%%  Delopgave 2
%   2. Et krav til maksimal indsvingningstid kunne v�re 100 ms til et
%   praktisk vejesystem. Beregn den maksimale l�ngde af jeres FIR
%   midlingsfilter. 
Ts = 1/fs;                   %   Sample periodetid
settlingtime = 100e-3;
N_max = settlingtime/Ts;        %   Maksimal l�ngde ud fra 100ms
fprintf('\nMaksimal L�ngde af FIR midlingsfilter: [%d]\n', N_max);

%%  Delopgave 3
%   3. Pr�v ogs� med et eksponentielt midlingsfilter. Eksperimenter med
%   alfa v�rdien pr�v f.eks. at s�tte meget lavt/h�jt. Hvad er betydningen
%   af alfa v�rdien, s�ledes at i f�r samme st�j-reduktion, som jeres 100.
%   ordens FIR midlings filter
alpha_1 = 2/(M1+1);         %   Lille alfa v�rdi med M=10
alpha_2 = 2/(M3+1);         %   Stort alfa v�rdi med M=100
b1 = alpha_1;               %   b koefficient med M=10
b2 = alpha_2;               %   b koefficient med M=100
a1 = [1 -(1-alpha_1)];      %   a koefficient med M=10
a2 = [1 -(1-alpha_2)];      %   a koefficient med M=100
yEXP1 = filter(b1, a1, x);  %   Filtrering af data fra vejecelle, M=10 
yEXP2 = filter(b2, a2, x);  %   Filtrering af data fra vejecelle, M=100  

figure('name', 'Exp. midlingsfilter')
plot(x), hold on
plot(yEXP1, 'r', 'linewidth', 1) 
plot(yEXP2, 'c', 'linewidth', 2) 
grid minor, ylim([1000 1530])
legend('inputsignal', 'M=10', 'M=100')
title('Exp. midlingsfiltre')

%%  Exp. midlingsfilter med samme d�mpning som 100. ordens MA filter
alpha = 2/(damping_ubelastet+1);
M = round((2/alpha)-1);
var_in = var(x_ubelastet_data(M:N_ubelastet_data));
var_out = var_in*alpha/(2-alpha);
fprintf('\nBem�rk! Samme st�jreduktion for MA filter med M=100\n');
fprintf('Reduktion i st�jeffekt, ubelastet: %.2f\n', var_in/var_out);

alpha = 2/(damping_belastet+1);
M = round((2/alpha)-1);
var_in = var(x_belastet_data(M:N_belastet_data));
var_out = var_in*alpha/(2-alpha);
fprintf('\nBem�rk! Samme st�jreduktion for MA filter med M=100\n');
fprintf('Reduktion i st�jeffekt, belastet: %.2f\n', var_in/var_out);

b = alpha;
a = [1 -(1-alpha)];
y_exp = filter(b, a, x);
figure('name', 'Exp filter, M=9')
plot(x), hold on, 
plot(y_exp, 'r', 'linewidth', 1), plot(yMA3, 'c',  'linewidth', 2)
title('Exp filter, M=9'), grid minor, ylim([980 1500])
