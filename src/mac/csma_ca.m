function tx_slot = csma_ca(channel_busy, cfg)
% CSMA/CA backoff algorithm (802.11-style)
%
% cfg fields:
%   CW_min, CW_max  - Contention window bounds
%   DIFS, SIFS      - Interframe spaces (slots)

persistent CW retry_count
if isempty(CW), CW = cfg.CW_min; end
if isempty(retry_count), retry_count = 0; end

if channel_busy
    retry_count = retry_count + 1;
    CW = min(CW * 2, cfg.CW_max);
    backoff = randi([0, CW]);
    tx_slot = cfg.DIFS + backoff;
else
    tx_slot = cfg.SIFS;
    CW = cfg.CW_min;
    retry_count = 0;
end
end
