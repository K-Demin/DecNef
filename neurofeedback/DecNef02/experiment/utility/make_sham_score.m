% dir_name = fullfile('..', '..', 'DATA');
dir_name = fullfile('..', '..', 'DATA', 'DETREND');
ascii_fname = {...
    'MO160308_001_000006_DecNef00.txt'...
    'MO160308_001_000007_DecNef00.txt'...
    'MO160308_001_000008_DecNef00.txt'...
    'MO160308_001_000009_DecNef00.txt'...
    'MO160308_001_000010_DecNef00.txt'...
    };

addpath('..');


score = [];
trial_num = [];
total_trial_num = 0;

for ii=1:length(ascii_fname)
  % neurofeedback実験データを読む。
  nf_data = load_decnef_data00(dir_name, ascii_fname{ii});

  % 得点(下限値と上限値内に補正後) と 総試行数 を求める
  score = [score; nf_data.data.score];
  trial_num = [trial_num; nf_data.para.scans.trial_num];
  total_trial_num = total_trial_num + nf_data.para.scans.trial_num;
end


% 乱数発生器を初期化する。
try
  rand('state', sum(100*clock));
  rng(round(sum(100*clock)), 'twister');
catch
  % 古いバージョンのMATLABでは、rng関数がリリースされていない。
  % また、rand('state', seed)で、rand関数とnormrnd関数の初期値が
  % 更新されるを考えていたが、normrnd関数の初期値は更新され
  % ていない様子。 (2013.12.10)
  dt = clock;
  % normrnd関数の初期化 (normrndをランダム回数繰り返す)
  s = normrnd(nf_data.para.score.normrnd_mu,...
      nf_data.para.score.normrnd_sigma,...
      round(sum(dt(1:3))), round(sum(dt(4:6))));
  % rand関数の初期化
  rand('state', sum(s(:))); 
end


RAND_TYPE = 0;  	% 試行順に得点を出力(乱数なし)
% RAND_TYPE = 1;  	% 全得点をランダムに出力
% RAND_TYPE = 2;  	% セット内の得点をランダムに出力

switch RAND_TYPE
  case 0,	% 試行順に得点を出力(乱数なし)
    ptr = [1:total_trial_num];
  case 1,	% 全得点をランダムに出力
    [r,ptr] = sort( rand(total_trial_num,1) );
  case 2;	% セット内の得点をランダムに出力
    ptr = [];
    offset = 0;
    for ii=1:length(ascii_fname)
      [r,p] = sort( rand(trial_num(ii),1) );
      ptr = [ptr; offset+p];
      offset = offset+trial_num(ii);
    end
end

% Sham score file用の得点文字列を出力する。
fprintf('\n\n');
cnt = 0;
for ii=1:length(ascii_fname)
  for trial=1:trial_num(ii)
    cnt = cnt+1;
    fprintf('sham_score[%d] = %f\n', trial, score(ptr(cnt)));
  end
  fprintf('\n\n');
end
