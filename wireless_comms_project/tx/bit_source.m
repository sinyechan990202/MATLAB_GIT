function bits = bit_source(n_bits, mode, filename)
% Generate bit stream
% mode: 'random' | 'file'

if nargin < 2, mode = 'random'; end

switch lower(mode)
    case 'random'
        bits = randi([0 1], n_bits, 1);
    case 'file'
        fid  = fopen(filename, 'rb');
        raw  = fread(fid, ceil(n_bits/8), 'uint8');
        fclose(fid);
        bits = de2bi(raw, 8, 'left-msb')';
        bits = bits(:);
        bits = bits(1:n_bits);
    otherwise
        error('Unknown mode: %s', mode);
end
end
