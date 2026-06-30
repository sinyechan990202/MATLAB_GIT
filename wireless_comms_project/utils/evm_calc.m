function [evm_rms, evm_peak] = evm_calc(tx_syms, rx_syms)
% Error Vector Magnitude (EVM) — IEEE 802.11 / 3GPP definition

err       = rx_syms(:) - tx_syms(:);
ref_pwr   = mean(abs(tx_syms(:)).^2);
evm_rms   = sqrt(mean(abs(err).^2) / ref_pwr) * 100;  % percent
evm_peak  = max(abs(err)) / sqrt(ref_pwr) * 100;
end
