function [nfb_data] = load_binary_data(load_dir, load_fname)
% function [nfb_data] = load_binary_data(load_dir, load_fname)
% Load the dataset of neurofeedback experiment. (BINARY format)
% 
% [input argument]
% load_dir   : directory name
% load_fname : experiment data file name (BINARY format)
% 
% [output argument]
% nfb_data : Experimental data structure
% 
% ----------------------------------------------------------
% Copyright 2013 All Rights Reserved.
% ATR Brain Information Communication Research Lab Group.
% ----------------------------------------------------------
% Toshinori YOSHIOKA
% 2-2-2 Hikaridai, Seika-cho, Sorakugun, Kyoto,
% 619-0288, Japan (Keihanna Science city)


load_file_name = fullfile(load_dir, load_fname);
fprintf('Load online neurofeedback data (BINARY format)\n');
fprintf('  Data load dir  = ''%s''\n', load_dir);
fprintf('  Data load file = ''%s''\n', load_fname);

nfb_data = struct(...
    'data_flag', false,...		% �f�[�^�L��/�����t���O (0:����/1:�L��)
    'decnef_project', -1,...		% DecNef�����v���W�F�N�g�R�[�h
    'decnef_release', -1,...		% DecNef�����v���W�F�N�g�̃����[�X���
    'decnef_exp_date', -1,...		% �����̓��t���
    'decnef_exp_time', -1,...		% �����̎��ԏ��
    'dir_name', load_dir,...		% �����f�[�^file��directory
    'file_name', load_fname,...		% BINARY�`���̎����f�[�^file
    'roi_num', 0,...			% ROI�̐�
    'roi_vox_num', [],...		% ROI��voxel��
    'trial_num', 0,...			% ���s��
    'pre_trial_scan_num', 1,...		% ���s���J�n���閘��scan��
    'prep_rest1_scan_num', 1,...	% �O�����p��REST��������1��scan��
    'prep_rest2_scan_num', 1,...	% �O�����p��REST��������2��scan��
    'rest_scan_num', 1,...		% REST������scan��
    'test_scan_num', 1,...		% TEST������scan��
    'pre_test_delay_scan_num', 1,...	% TEST�����J�n���delay scan��
    'post_test_delay_scan_num', 1,...	% TEST�����I�����delay scan��
    'calc_score_scan_num', 1,...	% ���_�v�Z������scan��
    'feedbk_score_scan_num', 1,...	% ���_�񎦏�����scan��
    'regress_scan_num', 1,...		% �m�C�Y���������ɗ��p����scan��
    'total_scan_num', 0,...		% ��Scan��
    'received_scan_num', 0,...		% ��M��������������Scan��
    'scan_condition', [],...	% �escan�̉ۑ����
    'roi_template', [],...	% ROI��Template�f�[�^���Ǘ�����cell�z��
    'roi_weight', [],...	% ROI�̏d�݌W�����Ǘ�����cell�z��
    'roi_vol', [],...		% �escan��ROI�̑Svoxel�M�����Ǘ�����cell�z��
    'roi_denoised_vol', [],...	% �escan��ROI�̃m�C�Yvoxel�M���Ǘ�����cell�z��
    'roi_baseline_mean', [],...	% ROI��BASELINE���ϒl���Ǘ�����cell�z��
    'roi_baseline_std', [],...	% ROI��BASELINE�W���΍����Ǘ�����cell�z��
    'wm_signal', [],...		% �escan�ł�WM�̐M���l�̕��ϒl
    'gs_signal', [],...		% �escan�ł�GM�̐M���l�̕��ϒl
    'csf_signal', [],...	% �escan�ł�CSF�̐M���l�̕��ϒl
    'realign_val', [],...	% �escan�ł�realignment parameter�̕��ϒl
    'FD', [],...		% Scan���̔]�̈ړ��� [mm]
    'corr_roi_template', [],...	% �escan��ROI data��ROI template data�̑��֌W��
    'ng_scan', [],...		% �escan�̌v���f�[�^�𓾓_�v�Z�ɍ̗p���Ȃ�/����
    'label', [],...		% �eROI��label�l
    'source_score', [],...	% �e���s�̉����l�Ə���l���ɕ␳�O�̓��_
    'score', []...		% �e���s�̉����l�Ə���l���ɕ␳��̓��_
    );


fd = fopen(load_file_name, 'r');
if fd == -1	% �����f�[�^file�����݂��Ȃ��B
  % �f�[�^�L��/�����t���O���X�V����B
  nfb_data.data_flag = false;	% �f�[�^������
else		% �����f�[�^file�����݂��Ȃ��B
  % �f�[�^�L�����t���O���X�V����B
  nfb_data.data_flag = true;	% �f�[�^���L��
  
  % DecNef�����v���W�F�N�g�R�[�h(32bit unsigned integer)���l������B
  nfb_data.decnef_project = fread(fd, 1, 'uint32');
  % DecNef�����v���W�F�N�g�̃����[�X���(32bit unsigned integer)���l������B
  nfb_data.decnef_release = fread(fd, 1, 'uint32');
  % �����̓��t���(32bit unsigned integer)���l������B
  nfb_data.decnef_exp_date = fread(fd, 1, 'uint32');
  % �����̎��ԏ��(32bit unsigned integer)���l������B
  nfb_data.decnef_exp_time = fread(fd, 1, 'uint32');
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load�֐� �� �f�[�^�t�@�C���̐��������`�F�b�N����B
  % ---------------------------------------------------------
  % ( �����v���W�F�N�g�R�[�h �� �����v���W�F�N�g�����[�X�� ���A
  %   Load�֐� �� �f�[�^�t�@�C�� �ň�v���Ȃ���΂Ȃ�Ȃ��B )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load�֐��� �����v���W�F�N�g�R�[�h(DecNef_Project) �� 
  % �����v���W�F�N�g�����[�X��(DecNef_ReleaseData) ���l������B
  [DecNef_Project, DecNef_ReleaseData] = release_info();
  if nfb_data.decnef_project ~= DecNef_Project |...
	nfb_data.decnef_release ~= DecNef_ReleaseData
    % Load�֐� �� �f�[�^�t�@�C�� ��
    % �����v���W�F�N�g�R�[�h �� �����v���W�F�N�g�����[�X�� ����v���Ȃ��B
    str = sprintf(' [Decnef project information mismatch]\n');
    str = sprintf('%s Function (%s)\n', str, mfilename);
    str = sprintf('%s \t decnef_project = %d\n', str, DecNef_Project);
    str = sprintf('%s \t decnef_release = %d\n', str, DecNef_ReleaseData);
    str = sprintf('%s Data file (%s)\n', str, load_fname);
    str = sprintf('%s \t decnef_project = %d\n',...
	str, nfb_data.decnef_project);
    str = sprintf('%s \t decnef_release = %d\n',...
	str, nfb_data.decnef_release);
    error(str);
  end
  
  
  % Realignment parameter�̔z��(32bit unsigned integer)���l������B
  REALIGN_VAL_NUM = fread(fd, 1, 'uint32');

  % ROI�̐�(32bit unsigned integer)���l������B
  nfb_data.roi_num = fread(fd, 1, 'uint32');
  % ROI��voxel��(32bit unsigned integer)���l������B
  nfb_data.roi_vox_num = fread(fd, [1,nfb_data.roi_num], 'uint32');

  % ���s��(32bit unsigned integer)���l������B
  nfb_data.trial_num = fread(fd, 1, 'uint32');

  % ���s���J�n���閘��scan��(32bit unsigned integer)���l������B
  nfb_data.pre_trial_scan_num = fread(fd, 1, 'uint32');
  % �O�����p��REST��������1��scan��(32bit unsigned integer)���l������B
  nfb_data.prep_rest1_scan_num = fread(fd, 1, 'uint32');
  % �O�����p��REST��������2��scan��(32bit unsigned integer)���l������B
  nfb_data.prep_rest2_scan_num = fread(fd, 1, 'uint32');
  % REST������scan��(32bit unsigned integer)���l������B
  nfb_data.rest_scan_num = fread(fd, 1, 'uint32');
  % TEST������scan��(32bit unsigned integer)���l������B
  nfb_data.test_scan_num = fread(fd, 1, 'uint32');
  % TEST�����J�n���delay scan��(32bit unsigned integer)���l������B
  nfb_data.pre_test_delay_scan_num = fread(fd, 1, 'uint32');
  % TEST�����I�����delay scan��(32bit unsigned integer)���l������B
  nfb_data.post_test_delay_scan_num = fread(fd, 1, 'uint32');
  % ���_�v�Z������scan��(32bit unsigned integer)���l������B
  nfb_data.calc_score_scan_num = fread(fd, 1, 'uint32');
  % ���_�񎦏�����scan��(32bit unsigned integer)���l������B
  nfb_data.feedbk_score_scan_num = fread(fd, 1, 'uint32');
  % ��Scan��(32bit unsigned integer)���l������B
  nfb_data.total_scan_num = fread(fd, 1, 'uint32');

  % �m�C�Y���������ɗ��p����Scan��(32bit unsigned integer)���l������B
  nfb_data.regress_scan_num = fread(fd, 1, 'uint32');
  
  % �escan�̉ۑ������ݒ肷��z���p�ӂ���B
  nfb_data.scan_condition = zeros(nfb_data.total_scan_num, 1);

  % ROI��Template�f�[�^���Ǘ�����cell�z���p�ӂ���B
  nfb_data.roi_template = cell(1, nfb_data.roi_num);
  % ROI�̏d�݌W�����Ǘ�����cell�z���p�ӂ���B
  nfb_data.roi_weight = cell(1, nfb_data.roi_num);
  % �escan��ROI�̑Svoxel�M�����Ǘ�����cell�z���p�ӂ���B
  nfb_data.roi_vol = cell(1, nfb_data.roi_num);
  % �escan��ROI�̃m�C�Y������̑Svoxel�M�����Ǘ�����cell�z���p�ӂ���B
  nfb_data.roi_denoised_vol = cell(1, nfb_data.roi_num);
  % ROI��BASELINE���ϒl���Ǘ�����cell�z���p�ӂ���B
  nfb_data.roi_baseline_mean = cell(1, nfb_data.roi_num);
  % ROI��BASELINE�W���΍����Ǘ�����cell�z���p�ӂ���B
  nfb_data.roi_baseline_std = cell(1, nfb_data.roi_num);
  % �escan�ł�WM�̐M���l�̕��ϒl��ݒ肷��z���p�ӂ���B
  nfb_data.wm_signal = zeros(nfb_data.total_scan_num, 1);
  % �escan�ł�GM�̐M���l�̕��ϒl��ݒ肷��z���p�ӂ���B
  nfb_data.gs_signal = zeros(nfb_data.total_scan_num, 1);
  % �escan�ł�CSF�̐M���l�̕��ϒl��ݒ肷��z���p�ӂ���B
  nfb_data.csf_signal = zeros(nfb_data.total_scan_num, 1);
  % �escan��realignment parameter��ݒ肷��z���p�ӂ���B
  nfb_data.realign_val = zeros(nfb_data.total_scan_num, REALIGN_VAL_NUM);
  % Scan���̔]�̈ړ��ʂ�ݒ肷��z���p�ӂ���B [mm]
  nfb_data.FD = zeros(nfb_data.total_scan_num, 1);
  % �escan�ł�ROI�̐M���l��ROI template�f�[�^�̑��֌W��
  % ��ݒ肷��z���p�ӂ���B
  nfb_data.corr_roi_template=zeros(nfb_data.total_scan_num, nfb_data.roi_num);
  % Scan�̌v���f�[�^�𓾓_�̌v�Z�ɍ̗p ���Ȃ�/���� ��ݒ肷��z���p�ӂ���B
  nfb_data.ng_scan = false(nfb_data.total_scan_num, 1);
  % �eROI��label�l��ۑ�����z���p�ӂ���B
  nfb_data.label = zeros(nfb_data.trial_num, nfb_data.roi_num);
  % �e���s�ł̉����l�Ə���l���ɕ␳�O�̓��_��ۑ�����z���p�ӂ���B
  nfb_data.source_score = zeros(nfb_data.trial_num, 1);
  % �e���s�ł̉����l�Ə���l���ɕ␳��̓��_��ۑ�����z���p�ӂ���B
  nfb_data.score = zeros(nfb_data.trial_num, 1);

  % �escan�̉ۑ����(32bit integer)���l������B
  nfb_data.scan_condition = fread(fd, nfb_data.total_scan_num, 'int32');

  for ii=1:nfb_data.roi_num
    roi_vol_num = nfb_data.roi_vox_num(ii);		% ROI��voxel��
    % ROI��Template�f�[�^���l������B
    nfb_data.roi_template{ii} = fread(fd, [1, roi_vol_num], 'double');
    % ROI�̏d�݌W�����l������B (ROI��voxel��+1)
    nfb_data.roi_weight{ii} = fread(fd, [1, roi_vol_num+1], 'double');
    % ROI�̑Svoxel�̃m�C�Y������̐M���l���l������B
    nfb_data.roi_vol{ii} =...
	fread(fd, [nfb_data.total_scan_num, roi_vol_num], 'double');
    % ROI�̑Svoxel�̐M���l���l������B
    nfb_data.roi_denoised_vol{ii} =...
	fread(fd, [nfb_data.total_scan_num, roi_vol_num], 'double');
    % ROI�̑Svoxel��BASELINE REST������scan�ł̐M���l�̕��ϒl���l������B
    nfb_data.roi_baseline_mean{ii} = fread(fd, [1, roi_vol_num], 'double');
    % ROI�̑Svoxel��BASELINE REST������scan�ł̐M���l�̕W���΍����l������B
    nfb_data.roi_baseline_std{ii} = fread(fd, [1, roi_vol_num], 'double');
  end
  % �escan�ł�WM�̐M���l�̕��ϒl���l������B
  nfb_data.wm_signal = fread(fd, nfb_data.total_scan_num, 'double');
  % �escan�ł�GM�̐M���l�̕��ϒl���l������B
  nfb_data.gs_signal = fread(fd, nfb_data.total_scan_num, 'double');
  % �escan�ł�CSF�̐M���l�̕��ϒl���l������B
  nfb_data.csf_signal = fread(fd, nfb_data.total_scan_num, 'double');
  % �escan�ł�realignment parameter�̕��ϒl���l������B
  nfb_data.realign_val =...
      fread(fd, [nfb_data.total_scan_num, REALIGN_VAL_NUM], 'double');

  % Scan���̔]�̈ړ��ʂ��l������B [mm]
  nfb_data.FD = fread(fd, [nfb_data.total_scan_num, 1], 'double');
  
  % �escan�ł�ROI�̐M���l��ROI template�̑��֌W�����l������B
  nfb_data.corr_roi_template =...
      fread(fd, [nfb_data.total_scan_num, nfb_data.roi_num], 'double');

  % Scan�̌v���f�[�^�𓾓_�̌v�Z�ɍ̗p ���Ȃ�/���� ���l������B
  nfb_data.ng_scan = fread(fd, [nfb_data.total_scan_num, 1], 'logical');
  
  % �eROI��label�l���l������B
  nfb_data.label = fread(fd, [nfb_data.trial_num, nfb_data.roi_num], 'double');
  % �e���s�̉����l�Ə���l���ɕ␳�O�̓��_���l������B
  nfb_data.source_score = fread(fd, nfb_data.trial_num, 'double');
  % �e���s�̉����l�Ə���l���ɕ␳��̓��_���l������B
  nfb_data.score = fread(fd, nfb_data.trial_num, 'double');

  fclose(fd);
  
  % ��M�������������Ă���Scan�������߂�B
  % (wm_signal�z��NaN�łȂ��f�[�^�̐�)
  nfb_data.received_scan_num = length( find( ~isnan(nfb_data.wm_signal) ) );
end	% <-- End of 'if fd == -1 ... else'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_binary_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
