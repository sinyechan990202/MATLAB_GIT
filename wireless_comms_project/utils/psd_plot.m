function psd_plot(signal, fs, title_str)
% Power Spectral Density plot (Welch method)

if nargin < 3, title_str = 'PSD'; end

figure('Name', title_str);
[pxx, f] = pwelch(signal, [], [], [], fs, 'centered');
plot(f/1e6, 10*log10(pxx));
xlabel('Frequency (MHz)');
ylabel('PSD (dBW/Hz)');
title(title_str);
grid on;
end
