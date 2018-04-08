
function y=midling(hMA, x, M, N, chr)

y_filter = filter(hMA, 1, x);
var_x = var(x(M:N));
var_y = var(y_filter(M:N));
damping = var_x/var_y;
y = damping;    %   D�mpning

fprintf('--------------------------------------------------\n');
fprintf('%c', chr);
fprintf('\nAntal filterkoefficienter M:  [%d]\n', M);
fprintf('St�jeffekt i inputsignal: ');
fprintf('    [%.2f]\n', var_x);
fprintf('St�jeffekter i outputsignal: ');
fprintf(' [%.2f]\n', var_y);
fprintf('Reduktion i st�jeffekt: ');
fprintf('      [%.2f]\n', damping);
fprintf('Reduktion i st�jeffekt i dB: ');
fprintf(' [%.2f]dB\n', 10*log10(damping));

end