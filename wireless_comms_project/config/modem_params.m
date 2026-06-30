% Modem parameters

%% Modulation
modem.scheme     = 'QAM16';   % 'BPSK'|'QPSK'|'QAM16'|'QAM64'|'QAM256'
modem.mod_order  = 16;
modem.bps        = log2(modem.mod_order);  % bits per symbol

%% FEC  — 'None': bypass (no toolbox required)
%%         'Conv' / 'LDPC' / 'Turbo': require Communications Toolbox
modem.fec_type   = 'None';
modem.code_rate  = 1/2;
modem.block_len  = 1024;      % FEC block length (bits); also used as tx frame size

%% Pulse shaping (RRC)
modem.rolloff    = 0.25;      % Roll-off factor (α)
modem.filt_span  = 8;         % Filter span (symbols)

%% RF Impairments
modem.iq_imbal_db    = 0.5;   % IQ amplitude imbalance (dB)
modem.iq_phase_deg   = 1.0;   % IQ phase imbalance (deg)
modem.phase_noise_dbc = -80;  % Phase noise floor (dBc/Hz @ 10kHz offset)
modem.dc_offset      = 0.01;  % DC offset (normalized)
