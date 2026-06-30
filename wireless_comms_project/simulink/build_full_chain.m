% build_full_chain.m — Builds full_chain.slx by referencing sub-models

mdl = 'full_chain';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

sim_dir = fileparts(mfilename('fullpath'));

%% ---- Model Reference blocks ----
add_block('simulink/Ports & Subsystems/Model', [mdl '/TX Model'], ...
    'ModelName','tx_model','Position',[80 80 220 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/Channel Model'], ...
    'ModelName','channel_model','Position',[300 80 440 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/RX Model'], ...
    'ModelName','rx_model','Position',[520 80 660 140]);

%% ---- BER Measurement ----
add_block('commblks/Error Rate Calculation', [mdl '/BER'], ...
    'Position',[740 75 860 145], ...
    'ReceiveDelay','0', ...
    'ComputationDelay','0', ...
    'OutputData','Workspace', ...
    'VariableName','ber_out');

add_block('built-in/Display', [mdl '/BER Display'], ...
    'Position',[920 90 1020 130]);

%% ---- Bit source for reference ----
add_block('built-in/Inport', [mdl '/Ref Bits'], ...
    'Position',[740 170 770 190]);

%% ---- Connections ----
add_line(mdl, 'TX Model/1',    'Channel Model/1');
add_line(mdl, 'Channel Model/1','RX Model/1');
add_line(mdl, 'RX Model/1',    'BER/1');   % received bits
add_line(mdl, 'Ref Bits/1',    'BER/2');   % reference bits
add_line(mdl, 'BER/1',         'BER Display/1');

%% ---- Annotation ----
add_block('built-in/Note', [mdl '/Note1'], 'Position',[80 30 1020 60]);
set_param([mdl '/Note1'], 'Text', ...
    'Full Link: TX Model → Channel Model (Multipath+Doppler+AWGN) → RX Model → BER');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','10e-3');

save_system(mdl, fullfile(sim_dir, 'full_chain.slx'));
fprintf('Saved: full_chain.slx\n');

fprintf('\n=== Build all models ===\n');
fprintf('Run in MATLAB:\n');
fprintf('  cd simulink\n');
fprintf('  build_tx_model\n');
fprintf('  build_channel_model\n');
fprintf('  build_rx_model\n');
fprintf('  build_full_chain\n');
