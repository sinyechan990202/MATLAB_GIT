function [rx_bits, rx_syms] = rx_top(rx_signal, meta, sys, modem)
% RX chain: AGC → sync → equalize → demodulate → deinterleave → decode

%% Noise variance estimate from meta (set by main.m)
if isfield(meta, 'EbNo_dB')
    EsNo_lin  = 10^(meta.EbNo_dB/10) * modem.bps;
    noise_var = 1 / EsNo_lin;   % assumes unit signal power after AGC
else
    noise_var = 0.1;
end

%% AGC
rx = agc(rx_signal);

%% Synchronization
[rx, ~]      = freq_sync(rx, sys, modem);
[rx_syms, ~] = timing_sync(rx, sys, modem);
[rx_syms, ~] = phase_sync(rx_syms, modem);

%% Channel estimation — 1-tap LS from pilot positions
%  TX inserts pilot (sys.pilot_val) every sys.pilot_period data symbols.
%  If meta.pilot_mask is available use it; otherwise assume flat channel.
if isfield(meta, 'pilot_mask')
    pm = meta.pilot_mask;
    Ns = length(rx_syms);
    pm = pm(1:min(length(pm), Ns));          % trim to available symbols

    pilot_pos = find(pm);
    pilot_pos = pilot_pos(pilot_pos <= Ns);

    if numel(pilot_pos) >= 2
        H_pilot = rx_syms(pilot_pos) / sys.pilot_val;
        H_est   = interp1(double(pilot_pos), H_pilot, (1:Ns)', 'linear', 'extrap');
    else
        H_est   = ones(Ns, 1);
    end
    data_pos = find(~pm(1:Ns));
else
    Ns       = length(rx_syms);
    H_est    = ones(Ns, 1);
    data_pos = (1:Ns)';
end

%% MMSE equalization
rx_syms = equalizer(rx_syms, H_est, noise_var, 'MMSE');

%% Extract data symbols (remove pilot positions)
rx_syms = rx_syms(data_pos);

%% Demodulation
[~, llr] = demodulator(rx_syms, modem, noise_var);

%% FEC decode
de_llr  = deinterleaver(llr, meta.perm, modem.block_len);
rx_bits = decoder(de_llr, modem);
end
