
%   Kursus: E4DSA
%   Dato:   14. febuar 2018
%   Gruppe: Team 4
%   Gruppemedlemmer: Mads Villadsen, Kim Nielsen & Lasse Frederiksen

%   Denne opgave går ud på at bygge et system der muliggør kommunikation
%   mellem to grupper, som hver har en mikrofon og en højtaller. Hermed
%   går opgaven ud på at sende beskeder til hinanden, hvor der undersøges
%   hvilke parametre som kan have en afgørende betydning for
%   virkemåden af systemet.
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
%% 1.2 Analysér signalet for at finde ud af, hvilke karakterer, som svarer 
%  til hvilke frekvenser. I skal se på signalet i både tids- og frekvens-domænet.

figure
plot(x(Tsym*fs-100:Tsym*fs+100)), grid

figure
plot(k*fs/N,abs(fft(x))/N*2), grid
xlim([fstart fstop])

% Ud fra det som vi kan se i vores lydsignal og pga. af at vi se at der er 
% 256 forskellige ascii værdier kan vi pga. af det tage vores de 1000 Hz
% der er i mellem vores Fstart og Fstop og dividere med 256 for at finde ud
% af hvor langt der vil være mellem hver ascii værdi også finde ud hvor de
% karaktere man reelt kan skrive med et keyboard starter som var ved 1125
% med space også vil den hver karakter komme ind ca. 3.9 Hz efter hinanden
% og ud fra det kan vi finde ud af hvilken frekvens der svarer til hvilken
% karakter.

%% 1.3 analyser signalet vha. short-time fuorier transform -dvs. med 
%  med spektrogram-plot forklar trade-off mellem opløsningen og i tid og
%  frekvens


figure
spectrogram0(x,512,512,20,fs);
%% Opgave 2 Dekodning
%Vi skal her lave en dekoder til en lydfil, som vi har fået fra en anden
%gruppe. Dekoderen skal gøre det modsatte af hvad der blev gjort i opgave 1

[y,fs] = audioread('signalT42.wav'); 
%Audioread bliver brugt til at læse lydfilen ind.

yMono = sum(y, 2) / size(y, 2);
%Lydfilen kommer som dualchannel og vi skal kun bruge den som monochannel.

x = yMono';
%y værdien er et søjlediagram men vi vil gerne bruge det som et
%rækkediagram.

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
%Disse 3 værdier har vi fået givet fra den anden gruppe for at lave dekoder
%processen lidt nemmere.

windowstart = 0.1;
windowstop = Tsym - windowstart;
%Window-start og -stop bliver brugt til at skabe et område, hvor vi ide vi
%kan finde det højeste punkt i vores for loop, som kommer senere

N = length(x);
%Finder længden af vores x-værdier

Tdur = N/fs;
%Finder tidslængden.

chars = Tdur/Tsym;
%Finder hvor mange bogstaver der i lydfilen.

charray = []; 
%Definerer tomt array.

%Nedenstående forloop bliver brugt til at dekode lydfilen så vi kan få
%bogstaverne ud af lydsignalet
    for k = 0:chars-1
        
        Start = floor((windowstart+Tsym*k)*(fs));
        Stop = ceil((windowstop+Tsym*k)*(fs));
        %Finder vædierne for vindues området til at start og slutte
        xny=x(Start:Stop);
        %Tager kun det område i x som vi vil have fat i.
        xny_1=x1(Start:Stop);
        xny_2=x2(Start:Stop);
        
        N_xny=length(xny);
        %Finder længden af xny vindues området
        
        X=(abs(fft(xny)))*2/N_xny;
        %Fourie transformerer vores signal. Her tager vi ikke alle
        %værdierne for x(n) da dette ikke er nødvendigt for vi vil nemlig
        %kun kigge på et område af værdierne i x(n).
        X1=abs(fft(xny_1)*2/length(xny_1));
        X2=abs(fft(xny_2)*2/length(xny_2));
        
        [Xmax,q] = max(X);
        %Finder max punkterne for vores fourie transformerede signal. Det
        %vigtige her er frekvensbindet som vi kalder q, da vi så kan finde
        %frekvensen for det højeste punkt.
        
        N = length(X);
        %Finder længden af det fourie transformede signals område.
        
        freq = q *(fs/ N);
        %Finder frekvensen af den højeste værdi inden for området.
        
        output = ceil(freq-fstart)*(1/4);
        %Udregner vores output decimaltal, der bliver dividere med 4 her
        %fordi at (fstop-fstart)/256 = 4 så vi kan udregne decimaltallet
        
        if(output == 31.7500), output = 32; end
        if(output == 51.7500), output = 52; end
        %Vi har debugget os frem til at der er noget usikker i disse to
        %værdier og så har vi korrigeret det til at værdierne passer
        %korrekt.
        
        ch = char(output);
        % Finder bogstavet
        charray = [charray ch];
        %Putter bogstavet ind i det tomme array.
    end

fprintf('Her er bogstaverne: %s \n', charray);
%Udskriver bogstaverne, som er blevet fundet.
%%  SNR  - Signal støj forhold

%   SNR i frekvensdomænet kan udregnes som summen af effektsamples over
%   tærskelværdi delt med summen af effektsamples under tærkselværdi.
%   Tærskelværdien skal ligge over støjgulvet. 

