function [data] = init_data(define, para, data)
% function [data] = init_data(define, para, data)
% �����f?[�^���Ǘ?����?\����(gData.data)��?�����(�z����m��)����?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% para   : �����p���??[�^?\����
% data   : �����f?[�^?\����
% 
% [output argument]
% data : �����f?[�^?\����


% �escan�ł�ROI�̈��?M?��l�̕��ς�?ݒ肷��z���p�ӂ���?B
roi_num = para.files.roi_fnum;		% ROI��?�
data.wm_signal = nan(para.scans.total_scan_num, 1);
% �escan�ł�GS�̈��?M?��l�̕��ς�?ݒ肷��z���p�ӂ���?B
data.gs_signal = nan(para.scans.total_scan_num, 1);
% �escan�ł�SCF�̈��?M?��l�̕��ς�?ݒ肷��z���p�ӂ���?B
data.csf_signal = nan(para.scans.total_scan_num, 1);
% �escan��realignment parameter��?ݒ肷��z���p�ӂ���?B
data.realign_val =...
    nan(para.scans.total_scan_num, define.default.REALIGN_VAL_NUM);
% receiver�v�?�O���������?M?ς݂�Scan��?����Ǘ?����z���p�ӂ���?B (*)
data.received_scan = false(para.scans.total_scan_num,1);
data.received_scan(1:para.scans.pre_trial_scan_num) = true;
% receiver�v�?�O���������?M?ς݂�Scan?���?ݒ肷��?B
data.received_scan_num = length( find(data.received_scan) );
% Scan���̔]�̈ړ��ʂ��Ǘ?����z���p�ӂ���?B
data.FD = nan(para.scans.total_scan_num, 1);
% ROI template�f?[�^�Ɗescan�ł�ROI�f?[�^�̑��֌W?���ۑ�����z���p�ӂ���?B
data.corr_roi_template = nan(para.scans.total_scan_num, roi_num);
% Scan�̌v���f?[�^�𓾓_�̌v�Z��?̗p ���Ȃ�/���� ���Ǘ?����z���p�ӂ���?B
data.ng_scan = false(para.scans.total_scan_num, 1);
% ���_�v�Z?ς݃t���O��ۑ�����z���p�ӂ���?B
data.calc_score_flg = false(para.scans.trial_num, 1);
% �eROI��label�l��ۑ�����z���p�ӂ���?B
data.label = nan(para.scans.trial_num, roi_num);
% �e��?s�ł̓��_(�����l��?���l���ɕ�?��O)��ۑ�����z���p�ӂ���?B
data.source_score = nan(para.scans.trial_num, 1);
% �e��?s�ł̓��_(�����l��?���l���ɕ�?���)��ۑ�����z���p�ӂ���?B
data.score = nan(para.scans.trial_num, 1);
% VTD edit- this will store the actual feedback value (when adjusted for
% group condition).
data.feedback_value = nan(para.scans.trial_num, 1);
% �팟�҂�?Q�Ă��Ȃ����̃`�F�b�N���ʂ�ۑ�����z���p�ӂ���?B
data.sleep_check = false(para.scans.sleep_check_trial_num, 1);

% (*)
% ��?s���J�n����Oscan(para.scans.pre_trial_scan_num)�̃f?[�^
% �͉�?͂ɗp���Ȃ��̂Ŏ�?M?ς݈����Ƃ���?B
% (gData.para.scans.pre_trial_scan_num+1�����?M)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
