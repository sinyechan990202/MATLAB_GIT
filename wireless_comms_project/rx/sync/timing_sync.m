function [symbols, tau_est] = timing_sync(rx_in, sys, modem)
% Timing synchronization — Gardner TED + interpolation

sps    = sys.sps;
N      = floor(length(rx_in) / sps);
mu     = 0;        % fractional delay estimate [0,1)
K1     = 0.01;     % proportional gain
K2     = 0.001;    % integral gain
vi     = 0;        % integrator
symbols = zeros(N, 1);
tau_history = zeros(N, 1);

k  = 1;
ki = sps + 1;

while k <= N && ki + sps <= length(rx_in)
    % Interpolate at current sample point
    i_floor = floor(ki);
    frac    = ki - i_floor;

    if i_floor + 1 <= length(rx_in)
        sym = rx_in(i_floor) * (1-frac) + rx_in(i_floor+1) * frac;
    else
        break;
    end
    symbols(k) = sym;

    % Gardner TED: error on midpoint between previous and current symbol
    mid_idx = i_floor - round(sps/2);
    if mid_idx >= 1 && mid_idx+1 <= length(rx_in)
        mid = rx_in(mid_idx)*(1-frac) + rx_in(mid_idx+1)*frac;
        if k > 1
            ted_err = real(mid) * (real(symbols(k-1)) - real(sym)) + ...
                      imag(mid) * (imag(symbols(k-1)) - imag(sym));
        else
            ted_err = 0;
        end
    else
        ted_err = 0;
    end

    % Loop filter
    vi  = vi + K2 * ted_err;
    mu  = mu + K1 * ted_err + vi;

    tau_history(k) = mu;
    ki = ki + sps + mu;
    k  = k + 1;
end

symbols  = symbols(1:k-1);
tau_est  = mean(tau_history(1:k-1));
end
