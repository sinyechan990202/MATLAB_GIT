% Unit test: OFDM modulate / demodulate over ideal channel

addpath(genpath('../src'));
run('../config/system_params.m');

N_fft = cfg.phy.N_fft;
N_sc  = cfg.phy.N_subcarriers;
N_cp  = cfg.phy.N_cp;
guard = (N_fft - N_sc) / 2;

ofdm_cfg = cfg.phy;
ofdm_cfg.data_idx  = (guard+1 : guard+N_sc)';
ofdm_cfg.pilot_idx = [];
ofdm_cfg.pilot_seq = [];
ofdm_cfg.N_fft     = N_fft;
ofdm_cfg.N_cp      = N_cp;

bits    = randi([0 1], N_sc * 4, 1);
symbols = modulator(bits, 'QPSK');
[tx_signal, ~] = ofdm_modulate(symbols, ofdm_cfg);
rx_sym  = ofdm_demodulate(tx_signal, ofdm_cfg);
rx_bits = demodulator(rx_sym, 'QPSK', 0);
rx_bits = rx_bits(1:length(bits));

err = sum(bits ~= rx_bits);
assert(err == 0, 'OFDM round-trip failed: %d errors', err);
fprintf('[PASS] OFDM round-trip: 0 errors\n');
