function [rx_bits, rx_syms] = rx_top(rx_signal, meta, sys, modem)
% RX chain: AGC → sync → equalize → demodulate → deinterleave → decode

%% AGC
rx = agc(rx_signal);

%% Synchronization
[rx, ~]       = freq_sync(rx, sys, modem);
[rx_syms, ~]  = timing_sync(rx, sys, modem);
[rx_syms, ~]  = phase_sync(rx_syms, modem);

%% Channel estimation & equalization (pilot-aided)
pilot_idx = sys.pilot_period : sys.pilot_period : length(rx_syms);
pilot_idx = pilot_idx(pilot_idx <= length(rx_syms));
H_est     = channel_estimator(rx_syms, sys.pilot_val * ones(size(pilot_idx')), ...
                               pilot_idx, length(rx_syms), 'MMSE');
noise_var = 10^(-10/10);  % estimated from AGC + link budget
rx_syms   = equalizer(rx_syms, H_est, noise_var, 'MMSE');

%% Demodulation
[~, llr] = demodulator(rx_syms, modem, noise_var);

%% FEC decode
de_llr   = deinterleaver(llr, meta.perm, modem.block_len);
rx_bits  = decoder(de_llr, modem);
end
