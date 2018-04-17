
%   Caseprojekt 4: Fri DSP-opgave
%   Team 4: Lasse A. Frederiksen, Kim C. Nielsen og Mads Villadsen
%   Dato: 14-03-2018

clear; close all; clc

%%  Opgave 1

%  Chirp signal specs:
fs = 1000;
f1 = 500;
Tdur = 10;
N  = Tdur*fs;
n  = 0:N-1;
Ts = 1/fs;
chirp = sin(pi*(f1/fs*n/N).*n);     %   Chrip signal

figure
plot(n*Ts, chirp), xlim([0 1]), xlabel('tid [s]'), title('Chirp signal')
grid minor

%%  Opgave 2

%%  Opgave 3

%%  Opgave 4