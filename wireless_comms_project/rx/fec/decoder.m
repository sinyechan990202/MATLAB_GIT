function decoded = decoder(llr, modem)
% FEC soft-decision decoder
% modem.fec_type: 'None' | 'LDPC' | 'Turbo' | 'Conv'

switch upper(modem.fec_type)
    case 'NONE'
        decoded = double(llr(:) < 0);

    case 'LDPC'
        cfg     = dvbs2ldpc(modem.code_rate);
        dec     = comm.LDPCDecoder(cfg, 'DecisionMethod', 'Soft decision', ...
                      'OutputFormat', 'Information bits', ...
                      'IterationTerminationCondition', 'Parity check satisfied');
        blk_in  = dec.NumInputBits;
        llr     = zero_pad(llr, blk_in);
        decoded = [];
        for i = 1 : blk_in : length(llr)
            decoded = [decoded; dec(llr(i:i+blk_in-1))]; %#ok<AGROW>
        end

    case 'TURBO'
        dec = comm.TurboDecoder( ...
            'TrellisStructure', poly2trellis(4,[13 15],13), ...
            'InterleaverIndices', randperm(modem.block_len), ...
            'NumIterations', 6);
        blk_in = 3*modem.block_len + 4*6;
        llr    = zero_pad(llr, blk_in);
        decoded = dec(llr(:));

    case 'CONV'
        trel    = poly2trellis(7, [171 133]);
        decoded = vitdec(double(llr < 0), trel, 34, 'cont', 'hard');
        decoded = decoded(35:end);

    otherwise
        error('Unknown FEC type: %s', modem.fec_type);
end

function out = zero_pad(x, blk)
    r = mod(length(x), blk);
    if r > 0, out = [x(:); zeros(blk-r,1)]; else, out = x(:); end
end
end
