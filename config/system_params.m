% System-level parameters for wireless data link simulation

%% PHY Parameters
cfg.phy.mod_scheme    = 'QAM16';      % Modulation: BPSK/QPSK/QAM16/QAM64
cfg.phy.coding_rate   = 1/2;          % Channel coding rate
cfg.phy.N_fft         = 64;           % OFDM FFT size
cfg.phy.N_cp          = 16;           % Cyclic prefix length
cfg.phy.N_subcarriers = 48;           % Data subcarriers
cfg.phy.pilot_spacing = 6;            % Pilot subcarrier spacing
cfg.phy.fs            = 20e6;         % Sample rate (Hz)

%% Channel Parameters
cfg.channel.type      = 'Rayleigh';   % 'AWGN' | 'Rayleigh'
cfg.channel.fc        = 2.4e9;        % Carrier frequency (Hz)
cfg.channel.fd        = 10;           % Max Doppler (Hz, ~3 km/h @2.4GHz)
cfg.channel.profile   = 'EPA';        % ITU delay profile
cfg.channel.snr_range = -5:2:30;      % Eb/N0 sweep range (dB)

% ITU EPA delay profile
cfg.channel.path_delays = [0, 30, 70, 90, 110, 190, 410] * 1e-9;
cfg.channel.path_gains  = [0, -1, -2, -3, -8, -17.2, -20.8];

%% MAC Parameters
cfg.mac.arq_mode      = 'SR';         % 'SAW' | 'SR' (Selective-Repeat)
cfg.mac.max_retx      = 4;            % Max ARQ retransmissions
cfg.mac.frame_size    = 1024;         % Frame payload size (bits)
cfg.mac.CW_min        = 15;           % CSMA/CA min contention window
cfg.mac.CW_max        = 1023;         % CSMA/CA max contention window
cfg.mac.DIFS          = 34e-6;        % DIFS (sec)
cfg.mac.SIFS          = 16e-6;        % SIFS (sec)

%% Simulation Parameters
cfg.sim.n_frames      = 1000;         % Number of frames per SNR point
cfg.sim.min_errors    = 100;          % Min errors before stopping
cfg.sim.seed          = 42;
