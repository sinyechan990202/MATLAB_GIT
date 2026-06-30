% main.m — Wireless Communications System Simulation Entry Point

clear; clc; close all;

%% Load configuration
proj_root = fileparts(mfilename('fullpath'));
addpath(genpath(proj_root));

run(fullfile(proj_root, 'config/sys_params.m'));
run(fullfile(proj_root, 'config/channel_params.m'));
run(fullfile(proj_root, 'config/modem_params.m'));

rng(sys.seed);

%% Link budget (위성 링크)
fprintf('\n--- Satellite Link Budget ---\n');
satellite_link_budget(sat, sys);

%% BER sweep
fprintf('\n--- BER Sweep: %s, %s, Multipath+Doppler ---\n', ...
    modem.scheme, modem.fec_type);

ber_results = zeros(1, length(sys.snr_range));

for si = 1:length(sys.snr_range)
    snr = sys.snr_range(si);
    n_errors = 0;  n_bits = 0;

    for f = 1:sys.n_frames
        %% TX
        [tx_signal, meta] = tx_top(modem.block_len, sys, modem);

        %% Channel
        rx_signal = channel_top(tx_signal, snr, sys, ch);

        %% RX
        [rx_bits, rx_syms] = rx_top(rx_signal, meta, sys, modem);

        %% Metrics
        n = min(length(meta.tx_bits), length(rx_bits));
        [~, ~, ne, ~] = ber_calc(meta.tx_bits(1:n), rx_bits(1:n), modem.bps);
        n_errors = n_errors + ne;
        n_bits   = n_bits + n;

        if n_errors >= sys.min_errors, break; end
    end

    ber_results(si) = n_errors / max(n_bits, 1);
    fprintf('Eb/N0 = %+4d dB | BER = %.2e\n', snr, ber_results(si));
end

%% Plots
figure('Name', 'BER Performance');
semilogy(sys.snr_range, ber_results, '-o', 'LineWidth', 1.5);
grid on;
xlabel('E_b/N_0 (dB)'); ylabel('BER');
title(sprintf('%s + %s | Multipath + Doppler', modem.scheme, modem.fec_type));

%% Save results
save(fullfile(proj_root, 'results/ber_curves/ber_main.mat'), ...
    'sys', 'modem', 'ch', 'sys.snr_range', 'ber_results');
fprintf('\nResults saved to results/ber_curves/ber_main.mat\n');
