function S=spectrogram0(x,L,Nfft,step,fs)
% Spektrogram. Beregner og viser spektrogram
% Ref. Baseret på: Manolakis & Ingle, Applied Digital Signal Processing, 
%                  Cambridge University Press 2011, Figure 7.34 p. 416
% KPL 2017-01-09

% transpose if row vector
if isrow(x); x = x'; end %  Funktioner under forudsætter at x er en søjlevektor.

N = length(x);
K = fix((N-L+step)/step);
w = hanning(L);
time = (1:L)';
Ts = 1/fs;
N2 = Nfft/2+1;
S = zeros(K,N2);

%   Beregner FFT i for loop
for k=1:K
    xw = x(time).*w;
    X  = fft(xw,Nfft);  %   Zero padder op til Nfft, hvis den er større end L som er længden af de segmenter som signalet brydes op i.
    X1 = X(1:N2)';
    S(k,1:N2) = X1.*conj(X1); % samme som |X1|^2 - effektspektrum
    time = time+step;
end
S = fliplr(S)';
S = S/max(max(S)); % normalisering
colormap(jet);     % farveskema, prøv også jet, summer, gray, ...
tk = (0:K-1)'*step*Ts;
F = (0:Nfft/2)'*fs/Nfft;
imagesc(tk,flipud(F),20*log10(S),[-100 10]);    %   Tegner spektogram
axis xy
xlabel('tid [s]')
ylabel('frekvens [Hz]')
title(['Spektrogram, N_{FFT}=' num2str(Nfft) ', L=' num2str(L)...
       ', step=' num2str(step)])