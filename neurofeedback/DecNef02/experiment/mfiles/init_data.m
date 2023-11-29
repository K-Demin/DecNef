function [data] = init_data(define, para, data)
% function [data] = init_data(define, para, data)
% ŽÀŒ±ƒf?[ƒ^‚ðŠÇ—?‚·‚é?\‘¢‘Ì(gData.data)‚ð?‰Šú‰»(”z—ñ‚ðŠm•Û)‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% para   : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% data   : ŽÀŒ±ƒf?[ƒ^?\‘¢‘Ì
% 
% [output argument]
% data : ŽÀŒ±ƒf?[ƒ^?\‘¢‘Ì


% Šescan‚Å‚ÌROI—Ìˆæ‚Ì?M?†’l‚Ì•½‹Ï‚ð?Ý’è‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
roi_num = para.files.roi_fnum;		% ROI‚Ì?”
data.wm_signal = nan(para.scans.total_scan_num, 1);
% Šescan‚Å‚ÌGS—Ìˆæ‚Ì?M?†’l‚Ì•½‹Ï‚ð?Ý’è‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.gs_signal = nan(para.scans.total_scan_num, 1);
% Šescan‚Å‚ÌSCF—Ìˆæ‚Ì?M?†’l‚Ì•½‹Ï‚ð?Ý’è‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.csf_signal = nan(para.scans.total_scan_num, 1);
% Šescan‚Ìrealignment parameter‚ð?Ý’è‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.realign_val =...
    nan(para.scans.total_scan_num, define.default.REALIGN_VAL_NUM);
% receiverƒvƒ?ƒOƒ‰ƒ€‚©‚çŽó?M?Ï‚Ý‚ÌScan”Ô?†‚ðŠÇ—?‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B (*)
data.received_scan = false(para.scans.total_scan_num,1);
data.received_scan(1:para.scans.pre_trial_scan_num) = true;
% receiverƒvƒ?ƒOƒ‰ƒ€‚©‚çŽó?M?Ï‚Ý‚ÌScan?”‚ð?Ý’è‚·‚é?B
data.received_scan_num = length( find(data.received_scan) );
% Scan’†‚Ì”]‚ÌˆÚ“®—Ê‚ðŠÇ—?‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.FD = nan(para.scans.total_scan_num, 1);
% ROI templateƒf?[ƒ^‚ÆŠescan‚Å‚ÌROIƒf?[ƒ^‚Ì‘ŠŠÖŒW?”‚ð•Û‘¶‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.corr_roi_template = nan(para.scans.total_scan_num, roi_num);
% Scan‚ÌŒv‘ªƒf?[ƒ^‚ð“¾“_‚ÌŒvŽZ‚É?Ì—p ‚µ‚È‚¢/‚·‚é ‚ðŠÇ—?‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.ng_scan = false(para.scans.total_scan_num, 1);
% “¾“_ŒvŽZ?Ï‚Ýƒtƒ‰ƒO‚ð•Û‘¶‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.calc_score_flg = false(para.scans.trial_num, 1);
% ŠeROI‚Ìlabel’l‚ð•Û‘¶‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.label = nan(para.scans.trial_num, roi_num);
% ŠeŽŽ?s‚Å‚Ì“¾“_(‰ºŒÀ’l‚Æ?ãŒÀ’l“à‚É•â?³‘O)‚ð•Û‘¶‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.source_score = nan(para.scans.trial_num, 1);
% ŠeŽŽ?s‚Å‚Ì“¾“_(‰ºŒÀ’l‚Æ?ãŒÀ’l“à‚É•â?³Œã)‚ð•Û‘¶‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.score = nan(para.scans.trial_num, 1);
% VTD edit- this will store the actual feedback value (when adjusted for
% group condition).
data.feedback_value = nan(para.scans.trial_num, 1);
% ”íŒŸŽÒ‚ª?Q‚Ä‚¢‚È‚¢‚©‚Ìƒ`ƒFƒbƒNŒ‹‰Ê‚ð•Û‘¶‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
data.sleep_check = false(para.scans.sleep_check_trial_num, 1);

% (*)
% ŽŽ?s‚ðŠJŽn‚·‚é‘Oscan(para.scans.pre_trial_scan_num)‚Ìƒf?[ƒ^
% ‚Í‰ð?Í‚É—p‚¢‚È‚¢‚Ì‚ÅŽó?M?Ï‚Ýˆµ‚¢‚Æ‚·‚é?B
% (gData.para.scans.pre_trial_scan_num+1‚©‚çŽó?M)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
