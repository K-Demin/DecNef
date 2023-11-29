function [] = save_ascii_data()


global gData

save_fname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,gData.define.files.ASCII_DATA_EXTENSION);
save_file_name = fullfile(gData.para.files.save_dir, save_fname);

fprintf('Save online neurofeedback data (ASCII format)\n');
fprintf('  Data store dir  = ''%s''\n', gData.para.files.save_dir );
fprintf('  Data store file = ''%s''\n', save_fname);

fd = fopen(save_file_name, 'w');
if fd == -1
  cd(gData.para.files.current_dir);	% Current directory‚ÉˆÚ“®‚·‚é?B
  err_msg = sprintf('Cannot creat exp file (''%s'')', save_file_name);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end


% ŽÀŒ±ƒvƒ?ƒWƒFƒNƒgƒR?[ƒh‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
fprintf(fd, 'ProjectCode = DecNef%02d\n', gData.define.DECNEF_PROJECT);
fprintf(fd, '\n');

% ƒo?[ƒWƒ‡ƒ“?î•ñ‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
save_version_value(gData.version, fd);
fprintf(fd, '\n');

% ŽÀŒ±ƒpƒ‰ƒ??[ƒ^•¶Žš—ñ‚ð?ì?¬‚·‚é?B
[tmp, str] = make_parameter_string(gData.define, gData.para, gData.data);
% ŽÀŒ±ƒpƒ‰ƒ??[ƒ^•¶Žš—ñ‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
for ii=1:length(str)
  fprintf(fd, '%s\n', str{ii});
end
fprintf(fd, '\n');

% define•Ï?”‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
save_define_value(gData.define, fd);
fprintf(fd, '\n');

% ŽÀŒ±ƒf?[ƒ^‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
save_exp_data(gData.define, gData.para, gData.data, fd)
fprintf(fd, '\n');

% ŽÀŒ±Œ‹‰Ê(‘ŠŠÖŒW?”‚Æ“¾“_)‚Ì•¶Žš—ñ‚ð?ì?¬‚·‚é?B
str = make_exp_result_string(gData.para, gData.data);
% ŽÀŒ±Œ‹‰Ê•¶Žš—ñ‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
for ii=1:length(str)
  fprintf(fd, '%s\n', str{ii});
end

fclose(fd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_ascii_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_version_value(version, fd)
% function [] = save_version_value(version, fd)
% ƒo?[ƒWƒ‡ƒ“?î•ñ‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
% 
% [input argument]
% version : ƒo?[ƒWƒ‡ƒ“?î•ñ‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% fd : ƒf?[ƒ^ƒtƒ@ƒCƒ‹‚Ìƒtƒ@ƒCƒ‹Ž¯•ÊŽq

% ŽÀŒ±ƒvƒ?ƒWƒFƒNƒgƒR?[ƒh‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.decnef_project = %d\n', version.decnef.project);
% ŽÀŒ±ƒvƒ?ƒWƒFƒNƒg‚ÌƒŠƒŠ?[ƒX?î•ñ‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.decnef_release = %d\n', version.decnef.release);
% ŽÀŒ±‚Ì“ú•t?î•ñ‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.decnef_exp_date = %d\n', version.decnef.exp_date);
% ŽÀŒ±‚ÌŽžŠÔ?î•ñ‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.decnef_exp_time = %d\n', version.decnef.exp_time);

% MATLABƒo?[ƒWƒ‡ƒ“‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.matlab_version = %s\n', version.matlab.version);
% MATLAB‚ÌƒŠƒŠ?[ƒX?î•ñ‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.matlab_release = %s\n', version.matlab.release);

% SPMƒo?[ƒWƒ‡ƒ“‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.spm_version = %s\n', version.spm.version);
% SPM‚ÌƒŠƒŠ?[ƒX”Ô?†‚ð?o—Í‚·‚é?B
fprintf(fd, 'version.spm_release = %d\n', version.spm.release);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_version_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = save_define_value(define, fd)
% function [] = save_define_value(define, fd)
% define•Ï?”‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% fd : ƒf?[ƒ^ƒtƒ@ƒCƒ‹‚Ìƒtƒ@ƒCƒ‹Ž¯•ÊŽq

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
% ŽÀŒ±ƒf?[ƒ^‚ðƒf?[ƒ^ƒtƒ@ƒCƒ‹‚É?o—Í‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% data : ŽÀŒ±ƒf?[ƒ^?\‘¢‘Ì
% fd : ƒf?[ƒ^ƒtƒ@ƒCƒ‹‚Ìƒtƒ@ƒCƒ‹Ž¯•ÊŽq


% Žó?M?ˆ—?‚ªŠ®—¹‚µ‚Ä‚¢‚éScan?”‚ð?o—Í‚·‚é?B
received_scan_num = data.received_scan_num;
fprintf(fd, 'received_scan_num = %d\n', received_scan_num);

% ROI‚Ìvoxel?”‚ð?o—Í‚·‚é?B
for ii=1:data.roi_num
  fprintf(fd, 'roi_vox_num[%d] = %d\n', ii, data.roi_vox_num(ii));
end
% WMƒf?[ƒ^‚Ìvoxel?”‚ð?o—Í‚·‚é?B
fprintf(fd, 'wm_vox_num = %d\n', length(find(data.wm_mask(:))) );
% GSƒf?[ƒ^‚Ìvoxel?”‚ð?o—Í‚·‚é?B
fprintf(fd, 'gs_vox_num = %d\n', length(find(data.gs_mask(:))) );
% CSFƒf?[ƒ^‚Ìvoxel?”‚ð?o—Í‚·‚é?B
fprintf(fd, 'csf_vox_num = %d\n', length(find(data.csf_mask(:))) );

% Šescan‚Å‚ÌWM‚Ì?M?†’l‚Ì•½‹Ï’l‚ð?o—Í‚·‚é?B
for ii=1:received_scan_num
  fprintf(fd, 'wm_signal[%d] = %f\n', ii, data.wm_signal(ii));
end
% Šescan‚Å‚ÌGS‚Ì?M?†’l‚Ì•½‹Ï’l‚ð?o—Í‚·‚é?B
for ii=1:received_scan_num
  fprintf(fd, 'gs_signal[%d] = %f\n', ii, data.gs_signal(ii));
end
% Šescan‚Å‚ÌCSF‚Ì?M?†’l‚Ì•½‹Ï’l‚ð?o—Í‚·‚é?B
for ii=1:received_scan_num
  fprintf(fd, 'csf_signal[%d] = %f\n', ii, data.csf_signal(ii));
end
% Šescan‚Å‚Ìrealignment parameter‚ð?o—Í‚·‚é?B
for ii=1:received_scan_num
  realign_val_format = vector_format('%e',' ', define.default.REALIGN_VAL_NUM);
  realign_val_str = sprintf(realign_val_format, data.realign_val(ii,:));
  fprintf(fd, 'realign_val[%d] = %s\n', ii, realign_val_str);
end

% Scan’†‚Ì”]‚ÌˆÚ“®—Ê‚ð?o—Í‚·‚é?B [mm] (2016.02.01)
for ii=1:received_scan_num
  fprintf(fd, 'FD[%d] = %f [mm]\n', ii, data.FD(ii));
end


% Šescan‚Å‚ÌROI‚Ì?M?†’l‚ÆROI templateƒf?[ƒ^‚Ì‘ŠŠÖŒW?”‚ð?o—Í‚·‚é?B
% (ROI‚ðŽw’è‚µ‚Ä‚¢‚é?ê?‡‚Ì‚Ý?o—Í‚·‚é?B)
if data.roi_num		% ROI‚ðŽw’è‚µ‚Ä‚¢‚é
  for ii=1:received_scan_num
    corr_roi_templ_format = vector_format('%f',' ', data.roi_num);
    corr_roi_templ_str =...
	sprintf(corr_roi_templ_format, data.corr_roi_template(ii,:));
    fprintf(fd, 'corr_roi_template[%d] = %s\n', ii, corr_roi_templ_str);
  end
end

% Scan‚ÌŒv‘ªƒf?[ƒ^‚ð“¾“_‚ÌŒvŽZ‚É?Ì—p ‚µ‚È‚¢/‚·‚é ‚ð?o—Í‚·‚é?B(2017.07.25)
for ii=1:received_scan_num
  fprintf(fd, 'ng_scan[%d] = %d\n', ii, data.ng_scan(ii));
end
  

% ”íŒŸŽÒ‚ª?Q‚Ä‚¢‚È‚¢‚©‚Ìƒ`ƒFƒbƒN(1:OK.0:NG)Œ‹‰Ê‚ð?o—Í‚·‚é?B
% 
% ŽÀŒ±Œ‹‰Ê‚Ì•¶Žš—ñ(make_exp_result_string()‚Å?ì?¬)‚Æ
% ?d•¡‚·‚é‚Ì‚ÅƒRƒ?ƒ“ƒg‰»‚µ‚Ä‚¨‚­?B
% fprintf(fd, '\n');
% for ii=1:para.scans.sleep_check_trial_num
%   str{end+1} = sprintf('sleep_check(%d) = %d \t # trial=%d',...
%       ii, data.sleep_check(ii), para.scans.sleep_check_trial(ii));
% end


fprintf(fd, '\n');

% ŠeŽŽ?s‚Ìlabel’l‚Æ“¾“_‚ð?o—Í‚·‚é?B
for ii=1:para.scans.trial_num
  for roi=1:data.roi_num
    fprintf(fd, 'label_ROI%d[%d] = %f\n', roi, ii, data.label(ii, roi));
  end
  fprintf(fd, 'source_score[%d] = %f\n', ii, data.source_score(ii));
  fprintf(fd, 'score[%d] = %f\n', ii, data.score(ii));
end
if data.roi_num
  % label’l‚ðŒvŽZ‚µ‚½ŽŽ?s”Ô?†‚ð‹?‚ß‚é?B
  label_trial = 1:para.scans.trial_num;
  label_trial( isnan(data.label(:,1)) ) = [];
  % label’l‚Ì•½‹Ï’l‚ð?o—Í‚·‚é?B
  for roi=1:data.roi_num
    fprintf(fd, 'LABEL_ROI%d AVERAGE = %f\n',...
	roi, mean(data.label(label_trial, roi)) );
  end
end
% “¾“_‚ðŒvŽZ‚µ‚½ŽŽ?s”Ô?†‚ð‹?‚ß‚é?B
score_trial = 1:para.scans.trial_num;
score_trial( isnan(data.score(:,1)) ) = [];
% “¾“_‚Ì•½‹Ï’l‚ð?o—Í‚·‚é?B
fprintf(fd, 'SOURCE_SCORE AVERAGE = %f\n',...
    mean(data.source_score(score_trial)) );
fprintf(fd, 'SCORE AVERAGE = %d\n', round( mean(data.score(score_trial)) ));

fprintf(fd, '\n');

% Stanford–°‹CŽÚ“xLevel‚ð?o—Í‚·‚é?B
fprintf(fd, 'sss_level = %d\n', data.sss.level);
% Stanford–°‹CŽÚ“x‚ÉŠÖ‚·‚éƒRƒ?ƒ“ƒg•¶Žš—ñ‚ð?o—Í‚·‚é?B
fprintf(fd, 'sss_comment = %s\n', data.sss.comment);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_exp_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
