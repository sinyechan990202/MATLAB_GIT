function [ack, retx_buf] = arq_controller(rx_ok, seq_num, retx_buf, cfg)
% Stop-and-Wait / Selective-Repeat ARQ controller
%
% cfg.mode: 'SAW' | 'SR'
% cfg.max_retx: maximum retransmission count

mode = cfg.mode;

if rx_ok
    ack = seq_num;
    retx_buf(seq_num).count = 0;
    retx_buf(seq_num).pending = false;
else
    ack = -1;  % NACK
    retx_buf(seq_num).count   = retx_buf(seq_num).count + 1;
    retx_buf(seq_num).pending = true;

    if retx_buf(seq_num).count > cfg.max_retx
        warning('ARQ: max retransmissions reached for seq %d', seq_num);
        retx_buf(seq_num).pending = false;
    end
end
end
