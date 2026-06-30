function plot_ber(snr_range, ber_results, labels)
% Plot BER vs SNR curves

figure('Name', 'BER Performance');
semilogy(snr_range, ber_results, '-o', 'LineWidth', 1.5);
grid on;
xlabel('E_b/N_0 (dB)');
ylabel('Bit Error Rate');
title('BER vs E_b/N_0');
legend(labels, 'Location', 'southwest');
ylim([1e-5 1]);
end
