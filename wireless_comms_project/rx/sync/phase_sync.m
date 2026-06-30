function [symbols_out, phase_est] = phase_sync(symbols_in, modem)
% Phase synchronization — Costas Loop (BPSK/QPSK) or Decision-Directed PLL

M      = modem.mod_order;
N      = length(symbols_in);
alpha  = 0.05;    % loop BW (proportional)
beta   = alpha^2 / 4;  % integrator
phase  = 0;
freq   = 0;
symbols_out  = zeros(N, 1);
phase_track  = zeros(N, 1);

for k = 1:N
    symbols_out(k) = symbols_in(k) * exp(-1j * phase);

    if M == 2  % BPSK Costas
        err = real(symbols_out(k)) * imag(symbols_out(k));
    elseif M == 4  % QPSK Costas
        err = sign(real(symbols_out(k))) * imag(symbols_out(k)) - ...
              sign(imag(symbols_out(k))) * real(symbols_out(k));
    else  % Decision-Directed
        dec = qammod(qamdemod(symbols_out(k), M, 'UnitAveragePower', true), ...
                     M, 'UnitAveragePower', true);
        err = imag(symbols_out(k) * conj(dec));
    end

    freq  = freq  + beta  * err;
    phase = phase + alpha * err + freq;
    phase_track(k) = phase;
end

phase_est = mean(phase_track);
end
