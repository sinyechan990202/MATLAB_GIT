function lb = satellite_link_budget(sat, sys)
% Satellite link budget calculation (ITU-R / ETSI EN 301 790)

c   = 3e8;
k_B = 1.380649e-23;  % Boltzmann constant

%% Free-space path loss
alt_m = sat.altitude_km * 1e3;
el    = sat.elevation_deg * pi / 180;
slant = alt_m / sin(el);               % Slant range (m)
FSPL  = 20*log10(4*pi*slant*sat.freq_hz/c);

%% Received C/N0
CN0 = sat.EIRP_dBW - FSPL - sat.losses_dB + sat.GT_dBK - 10*log10(k_B);

%% SNR given bandwidth
BW  = sys.Rs;  % Noise bandwidth ≈ symbol rate
SNR = CN0 - 10*log10(BW);

%% Shannon capacity
lb.FSPL_dB    = FSPL;
lb.CN0_dBHz   = CN0;
lb.SNR_dB     = SNR;
lb.slant_km   = slant / 1e3;
lb.capacity_bps = BW * log2(1 + 10^(SNR/10));

fprintf('=== Link Budget ===\n');
fprintf('Slant range : %.1f km\n', lb.slant_km);
fprintf('FSPL        : %.1f dB\n', lb.FSPL_dB);
fprintf('C/N0        : %.1f dBHz\n', lb.CN0_dBHz);
fprintf('SNR         : %.1f dB\n', lb.SNR_dB);
fprintf('Capacity    : %.2f Mbps\n', lb.capacity_bps/1e6);
end
