function rx = rf_impairments(tx, modem)
% Apply RF impairments: IQ imbalance, phase noise, DC offset

%% IQ amplitude/phase imbalance
amp_err   = 10^(modem.iq_imbal_db / 20);
phase_err = modem.iq_phase_deg * pi / 180;
I = real(tx); Q = imag(tx);
I_out = amp_err * (I*cos(phase_err/2) - Q*sin(phase_err/2));
Q_out =           (I*sin(phase_err/2) + Q*cos(phase_err/2));
rx = complex(I_out, Q_out);

%% Phase noise (Wiener process approximation)
sigma_pn  = sqrt(10^(modem.phase_noise_dbc/10));
phase_noise = cumsum(sigma_pn * randn(size(rx)));
rx = rx .* exp(1j * phase_noise);

%% DC offset
rx = rx + modem.dc_offset * (1 + 1j);
end
