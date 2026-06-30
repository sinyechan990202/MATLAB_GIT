function constellation_plot(symbols, title_str, ref_syms)
% Constellation diagram

if nargin < 2, title_str = 'Constellation'; end

figure('Name', title_str);
plot(real(symbols), imag(symbols), '.', 'MarkerSize', 4);
hold on;
if nargin == 3 && ~isempty(ref_syms)
    plot(real(ref_syms), imag(ref_syms), 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    legend('Received', 'Reference');
end
xlabel('In-Phase');
ylabel('Quadrature');
title(title_str);
grid on; axis equal;
end
