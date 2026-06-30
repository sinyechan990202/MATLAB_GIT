function rx = multipath_channel(tx, ch, sys)
% Frequency-selective multipath channel — pure MATLAB block fading
% ch.path_delays_s / ch.path_gains_db: ITU VehA (or similar) profile

delays_samp = round(ch.path_delays_s * sys.fs);   % [0 3 7 10 17 25] @ 10 MHz
gains_lin   = 10.^(ch.path_gains_db / 20);
max_delay   = max(delays_samp);
N           = length(tx);
rx          = zeros(N, 1);

% Block-fading: draw one Rayleigh coefficient per path per frame
for k = 1:length(delays_samp)
    h = gains_lin(k) * (randn + 1j*randn) / sqrt(2);
    d = delays_samp(k);
    rx(1+d:end) = rx(1+d:end) + h * tx(1:N-d);
end
end
