
%   DFT
%   KCN

clear; close all; clc

text = 'Heil Hitler!';
fs     = 20000;
fstart = 1000;
fstop  = 2000;
Tsym   = 0.5;

x = FSKgen(text,fs,fstart,fstop,Tsym);
N = length(x);
w = exp(-1j*2*pi/N);
X = zeros(N, 1)';
DFT_x = fft(x);

for k = 0:15:N-1
for n = 0:15:N-1
    X(k+1) = X(k+1) + x(n+1)*w^(k*n);
end
end