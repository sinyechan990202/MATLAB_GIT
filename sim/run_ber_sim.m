% BER simulation: PHY chain only (modulation + channel + demodulation)

clear; clc;
addpath(genpath('../src'));
run('../config/system_params.m');

rng(cfg.sim.seed);

snr_range = cfg.channel.snr_range;
ber_results = zeros(1, length(snr_range));

for i = 1:length(snr_range)
    snr = snr_range(i);
    n_errors = 0;
    n_bits   = 0;

    for f = 1:cfg.sim.n_frames
        % Generate random bits
        bits = randi([0 1], cfg.mac.frame_size, 1);

        % Modulate
        symbols = modulator(bits, cfg.phy.mod_scheme);

        % Channel
        if strcmp(cfg.channel.type, 'AWGN')
            rx_sym = awgn_channel(symbols, snr);
        else
            [rx_noisy, ~] = rayleigh_channel(symbols, cfg.channel);
            rx_sym = awgn(rx_noisy, snr, 'measured');
        end

        % Demodulate
        noise_var = 10^(-snr/10);
        rx_bits = demodulator(rx_sym, cfg.phy.mod_scheme, noise_var);

        [~, ne] = ber_calculator(bits, rx_bits);
        n_errors = n_errors + ne;
        n_bits   = n_bits + length(bits);

        if n_errors >= cfg.sim.min_errors
            break;
        end
    end

    ber_results(i) = n_errors / n_bits;
    fprintf('SNR = %+4d dB | BER = %.2e\n', snr, ber_results(i));
end

plot_ber(snr_range, ber_results, {cfg.phy.mod_scheme});
save('../results/ber_results.mat', 'snr_range', 'ber_results', 'cfg');
