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
  % neurofeedback�����f�[�^��ǂށB
  nf_data = load_decnef_data00(dir_name, ascii_fname{ii});

  % ���_(�����l�Ə���l���ɕ␳��) �� �����s�� �����߂�
  score = [score; nf_data.data.score];
  trial_num = [trial_num; nf_data.para.scans.trial_num];
  total_trial_num = total_trial_num + nf_data.para.scans.trial_num;
end


% ���������������������B
try
  rand('state', sum(100*clock));
  rng(round(sum(100*clock)), 'twister');
catch
  % �Â��o�[�W������MATLAB�ł́Arng�֐��������[�X����Ă��Ȃ��B
  % �܂��Arand('state', seed)�ŁArand�֐���normrnd�֐��̏����l��
  % �X�V�������l���Ă������Anormrnd�֐��̏����l�͍X�V����
  % �Ă��Ȃ��l�q�B (2013.12.10)
  dt = clock;
  % normrnd�֐��̏����� (normrnd�������_���񐔌J��Ԃ�)
  s = normrnd(nf_data.para.score.normrnd_mu,...
      nf_data.para.score.normrnd_sigma,...
      round(sum(dt(1:3))), round(sum(dt(4:6))));
  % rand�֐��̏�����
  rand('state', sum(s(:))); 
end


RAND_TYPE = 0;  	% ���s���ɓ��_���o��(�����Ȃ�)
% RAND_TYPE = 1;  	% �S���_�������_���ɏo��
% RAND_TYPE = 2;  	% �Z�b�g���̓��_�������_���ɏo��

switch RAND_TYPE
  case 0,	% ���s���ɓ��_���o��(�����Ȃ�)
    ptr = [1:total_trial_num];
  case 1,	% �S���_�������_���ɏo��
    [r,ptr] = sort( rand(total_trial_num,1) );
  case 2;	% �Z�b�g���̓��_�������_���ɏo��
    ptr = [];
    offset = 0;
    for ii=1:length(ascii_fname)
      [r,p] = sort( rand(trial_num(ii),1) );
      ptr = [ptr; offset+p];
      offset = offset+trial_num(ii);
    end
end

% Sham score file�p�̓��_��������o�͂���B
fprintf('\n\n');
cnt = 0;
for ii=1:length(ascii_fname)
  for trial=1:trial_num(ii)
    cnt = cnt+1;
    fprintf('sham_score[%d] = %f\n', trial, score(ptr(cnt)));
  end
  fprintf('\n\n');
end
