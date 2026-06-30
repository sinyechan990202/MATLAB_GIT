% build_full_chain.m — Builds full_chain.slx integrating TX/Channel/RX as subsystems

mdl     = 'full_chain';
sim_dir = fileparts(mfilename('fullpath'));

if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

%% ---- Load sub-models as referenced subsystems ----
add_block('simulink/Ports & Subsystems/Model', [mdl '/TX Model'], ...
    'ModelName','tx_model','Position',[60 80 200 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/Channel Model'], ...
    'ModelName','channel_model','Position',[260 80 400 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/RX Model'], ...
    'ModelName','rx_model','Position',[460 80 600 140]);

%% ---- BER Measurement ----
add_block('commlib/Error Rate Calculation', [mdl '/BER Calc'], ...
    'Position',[660 75 800 145], ...
    'ReceiveDelay','0', ...
    'ComputationDelay','0', ...
    'OutputData','Workspace', ...
    'VariableName','ber_result');

add_block('simulink/Sinks/Display', [mdl '/BER Display'], ...
    'Position',[860 90 980 130]);

add_block('simulink/Sources/In1', [mdl '/Ref Bits'], ...
    'Position',[660 175 690 195]);

%% ---- Connections ----
add_line(mdl, 'TX Model/1',     'Channel Model/1');
add_line(mdl, 'Channel Model/1','RX Model/1');
add_line(mdl, 'RX Model/1',     'BER Calc/1');
add_line(mdl, 'Ref Bits/1',     'BER Calc/2');
add_line(mdl, 'BER Calc/1',     'BER Display/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','10e-3');

save_system(mdl, fullfile(sim_dir, 'full_chain.slx'));
fprintf('Saved: full_chain.slx\n');
