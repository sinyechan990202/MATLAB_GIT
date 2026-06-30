function H_est = channel_estimator(rx_pilots, pilot_seq, pilot_idx, N_fft, method)
% Pilot-based channel estimation
%
% method: 'LS' | 'MMSE'

H_pilot = rx_pilots ./ pilot_seq(:);

switch upper(method)
    case 'LS'
        % Linear interpolation across all subcarriers
        H_est = interp1(pilot_idx, H_pilot, (1:N_fft)', 'linear', 'extrap');

    case 'MMSE'
        % Simplified MMSE (requires noise variance estimate)
        H_est = interp1(pilot_idx, H_pilot, (1:N_fft)', 'spline', 'extrap');

    otherwise
        error('Unknown estimation method: %s', method);
end
end
