function symbols = ofdm_demodulate(rx_signal, cfg)
% OFDM demodulation: remove CP, FFT, extract subcarriers

N_fft = cfg.N_fft;
N_cp  = cfg.N_cp;
N_sc  = cfg.N_subcarriers;

sym_len  = N_fft + N_cp;
n_sym    = floor(length(rx_signal) / sym_len);
rx_signal = rx_signal(1 : n_sym * sym_len);
rx_matrix = reshape(rx_signal, sym_len, n_sym);

% Remove CP
rx_no_cp = rx_matrix(N_cp + 1 : end, :);

% FFT
freq_domain = fft(rx_no_cp, N_fft);

% Extract data subcarriers
symbols = freq_domain(cfg.data_idx, :);
symbols = symbols(:);
end
