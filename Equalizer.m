
%   DSB Øvelse 2 Audio Equalizer
%   Opgaven: 
%   Lav en 5-bånds audioequalizer i Matlab. Equalizeren skal kunne
%   justere niveauet i fem forskellige frekvensbånd (LP, BP1, BP2, Bp3, HP)
%   fordelt over det hørbare frekvensområde. Niveauet i hvert bånd skal
%   kunne justeres med +/- 12dB. Equalizeren skal bestå af både FIR og IIR
%   filtre. 
%   Eksperimentér med knækfrekvenser, filterorden og filtertyper. I skal
%   kunne vise equalizerens samlede impuls-og frekvensrespons (amplitude 
%   og fase)

%   Authors: Lasse Frederiksen, Mark Chylinski og Kim Nielsen

close all; clear; clc

%%  Overordnet:
N = 2;
N_HP = 16;
fs = 44100; %   Samplerate
L = 100;    %   Bruges til at finde de første 100 samples af impulsrespons
test = audioread('test.mp3');   %   inputsignal:
%%  FFT specs:
Ndft= 1024;
k = 0:Ndft-1;
%% forstærkning [gg]:
LP_g = 10^(12/20);
B1_g = 10^(-12/20);
B2_g = 10^(12/20);
B3_g = 10^(12/20);
HP_g = 10^(-12/20);
%%  cutoff frekvenser:
LPfc = 60;    
b1_fc1 = 65;    
b1_fc2 = 950;
b2_fc1 = 1000;   
b2_fc2 = 3400;
b3_fc1 = 3500;  
b3_fc2 = 9000;
HPfc = 10000;
%% Implementering af filtre:
bLP = fir1(22, 2*LPfc/fs);                       %   FIR lavpas filter
[b1, a1] = butter(N, 2*[b1_fc1 b1_fc2]/fs);      %   Butterworth IIR båndpas bas
[b2, a2] = butter(N, 2*[b2_fc1 b2_fc2]/fs);      %   Butterworth IIR båndpas mellemtone
[b3, a3] = butter(N, 2*[b3_fc1 b3_fc2]/fs);      %   Butterworth IIR båndpas diskant
bHP = fir1(N_HP, 2*HPfc/fs, 'high', blackman(N_HP+1));             %   FIR højpas filter

bLP = bLP*LP_g;
b1 = b1*B1_g;
b2 = b2*B2_g;
b3 = b3*B3_g;
bHP = bHP*HP_g;

%   Filtrering af lydsignal ud fra de implementerede filtre:
LP = filter(bLP, 1, test);
B1 = filter(b1, a1, test);
B2 = filter(b2, a2, test);
B3 = filter(b3, a3, test);
HP = filter(bHP, 1, test);
%%  Implementering af equalizer:
eqz = LP+B1+B2+B3+HP;
%% Afspil musik
%soundsc(eqz, fs)

%%  Plot af lavpasfilter:--------------------------------------------------
figure
subplot(2, 1, 2)
stem(0:22, bLP)
title('FIR Lavpasfilter - Impulsrespons')
xlabel('n')
grid

subplot(2, 2, 1)
HLP = fft(bLP, Ndft);
plot(k(1:Ndft/2)*fs/Ndft, 20*log10(abs(HLP(1:Ndft/2))))
title('FIR Lavpasfilter - Amplituderespons')
xlabel('f [Hz]'), ylabel('[dB]')
%axis([0 fs/10, -20 12])
grid

subplot(2, 2, 2)
plot(k(1:Ndft/2)*fs/Ndft, angle(HLP(1:Ndft/2))*180/pi)
title('FIR Lavpasfilter - Faserespons')
xlabel('f [Hz]'), ylabel('[deg]')
xlim([0 fs/2])
grid
%%  Plot af højpasfilter:--------------------------------------------------
figure
subplot(2, 1, 2)
stem(0:N_HP, bHP)
title('FIR Højpasfilter - Impulsrespons')
xlabel('n')
grid

