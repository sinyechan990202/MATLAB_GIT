function tput = throughput_calc(n_bits, t_total_s, ber, overhead_ratio)
% Effective throughput accounting for errors and overhead
%
% overhead_ratio: fraction of bits used for header/pilot/CP (0~1)

goodput_ratio = (1 - ber)^2 * (1 - overhead_ratio);
tput = (n_bits / t_total_s) * goodput_ratio;
end
