function [] = save_ascii_data()


global gData

save_fname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,gData.define.files.ASCII_DATA_EXTENSION);
save_file_name = fullfile(gData.para.files.save_dir, save_fname);

fprintf('Save online neurofeedback data (ASCII format)\n');
fprintf('  Data store dir  = ''%s''\n', gData.para.files.save_dir );
fprintf('  Data store file = ''%s''\n', save_fname);

fd = fopen(save_file_name, 'w');
if fd == -1
  cd(gData.para.files.current_dir);	% Current directory�Ɉړ�����?B
  err_msg = sprintf('Cannot creat exp file (''%s'')', save_file_name);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end


% �����v�?�W�F�N�g�R?[�h���f?[�^�t�@�C����?o�͂���?B
fprintf(fd, 'ProjectCode = DecNef%02d\n', gData.define.DECNEF_PROJECT);
fprintf(fd, '\n');

% �o?[�W����?����f?[�^�t�@�C����?o�͂���?B
save_version_value(gData.version, fd);
fprintf(fd, '\n');

% �����p���??[�^�������?�?�����?B
[tmp, str] = make_parameter_string(gData.define, gData.para, gData.data);
% �����p���??[�^��������f?[�^�t�@�C����?o�͂���?B
for ii=1:length(str)
  fprintf(fd, '%s\n', str{ii});
end
fprintf(fd, '\n');

% define��?����f?[�^�t�@�C����?o�͂���?B
save_define_value(gData.define, fd);
fprintf(fd, '\n');

% �����f?[�^���f?[�^�t�@�C����?o�͂���?B
save_exp_data(gData.define, gData.para, gData.data, fd)
fprintf(fd, '\n');

% ��������(���֌W?��Ɠ��_)�̕������?�?�����?B
str = make_exp_result_string(gData.para, gData.data);
% �������ʕ�������f?[�^�t�@�C����?o�͂���?B
for ii=1:length(str)
  fprintf(fd, '%s\n', str{ii});
end

fclose(fd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_ascii_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_version_value(version, fd)
% function [] = save_version_value(version, fd)
% �o?[�W����?����f?[�^�t�@�C����?o�͂���?B
% 
% [input argument]
% version : �o?[�W����?����Ǘ?����?\����
% fd : �f?[�^�t�@�C���̃t�@�C�����ʎq

% �����v�?�W�F�N�g�R?[�h��?o�͂���?B
fprintf(fd, 'version.decnef_project = %d\n', version.decnef.project);
% �����v�?�W�F�N�g�̃���?[�X?���?o�͂���?B
fprintf(fd, 'version.decnef_release = %d\n', version.decnef.release);
% �����̓��t?���?o�͂���?B
fprintf(fd, 'version.decnef_exp_date = %d\n', version.decnef.exp_date);
% �����̎���?���?o�͂���?B
fprintf(fd, 'version.decnef_exp_time = %d\n', version.decnef.exp_time);

% MATLAB�o?[�W������?o�͂���?B
fprintf(fd, 'version.matlab_version = %s\n', version.matlab.version);
% MATLAB�̃���?[�X?���?o�͂���?B
fprintf(fd, 'version.matlab_release = %s\n', version.matlab.release);

% SPM�o?[�W������?o�͂���?B
fprintf(fd, 'version.spm_version = %s\n', version.spm.version);
% SPM�̃���?[�X��?���?o�͂���?B
fprintf(fd, 'version.spm_release = %d\n', version.spm.release);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_version_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_define_value(define, fd)
% function [] = save_define_value(define, fd)
% define��?����f?[�^�t�@�C����?o�͂���?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% fd : �f?[�^�t�@�C���̃t�@�C�����ʎq

fprintf(fd, 'define.REALIGN_VAL_NUM = %d\n',...
    define.default.REALIGN_VAL_NUM);
fprintf(fd, 'define.REALIG_PARA_FNAME_PREFIX_CODE = %s\n',...
    define.files.REALIG_PARA_FNAME_PREFIX_CODE);
fprintf(fd, 'define.ASCII_DATA_EXTENSION = %s\n',...
    define.files.ASCII_DATA_EXTENSION);
fprintf(fd, 'define.BINARY_DATA_EXTENSION = %s\n',...
    define.files.BINARY_DATA_EXTENSION);

fprintf(fd, '\n');

fprintf(fd, 'define.scan_condition.IDLING = %d\n',...
    define.scan_condition.IDLING);
fprintf(fd, 'define.scan_condition.PRE_TRIAL = %d\n',...
    define.scan_condition.PRE_TRIAL);
fprintf(fd, 'define.scan_condition.PREP_REST1 = %d\n',...
    define.scan_condition.PREP_REST1);
fprintf(fd, 'define.scan_condition.PREP_REST2 = %d\n',...
    define.scan_condition.PREP_REST2);
fprintf(fd, 'define.scan_condition.REST = %d\n',...
    define.scan_condition.REST);
fprintf(fd, 'define.scan_condition.TEST = %d\n',...
    define.scan_condition.TEST);
fprintf(fd, 'define.scan_condition.DELAY = %d\n',...
    define.scan_condition.DELAY);
fprintf(fd, 'define.scan_condition.CALC_SCORE = %d\n',...
    define.scan_condition.CALC_SCORE);
fprintf(fd, 'define.scan_condition.FEEDBACK_SCORE = %d\n',...
    define.scan_condition.FEEDBACK_SCORE);
fprintf(fd, 'define.scan_condition.FINISH = %d\n',...
    define.scan_condition.FINISH);

fprintf(fd, '\n');

fprintf(fd, 'define.CLEANUP_WORK_FILES = %d\n',...
    define.files.CLEANUP_WORK_FILES);
fprintf(fd, 'define.STD_DIALOG_BOX = %d', define.files.STD_DIALOG_BOX);

fprintf(fd, '\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_define_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_exp_data(define, para, data, fd)
% function [] = save_exp_data(define, data, fd)
% �����f?[�^���f?[�^�t�@�C����?o�͂���?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% data : �����f?[�^?\����
% fd : �f?[�^�t�@�C���̃t�@�C�����ʎq


% ��?M?��?���������Ă���Scan?���?o�͂���?B
received_scan_num = data.received_scan_num;
fprintf(fd, 'received_scan_num = %d\n', received_scan_num);

% ROI��voxel?���?o�͂���?B
for ii=1:data.roi_num
  fprintf(fd, 'roi_vox_num[%d] = %d\n', ii, data.roi_vox_num(ii));
end
% WM�f?[�^��voxel?���?o�͂���?B
fprintf(fd, 'wm_vox_num = %d\n', length(find(data.wm_mask(:))) );
% GS�f?[�^��voxel?���?o�͂���?B
fprintf(fd, 'gs_vox_num = %d\n', length(find(data.gs_mask(:))) );
% CSF�f?[�^��voxel?���?o�͂���?B
fprintf(fd, 'csf_vox_num = %d\n', length(find(data.csf_mask(:))) );

% �escan�ł�WM��?M?��l�̕��ϒl��?o�͂���?B
for ii=1:received_scan_num
  fprintf(fd, 'wm_signal[%d] = %f\n', ii, data.wm_signal(ii));
end
% �escan�ł�GS��?M?��l�̕��ϒl��?o�͂���?B
for ii=1:received_scan_num
  fprintf(fd, 'gs_signal[%d] = %f\n', ii, data.gs_signal(ii));
end
% �escan�ł�CSF��?M?��l�̕��ϒl��?o�͂���?B
for ii=1:received_scan_num
  fprintf(fd, 'csf_signal[%d] = %f\n', ii, data.csf_signal(ii));
end
% �escan�ł�realignment parameter��?o�͂���?B
for ii=1:received_scan_num
  realign_val_format = vector_format('%e',' ', define.default.REALIGN_VAL_NUM);
  realign_val_str = sprintf(realign_val_format, data.realign_val(ii,:));
  fprintf(fd, 'realign_val[%d] = %s\n', ii, realign_val_str);
end

% Scan���̔]�̈ړ��ʂ�?o�͂���?B [mm] (2016.02.01)
for ii=1:received_scan_num
  fprintf(fd, 'FD[%d] = %f [mm]\n', ii, data.FD(ii));
end


% �escan�ł�ROI��?M?��l��ROI template�f?[�^�̑��֌W?���?o�͂���?B
% (ROI���w�肵�Ă���?�?��̂�?o�͂���?B)
if data.roi_num		% ROI���w�肵�Ă���
  for ii=1:received_scan_num
    corr_roi_templ_format = vector_format('%f',' ', data.roi_num);
    corr_roi_templ_str =...
	sprintf(corr_roi_templ_format, data.corr_roi_template(ii,:));
    fprintf(fd, 'corr_roi_template[%d] = %s\n', ii, corr_roi_templ_str);
  end
end

% Scan�̌v���f?[�^�𓾓_�̌v�Z��?̗p ���Ȃ�/���� ��?o�͂���?B(2017.07.25)
for ii=1:received_scan_num
  fprintf(fd, 'ng_scan[%d] = %d\n', ii, data.ng_scan(ii));
end
  

% �팟�҂�?Q�Ă��Ȃ����̃`�F�b�N(1:OK.0:NG)���ʂ�?o�͂���?B
% 
% �������ʂ̕�����(make_exp_result_string()��?�?�)��
% ?d������̂ŃR�?���g�����Ă���?B
% fprintf(fd, '\n');
% for ii=1:para.scans.sleep_check_trial_num
%   str{end+1} = sprintf('sleep_check(%d) = %d \t # trial=%d',...
%       ii, data.sleep_check(ii), para.scans.sleep_check_trial(ii));
% end


fprintf(fd, '\n');

% �e��?s��label�l�Ɠ��_��?o�͂���?B
for ii=1:para.scans.trial_num
  for roi=1:data.roi_num
    fprintf(fd, 'label_ROI%d[%d] = %f\n', roi, ii, data.label(ii, roi));
  end
  fprintf(fd, 'source_score[%d] = %f\n', ii, data.source_score(ii));
  fprintf(fd, 'score[%d] = %f\n', ii, data.score(ii));
end
if data.roi_num
  % label�l���v�Z������?s��?����?�߂�?B
  label_trial = 1:para.scans.trial_num;
  label_trial( isnan(data.label(:,1)) ) = [];
  % label�l�̕��ϒl��?o�͂���?B
  for roi=1:data.roi_num
    fprintf(fd, 'LABEL_ROI%d AVERAGE = %f\n',...
	roi, mean(data.label(label_trial, roi)) );
  end
end
% ���_���v�Z������?s��?����?�߂�?B
score_trial = 1:para.scans.trial_num;
score_trial( isnan(data.score(:,1)) ) = [];
% ���_�̕��ϒl��?o�͂���?B
fprintf(fd, 'SOURCE_SCORE AVERAGE = %f\n',...
    mean(data.source_score(score_trial)) );
fprintf(fd, 'SCORE AVERAGE = %d\n', round( mean(data.score(score_trial)) ));

fprintf(fd, '\n');

% Stanford���C�ړxLevel��?o�͂���?B
fprintf(fd, 'sss_level = %d\n', data.sss.level);
% Stanford���C�ړx�Ɋւ���R�?���g�������?o�͂���?B
fprintf(fd, 'sss_comment = %s\n', data.sss.comment);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_exp_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
