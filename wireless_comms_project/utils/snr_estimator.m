function snr_est = snr_estimator(rx_syms, modem)
% SNR estimation — M2M4 moment-based estimator (non-data-aided)

M  = modem.mod_order;
m2 = mean(abs(rx_syms).^2);
m4 = mean(abs(rx_syms).^4);

% M2M4 estimator (works for QAM/PSK)
kurtosis_const = (E_s4(M)) / (E_s2(M))^2;  % modulation-dependent constant
snr_est = real(sqrt((kurtosis_const * m2^2 - m4) / (m4 - m2^2)));
snr_est = 10*log10(max(snr_est, eps));

function v = E_s2(M)
    syms = qammod((0:M-1)', M, 'UnitAveragePower', true);
    v = mean(abs(syms).^2);
end

function v = E_s4(M)
    syms = qammod((0:M-1)', M, 'UnitAveragePower', true);
    v = mean(abs(syms).^4);
end
end
