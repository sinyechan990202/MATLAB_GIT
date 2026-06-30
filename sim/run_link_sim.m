% Full link-level simulation: MAC frame + PHY chain + ARQ

clear; clc;
addpath(genpath('../src'));
run('../config/system_params.m');

rng(cfg.sim.seed);

snr_range = cfg.channel.snr_range;
tput_results = zeros(1, length(snr_range));
ber_results  = zeros(1, length(snr_range));

% ARQ buffer init
retx_buf = repmat(struct('count', 0, 'pending', false), 256, 1);

% MAC header config
mac_cfg.preamble = [1 1 0 1 0 1 1 0 1 1 0 0 1 0 1 0]';
mac_cfg.header.src_id     = 1;
mac_cfg.header.dst_id     = 2;
mac_cfg.header.frame_type = 0;

for i = 1:length(snr_range)
    snr = snr_range(i);
    total_bits = 0; rx_ok_bits = 0;
    t_start = tic;

    for f = 1:cfg.sim.n_frames
        seq = mod(f-1, 256);
        mac_cfg.header.seq_num = seq;

        % Generate payload and build frame
        payload = randi([0 1], cfg.mac.frame_size, 1);
        frame   = frame_builder(payload, mac_cfg);

        % PHY TX
        symbols = modulator(frame, cfg.phy.mod_scheme);

        % Channel
        rx_sym = awgn_channel(symbols, snr);

        % PHY RX
        noise_var = 10^(-snr/10);
        rx_bits = demodulator(rx_sym, cfg.phy.mod_scheme, noise_var);

        % MAC RX
        [rx_payload, ~, crc_ok] = frame_parser(rx_bits, mac_cfg);

        % ARQ
        [ack, retx_buf] = arq_controller(crc_ok, seq, retx_buf, cfg.mac);

        total_bits = total_bits + length(payload);
        if crc_ok
            rx_ok_bits = rx_ok_bits + length(rx_payload);
        end
    end

    t_elapsed = toc(t_start);
    tput_results(i) = rx_ok_bits / t_elapsed;
    ber_results(i)  = 1 - (rx_ok_bits / total_bits);

    fprintf('SNR = %+4d dB | Tput = %.2f Mbps | FER ≈ %.3f\n', ...
        snr, tput_results(i)/1e6, ber_results(i));
end

save('../results/link_results.mat', 'snr_range', 'tput_results', 'ber_results', 'cfg');
