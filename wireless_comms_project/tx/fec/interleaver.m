function [interleaved, perm] = interleaver(bits, block_len, mode)
% Bit interleaver
% mode: 'block' | 'random'

if nargin < 3, mode = 'random'; end

n_bits = length(bits);
bits   = zero_pad(bits, block_len);
n_blk  = length(bits) / block_len;
interleaved = zeros(size(bits));
perm = zeros(block_len, 1);

switch lower(mode)
    case 'random'
        rng(0);
        perm = randperm(block_len)';
    case 'block'
        % Row-write / column-read block interleaver
        cols = sqrt(block_len);
        rows = block_len / cols;
        perm = reshape(reshape(1:block_len, rows, cols)', 1, [])';
end

for b = 1:n_blk
    idx = (b-1)*block_len + 1 : b*block_len;
    interleaved(idx) = bits(idx(perm));
end

interleaved = interleaved(1:n_bits);

function out = zero_pad(x, blk)
    r = mod(length(x), blk);
    if r > 0, out = [x(:); zeros(blk-r,1)]; else, out = x(:); end
end
end
