
%   Caseprojekt 2: Notch filter
%   Team 4: Lasse A. Frederiksen, Kim C. Nielsen og Mads Villadsen
%   Dato: 14-03-2018

clear; close all; clc

%%  Opgave 1 - Analyse af inputsignal
[x, fs] = audioread('musik_tone_48k.ogg');
N = length(x);
k = 0:N-1;
ampl = abs(fft(x)*2/N);
A = max(ampl);
I = find(ampl == A);
f = I*fs/N;

fprintf('Maksimal amplitude/tonehøjde: %.3f\n', A);
fprintf('f1: %.2f [Hz], f2: %.2f [Hz]\n', f(1), f(2));

%   Plots
figure
plot(x), title('Tidssignal, musiksignal'), grid, xlabel('Tid [s]')

figure, plot(k*fs/N, ampl)
hold on, plot(f, A, 'rO', 'linewidth', 3) 
title('Amplitudespekter, musiksignal (ikke filtreret)')
xlabel('Frekvens [Hz]'), xlim([0 fs]), grid

figure
spectrogram0(x(1:I*2), 1024, 1024, 20, fs);
title('Spektogram, musiksignal')

%%  Opgave 2 - Filterdesign
omega = 2*pi*f(1)/fs;       %   Normeret vinkelfrekvens
rz = 1;                     %   Radius for nulpunkt
rp = 0.9;                   %   Radius for pol

z1 = rz*exp(1j*omega);      %   Beregning af 1. nulpunkt
z2 = conj(z1);              %   Beregning af 2. nulpunkt
p1 = rp*exp(1j*omega);      %   Beregning af 1. pol
p2 = conj(p1);              %   Beregning af 2. pol

b = [1 -(z1+z2) 1];         %  Nulpunkter i decimalformat
a = [1 -(p1+p2) 0.81 ];     %  Poler i decimalformat
b15 = [S15(b(1)) S15(b(2)/2) S15(b(3))];    %  Nulpunkter i S15 format
a15 = [S15(a(1)) S15(a(2)/2) S15(a(3))];    %  Poler i S15 format

fprintf('Filterkoefficienter i S15 format:\n');
fprintf('b koefficienter: [ %d ]\n', b15);
fprintf('a koefficienter: [ %d ]\n', a15);

y = filter(b, a, x);        %  Filtrere musiksignal for ønsket frekvens
N = length(y);              %  Antal Samples af filtreret musiksignal
ampl = abs(fft(y)*2/N);

%   Plots
figure
plot(k*fs/N, ampl)
xlim([0 fs]), xlabel('f [Hz]')
title('Amplitudespekter, filtreret musiksignal'), grid

figure
zplane(b, a, 'r')
title('Pol/Nulpunktsdiagram, 2. ordens IIR Notch filter')
grid