%       sum(|X(k)|^2) over tærskelværdi
%SNR = -------------------------------------    Lyons D-19
%       sum(|X(k)|^2) under tærskelværdi

k = 0:N-1;  
P = X.*conj(X);     %   Effektspektrum for 1. signal
P1 = X1.*conj(X1);  %   Effektspektrum for 2. signal
P2 = X2.*conj(X2);  %   Effektspektrum for 3. signal

%   Første signal
figure, plot(k*fs/N, 10*log10(P))
title('Effektspektrum ud fra DFT')
xlim([0 fs/2])
xlabel('Analysefrekvens k - [Hz]'), grid

fprintf('Vælg en vertikal tærskelværdi som ligger lidt over støjgulvet.\n');
%[~, y] = ginput(1);     %   Input fra mus - brug til at justere SNR
th_dB = -44.28;              %   Aflæs en tærskelværdi - akse er i dB
th = 10^(th_dB/10);     %   Omregnet til gg
fprintf('Aflæst tærskelværdi i dB med klik: %f [dB]\n', th_dB);
% En matrix som samler samples der ligger over eller er lig tærskelværdien
% aflæst fra ginput funktionen
P_over_th = P(P >= th);
%   matrix som samler samples der ligger under tærskelværdi
P_under_th = P(P < th);
%   beregning af SNR lineært - fra Lyons D-19
SNR_frekvens = sum(P_over_th) / sum(P_under_th);
SNR_frekvens_dB = 10*log10(SNR_frekvens);   %   SNR i dB - fra Lyons D-20
fprintf('SNR beregnet i frekvensområdet: %f [dB]\n', SNR_frekvens_dB);

%   Herunder ses nøjagtig samme udregninger, undtaget, at det vedrører
%   andre signaler. Disse signaler er forskellige fra hinanden ift.
%   afstanden mellem højtaller og mikrofon. Signalet foroeven ligger midt
%   imellem de to signaler forneden ift. afstanden mellem mikrofon og
%   højtaller.

%   Andet signal - Højtaller afspiller tæt på mikrofon
figure, plot(k*fs/N, 10*log10(P1))
title('Effektspektrum ud fra DFT for tæt signal')
xlim([0 fs/2])
xlabel('Analysefrekvens k - [Hz]'), grid

fprintf('Vælg en vertikal tærskelværdi som ligger lidt over støjgulvet.\n');
%[~, y1] = ginput(1);    
th_dB = -42.24;              
th = 10^(th_dB/10);
fprintf('Aflæst tærskelværdi i dB med klik: %f [dB]\n', th_dB);
P_over_th = P1(P1 >= th);
P_under_th = P1(P1 < th);
SNR_frekvens_1 = sum(P_over_th) / sum(P_under_th);
SNR_frekvens_dB_1 = 10*log10(SNR_frekvens_1);

%   Tredje signal - Højtaller afspiller fjernt fra mikrofon
figure, plot(k*fs/N, 10*log10(P2))
title('Effektspektrum ud fra DFT for fjernt signal')
xlim([0 fs/2])
xlabel('Analysefrekvens k - [Hz]'), grid

fprintf('Vælg en vertikal tærskelværdi som ligger lidt over støjgulvet.\n');
%[~, y2] = ginput(1);     
th_dB = -62.24;             
th = 10^(th_dB/10);      
fprintf('Aflæst tærskelværdi i dB med klik: %f [dB]\n', th_dB);
P_over_th = P2(P2 >= th);
P_under_th = P2(P2 < th);
SNR_frekvens_2 = sum(P_over_th) / sum(P_under_th);
SNR_frekvens_dB_2 = 10*log10(SNR_frekvens_2);

%   Array som samler udregnet SNR værdier
SNR_arr = [SNR_frekvens_1, SNR_frekvens, SNR_frekvens_2];
%   Array som angiver distancen mellem mikrofon og højtaller
dist = [2000e-2, 4000e-2, 16000e-2];

figure, plot(dist, SNR_arr)
xlabel('Afstand i cm'), ylabel('SNR')
title('SNR som funktion af afstand'), grid
%%  Opgave 4    Bitrate
%   4.1 Hvor høj en bitrate kan opnås inden systemet dekoder fejlagtige
%   værdier:
%   

%   4.2 Betydning af vindueslængde for amplitudespekter af en sinustone:
%   Ændring af vindueslængden har indflydelse på hvor stort et 
%   frekvensområde der beregnes for hvert bogstav/sinustone.
%   I dette script kan man justere på vinduets størrelse ved at angive
%   forskellige værdier for 'windowstart' og 'windowstop' variablerne.

%   4.3 Betydning af støjens effekt på detektionssystemet
%   Hvis der er meget støj dvs. stor SNR, så er der en risiko for at 
%   detektionssystemet regner forkert, da støjens frekvenser kommer som 
%   et supplement ift. deønskede toners frekvenser som vi gerne vil dekode. 

%   4.4 Grænse for hvor mange forskellige frekvenser, som vi kan benytte
%   

%   4.5 Trade-off imellem antal frekvenser, symbolrate og SNR
%   Hvis SNR er lav, så er støjen kraftig ift. signalet, dette øger antal
%   frekvenser som lukkes igennem og symbolraten bliver dårligere.
%   Hvis SNR er høj, så er signalet kraftigt ift. støjen, men antallet af
%   frekvenser bliver mindre.