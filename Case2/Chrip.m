
%   Generation af lydsignaler

close all; clear; clc

%  Chirp signal specs:
fs = 48000;
f1 = 500;
Tdur = 10;
N  = Tdur*fs;
n  = 0:N-1;

chrip = sin(pi*(f1/fs*n/N).*n);     %   Chrip signal
sound(chrip,fs)                     %   Afspille chirp signal

