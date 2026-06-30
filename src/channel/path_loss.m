function pl_db = path_loss(d_m, fc_hz, model)
% Free-space and empirical path loss models
%
% model: 'FSPL' | 'Log-Distance' | 'Okumura-Hata'

c = 3e8;
switch upper(model)
    case 'FSPL'
        pl_db = 20*log10(4*pi*d_m*fc_hz/c);

    case 'LOG-DISTANCE'
        d0 = 1;
        n  = 3.5;  % path loss exponent (urban)
        pl_db = 20*log10(4*pi*d0*fc_hz/c) + 10*n*log10(d_m/d0);

    case 'OKUMURA-HATA'
        % Urban macro cell, fc in MHz, d in km
        fc_mhz = fc_hz / 1e6;
        d_km   = d_m / 1e3;
        hb = 30; hm = 1.5;  % base/mobile antenna heights (m)
        a_hm = (1.1*log10(fc_mhz) - 0.7)*hm - (1.56*log10(fc_mhz) - 0.8);
        pl_db = 69.55 + 26.16*log10(fc_mhz) - 13.82*log10(hb) ...
                - a_hm + (44.9 - 6.55*log10(hb))*log10(d_km);

    otherwise
        error('Unknown path loss model: %s', model);
end
end
