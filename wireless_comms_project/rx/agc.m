function [rx_out, gain] = agc(rx_in, target_pwr)
% Automatic Gain Control — normalize signal power to target

if nargin < 2, target_pwr = 1.0; end

measured_pwr = mean(abs(rx_in).^2);
gain         = sqrt(target_pwr / (measured_pwr + eps));
rx_out       = rx_in * gain;
end
