function rx = channel_top(tx, snr_db, sys, ch)
% Channel chain: multipath → Doppler → AWGN

rx = multipath_channel(tx, ch, sys);
rx = doppler_channel(rx, ch, sys);
rx = awgn_channel(rx, snr_db);
end
