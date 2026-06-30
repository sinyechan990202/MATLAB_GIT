% Channel parameters

%% Doppler (항공·위성)
ch.doppler_hz   = 5000;       % Max Doppler shift (Hz)  — LEO ~20kHz, 항공 ~1-5kHz
ch.velocity_mps = 250;        % Platform speed (m/s)

%% Multipath delay profile (ITU Vehicular A)
ch.path_delays_s  = [0, 310, 710, 1090, 1730, 2510] * 1e-9;
ch.path_gains_db  = [0, -1,  -9,  -10,  -15,  -20];
ch.path_profile   = 'VehA';

%% Satellite orbit
sat.orbit        = 'LEO';     % 'LEO' | 'MEO' | 'GEO'
sat.altitude_km  = 550;       % Orbit altitude (km)
sat.elevation_deg = 45;       % Elevation angle (deg)
sat.freq_hz      = 2.4e9;

%% Link budget (ITU / ETSI)
sat.EIRP_dBW     = 47;        % Transmitter EIRP
sat.GT_dBK       = -5;        % Receiver G/T (dB/K)
sat.losses_dB    = 2;         % Misc losses (polarization, pointing)
