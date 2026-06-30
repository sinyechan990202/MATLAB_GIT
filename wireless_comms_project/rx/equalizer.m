function rx_eq = equalizer(rx_syms, H_est, noise_var, method)
% Single-tap frequency-domain equalizer
% method: 'ZF' | 'MMSE'

switch upper(method)
    case 'ZF'
        rx_eq = rx_syms ./ H_est;

    case 'MMSE'
        rx_eq = conj(H_est) ./ (abs(H_est).^2 + noise_var) .* rx_syms;

    otherwise
        error('Unknown equalizer type: %s', method);
end
end
