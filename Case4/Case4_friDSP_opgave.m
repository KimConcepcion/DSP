
%   Caseprojekt 4: SONAR
%   Team 4: Lasse A. Frederiksen, Kim C. Nielsen og Mads Villadsen
%   Dato: 11-05-2018

clear; close all; clc

%%  Init #################################################################################
%   Indlæs data fra ccs:
input_data = load('Input_data.dat');
output_data = load('Recorded_data.dat');

%   Specifikationer for simulering:
v_lyd = 340;
fs = 1000;
f1 = 500;
Tdur = 10;
Ts = 1/fs;
N  = Tdur*fs;
n  = 0:N-1;
delay = 200;

%   Specifikationer for data indlæst fra ccs:
fs_c55x = 16000;
Ts_c55x = 1/fs_c55x;

%%  Opgave 1 - Signalgenerering og simulering ############################################
%  Chirp signal opsætning:
x = sin(pi*f1/fs*n/N);
chirp_tx = sin(pi*(f1/fs*n/N).*n);                %   Chirp signal - (afsendersignal)
chirp_rx_clean = [zeros(1, delay) 1/2*chirp_tx];  %   Forsinket chirp - (modtagersignal)

%   Hvidstøj:
var_n = 0.3;
stdafv_n = sqrt(var_n);
noise = stdafv_n*randn(1, length(chirp_rx_clean));
chirp_rx_noise = chirp_rx_clean + noise;                %   Støjfyldt chirp

%   Plots af afsender-signal & modtager-signal:
figure('name', 'Simulering')
plot(chirp_tx, 'linewidth', 1.5), hold on, 
plot(chirp_rx_noise, 'r'), plot(chirp_rx_clean, 'c', 'linewidth', 1.5)
title('Simulering af chirp_{TX} og chirp_{RX}'), grid minor, 
xlim([0 1000]), xlabel('tid [s]'), legend('chirp_{TX}', 'chirp_{RX-støjfyldt}', ...
    'chirp_{RX-clean}')

%   Krydskorrelation:
[c, n_lags] = xcorr(chirp_rx_noise, chirp_tx);
[~, n_maxlag] = max(c);                       

figure('name', 'krydskorrelation - simulering')
stem(n_lags, c), grid minor, title('Krydskorrelation (simulering)') 
xlabel('n')

N_delay = n_lags(n_maxlag);
dist = Ts*N_delay*v_lyd*1/2;
fprintf('Opg 1: Afstand fra transmission til objekt: %.2f meter\n', dist);

%%  Opgave 4 - Analyse i Matlab ##########################################################
%   Plots af praktiske målinger:
figure('name', 'Praktiske målinger')
subplot(211)
plot(input_data), title('input_{data}'), grid minor
subplot(212)
plot(output_data), title('output_{data}'), grid minor, 
xlabel('tid [s]')

%   Krydskorrelation:
[c, n_lags] = xcorr(output_data, input_data);
[~, n_maxlag] = max(c);                          

figure('name', 'krydskorrelation - praktiske målinger')
plot(n_lags, c), grid minor, title('Krydskorrelation (praktisk måling)')

N_delay_C55x = n_lags(n_maxlag);
dist = Ts_c55x*N_delay_C55x*v_lyd*1/2;
fprintf('Opg 4: Afstand fra transmission til objekt: %.2f meter\n', dist);