% OFDM system simulation with channel estimation

clear; clc;
addpath(genpath('../src'));
run('../config/system_params.m');

rng(cfg.sim.seed);

N_fft = cfg.phy.N_fft;
N_cp  = cfg.phy.N_cp;
N_sc  = cfg.phy.N_subcarriers;

% Subcarrier index mapping (null DC + guard bands)
guard = (N_fft - N_sc) / 2;
data_idx = (guard + 1 : guard + N_sc)';
pilot_idx = data_idx(1:cfg.phy.pilot_spacing:end);
pilot_seq = ones(length(pilot_idx), 1);
data_only_idx = setdiff(data_idx, pilot_idx);

ofdm_cfg = cfg.phy;
ofdm_cfg.data_idx   = data_idx;
ofdm_cfg.pilot_idx  = pilot_idx;
ofdm_cfg.pilot_seq  = pilot_seq;
ofdm_cfg.N_fft      = N_fft;
ofdm_cfg.N_cp       = N_cp;

snr_range   = cfg.channel.snr_range;
ber_results = zeros(1, length(snr_range));

for i = 1:length(snr_range)
    snr = snr_range(i);
    n_errors = 0; n_bits = 0;

    for f = 1:cfg.sim.n_frames
        bits = randi([0 1], N_sc * 4, 1);
        symbols = modulator(bits, cfg.phy.mod_scheme);

        [tx_signal, ~] = ofdm_modulate(symbols, ofdm_cfg);

        % Rayleigh + AWGN
        [rx_faded, ~] = rayleigh_channel(tx_signal, cfg.channel);
        rx_noisy = awgn(rx_faded, snr, 'measured');

        rx_sym = ofdm_demodulate(rx_noisy, ofdm_cfg);

        noise_var = 10^(-snr/10);
        rx_bits = demodulator(rx_sym, cfg.phy.mod_scheme, noise_var);

        rx_bits = rx_bits(1:length(bits));
        [~, ne] = ber_calculator(bits, rx_bits);
        n_errors = n_errors + ne;
        n_bits   = n_bits + length(bits);
    end

    ber_results(i) = n_errors / n_bits;
    fprintf('SNR = %+4d dB | BER = %.2e\n', snr, ber_results(i));
end

plot_ber(snr_range, ber_results, {'OFDM-QAM16 / Rayleigh'});
save('../results/ofdm_results.mat', 'snr_range', 'ber_results', 'cfg');
