
%   Caseprojekt 4: SONAR
%   Team 4: Lasse A. Frederiksen, Kim C. Nielsen og Mads Villadsen
%   Dato: 11-05-2018

clear; close all; clc

%%  Init #################################################################################
v_lyd = 340;
fstart = 20;
fstop = 11000;
fs = 1000;
f1 = 500;
Tdur = 10;
Ts = 1/fs;
N  = Tdur*fs;
n  = 0:N-1;
delay = 200;
delay_2 = 10;
%%  Opgave 1 #############################################################################

%  Chirp signal opsætning:
chirp_tx = sin(pi*(f1/fs*n/N).*n);          %   Chirp signal - (afsendersignal)
chirp_rx = [zeros(1, delay) 1/2*chirp_tx];  %   Forsinket chirp - (modtagersignal)
chirp_rx_close = [zeros(1, delay_2) chirp_tx zeros(1, 190)];  %   Forsinket chirp - (modtagersignal)

d = length(chirp_rx);
sigma = sqrt(2);
noise = sigma * randn(1,d);
chirp_rx_noise = noise + chirp_rx + chirp_rx_close;
figure('name', 'Simulering')
plot(chirp_tx), hold on, 
plot(chirp_rx_noise, 'r')
title('Simulering af chirp_{TX} og chirp_{RX}'), grid minor, 
xlim([0 1000]), xlabel('tid [s]'), legend('chirp_{TX}', 'chirp_{RX}')

[c, n_lags] = xcorr(chirp_rx_noise, chirp_tx);      %   Krydskorrelation
[~, n_maxlag] = max(c);                       %   Højeste punkt, er hvor signaler ligner
                                              %   mest hinanden
figure
stem(n_lags, c), grid minor, title('Krydskorrelation'), xlim([0 300])

N_delay = n_lags(n_maxlag);
dist = Ts*delay*v_lyd*1/2;
fprintf('Afstand fra transmission til objekt: %.2f meter\n', dist);

%%  Opgave 4 #############################################################################

