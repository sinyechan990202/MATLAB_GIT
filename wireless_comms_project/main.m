% main.m — Wireless Communications System BER Simulation
% 16-QAM, RRC pulse shaping, ITU VehA multipath + Doppler + AWGN
% Run from wireless_comms_project/ directory

clear; clc; close all;

%% Configuration
proj_root = fileparts(mfilename('fullpath'));
addpath(genpath(proj_root));

run(fullfile(proj_root, 'config/sys_params.m'));
run(fullfile(proj_root, 'config/channel_params.m'));
run(fullfile(proj_root, 'config/modem_params.m'));

rng(sys.seed);

%% Satellite link budget
fprintf('\n=== Satellite Link Budget ===\n');
lb = satellite_link_budget(sat, sys);

%% BER sweep ────────────────────────────────────────────────────────────────
snr_range = -2:2:20;   % Eb/N0 (dB)
n_modes   = 2;         % 1=AWGN only, 2=Multipath+Doppler+AWGN

ber_results = nan(n_modes, length(snr_range));
mode_labels = {'AWGN only', 'Multipath + Doppler + AWGN'};

for mode = 1:n_modes
    fprintf('\n--- BER Sweep [%s] | %s | FEC=%s ---\n', ...
        mode_labels{mode}, modem.scheme, modem.fec_type);

    % For AWGN-only mode: zero out channel impairments
    ch_run = ch;
    if mode == 1
        ch_run.doppler_hz    = 0;
        ch_run.path_delays_s = 0;
        ch_run.path_gains_db = 0;
    end

    for si = 1:length(snr_range)
        EbNo = snr_range(si);
        n_errors = 0;
        n_bits   = 0;

        for f = 1:sys.n_frames
            %% TX
            [tx_signal, meta] = tx_top(modem.block_len, sys, modem);
            meta.EbNo_dB = EbNo;

            %% Channel
            rx_signal = channel_top(tx_signal, EbNo, sys, ch_run, modem);

            %% RX
            [rx_bits, ~] = rx_top(rx_signal, meta, sys, modem);

            %% BER
            n = min(length(meta.tx_bits), length(rx_bits));
            [~, ~, ne, ~] = ber_calc(meta.tx_bits(1:n), rx_bits(1:n), modem.bps);
            n_errors = n_errors + ne;
            n_bits   = n_bits   + n;

            if n_errors >= sys.min_errors, break; end
        end

        ber_results(mode, si) = n_errors / max(n_bits, 1);
        fprintf('Eb/N0 = %+4d dB | BER = %.2e  (%d errors / %d bits)\n', ...
            EbNo, ber_results(mode, si), n_errors, n_bits);
    end
end

%% Theoretical BER ──────────────────────────────────────────────────────────
% Gray-coded 16-QAM in AWGN (tight approximation)
%   BER ≈ (3/8) · erfc( sqrt(0.4 · Eb/N0) )
EbNo_lin     = 10.^(snr_range / 10);
ber_theory   = (3/8) * erfc(sqrt(0.4 * EbNo_lin));

%% Plot ─────────────────────────────────────────────────────────────────────
figure('Name', 'BER Performance', 'Position', [100 100 700 500]);
colors = {'b', 'r'};
markers = {'o', 's'};

semilogy(snr_range, ber_theory, 'k--', 'LineWidth', 1.5, 'DisplayName', ...
    '16-QAM Theory (AWGN)');
hold on;

for mode = 1:n_modes
    semilogy(snr_range, ber_results(mode,:), ...
        [colors{mode} '-' markers{mode}], ...
        'LineWidth', 1.5, 'MarkerSize', 6, ...
        'DisplayName', mode_labels{mode});
end

grid on;
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('Bit Error Rate (BER)', 'FontSize', 12);
title(sprintf('BER vs E_b/N_0 — %s, FEC=%s, R_s=%.1f Mbaud, sps=%d', ...
    modem.scheme, modem.fec_type, sys.Rs/1e6, sys.sps), 'FontSize', 12);
legend('Location', 'southwest', 'FontSize', 10);
ylim([1e-5 1]);
xlim([snr_range(1) snr_range(end)]);

%% Save results ─────────────────────────────────────────────────────────────
result_dir = fullfile(proj_root, 'results/ber_curves');
if ~exist(result_dir, 'dir'), mkdir(result_dir); end

snr_axis   = snr_range;
ber_awgn   = ber_results(1,:);
ber_fading = ber_results(2,:);
save(fullfile(result_dir, 'ber_main.mat'), ...
    'snr_axis', 'ber_awgn', 'ber_fading', 'ber_theory', 'sys', 'modem', 'ch');
fprintf('\nResults saved → results/ber_curves/ber_main.mat\n');

saveas(gcf, fullfile(proj_root, 'results/ber_curves/ber_main.png'));
fprintf('Plot saved    → results/ber_curves/ber_main.png\n');
