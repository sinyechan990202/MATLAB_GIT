function rx = awgn_channel(tx, EbNo_dB, bps, sps)
% AWGN channel — Eb/N0 based, no toolbox required
% EbNo_dB: Eb/N0 in dB
% bps    : bits per symbol (default 4 for 16-QAM)
% sps    : samples per symbol (default 1 if already at symbol rate)

if nargin < 3, bps = 4;  end
if nargin < 4, sps = 1;  end

EbNo_lin   = 10^(EbNo_dB / 10);
EsNo_lin   = EbNo_lin * bps;
SNR_lin    = EsNo_lin / sps;          % per-sample SNR

sig_power  = mean(abs(tx(:)).^2);
noise_var  = sig_power / SNR_lin;     % total complex noise variance

noise = sqrt(noise_var / 2) * (randn(size(tx)) + 1j * randn(size(tx)));
rx    = tx(:) + noise;
end
