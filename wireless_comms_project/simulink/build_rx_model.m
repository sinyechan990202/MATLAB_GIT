% build_rx_model.m — Programmatically creates rx_model.slx

mdl = 'rx_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

pos_x = 30;
step  = 160;

%% Helper: add a block and auto-advance position
function p = blk(mdl, lib, name, px, label)
    p = [px 55 px+120 105];
    add_block(lib, [mdl '/' name], 'Position', p);
    if nargin == 5
        set_param([mdl '/' name], 'MATLABFunction', label);
    end
end

%% Blocks
add_block('built-in/Inport',          [mdl '/RX In'],          'Position',[pos_x 70 pos_x+30 90]);
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/AGC'],             'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/AGC'], 'MATLABFunction', ...
    'function y=fcn(x); g=sqrt(1/(mean(abs(x).^2)+eps)); y=x*g;');
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/Freq Sync'],       'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/Freq Sync'], 'MATLABFunction', ...
    'function y=fcn(x); N=length(x); [~,i]=max(abs(fft(x.^4,N))); fo=(i-1)*10e6/N/4; t=(0:N-1)''/10e6; y=x.*exp(-1j*2*pi*fo*t);');
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/Timing Sync'],     'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/Timing Sync'], 'MATLABFunction', ...
    'function y=fcn(x); sps=4; N=floor(length(x)/sps); y=x(round(sps/2):sps:N*sps);');
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/Phase Sync'],      'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/Phase Sync'], 'MATLABFunction', ...
    'function y=fcn(x); alpha=0.05; ph=0; fr=0; y=zeros(size(x)); for k=1:length(x), y(k)=x(k)*exp(-1j*ph); d=sign(real(y(k)))+1j*sign(imag(y(k))); e=imag(y(k)*conj(d)); fr=fr+0.0025*e; ph=ph+alpha*e+fr; end');
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/Ch Estimator'],    'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/Ch Estimator'], 'MATLABFunction', ...
    'function y=fcn(x); y=x;');  % placeholder — replace with pilot-based estimation
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/MMSE Equalizer'],  'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/MMSE Equalizer'], 'MATLABFunction', ...
    'function y=fcn(x,H); nv=0.01; y=conj(H)./(abs(H).^2+nv).*x;');
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/Demodulator'],     'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/Demodulator'], 'MATLABFunction', ...
    'function y=fcn(x); y=qamdemod(x,16,"OutputType","bit","UnitAveragePower",true);');
pos_x = pos_x + step;

add_block('built-in/MATLAB Function', [mdl '/FEC Decoder'],     'Position',[pos_x 55 pos_x+120 105]);
set_param([mdl '/FEC Decoder'], 'MATLABFunction', ...
    'function y=fcn(x); trel=poly2trellis(7,[171 133]); y=vitdec(x,trel,34,"cont","hard"); y=y(35:end);');
pos_x = pos_x + step;

add_block('built-in/Outport',         [mdl '/RX Bits'],         'Position',[pos_x 70 pos_x+30 90]);

%% Connections (linear chain)
chain = {'RX In','AGC','Freq Sync','Timing Sync','Phase Sync', ...
         'Ch Estimator','MMSE Equalizer','Demodulator','FEC Decoder','RX Bits'};
for i = 1:length(chain)-1
    add_line(mdl, [chain{i} '/1'], [chain{i+1} '/1']);
end

%% Annotation
add_block('built-in/Note', [mdl '/Note1'], 'Position',[30 15 1450 40]);
set_param([mdl '/Note1'], 'Text', ...
    'RX Chain: AGC → FreqSync → TimingSync(Gardner) → PhaseSync(Costas) → ChEst → MMSE EQ → Demod(16QAM) → Viterbi');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','1e-3');

save_system(mdl, fullfile(fileparts(mfilename('fullpath')), 'rx_model.slx'));
fprintf('Saved: rx_model.slx\n');
