function [tx_signal, cfg] = ofdm_modulate(symbols, cfg)
% OFDM modulation (802.11/LTE-style)
%
% cfg fields:
%   N_fft       - FFT size
%   N_cp        - Cyclic prefix length
%   N_subcarriers - Number of data subcarriers
%   pilot_idx   - Pilot subcarrier indices

N_fft = cfg.N_fft;
N_cp  = cfg.N_cp;
N_sc  = cfg.N_subcarriers;

n_sym = floor(length(symbols) / N_sc);
symbols = symbols(1 : n_sym * N_sc);
sym_matrix = reshape(symbols, N_sc, n_sym);

% Map to subcarriers (null DC and guard bands)
freq_domain = zeros(N_fft, n_sym);
data_idx = cfg.data_idx;
freq_domain(data_idx, :) = sym_matrix;

% Insert pilots
if isfield(cfg, 'pilot_idx') && ~isempty(cfg.pilot_idx)
    freq_domain(cfg.pilot_idx, :) = repmat(cfg.pilot_seq, 1, n_sym);
end

% IFFT + cyclic prefix
time_domain = ifft(freq_domain, N_fft);
cp = time_domain(end - N_cp + 1 : end, :);
tx_signal = [cp; time_domain];
tx_signal = tx_signal(:);
end
