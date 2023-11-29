function [nfb_data] = load_decnef_data10(dir_name, ascii_fname)
% function [nfb_data] = load_decnef_data10(dir_name, ascii_fname)
% Load the dataset of Decoded Neurofeedback(DecNef) experiment.
%                                            (DecNef10)
% 
% [input argument]
% dir_name    : directory name
% ascii_fname : experiment data file name (ASCII format)
% 
% [output argument]
% nfb_data : Experimental data structure
%        nfb_data.DECNEF_PROJECT : Project code of DecNef experiment 
%        nfb_data.version: Structure which manages the version variables
%        nfb_data.define : Structure which manages the define variables
%        nfb_data.para   : Structure which manages the parameter variables
%        nfb_data.data   : Structure which manages the trial variables
% 
% ----------------------------------------------------------
% Copyright 2013 All Rights Reserved.
% ATR Brain Information Communication Research Lab Group.
% ----------------------------------------------------------
% Toshinori YOSHIOKA
% 2-2-2 Hikaridai, Seika-cho, Sorakugun, Kyoto,
% 619-0288, Japan (Keihanna Science city)



% MATLAB path��ǉ��ݒ肷��B
fullpath = which( mfilename );
[my_path, my_name, extension] = fileparts(deblank(fullpath));
addpath( my_path );

if nargin < 2
  usage_message(my_name);	% Usage message���o�͂���B
  return;
end

% �����f�[�^���f�[�^�t�@�C��(ASCII�`��)����ǂݍ��ށB
nfb_data = load_ascii_data(dir_name, ascii_fname);

% BINARY�`���̎����f�[�^�t�@�C�������l������B
% (�f�[�^�t�@�C����(ASCII�`��)����ASCII�`����
%  �t�@�C���g���q����菜����������ɁA
%  BINARY�`���̃t�@�C���g���q��A������B)
p = strfind(ascii_fname, nfb_data.define.ASCII_DATA_EXTENSION);
binary_fname = sprintf('%s%s',...
    ascii_fname(1:p-1), nfb_data.define.BINARY_DATA_EXTENSION);
% �����f�[�^���f�[�^�t�@�C��(BINARY�`��)����ǂݍ��ށB
binary_data = load_binary_data(dir_name, binary_fname);


if binary_data.data_flag
  % BINARY�`���̃f�[�^�t�@�C�����L���ȏꍇ�A
  % ���s�f�[�^���Ǘ�����\���̂́ABINARY�`��
  % �̃f�[�^�t�@�C������ǂݍ��񂾃f�[�^���̗p����B
  % (BINARY�`���̕����L����������������)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ASCII�`�� �� BINARY�`�� �̃f�[�^�t�@�C���̐��������`�F�b�N����B
  % ---------------------------------------------------------
  % ( �����̓��t��� �� �����̎��ԏ�� ���AASCII�`�� �� BINARY�`�� 
  %   �̃f�[�^�t�@�C�� �ň�v���Ȃ���΂Ȃ�Ȃ��B )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if nfb_data.version.decnef_exp_date ~=...
	binary_data.decnef_exp_date |...
	nfb_data.version.decnef_exp_time ~=...
	binary_data.decnef_exp_time
    % �����̓��t��� �� �����̎��ԏ�� ����v���Ȃ��B
    str = sprintf(' [Experiment date information mismatch]\n');
    str = sprintf('%s ASCII format file (%s)\n', str, ascii_fname);
    str = sprintf('%s \t decnef_exp_date = %d\n',...
	str, nfb_data.version.decnef_exp_date);
    str = sprintf('%s \t decnef_exp_time = %d\n',...
	str, nfb_data.version.decnef_exp_time);
    str = sprintf('%s BINARY format file (%s)\n', str, binary_fname);
    str = sprintf('%s \t decnef_exp_date = %d\n',...
	str, binary_data.decnef_exp_date);
    str = sprintf('%s \t decnef_exp_time = %d\n',...
	str,  binary_data.decnef_exp_time);
    error(str);
  end
  
  nfb_data.data.scan_condition = binary_data.scan_condition;
  nfb_data.data.roi_template = binary_data.roi_template;
  nfb_data.data.roi_weight = binary_data.roi_weight;
  nfb_data.data.roi_vol = binary_data.roi_vol;
  nfb_data.data.roi_denoised_vol = binary_data.roi_denoised_vol;
  nfb_data.data.roi_baseline_mean = binary_data.roi_baseline_mean;
  nfb_data.data.roi_baseline_std = binary_data.roi_baseline_std;
  nfb_data.data.wm_signal = binary_data.wm_signal;
  nfb_data.data.gs_signal = binary_data.gs_signal;
  nfb_data.data.csf_signal = binary_data.csf_signal;
  nfb_data.data.realign_val = binary_data.realign_val;
  nfb_data.data.FD = binary_data.FD;
  nfb_data.data.corr_roi_template = binary_data.corr_roi_template;
  nfb_data.data.ng_scan = binary_data.ng_scan;
  nfb_data.data.label = binary_data.label;
  nfb_data.data.source_score = binary_data.source_score;
  nfb_data.data.score = binary_data.score;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_decnef_data10()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function usage_message(my_name)
% function usage_message(my_name)
% Load�v���O������Usage message��W���o�͂���B
% 
% [input argument]
% my_name : Load�v���O�����̃v���O������
fprintf('USAGE : nfb_data = %s(dir_name, ascii_fname)\n', my_name);
fprintf('  dir_name    : directory name\n');
fprintf('  ascii_fname : experiment data file name (ASCII format)\n');
fprintf('  nfb_data    : experimental data structure\n');
fprintf('\n  help %s\n', my_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function usage_message()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
