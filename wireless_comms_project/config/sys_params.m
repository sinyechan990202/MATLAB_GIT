% System-level parameters

%% Sampling & Carrier
sys.fs      = 10e6;         % Sample rate (Hz)
sys.fc      = 2.4e9;        % Carrier frequency (Hz)
sys.Rs      = 1e6;          % Symbol rate (baud)
sys.sps     = sys.fs / sys.Rs;  % Samples per symbol

%% SNR Sweep
sys.snr_range = -5:1:25;    % Eb/N0 (dB)

%% Simulation
sys.n_frames   = 500;
sys.min_errors = 200;
sys.seed       = 42;

%% Pilot
sys.pilot_period = 8;       % Insert pilot every N symbols
sys.pilot_val    = 1+0j;
