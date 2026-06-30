function [rx_out, fo_est] = freq_sync(rx_in, sys, modem)
% Frequency synchronization — AFC for Doppler compensation
% Uses non-data-aided FFT-based coarse frequency estimation followed by
% a decision-directed loop for fine tracking.

%% Coarse: FFT-based (works for PSK with M-th power nonlinearity)
M   = modem.mod_order;
N   = length(rx_in);
pwr = rx_in .^ M;
[~, idx] = max(abs(fft(pwr, N)));
fo_coarse = (idx - 1) * sys.fs / N / M;
if fo_coarse > sys.fs/2, fo_coarse = fo_coarse - sys.fs; end

%% Remove coarse offset
t = (0:N-1)' / sys.fs;
rx_coarse = rx_in .* exp(-1j * 2*pi * fo_coarse * t);

%% Fine: decision-directed PLL
alpha  = 0.01;   % loop bandwidth
fo_fine = 0;
phase   = 0;
rx_out  = zeros(N, 1);

for k = 1:N
    rx_out(k) = rx_coarse(k) * exp(-1j * phase);
    sym_dec    = sign(real(rx_out(k))) + 1j*sign(imag(rx_out(k)));
    err        = imag(rx_out(k) * conj(sym_dec));
    fo_fine    = fo_fine + alpha^2 * err;
    phase      = phase + fo_fine + alpha * err;
end

fo_est = fo_coarse + fo_fine;
end
