% test_full_chain.m — Integration test: TX → AWGN → RX, BER check

clear; clc;
addpath(genpath(fullfile(fileparts(mfilename('fullpath')), '..')));

run('../config/sys_params.m');
run('../config/channel_params.m');
run('../config/modem_params.m');

rng(sys.seed);

% AWGN-only channel for integration test
ch_test = ch;
ch_test.doppler_hz    = 0;
ch_test.path_delays_s = 0;
ch_test.path_gains_db = 0;

EbNo_dB = 15;   % High SNR → should yield very low BER
n_errors = 0; n_bits = 0;

for f = 1:20
    [tx_signal, meta] = tx_top(modem.block_len, sys, modem);
    meta.EbNo_dB      = EbNo_dB;

    rx_signal         = channel_top(tx_signal, EbNo_dB, sys, ch_test, modem);
    [rx_bits, ~]      = rx_top(rx_signal, meta, sys, modem);

    n = min(length(meta.tx_bits), length(rx_bits));
    [~, ~, ne, ~] = ber_calc(meta.tx_bits(1:n), rx_bits(1:n), modem.bps);
    n_errors = n_errors + ne;
    n_bits   = n_bits   + n;
end

ber = n_errors / max(n_bits, 1);
fprintf('Full chain test @ %d dB Eb/N0:  BER = %.2e  (%d errors / %d bits)\n', ...
    EbNo_dB, ber, n_errors, n_bits);

assert(ber < 0.05, sprintf('BER %.2e exceeds 5%% threshold', ber));
fprintf('[PASS] Full chain integration test\n');
