function rx = channel_top(tx, EbNo_dB, sys, ch, modem)
% Channel chain: multipath → Doppler → AWGN
% modem.bps and sys.sps are used for correct Eb/N0 to noise power conversion

if nargin < 5
    modem.bps = 4;
end

rx = multipath_channel(tx, ch, sys);
rx = doppler_channel(rx, ch, sys);
rx = awgn_channel(rx, EbNo_dB, modem.bps, sys.sps);
end
