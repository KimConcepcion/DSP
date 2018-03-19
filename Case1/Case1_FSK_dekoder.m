
%   Kursus: E4DSA
%   Dato:   14. febuar 2018
%   Gruppe: Team 4
%   Gruppemedlemmer: Mads Villadsen, Kim Nielsen & Lasse Frederiksen

%   Denne opgave g�r ud p� at bygge et system der muligg�r kommunikation
%   mellem to grupper, som hver har en mikrofon og en h�jtaller. Hermed
%   g�r opgaven ud p� at sende beskeder til hinanden, hvor der unders�ges
%   hvilke parametre som kan have en afg�rende betydning for
%   virkem�den af systemet.
clear; close all
%% 1.1 generering af lydsignal
% text = 'Do ya feel lucky? Well, do ya, punk';
text = 'Hello!';

fs     = 20000;
fstart = 1000;
fstop  = 2024;
Tsym   = 0.5;
x = FSKgen(text,fs,fstart,fstop,Tsym);

N = length(x);
k = 0:N-1;

%sound(x,fs)
%% 1.2 Analys�r signalet for at finde ud af, hvilke karakterer, som svarer 
%  til hvilke frekvenser. I skal se p� signalet i b�de tids- og frekvens-dom�net.

figure
plot(x(Tsym*fs-100:Tsym*fs+100)), grid

figure
plot(k*fs/N,abs(fft(x))/N*2), grid
xlim([fstart fstop])

% Ud fra det som vi kan se i vores lydsignal og pga. af at vi se at der er 
% 256 forskellige ascii v�rdier kan vi pga. af det tage vores de 1000 Hz
% der er i mellem vores Fstart og Fstop og dividere med 256 for at finde ud
% af hvor langt der vil v�re mellem hver ascii v�rdi ogs� finde ud hvor de
% karaktere man reelt kan skrive med et keyboard starter som var ved 1125
% med space ogs� vil den hver karakter komme ind ca. 3.9 Hz efter hinanden
% og ud fra det kan vi finde ud af hvilken frekvens der svarer til hvilken
% karakter.

%% 1.3 analyser signalet vha. short-time fuorier transform -dvs. med 
%  med spektrogram-plot forklar trade-off mellem opl�sningen og i tid og
%  frekvens


figure
spectrogram0(x,512,512,20,fs);
%% Opgave 2 Dekodning
%Vi skal her lave en dekoder til en lydfil, som vi har f�et fra en anden
%gruppe. Dekoderen skal g�re det modsatte af hvad der blev gjort i opgave 1

[y,fs] = audioread('signalT42.wav'); 
%Audioread bliver brugt til at l�se lydfilen ind.

yMono = sum(y, 2) / size(y, 2);
%Lydfilen kommer som dualchannel og vi skal kun bruge den som monochannel.

x = yMono';
%y v�rdien er et s�jlediagram men vi vil gerne bruge det som et
%r�kkediagram.

% Andre signaler
y1 = audioread('close_signal.wav');
y2 = audioread('far_away.wav');
y1mono = sum(y1,2)/size(y1,2);
y2mono = sum(y2,2)/size(y2,2);
x1 = y1mono';
x2 = y2mono';

fstart = 1000;
fstop  = 2024;
Tsym   = 0.5;
%Disse 3 v�rdier har vi f�et givet fra den anden gruppe for at lave dekoder
%processen lidt nemmere.

windowstart = 0.1;
windowstop = Tsym - windowstart;
%Window-start og -stop bliver brugt til at skabe et omr�de, hvor vi ide vi
%kan finde det h�jeste punkt i vores for loop, som kommer senere

N = length(x);
%Finder l�ngden af vores x-v�rdier

Tdur = N/fs;
%Finder tidsl�ngden.

chars = Tdur/Tsym;
%Finder hvor mange bogstaver der i lydfilen.

charray = []; 
%Definerer tomt array.

