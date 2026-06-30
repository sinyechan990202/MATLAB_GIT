% build_channel_model.m — Programmatically creates channel_model.slx

mdl = 'channel_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

lib = 'simulink/User-Defined Functions/MATLAB Function';

%% Input
add_block('simulink/Sources/In1', [mdl '/TX In'], 'Position',[30 70 60 90]);

%% Multipath Rayleigh (Communications Toolbox)
add_block('commlib/Multipath Rayleigh Fading Channel', [mdl '/Multipath'], ...
    'Position',[120 50 270 110], ...
    'SampleRate','10e6', ...
    'MaximumDopplerShift','5000', ...
    'PathDelays','[0 310e-9 710e-9 1090e-9 1730e-9 2510e-9]', ...
    'AveragePathGains','[0 -1 -9 -10 -15 -20]');

%% Doppler Shift
add_block(lib, [mdl '/Doppler Shift'], 'Position',[330 50 480 110]);
set_fcn(mdl, 'Doppler Shift', ...
    ['function y = fcn(x)' newline ...
     'persistent k' newline ...
     'if isempty(k), k = 0; end' newline ...
     'n = length(x);' newline ...
     't = (k : k+n-1)'' / 10e6;' newline ...
     'y = x .* exp(1j * 2*pi * 5000 * t);' newline ...
     'k = k + n;']);

%% AWGN
add_block('commlib/AWGN Channel', [mdl '/AWGN'], ...
    'Position',[540 50 670 110], ...
    'Mode','Signal to noise ratio (Eb/No)', ...
    'EbNo','10', ...
    'BitsPerSymbol','4');

%% Output
add_block('simulink/Sinks/Out1', [mdl '/RX Out'], 'Position',[740 70 770 90]);

%% Connections
add_line(mdl, 'TX In/1',        'Multipath/1');
add_line(mdl, 'Multipath/1',    'Doppler Shift/1');
add_line(mdl, 'Doppler Shift/1','AWGN/1');
add_line(mdl, 'AWGN/1',         'RX Out/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','1e-3');

save_system(mdl, fullfile(fileparts(mfilename('fullpath')), 'channel_model.slx'));
fprintf('Saved: channel_model.slx\n');

function set_fcn(mdl, blk_name, script)
    rt = sfroot();
    ch = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk_name]);
    ch.Script = script;
end
