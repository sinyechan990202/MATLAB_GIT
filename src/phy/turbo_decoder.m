function decoded = turbo_decoder(llr, n_iterations)
% Turbo decoder (LTE-compatible MAP algorithm)

if nargin < 2, n_iterations = 6; end

intrlvrLen = length(llr);
dec = comm.TurboDecoder('TrellisStructure', poly2trellis(4, [13 15], 13), ...
    'InterleaverIndices', randperm(intrlvrLen), ...
    'NumIterations', n_iterations);
decoded = dec(llr(:));
end