%Nedenst�ende forloop bliver brugt til at dekode lydfilen s� vi kan f�
%bogstaverne ud af lydsignalet
    for k = 0:chars-1
        
        Start = floor((windowstart+Tsym*k)*(fs));
        Stop = ceil((windowstop+Tsym*k)*(fs));
        %Finder v�dierne for vindues omr�det til at start og slutte
        xny=x(Start:Stop);
        %Tager kun det omr�de i x som vi vil have fat i.
        xny_1=x1(Start:Stop);
        xny_2=x2(Start:Stop);
        
        N_xny=length(xny);
        %Finder l�ngden af xny vindues omr�det
        
        X=(abs(fft(xny)))*2/N_xny;
        %Fourie transformerer vores signal. Her tager vi ikke alle
        %v�rdierne for x(n) da dette ikke er n�dvendigt for vi vil nemlig
        %kun kigge p� et omr�de af v�rdierne i x(n).
        X1=abs(fft(xny_1)*2/length(xny_1));
        X2=abs(fft(xny_2)*2/length(xny_2));
        
        [Xmax,q] = max(X);
        %Finder max punkterne for vores fourie transformerede signal. Det
        %vigtige her er frekvensbindet som vi kalder q, da vi s� kan finde
        %frekvensen for det h�jeste punkt.
        
        N = length(X);
        %Finder l�ngden af det fourie transformede signals omr�de.
        
        freq = q *(fs/ N);
        %Finder frekvensen af den h�jeste v�rdi inden for omr�det.
        
        output = ceil(freq-fstart)*(1/4);
        %Udregner vores output decimaltal, der bliver dividere med 4 her
        %fordi at (fstop-fstart)/256 = 4 s� vi kan udregne decimaltallet
        
        if(output == 31.7500), output = 32; end
        if(output == 51.7500), output = 52; end
        %Vi har debugget os frem til at der er noget usikker i disse to
        %v�rdier og s� har vi korrigeret det til at v�rdierne passer
        %korrekt.
        
        ch = char(output);
        % Finder bogstavet
        charray = [charray ch];
        %Putter bogstavet ind i det tomme array.
    end

fprintf('Her er bogstaverne: %s \n', charray);
%Udskriver bogstaverne, som er blevet fundet.
%%  SNR  - Signal st�j forhold

%   SNR i frekvensdom�net kan udregnes som summen af effektsamples over
%   t�rskelv�rdi delt med summen af effektsamples under t�rkselv�rdi.
%   T�rskelv�rdien skal ligge over st�jgulvet. 

%       sum(|X(k)|^2) over t�rskelv�rdi
%SNR = -------------------------------------    Lyons D-19
%       sum(|X(k)|^2) under t�rskelv�rdi

k = 0:N-1;  
P = X.*conj(X);     %   Effektspektrum for 1. signal
P1 = X1.*conj(X1);  %   Effektspektrum for 2. signal
P2 = X2.*conj(X2);  %   Effektspektrum for 3. signal

%   F�rste signal
figure, plot(k*fs/N, 10*log10(P))
title('Effektspektrum ud fra DFT')
xlim([0 fs/2])
xlabel('Analysefrekvens k - [Hz]'), grid

fprintf('V�lg en vertikal t�rskelv�rdi som ligger lidt over st�jgulvet.\n');
%[~, y] = ginput(1);     %   Input fra mus - brug til at justere SNR
th_dB = -44.28;              %   Afl�s en t�rskelv�rdi - akse er i dB
th = 10^(th_dB/10);     %   Omregnet til gg
fprintf('Afl�st t�rskelv�rdi i dB med klik: %f [dB]\n', th_dB);
% En matrix som samler samples der ligger over eller er lig t�rskelv�rdien
% afl�st fra ginput funktionen
P_over_th = P(P >= th);
%   matrix som samler samples der ligger under t�rskelv�rdi
P_under_th = P(P < th);
%   beregning af SNR line�rt - fra Lyons D-19
SNR_frekvens = sum(P_over_th) / sum(P_under_th);
SNR_frekvens_dB = 10*log10(SNR_frekvens);   %   SNR i dB - fra Lyons D-20
fprintf('SNR beregnet i frekvensomr�det: %f [dB]\n', SNR_frekvens_dB);

