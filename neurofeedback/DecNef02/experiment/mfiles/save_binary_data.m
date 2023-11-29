function [] = save_binary_data()
% function [] = save_binary_data()
% �����f�[�^���f�[�^�t�@�C��(BINARY�`��)�ɏo�͂���B

global gData
% BINARY�`���̃f�[�^�t�@�C�����쐬����B
save_fname = sprintf('%s_%s%s',...
    gData.para.save_name, gData.para.files.dicom_fnameB,...
    gData.define.files.BINARY_DATA_EXTENSION);
save_file_name = fullfile(gData.para.files.save_dir, save_fname);
save_matname = [save_fname(1:end-4),'.mat'];
save(save_matname,'gData');

fprintf('Save online neurofeedback data (BINARY format)\n');
fprintf('  Data store dir  = ''%s''\n', gData.para.files.save_dir );
fprintf('  Data store file = ''%s''\n', save_fname);

fd = fopen(save_file_name, 'w');
if fd == -1
  err_msg = sprintf('Cannot creat exp file (''%s'')', save_file_name);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end

% �����v���W�F�N�g�R�[�h(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.version.decnef.project ), 'uint32');
% �����v���W�F�N�g�̃����[�X���(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.version.decnef.release ), 'uint32');
% �����̓��t���(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.version.decnef.exp_date ), 'uint32');
% �����̎��ԏ��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.version.decnef.exp_time ), 'uint32');

% Realignment parameter�̔z��(32bit integer)���o�͂���B
fwrite(fd, int32( gData.define.default.REALIGN_VAL_NUM ), 'int32');

% ROI�̐�(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.data.roi_num ), 'uint32');
% ROI��voxel��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.data.roi_vox_num ), 'uint32');

% ���s��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.trial_num ), 'uint32');

% ���s���J�n���閘��scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.pre_trial_scan_num ), 'uint32');
% 1���s�ڂ̑O�����p��REST��������1��scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.prep_rest1_scan_num ), 'uint32');
% 1���s�ڂ̑O�����p��REST��������2��scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.prep_rest2_scan_num ), 'uint32');
% REST������scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.rest_scan_num ), 'uint32');
% TEST������scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.test_scan_num ), 'uint32');
% TEST�����J�n���delay scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.pre_test_delay_scan_num ), 'uint32');
% TEST�����I�����delay scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.post_test_delay_scan_num ), 'uint32');
% ���_�v�Z������scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.calc_score_scan_num ), 'uint32');
% ���_�񎦏�����scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.feedbk_score_scan_num ), 'uint32');
% ��Scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.total_scan_num ), 'uint32');

% �m�C�Y����������Scan��(32bit unsigned integer)���o�͂���B
fwrite(fd, uint32( gData.para.scans.regress_scan_num ), 'uint32');

% �escan�̉ۑ����(32bit integer)���o�͂���B
fwrite(fd, int32( gData.data.scan_condition ), 'int32');

for ii=1:gData.data.roi_num
  % ROI��Template�f�[�^���o�͂���B
  fwrite(fd, gData.data.roi_template{ii}, 'double');
  % ROI�̏d�݌W�����o�͂���B
  fwrite(fd, gData.data.roi_weight{ii}, 'double');
  % ROI�̑Svoxel�̐M���l���o�͂���B
  fwrite(fd, gData.data.roi_vol{ii}, 'double');
  % ROI�̑Svoxel�̃m�C�Y������̐M���l���o�͂���B
  fwrite(fd, gData.data.roi_denoised_vol{ii}, 'double');
  % ROI�̑Svoxel��BASELINE REST������scan�ł̐M���l�̕��ϒl���o�͂���B
  fwrite(fd, gData.data.roi_baseline_mean{ii}, 'double');
  % ROI�̑Svoxel��BASELINE REST������scan�ł̐M���l�̕W���΍����o�͂���B
  fwrite(fd, gData.data.roi_baseline_std{ii}, 'double');
end
% �escan�ł�WM�̐M���l�̕��ϒl���o�͂���B
fwrite(fd, gData.data.wm_signal, 'double');
% �escan�ł�GS�̐M���l�̕��ϒl���o�͂���B
fwrite(fd, gData.data.gs_signal, 'double');
% �escan�ł�CSF�̐M���l�̕��ϒl���o�͂���B
fwrite(fd, gData.data.csf_signal, 'double');
% �escan�ł�realignment parameter�̕��ϒl���o�͂���B
fwrite(fd, gData.data.realign_val, 'double');

% Scan���̔]�̈ړ��ʂ��o�͂���B [mm] (2016.02.01)
fwrite(fd, gData.data.FD, 'double');

% �escan�ł�ROI�̐M���l��ROI template�f�[�^�̑��֌W�����o�͂���B
fwrite(fd, gData.data.corr_roi_template, 'double');

% Scan�̌v���f�[�^�𓾓_�̌v�Z�ɍ̗p ���Ȃ�/���� ���o�͂���B(2017.07.25)
fwrite(fd, gData.data.ng_scan, 'logical');

% �e���s�̊eROI��label�l���o�͂���B
fwrite(fd, gData.data.label, 'double');
% �e���s�̉����l�Ə���l���ɕ␳�O�̓��_���o�͂���B
fwrite(fd, gData.data.source_score, 'double');
% �e���s�̉����l�Ə���l���ɕ␳��̓��_���o�͂���B
fwrite(fd, gData.data.score, 'double');

fclose(fd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_binary_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
