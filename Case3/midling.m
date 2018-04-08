
function y=midling(hMA, x, M, N, chr)

y_filter = filter(hMA, 1, x);
var_x = var(x(M:N));
var_y = var(y_filter(M:N));
damping = var_x/var_y;
y = damping;    %   Dæmpning

fprintf('--------------------------------------------------\n');
fprintf('%c', chr);
fprintf('\nAntal filterkoefficienter M:  [%d]\n', M);
fprintf('Støjeffekt i inputsignal: ');
fprintf('    [%.2f]\n', var_x);
fprintf('Støjeffekter i outputsignal: ');
fprintf(' [%.2f]\n', var_y);
fprintf('Reduktion i støjeffekt: ');
fprintf('      [%.2f]\n', damping);
fprintf('Reduktion i støjeffekt i dB: ');
fprintf(' [%.2f]dB\n', 10*log10(damping));

end