%   Herunder ses n�jagtig samme udregninger, undtaget, at det vedr�rer
%   andre signaler. Disse signaler er forskellige fra hinanden ift.
%   afstanden mellem h�jtaller og mikrofon. Signalet foroeven ligger midt
%   imellem de to signaler forneden ift. afstanden mellem mikrofon og
%   h�jtaller.

%   Andet signal - H�jtaller afspiller t�t p� mikrofon
figure, plot(k*fs/N, 10*log10(P1))
title('Effektspektrum ud fra DFT for t�t signal')
xlim([0 fs/2])
xlabel('Analysefrekvens k - [Hz]'), grid

fprintf('V�lg en vertikal t�rskelv�rdi som ligger lidt over st�jgulvet.\n');
%[~, y1] = ginput(1);    
th_dB = -42.24;              
th = 10^(th_dB/10);
fprintf('Afl�st t�rskelv�rdi i dB med klik: %f [dB]\n', th_dB);
P_over_th = P1(P1 >= th);
P_under_th = P1(P1 < th);
SNR_frekvens_1 = sum(P_over_th) / sum(P_under_th);
SNR_frekvens_dB_1 = 10*log10(SNR_frekvens_1);

%   Tredje signal - H�jtaller afspiller fjernt fra mikrofon
figure, plot(k*fs/N, 10*log10(P2))
title('Effektspektrum ud fra DFT for fjernt signal')
xlim([0 fs/2])
xlabel('Analysefrekvens k - [Hz]'), grid

fprintf('V�lg en vertikal t�rskelv�rdi som ligger lidt over st�jgulvet.\n');
%[~, y2] = ginput(1);     
th_dB = -62.24;             
th = 10^(th_dB/10);      
fprintf('Afl�st t�rskelv�rdi i dB med klik: %f [dB]\n', th_dB);
P_over_th = P2(P2 >= th);
P_under_th = P2(P2 < th);
SNR_frekvens_2 = sum(P_over_th) / sum(P_under_th);
SNR_frekvens_dB_2 = 10*log10(SNR_frekvens_2);

%   Array som samler udregnet SNR v�rdier
SNR_arr = [SNR_frekvens_1, SNR_frekvens, SNR_frekvens_2];
%   Array som angiver distancen mellem mikrofon og h�jtaller
dist = [2000e-2, 4000e-2, 16000e-2];

figure, plot(dist, SNR_arr)
xlabel('Afstand i cm'), ylabel('SNR')
title('SNR som funktion af afstand'), grid
%%  Opgave 4    Bitrate
%   4.1 Hvor h�j en bitrate kan opn�s inden systemet dekoder fejlagtige
%   v�rdier:
%   

%   4.2 Betydning af vinduesl�ngde for amplitudespekter af en sinustone:
%   �ndring af vinduesl�ngden har indflydelse p� hvor stort et 
%   frekvensomr�de der beregnes for hvert bogstav/sinustone.
%   I dette script kan man justere p� vinduets st�rrelse ved at angive
%   forskellige v�rdier for 'windowstart' og 'windowstop' variablerne.

%   4.3 Betydning af st�jens effekt p� detektionssystemet
%   Hvis der er meget st�j dvs. stor SNR, s� er der en risiko for at 
%   detektionssystemet regner forkert, da st�jens frekvenser kommer som 
%   et supplement ift. de�nskede toners frekvenser som vi gerne vil dekode. 

%   4.4 Gr�nse for hvor mange forskellige frekvenser, som vi kan benytte
%   

%   4.5 Trade-off imellem antal frekvenser, symbolrate og SNR
%   Hvis SNR er lav, s� er st�jen kraftig ift. signalet, dette �ger antal
%   frekvenser som lukkes igennem og symbolraten bliver d�rligere.
%   Hvis SNR er h�j, s� er signalet kraftigt ift. st�jen, men antallet af
%   frekvenser bliver mindre.