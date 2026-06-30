function H_est = channel_estimator(rx_syms, tx_pilot, pilot_idx, N_total, method)
% Pilot-based channel estimation
% method: 'LS' | 'MMSE'

H_pilot = rx_syms(pilot_idx) ./ tx_pilot(:);

switch upper(method)
    case 'LS'
        H_est = interp1(pilot_idx, H_pilot, (1:N_total)', 'linear', 'extrap');

    case 'MMSE'
        % Simplified MMSE via spline interpolation
        H_est = interp1(pilot_idx, H_pilot, (1:N_total)', 'spline', 'extrap');

    otherwise
        error('Unknown method: %s', method);
end
end
