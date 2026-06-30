function encoded = turbo_encoder(bits, rate)
% Turbo encoder (LTE-compatible, rate 1/3 default)
% Uses MATLAB comm.TurboEncoder

if nargin < 2, rate = 1/3; end

intrlvrLen = length(bits);
enc = comm.TurboEncoder('TrellisStructure', poly2trellis(4, [13 15], 13), ...
    'InterleaverIndices', randperm(intrlvrLen));
encoded = enc(bits(:));
end
