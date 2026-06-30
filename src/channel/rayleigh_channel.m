function [rx_signal, h] = rayleigh_channel(tx_signal, cfg)
% Rayleigh fading channel (ITU pedestrian/vehicular profiles)
%
% cfg fields:
%   fs          - Sample rate (Hz)
%   fd          - Max Doppler shift (Hz)
%   delay_prof  - Delay profile: 'EPA', 'EVA', 'ETU'

chan = comm.RayleighChannel( ...
    'SampleRate',           cfg.fs, ...
    'MaximumDopplerShift',  cfg.fd, ...
    'PathDelays',           cfg.path_delays, ...
    'AveragePathGains',     cfg.path_gains, ...
    'NormalizePathGains',   true);

rx_signal = chan(tx_signal(:));
h = info(chan);
end