subplot(2, 2, 1)
HHP = fft(bHP, Ndft);
plot(k(1:Ndft/2)*fs/Ndft, 20*log10(abs(HHP(1:Ndft/2))))
title('FIR Højpasfilter - Amplituderespons')
xlabel('f [Hz]'), ylabel('[dB]')
%axis([0 fs/10, -20 12])
grid

subplot(2, 2, 2)
plot(k(1:Ndft/2)*fs/Ndft, angle(HHP(1:Ndft/2))*180/pi)
title('FIR Højpasfilter - Faserespons')
xlabel('f [Hz]'), ylabel('[deg]')
xlim([0 fs/2])
grid
%%  Plot af Båndpasfilter (B1)---------------------------------------------
figure
subplot(2, 1, 2)
hB1 = impz(b1, a1, 1000);
plot(0:1000-1, hB1)
title('IIR Båndpasfilter B1 - Impulsrespons')
xlabel('n')
grid

subplot(2, 2, 1)
HB1 = fft(b1, Ndft)./fft(a1, Ndft);
semilogx(k(1:Ndft/2)*fs/Ndft, 20*log10(abs(HB1(1:Ndft/2))))
title('IIR Båndpasfilter B1 - Amplituderespons')
xlabel('f [Hz]'), ylabel('[dB]')
axis([0 fs/2, -20 12])
grid

subplot(2, 2, 2)
semilogx(k(1:Ndft/2)*fs/Ndft, angle(HB1(1:Ndft/2))*180/pi)
title('IIR Båndpasfilter B1 - Faserespons')
xlabel('f [Hz]'), ylabel('[deg]')
grid
%%  Plot af Båndpasfilter (B2)---------------------------------------------
figure
subplot(2, 1, 2)
hB2 = impz(b2, a2, 300);
plot(0:300-1, hB2)
title('IIR Båndpasfilter B2 - Impulsrespons')
xlabel('n')
grid

subplot(2, 2, 1)
HB2 = fft(b2, Ndft)./fft(a2, Ndft);
semilogx(k(1:Ndft/2)*fs/Ndft, 20*log10(abs(HB2(1:Ndft/2))))
title('IIR Båndpasfilter B2 - Amplituderespons')
xlabel('f [Hz]'), ylabel('[dB]')
axis([0 fs/2, -20 12])
grid

subplot(2, 2, 2)
semilogx(k(1:Ndft/2)*fs/Ndft, angle(HB2(1:Ndft/2))*180/pi)
title('IIR Båndpasfilter B2 - Faserespons')
xlabel('f [Hz]'), ylabel('[deg]')
grid

%%  Plot af Båndpasfilter (B3)---------------------------------------------
figure
subplot(2, 1, 2)
hB3 = impz(b3, a3, 100);
plot(0:100-1, hB3)
title('IIR Båndpasfilter B3 - Impulsrespons')
xlabel('n')
grid

subplot(2, 2, 1)
HB3 = fft(b3, Ndft)./fft(a3, Ndft);
semilogx(k(1:Ndft/2)*fs/Ndft, 20*log10(abs(HB3(1:Ndft/2))))
title('IIR Båndpasfilter B3 - Amplituderespons')
xlabel('f [Hz]'), ylabel('[dB]')
axis([0 fs/2, -20 12])
grid

subplot(2, 2, 2)
semilogx(k(1:Ndft/2)*fs/Ndft, angle(HB3(1:Ndft/2))*180/pi)
title('IIR Båndpasfilter B3 - Faserespons')
xlabel('f [Hz]'), ylabel('[deg]')
grid
%%  Plots af lyd før/efter equalizer:--------------------------------------
figure
subplot(211)
plot(test)
title('Plot af lyd før equalizer')
grid

subplot(212)
plot(eqz)
title('Plot af lyd efter equalizer')
grid

figure
H_eqz = HLP+HB1+HB2+HB3+HHP;
semilogx(k(1:Ndft/2)*fs/Ndft, 20*log10(abs(H_eqz(1:Ndft/2))))
grid
title('Amplituderespons for alle filtre samlet')