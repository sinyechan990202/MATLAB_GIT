function coded_bits = encoder(bits, modem)
% FEC encoder dispatcher
% modem.fec_type: 'None' | 'LDPC' | 'Turbo' | 'Conv'

switch upper(modem.fec_type)
    case 'NONE'
        coded_bits = bits(:);

    case 'LDPC'
        cfg = dvbs2ldpc(modem.code_rate);
        enc = comm.LDPCEncoder(cfg);
        blk = enc.NumInputBits;
        bits = zero_pad(bits, blk);
        coded_bits = [];
        for i = 1 : blk : length(bits)
            coded_bits = [coded_bits; enc(bits(i:i+blk-1))]; %#ok<AGROW>
        end

    case 'TURBO'
        enc = comm.TurboEncoder( ...
            'TrellisStructure', poly2trellis(4,[13 15],13), ...
            'InterleaverIndices', randperm(modem.block_len));
        bits = zero_pad(bits, modem.block_len);
        coded_bits = [];
        for i = 1 : modem.block_len : length(bits)
            coded_bits = [coded_bits; enc(bits(i:i+modem.block_len-1))]; %#ok<AGROW>
        end

    case 'CONV'
        trel = poly2trellis(7, [171 133]);
        coded_bits = convenc(bits(:), trel);

    otherwise
        error('Unknown FEC type: %s', modem.fec_type);
end
end

function out = zero_pad(bits, blk)
r = mod(length(bits), blk);
if r > 0, out = [bits(:); zeros(blk - r, 1)]; else, out = bits(:); end
end
