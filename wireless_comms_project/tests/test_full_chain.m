% Integration test: full TX → channel → RX chain

addpath(genpath('../'));
run('../config/sys_params.m');
run('../config/channel_params.m');
run('../config/modem_params.m');

rng(sys.seed);

% Use Conv FEC for fast test
modem.fec_type  = 'Conv';
modem.mod_order = 4;
modem.bps       = 2;

n_bits  = modem.block_len;
snr_db  = 15;

%% TX
[tx_signal, meta] = tx_top(n_bits, sys, modem);

%% Channel (AWGN only for integration test)
rx_signal = awgn_channel(tx_signal, snr_db);

%% RX
[rx_bits, ~] = rx_top(rx_signal, meta, sys, modem);

%% Evaluate
n = min(length(meta.tx_bits), length(rx_bits));
[ber, ~, ~, ~] = ber_calc(meta.tx_bits(1:n), rx_bits(1:n), modem.bps);

fprintf('Full chain test @ %d dB: BER = %.2e\n', snr_db, ber);
assert(ber < 0.1, 'BER too high in full chain test');
fprintf('[PASS] Full chain integration test\n');
