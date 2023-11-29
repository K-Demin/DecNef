function [denoised_data] = denoising_fmri_data(scan, regress_scan_num)
% function [denoised_data] = denoising_fmri_data(scan)
% ROI‚Ì‘Svoxel‚ÌfMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚ð?s‚È‚¤?B
% 
% [input argument]
% scan   : scan”Ô?†
% regress_scan_num : fMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan?”
% 
% [output argument]
% denoised_data : ƒmƒCƒY?œ‹ŽŒã‚ÌROI‚Ì‘Svoxel‚ÌfMRIƒf?[ƒ^‚ðŠÇ—?‚·‚écell”z—ñ

global gData


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scan’†‚Ì”]‚ÌˆÚ“®—Ê‚ð‹?‚ß‚é?B [mm]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SCANS = [gData.para.scans.pre_trial_scan_num+1:scan];
DELTA_REALIGN_VAL = nan( size( gData.data.realign_val ) );
[gData.data.FD(SCANS), DELTA_REALIGN_VAL(SCANS,:)] =...
    calc_fd(gData.data.realign_val, SCANS, gData.para);

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scan’†‚Ì”]‚ÌˆÚ“®—Ê‚ð”»’è‚µ?A‚±‚Ìscan‚ÌŒv‘ªƒf?[ƒ^‚ð“¾“_‚ÌŒvŽZ‚É
% ?Ì—p ‚µ‚È‚¢/‚·‚é ‚ðŠÇ—?‚·‚é”z—ñ(gData.data.ng_scan)‚ð?Ý’è‚·‚é?B
% ------------------------------------------------------------------
% gData.data.ng_scan(scan) = false; (ŒvŽZ‚Ì‘Î?Û)
% gData.data.ng_scan(scan) = true;  (ŒvŽZ‚Ì‘Î?ÛŠO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.ng_scan(SCANS) = set_ng_scan(...
    gData.data.corr_roi_template(SCANS,:), gData.data.FD(SCANS),...
    gData.para.score.corr_roi_template_threshold,...
    gData.para.score.FD_threshold);


switch gData.para.denoising_method
  case gData.define.denoising_method.REGRESS
    % ‘½?d?üŒ`‰ñ‹A‚ÌŽc?·‚©‚çfMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚ð?s‚È‚¤
    denoised_data=regress_method(scan, DELTA_REALIGN_VAL,...
	gData.data.ng_scan, regress_scan_num);
  
  case  gData.define.denoising_method.DETREND
    % ?üŒ`ƒgƒŒƒ“ƒh?œ‹Ž?ˆ—?‚ÅfMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚ð?s‚È‚¤
    denoised_data = detrend_method(scan);
    
end	% <-- End of 'switch gData.para.denoising_method'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function denoising_fmri_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [denoised_data] = regress_method(scan, DELTA_REALIGN_VAL,...
    NG_SCAN, regress_scan_num)
% function [denoised_data] = regress_method(scan, DELTA_REALIGN_VAL, NG_SCAN)
% ‘½?d?üŒ`‰ñ‹A‚ÌŽc?·‚©‚çROI‚Ì‘Svoxel‚ÌfMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚ð?s‚È‚¤?B
% 
% [input argument]
% scan   : scan”Ô?†
% DELTA_REALIGN_VAL : Scan’†‚Ì”]‚ÌˆÚ“®—Ê/‰ñ“]Šp“x (‘Sscan‚ð•ÛŽ?)
% NG_SCAN           : ŒvŽZ‚Ì‘Î?ÛŠO‚Æ‚·‚éscan”Ô?†‚ðŠÇ—?‚·‚é”z—ñ (‘Sscan‚ð•ÛŽ?)
% regress_scan_num  : fMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan?”
% 
% [output argument]
% denoised_data : ƒmƒCƒY?œ‹ŽŒã‚ÌROI‚Ì‘Svoxel‚ÌfMRIƒf?[ƒ^‚ðŠÇ—?‚·‚écell”z—ñ

global gData


% ƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan”Ô?†
scans = scan-regress_scan_num+1:scan;
% ŽŽ?s‚ðŠJŽn‚·‚é–˜‚Ìscan‚ÌfMRIƒf?[ƒ^‚Í?Ì—p‚µ‚È‚¢?B
scans(scans <= gData.para.scans.pre_trial_scan_num) = [];
% ƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan?”
scans_num = length(scans);


% NG_SCAN”z—ñ ‚Æ DELTA_REALIGN_VAL”z—ñ ‚©‚ç?A
% ƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan”Ô?†•”•ª‚ð?Ø‚è?o‚·?B
ng_scan = NG_SCAN(scans);	% ŒvŽZ‚Ì‘Î?ÛŠO(TRUE)/‘Î?Û(FALSE)‚Ìscan
delta_realign_val = DELTA_REALIGN_VAL(scans, :);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WM, GS, CSF—Ìˆæ‚Ì•½‹Ï’l‚ÌscanŠÔ‚Ì•Ï‰»—Ê‚ð‹?‚ß‚é?B (2015.11.10)
% ------------------------------------------------------------
% ‚±‚±‚Å?AŽŽ?s‚ðŠJŽn‚·‚éscan(para.scans.pre_trial_scan_num+1)‚Ì
% WM?AGS?ACSF—Ìˆæ‚Ì•½‹Ï’l‚Ì‘Oscan‚Æ‚Ì•Ï‰»—Ê‚Í0.0‚Æ‚·‚é?B
% ( ŽŽ?sŠJŽn‚Ì‘O‚Ìscan(para.scans.pre_trial_scan_num)‚Í?Aƒf?[ƒ^
%   ‚ðŽæ“¾‚µ‚Ä‚¢‚È‚¢(NaN‚ª?Ý’è‚³‚ê‚Ä‚¢‚é)‚Ì‚Å?AROI—Ìˆæ‚Ì•½‹Ï’l‚Ì
%   ‘Oscan‚Æ‚Ì•Ï‰»—Ê‚ð‹?‚ß‚é‚±‚Æ‚ª‚Å‚«‚È‚¢?B )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_wm_signal = gData.data.wm_signal(scans) - gData.data.wm_signal(scans-1);
delta_gs_signal = gData.data.gs_signal(scans) - gData.data.gs_signal(scans-1);
delta_csf_signal= gData.data.csf_signal(scans)- gData.data.csf_signal(scans-1);
% ŽŽ?sŠJŽnscan(para.scans.pre_trial_scan_num+1)‚Ì•Ï‰»—Ê‚Í0‚Æ‚·‚é?B
tmp = find(scans==gData.para.scans.pre_trial_scan_num+1);
delta_wm_signal(tmp) = 0.0;
delta_gs_signal(tmp) = 0.0;
delta_csf_signal(tmp) = 0.0;



x = [...
      gData.data.realign_val(scans,:),...	% Template file‚©‚ç‚Ì”]‚Ì“®‚«
      delta_realign_val,...			% Scan’†‚Ì”]‚ÌˆÚ“®—Ê/‰ñ“]Šp“x
      gData.data.wm_signal(scans),...		% WM‚Ì•½‹Ï’l
      gData.data.gs_signal(scans),...		% GS‚Ì•½‹Ï’l
      gData.data.csf_signal(scans),...		% CSF‚Ì•½‹Ï’l
      delta_wm_signal,...			% WM‚Ì•½‹Ï’l‚ÌscanŠÔ‚Ì•Ï‰»—Ê
      delta_gs_signal,...			% GS‚Ì•½‹Ï’l‚ÌscanŠÔ‚Ì•Ï‰»—Ê
      delta_csf_signal];			% CSF‚Ì•½‹Ï’l‚ÌscanŠÔ‚Ì•Ï‰»—Ê

% ƒgƒŒƒ“ƒh?œ‹Ž‚·‚é? (2015.11.10)
% ----------------------------------------------------
% (•s—v‚¾‚ª”O‚Ì‚½‚ß“ü‚ê‚Ä‚¢‚é‚¾‚¯... by ŽR“c?æ?¶)
x = spm_detrend(x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NG scan?î•ñ?s—ñ(ng_mtx) ‚Æ ’è?”?€(1.0) ‚ð’Ç‰Á‚·‚é?B (2016.07.19)
% -------------------------------------------
% NG scanƒtƒ‰ƒO(ng_scan)‚ÉTRUE‚ðŠÜ‚Þ?ê?‡?B
%   -> NG scan”Ô?†‚ðŠÇ—?‚·‚é?s—ñ(ng_mtx)‚Æ’è?”?€(1.0)‚ð’Ç‰Á‚·‚é?B
%      ng_mtx ‚Í NG scan”Ô?†‚Ì?s‚ª1.0 ‘¼‚Í0.0‚Ì?s—ñ‚Å?ANG scan‚ª
%      •¡?”scan‚É‹y‚Ô?ê?‡?A—ñ”Ô?†‚ð‚¸‚ç‚µ‚ÄNG scan”Ô?†‚Ì?s‚É1.0‚ð
%      ?Ý’è‚·‚é?B
%      ( ng_scan(10) ‚Æ ng_scan(12) ‚ªTRUE‚Å?A‘¼‚ÍFALSE‚Ì?ê?‡?A
%        ng_mtx(10,1)=1.0, ng_mtx(12,2)=1.0‚Å?A‘¼‚Í0.0‚Ì?s—ñ )
% NG scanƒtƒ‰ƒO(ng_scan)‚ÉTRUE‚ðŠÜ‚Ü‚È‚¢?ê?‡?B
%   -> ’è?”?€(1.0)‚ð’Ç‰Á‚·‚é?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length( find(ng_scan == true) )
  % NG scanƒtƒ‰ƒO(ng_scan)‚É?ATRUE‚Ìscan‚ðŠÜ‚Þ?ê?‡?B
  % ( Scan’†‚Ì”]‚ÌˆÚ“®—Ê(FD)‚ª?AScan’†‚Ì”]‚ÌˆÚ“®—Ê‚Ì
  %   è‡’l(para.score.FD_threshold)
  %   ‚æ‚è‘å‚«‚¢Scan‚ªŠÜ‚Ü‚ê‚Ä‚¢‚é?B )
  % -----------------------------------------------
  %  NG scan?î•ñ?s—ñ(ng_mtx) ‚Æ ’è?”?€(1.0) ‚ð’Ç‰Á‚·‚é?B
  ng_ptr = find(ng_scan == true);	% NG scan”Ô?†
  ng_num = length( ng_ptr );		% NG scan?”
  ng_mtx = zeros(scans_num, ng_num);	% ƒmƒCƒY?œ‹Ž?ˆ—?scan?” x NG scan?”
  % NG scan‚ª•¡?”scan‚É‹y‚Ô?ê?‡?A—ñ”Ô?†‚ð‚¸‚ç‚µ‚È‚ª‚ç?A 
  % NG scan”Ô?†‚Ì?s‚É1.0‚ð?Ý’è‚·‚é?B
  for ii=1:ng_num
    ng_mtx(ng_ptr(ii), ii) = 1.0;
  end
  X = [x, ng_mtx, ones(scans_num,1)];    
else
  % NG scanƒtƒ‰ƒO(ng_scan)‚É?ATRUE‚Ìscan‚ðŠÜ‚Ü‚È‚¢?ê?‡?B
  % ( Scan’†‚Ì”]‚ÌˆÚ“®—Ê(FD)‚ª?AScan’†‚Ì”]‚ÌˆÚ“®—Ê‚Ì
  %   è‡’l(para.score.FD_threshold)
  %   ‚æ‚è‘å‚«‚¢Scan‚ÍŠÜ‚Ü‚ê‚Ä‚¢‚È‚¢?B )
  % -----------------------------------------------
  %  ’è?”?€(1.0)‚Ì‚Ý’Ç‰Á‚·‚é?B
  X = [x, ones(scans_num,1) ];
end
			    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ƒmƒCƒY?œ‹Žƒf?[ƒ^(‘½?d?üŒ`‰ñ‹A‚ÌŽc?·)‚ð‹?‚ß‚é?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ŽR“c?æ?¶‚Ìƒ??[ƒ‹(2017.03.03)‚æ‚è
% ----------------------------------------
% Y : bold signal matrix
%     ( gData.data.roi_vol{ROI}(scans,:) )
% X : regressors matrix
% B : beta(ŒW?”)
% B = pinv(X)*Y ‚È‚Ì‚Å
% Žc?· = Y - X*pinv(X)*Y
denoised_data = cell(gData.data.roi_num,1);
for roi=1:gData.data.roi_num

  roi_vol = gData.data.roi_vol{roi}(scans,:);	% ROI‚Ì‘Svoxel‚Ì?M?†’l
  roi_vox_num = gData.data.roi_vox_num(roi);	% ROI‚Ìvoxel?”
  
  residuals = roi_vol - X*pinv(X)*roi_vol;

  % ƒmƒCƒY?œ‹Ž '‘O' ‚ÌfMRIƒf?[ƒ^‚Ì•½‹Ï’l‚ðŠl“¾‚·‚é?B
  if isempty( find(isnan(roi_vol)) )	% roi_vol‚ÉNaN‚ðŠÜ‚Ü‚È‚¢?ê?‡
    mean_vol = mean(roi_vol);
  else					% roi_vol‚ÉNaN‚ðŠÜ‚Þ?ê?‡
    % NaN‚ð?œ‚¢‚½ƒf?[ƒ^‚Ì•½‹Ï’l‚ð‹?‚ß‚é?B
    mean_vol = zeros(1,roi_vox_num);
    for ii=1:roi_vox_num
      p = ~isnan( roi_vol(:,ii) );
      mean_vol(ii) = mean(roi_vol(p,ii));
    end
  end
  
  % ƒmƒCƒY?œ‹Žƒf?[ƒ^ ‚É ƒmƒCƒY?œ‹Ž '‘O' ‚Ì•½‹Ï’l ‚ð‰Á‚¦‚é?B
  % ------------------------------------------------------------
  % ( ‘½?d?üŒ`‰ñ‹A‚ÌŽc?·(regressŠÖ?”‚Ì‘æ3•Ô‚è’l‚ÌƒxƒNƒgƒ‹)
  %   ‚Í•½‹Ï’l‚ª0.0‚Ì”gŒ`‚ª?o—Í‚³‚ê‚é‚Ì‚Å?A
  %   ƒmƒCƒY?œ‹Ž‘O‚Ì•½‹Ï’l‚ð‰Á‚¦‚é?B )
  denoised_data{roi} = nan(scan, roi_vox_num);
  denoised_data{roi}(scans,:) = residuals + ones(scans_num,1)*mean_vol;
end	% <-- End of 'for ii=1:roi_vox_num'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function regress_method()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [denoised_data] = detrend_method(scan)
% function [denoised_data] = detrend_method(scan)
% ?üŒ`ƒgƒŒƒ“ƒh?œ‹Ž?ˆ—?‚ÅROI‚Ì‘Svoxel‚ÌfMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚ð?s‚È‚¤?B
% 
% [input argument]
% scan   : scan”Ô?†
% 
% [output argument]
% denoised_data : ƒmƒCƒY?œ‹ŽŒã‚ÌROI‚Ì‘Svoxel‚ÌfMRIƒf?[ƒ^‚ðŠÇ—?‚·‚écell”z—ñ

global gData

scans = 1:scan;
% ŽŽ?s‚ðŠJŽn‚·‚é–˜‚Ìscan‚ÌfMRIƒf?[ƒ^‚Í?Ì—p‚µ‚È‚¢?B
scans(scans <= gData.para.scans.pre_trial_scan_num) = [];


scans_num = length(scans);		% ‘Î?Ûscan‚Ì?”
denoised_data = cell(gData.data.roi_num,1);


% ROI‚ðvoxel–ˆ‚É?A?üŒ`ƒgƒŒƒ“ƒh?œ‹Ž–@‚ÅfMRIƒf?[ƒ^‚Ì
% ƒmƒCƒY?œ‹Žƒf?[ƒ^‚ð‹?‚ß‚é?B
% ------------------------------------------------------------
% ( ?üŒ`ƒgƒŒƒ“ƒh?œ‹Ž‚Í?AdetrendŠÖ?”‚Å‹?‚ß‚é?B
%   Y = detrend(X,'linear');
%   ‚±‚±‚Å?A
%   detrendŠÖ?”‚Ì‘æ1ˆø?”‚ÌƒxƒNƒgƒ‹X‚ÉNaN‚ÌƒtƒŒ?[ƒ€‚ªŠÜ‚Ü‚ê‚Ä
%   ‚¢‚é?ê?‡?AdetrendŠÖ?”‚Ì‘æ3•Ô‚è’l‚ÌƒxƒNƒgƒ‹Y‚Í?A‘S‚ÄNaN‚ª
%   ?Ý’è‚³‚ê‚é?B‚»‚±‚Å?ANaN?œ‚¢‚½ƒf?[ƒ^‚ð—p‚¢‚ÄƒmƒCƒY?œ‹Ž?ˆ—?
%   ‚ð?s‚È‚¤?B )
for roi=1:gData.data.roi_num
  roi_vol = gData.data.roi_vol{roi}(scans,:);	% ROI‚Ì‘Svoxel‚Ì?M?†’l
  roi_vox_num = gData.data.roi_vox_num(roi);	% ROI‚Ìvoxel?”
  
  if gData.GPU
      denoised_data{roi} = gpuArray(nan(scan, roi_vox_num));
  else
      denoised_data{roi} = nan(scan, roi_vox_num);
  end

  
  % ROI‚ðvoxel–ˆ‚É?A?üŒ`ƒgƒŒƒ“ƒh?œ‹Ž‚µ‚½ƒf?[ƒ^‚É?A
  % ƒmƒCƒY?œ‹Ž '‘O' ‚Ì•½‹Ï’l‚ð‰Á‚¦‚é?B
  % ------------------------------------------------------------
  % ?üŒ`ƒgƒŒƒ“ƒh?œ‹Žƒf?[ƒ^(detrendŠÖ?”‚Ì•Ô‚è’l)‚Í•½‹Ï’l‚ª0.0‚Ì
  % ”gŒ`‚ª?o—Í‚³‚ê‚é‚Ì‚Å?AƒmƒCƒY?œ‹Ž‘O‚Ì•½‹Ï’l‚ð‰Á‚¦‚é?B
  % (http://jp.mathworks.com/help/matlab/data_analysis/detrending-data.html)
  if isempty( find(isnan(roi_vol)) )	% roi_vol‚ÉNaN‚ðŠÜ‚Ü‚È‚¢?ê?‡
    mean_vol = mean(roi_vol);		% ƒmƒCƒY?œ‹Ž‘O‚ÌROI?M?†’l‚Ì•½‹Ï’l
    denoised_data{roi}(scans,:) =...
	detrend(roi_vol,'linear') + ones(scans_num,1)*mean_vol;
  else					% ROI_VOL‚ÉNaN‚ðŠÜ‚Þ?ê?‡
    % NaN‚ð?œ‚¢‚½ƒf?[ƒ^‚ÅƒmƒCƒY?œ‹Ž?ˆ—?‚ð?s‚È‚¤?B
    fprintf('Detrending...')
    start = GetSecs;
    for ii=1:roi_vox_num
      p = ~isnan( roi_vol(:,ii) );
      denoised_data{roi}(scans(p),ii) =...
	  detrend(roi_vol(p,ii),'linear') + mean(roi_vol(p,ii));
    end
    finish = GetSecs;
    fprintf('Took =%8.3f (sec)\n',finish-start)
  end
end	% <-- End of 'for roi=1:gData.data.roi_num'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function detrend_method()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
