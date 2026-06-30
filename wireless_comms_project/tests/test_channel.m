% Unit test: channel models and link budget

addpath(genpath('../'));
run('../config/sys_params.m');
run('../config/channel_params.m');

%% AWGN
tx = (randn(1000,1) + 1j*randn(1000,1)) / sqrt(2);
rx = awgn_channel(tx, 20);
snr_meas = 10*log10(mean(abs(tx).^2) / mean(abs(rx-tx).^2));
assert(abs(snr_meas - 20) < 2, 'AWGN SNR mismatch');
fprintf('[PASS] AWGN channel: measured SNR = %.1f dB\n', snr_meas);

%% Multipath
[rx_mp, ~] = multipath_channel(tx, ch, sys);
assert(length(rx_mp) >= length(tx), 'Multipath output too short');
fprintf('[PASS] Multipath channel: output length = %d\n', length(rx_mp));

%% Doppler
[rx_dop, fo] = doppler_channel(tx, ch, sys);
assert(length(rx_dop) == length(tx), 'Doppler output length mismatch');
fprintf('[PASS] Doppler channel: shift = %.0f Hz\n', fo);

%% Link budget
lb = satellite_link_budget(sat, sys);
assert(lb.SNR_dB > 0, 'Link budget SNR unexpectedly negative');
fprintf('[PASS] Link budget: SNR = %.1f dB, Capacity = %.2f Mbps\n', ...
    lb.SNR_dB, lb.capacity_bps/1e6);
