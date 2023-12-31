function [] = save_ascii_data()


global gData

save_fname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,gData.define.files.ASCII_DATA_EXTENSION);
save_file_name = fullfile(gData.para.files.save_dir, save_fname);

fprintf('Save online neurofeedback data (ASCII format)\n');
fprintf('  Data store dir  = ''%s''\n', gData.para.files.save_dir );
fprintf('  Data store file = ''%s''\n', save_fname);

fd = fopen(save_file_name, 'w');
if fd == -1
  cd(gData.para.files.current_dir);	% Current directoryに移動する?B
  err_msg = sprintf('Cannot creat exp file (''%s'')', save_file_name);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end


% 実験プ�?ジェクトコ?[ドをデ?[タファイルに?o力する?B
fprintf(fd, 'ProjectCode = DecNef%02d\n', gData.define.DECNEF_PROJECT);
fprintf(fd, '\n');

% バ?[ジョン?�報をデ?[タファイルに?o力する?B
save_version_value(gData.version, fd);
fprintf(fd, '\n');

% 実験パラ�??[タ文字列を?�?ｬする?B
[tmp, str] = make_parameter_string(gData.define, gData.para, gData.data);
% 実験パラ�??[タ文字列をデ?[タファイルに?o力する?B
for ii=1:length(str)
  fprintf(fd, '%s\n', str{ii});
end
fprintf(fd, '\n');

% define変?狽�デ?[タファイルに?o力する?B
save_define_value(gData.define, fd);
fprintf(fd, '\n');

% 実験デ?[タをデ?[タファイルに?o力する?B
save_exp_data(gData.define, gData.para, gData.data, fd)
fprintf(fd, '\n');

% 実験結果(相関係?狽ﾆ得点)の文字列を?�?ｬする?B
str = make_exp_result_string(gData.para, gData.data);
% 実験結果文字列をデ?[タファイルに?o力する?B
for ii=1:length(str)
  fprintf(fd, '%s\n', str{ii});
end

fclose(fd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_ascii_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_version_value(version, fd)
% function [] = save_version_value(version, fd)
% バ?[ジョン?�報をデ?[タファイルに?o力する?B
% 
% [input argument]
% version : バ?[ジョン?�報を管�?する?\造体
% fd : デ?[タファイルのファイル識別子

% 実験プ�?ジェクトコ?[ドを?o力する?B
fprintf(fd, 'version.decnef_project = %d\n', version.decnef.project);
% 実験プ�?ジェクトのリリ?[ス?�報を?o力する?B
fprintf(fd, 'version.decnef_release = %d\n', version.decnef.release);
% 実験の日付?�報を?o力する?B
fprintf(fd, 'version.decnef_exp_date = %d\n', version.decnef.exp_date);
% 実験の時間?�報を?o力する?B
fprintf(fd, 'version.decnef_exp_time = %d\n', version.decnef.exp_time);

% MATLABバ?[ジョンを?o力する?B
fprintf(fd, 'version.matlab_version = %s\n', version.matlab.version);
% MATLABのリリ?[ス?�報を?o力する?B
fprintf(fd, 'version.matlab_release = %s\n', version.matlab.release);

% SPMバ?[ジョンを?o力する?B
fprintf(fd, 'version.spm_version = %s\n', version.spm.version);
% SPMのリリ?[ス番?�を?o力する?B
fprintf(fd, 'version.spm_release = %d\n', version.spm.release);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_version_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_define_value(define, fd)
% function [] = save_define_value(define, fd)
% define変?狽�デ?[タファイルに?o力する?B
% 
% [input argument]
% define : define変?狽�管�?する?\造体
% fd : デ?[タファイルのファイル識別子

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
% 実験デ?[タをデ?[タファイルに?o力する?B
% 
% [input argument]
% define : define変?狽�管�?する?\造体
% data : 実験デ?[タ?\造体
% fd : デ?[タファイルのファイル識別子


% 受?M?��?が完了しているScan?狽�?o力する?B
received_scan_num = data.received_scan_num;
fprintf(fd, 'received_scan_num = %d\n', received_scan_num);

% ROIのvoxel?狽�?o力する?B
for ii=1:data.roi_num
  fprintf(fd, 'roi_vox_num[%d] = %d\n', ii, data.roi_vox_num(ii));
end
% WMデ?[タのvoxel?狽�?o力する?B
fprintf(fd, 'wm_vox_num = %d\n', length(find(data.wm_mask(:))) );
% GSデ?[タのvoxel?狽�?o力する?B
fprintf(fd, 'gs_vox_num = %d\n', length(find(data.gs_mask(:))) );
% CSFデ?[タのvoxel?狽�?o力する?B
fprintf(fd, 'csf_vox_num = %d\n', length(find(data.csf_mask(:))) );

% 各scanでのWMの?M?�値の平均値を?o力する?B
for ii=1:received_scan_num
  fprintf(fd, 'wm_signal[%d] = %f\n', ii, data.wm_signal(ii));
end
% 各scanでのGSの?M?�値の平均値を?o力する?B
for ii=1:received_scan_num
  fprintf(fd, 'gs_signal[%d] = %f\n', ii, data.gs_signal(ii));
end
% 各scanでのCSFの?M?�値の平均値を?o力する?B
for ii=1:received_scan_num
  fprintf(fd, 'csf_signal[%d] = %f\n', ii, data.csf_signal(ii));
end
% 各scanでのrealignment parameterを?o力する?B
for ii=1:received_scan_num
  realign_val_format = vector_format('%e',' ', define.default.REALIGN_VAL_NUM);
  realign_val_str = sprintf(realign_val_format, data.realign_val(ii,:));
  fprintf(fd, 'realign_val[%d] = %s\n', ii, realign_val_str);
end

% Scan中の脳の移動量を?o力する?B [mm] (2016.02.01)
for ii=1:received_scan_num
  fprintf(fd, 'FD[%d] = %f [mm]\n', ii, data.FD(ii));
end


% 各scanでのROIの?M?�値とROI templateデ?[タの相関係?狽�?o力する?B
% (ROIを指定している?�?�のみ?o力する?B)
if data.roi_num		% ROIを指定している
  for ii=1:received_scan_num
    corr_roi_templ_format = vector_format('%f',' ', data.roi_num);
    corr_roi_templ_str =...
	sprintf(corr_roi_templ_format, data.corr_roi_template(ii,:));
    fprintf(fd, 'corr_roi_template[%d] = %s\n', ii, corr_roi_templ_str);
  end
end

% Scanの計測デ?[タを得点の計算に?ﾌ用 しない/する を?o力する?B(2017.07.25)
for ii=1:received_scan_num
  fprintf(fd, 'ng_scan[%d] = %d\n', ii, data.ng_scan(ii));
end
  

% 被検者が?Qていないかのチェック(1:OK.0:NG)結果を?o力する?B
% 
% 実験結果の文字列(make_exp_result_string()で?�?ｬ)と
% ?d複するのでコ�?ント化しておく?B
% fprintf(fd, '\n');
% for ii=1:para.scans.sleep_check_trial_num
%   str{end+1} = sprintf('sleep_check(%d) = %d \t # trial=%d',...
%       ii, data.sleep_check(ii), para.scans.sleep_check_trial(ii));
% end


fprintf(fd, '\n');

% 各試?sのlabel値と得点を?o力する?B
for ii=1:para.scans.trial_num
  for roi=1:data.roi_num
    fprintf(fd, 'label_ROI%d[%d] = %f\n', roi, ii, data.label(ii, roi));
  end
  fprintf(fd, 'source_score[%d] = %f\n', ii, data.source_score(ii));
  fprintf(fd, 'score[%d] = %f\n', ii, data.score(ii));
end
if data.roi_num
  % label値を計算した試?s番?�を�?める?B
  label_trial = 1:para.scans.trial_num;
  label_trial( isnan(data.label(:,1)) ) = [];
  % label値の平均値を?o力する?B
  for roi=1:data.roi_num
    fprintf(fd, 'LABEL_ROI%d AVERAGE = %f\n',...
	roi, mean(data.label(label_trial, roi)) );
  end
end
% 得点を計算した試?s番?�を�?める?B
score_trial = 1:para.scans.trial_num;
score_trial( isnan(data.score(:,1)) ) = [];
% 得点の平均値を?o力する?B
fprintf(fd, 'SOURCE_SCORE AVERAGE = %f\n',...
    mean(data.source_score(score_trial)) );
fprintf(fd, 'SCORE AVERAGE = %d\n', round( mean(data.score(score_trial)) ));

fprintf(fd, '\n');

% Stanford眠気尺度Levelを?o力する?B
fprintf(fd, 'sss_level = %d\n', data.sss.level);
% Stanford眠気尺度に関するコ�?ント文字列を?o力する?B
fprintf(fd, 'sss_comment = %s\n', data.sss.comment);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_exp_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
