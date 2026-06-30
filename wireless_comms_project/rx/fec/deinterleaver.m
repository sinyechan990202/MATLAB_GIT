function bits_out = deinterleaver(bits_in, perm, block_len)
% Bit deinterleaver — inverse permutation of interleaver

n_bits  = length(bits_in);
bits_in = zero_pad(bits_in, block_len);
n_blk   = length(bits_in) / block_len;
bits_out = zeros(size(bits_in));

inv_perm(perm) = 1:length(perm);

for b = 1:n_blk
    idx = (b-1)*block_len + 1 : b*block_len;
    bits_out(idx) = bits_in(idx(inv_perm));
end

bits_out = bits_out(1:n_bits);

function out = zero_pad(x, blk)
    r = mod(length(x), blk);
    if r > 0, out = [x(:); zeros(blk-r,1)]; else, out = x(:); end
end
end
