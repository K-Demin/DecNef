function [denoised_data] = denoising_fmri_data(scan, regress_scan_num)
% function [denoised_data] = denoising_fmri_data(scan)
% ROIの全voxelのfMRIデ?[タのノイズ?恚�?��?を?sなう?B
% 
% [input argument]
% scan   : scan番?�
% regress_scan_num : fMRIデ?[タのノイズ?恚�?��?に利用するscan?�
% 
% [output argument]
% denoised_data : ノイズ?恚詞繧ﾌROIの全voxelのfMRIデ?[タを管�?するcell配列

global gData


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scan中の脳の移動量を�?める?B [mm]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SCANS = [gData.para.scans.pre_trial_scan_num+1:scan];
DELTA_REALIGN_VAL = nan( size( gData.data.realign_val ) );
[gData.data.FD(SCANS), DELTA_REALIGN_VAL(SCANS,:)] =...
    calc_fd(gData.data.realign_val, SCANS, gData.para);

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scan中の脳の移動量を判定し?Aこのscanの計測デ?[タを得点の計算に
% ?ﾌ用 しない/する を管�?する配列(gData.data.ng_scan)を?ﾝ定する?B
% ------------------------------------------------------------------
% gData.data.ng_scan(scan) = false; (計算の対?ﾛ)
% gData.data.ng_scan(scan) = true;  (計算の対?ﾛ外)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.ng_scan(SCANS) = set_ng_scan(...
    gData.data.corr_roi_template(SCANS,:), gData.data.FD(SCANS),...
    gData.para.score.corr_roi_template_threshold,...
    gData.para.score.FD_threshold);


switch gData.para.denoising_method
  case gData.define.denoising_method.REGRESS
    % 多?d?�形回帰の残?ｷからfMRIデ?[タのノイズ?恚�?��?を?sなう
    denoised_data=regress_method(scan, DELTA_REALIGN_VAL,...
	gData.data.ng_scan, regress_scan_num);
  
  case  gData.define.denoising_method.DETREND
    % ?�形トレンド?恚�?��?でfMRIデ?[タのノイズ?恚�?��?を?sなう
    denoised_data = detrend_method(scan);
    
end	% <-- End of 'switch gData.para.denoising_method'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function denoising_fmri_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [denoised_data] = regress_method(scan, DELTA_REALIGN_VAL,...
    NG_SCAN, regress_scan_num)
% function [denoised_data] = regress_method(scan, DELTA_REALIGN_VAL, NG_SCAN)
% 多?d?�形回帰の残?ｷからROIの全voxelのfMRIデ?[タのノイズ?恚�?��?を?sなう?B
% 
% [input argument]
% scan   : scan番?�
% DELTA_REALIGN_VAL : Scan中の脳の移動量/回転角度 (全scanを保�?)
% NG_SCAN           : 計算の対?ﾛ外とするscan番?�を管�?する配列 (全scanを保�?)
% regress_scan_num  : fMRIデ?[タのノイズ?恚�?��?に利用するscan?�
% 
% [output argument]
% denoised_data : ノイズ?恚詞繧ﾌROIの全voxelのfMRIデ?[タを管�?するcell配列

global gData


% ノイズ?恚�?��?に利用するscan番?�
scans = scan-regress_scan_num+1:scan;
% 試?sを開始する迄のscanのfMRIデ?[タは?ﾌ用しない?B
scans(scans <= gData.para.scans.pre_trial_scan_num) = [];
% ノイズ?恚�?��?に利用するscan?�
scans_num = length(scans);


% NG_SCAN配列 と DELTA_REALIGN_VAL配列 から?A
% ノイズ?恚�?��?に利用するscan番?�部分を?ﾘり?oす?B
ng_scan = NG_SCAN(scans);	% 計算の対?ﾛ外(TRUE)/対?ﾛ(FALSE)のscan
delta_realign_val = DELTA_REALIGN_VAL(scans, :);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WM, GS, CSF領域の平均値のscan間の変化量を�?める?B (2015.11.10)
% ------------------------------------------------------------
% ここで?A試?sを開始するscan(para.scans.pre_trial_scan_num+1)の
% WM?AGS?ACSF領域の平均値の前scanとの変化量は0.0とする?B
% ( 試?s開始の前のscan(para.scans.pre_trial_scan_num)は?Aデ?[タ
%   を取得していない(NaNが?ﾝ定されている)ので?AROI領域の平均値の
%   前scanとの変化量を�?めることができない?B )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_wm_signal = gData.data.wm_signal(scans) - gData.data.wm_signal(scans-1);
delta_gs_signal = gData.data.gs_signal(scans) - gData.data.gs_signal(scans-1);
delta_csf_signal= gData.data.csf_signal(scans)- gData.data.csf_signal(scans-1);
% 試?s開始scan(para.scans.pre_trial_scan_num+1)の変化量は0とする?B
tmp = find(scans==gData.para.scans.pre_trial_scan_num+1);
delta_wm_signal(tmp) = 0.0;
delta_gs_signal(tmp) = 0.0;
delta_csf_signal(tmp) = 0.0;



x = [...
      gData.data.realign_val(scans,:),...	% Template fileからの脳の動き
      delta_realign_val,...			% Scan中の脳の移動量/回転角度
      gData.data.wm_signal(scans),...		% WMの平均値
      gData.data.gs_signal(scans),...		% GSの平均値
      gData.data.csf_signal(scans),...		% CSFの平均値
      delta_wm_signal,...			% WMの平均値のscan間の変化量
      delta_gs_signal,...			% GSの平均値のscan間の変化量
      delta_csf_signal];			% CSFの平均値のscan間の変化量

% トレンド?恚獅ｷる? (2015.11.10)
% ----------------------------------------------------
% (不要だが念のため入れているだけ... by 山田?�?ｶ)
x = spm_detrend(x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NG scan?�報?s列(ng_mtx) と 定?�?�(1.0) を追加する?B (2016.07.19)
% -------------------------------------------
% NG scanフラグ(ng_scan)にTRUEを含む?�?�?B
%   -> NG scan番?�を管�?する?s列(ng_mtx)と定?�?�(1.0)を追加する?B
%      ng_mtx は NG scan番?�の?sが1.0 他は0.0の?s列で?ANG scanが
%      複?敗canに及ぶ?�?�?A列番?�をずらしてNG scan番?�の?sに1.0を
%      ?ﾝ定する?B
%      ( ng_scan(10) と ng_scan(12) がTRUEで?A他はFALSEの?�?�?A
%        ng_mtx(10,1)=1.0, ng_mtx(12,2)=1.0で?A他は0.0の?s列 )
% NG scanフラグ(ng_scan)にTRUEを含まない?�?�?B
%   -> 定?�?�(1.0)を追加する?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length( find(ng_scan == true) )
  % NG scanフラグ(ng_scan)に?ATRUEのscanを含む?�?�?B
  % ( Scan中の脳の移動量(FD)が?AScan中の脳の移動量の
  %   閾値(para.score.FD_threshold)
  %   より大きいScanが含まれている?B )
  % -----------------------------------------------
  %  NG scan?�報?s列(ng_mtx) と 定?�?�(1.0) を追加する?B
  ng_ptr = find(ng_scan == true);	% NG scan番?�
  ng_num = length( ng_ptr );		% NG scan?�
  ng_mtx = zeros(scans_num, ng_num);	% ノイズ?恚�?��?scan?� x NG scan?�
  % NG scanが複?敗canに及ぶ?�?�?A列番?�をずらしながら?A 
  % NG scan番?�の?sに1.0を?ﾝ定する?B
  for ii=1:ng_num
    ng_mtx(ng_ptr(ii), ii) = 1.0;
  end
  X = [x, ng_mtx, ones(scans_num,1)];    
else
  % NG scanフラグ(ng_scan)に?ATRUEのscanを含まない?�?�?B
  % ( Scan中の脳の移動量(FD)が?AScan中の脳の移動量の
  %   閾値(para.score.FD_threshold)
  %   より大きいScanは含まれていない?B )
  % -----------------------------------------------
  %  定?�?�(1.0)のみ追加する?B
  X = [x, ones(scans_num,1) ];
end
			    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ノイズ?恚祉f?[タ(多?d?�形回帰の残?ｷ)を�?める?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 山田?�?ｶの�??[ル(2017.03.03)より
% ----------------------------------------
% Y : bold signal matrix
%     ( gData.data.roi_vol{ROI}(scans,:) )
% X : regressors matrix
% B : beta(係?�)
% B = pinv(X)*Y なので
% 残?ｷ = Y - X*pinv(X)*Y
denoised_data = cell(gData.data.roi_num,1);
for roi=1:gData.data.roi_num

  roi_vol = gData.data.roi_vol{roi}(scans,:);	% ROIの全voxelの?M?�値
  roi_vox_num = gData.data.roi_vox_num(roi);	% ROIのvoxel?�
  
  residuals = roi_vol - X*pinv(X)*roi_vol;

  % ノイズ?恚� '前' のfMRIデ?[タの平均値を獲得する?B
  if isempty( find(isnan(roi_vol)) )	% roi_volにNaNを含まない?�?�
    mean_vol = mean(roi_vol);
  else					% roi_volにNaNを含む?�?�
    % NaNを?怩｢たデ?[タの平均値を�?める?B
    mean_vol = zeros(1,roi_vox_num);
    for ii=1:roi_vox_num
      p = ~isnan( roi_vol(:,ii) );
      mean_vol(ii) = mean(roi_vol(p,ii));
    end
  end
  
  % ノイズ?恚祉f?[タ に ノイズ?恚� '前' の平均値 を加える?B
  % ------------------------------------------------------------
  % ( 多?d?�形回帰の残?ｷ(regress関?狽ﾌ第3返り値のベクトル)
  %   は平均値が0.0の波形が?o力されるので?A
  %   ノイズ?恚資Oの平均値を加える?B )
  denoised_data{roi} = nan(scan, roi_vox_num);
  denoised_data{roi}(scans,:) = residuals + ones(scans_num,1)*mean_vol;
end	% <-- End of 'for ii=1:roi_vox_num'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function regress_method()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [denoised_data] = detrend_method(scan)
% function [denoised_data] = detrend_method(scan)
% ?�形トレンド?恚�?��?でROIの全voxelのfMRIデ?[タのノイズ?恚�?��?を?sなう?B
% 
% [input argument]
% scan   : scan番?�
% 
% [output argument]
% denoised_data : ノイズ?恚詞繧ﾌROIの全voxelのfMRIデ?[タを管�?するcell配列

global gData

scans = 1:scan;
% 試?sを開始する迄のscanのfMRIデ?[タは?ﾌ用しない?B
scans(scans <= gData.para.scans.pre_trial_scan_num) = [];


scans_num = length(scans);		% 対?ﾛscanの?�
denoised_data = cell(gData.data.roi_num,1);


% ROIをvoxel毎に?A?�形トレンド?恚事@でfMRIデ?[タの
% ノイズ?恚祉f?[タを�?める?B
% ------------------------------------------------------------
% ( ?�形トレンド?恚獅ﾍ?Adetrend関?狽ﾅ�?める?B
%   Y = detrend(X,'linear');
%   ここで?A
%   detrend関?狽ﾌ第1引?狽ﾌベクトルXにNaNのフレ?[ムが含まれて
%   いる?�?�?Adetrend関?狽ﾌ第3返り値のベクトルYは?A全てNaNが
%   ?ﾝ定される?Bそこで?ANaN?怩｢たデ?[タを用いてノイズ?恚�?��?
%   を?sなう?B )
for roi=1:gData.data.roi_num
  roi_vol = gData.data.roi_vol{roi}(scans,:);	% ROIの全voxelの?M?�値
  roi_vox_num = gData.data.roi_vox_num(roi);	% ROIのvoxel?�
  
  if gData.GPU
      denoised_data{roi} = gpuArray(nan(scan, roi_vox_num));
  else
      denoised_data{roi} = nan(scan, roi_vox_num);
  end

  
  % ROIをvoxel毎に?A?�形トレンド?恚獅ｵたデ?[タに?A
  % ノイズ?恚� '前' の平均値を加える?B
  % ------------------------------------------------------------
  % ?�形トレンド?恚祉f?[タ(detrend関?狽ﾌ返り値)は平均値が0.0の
  % 波形が?o力されるので?Aノイズ?恚資Oの平均値を加える?B
  % (http://jp.mathworks.com/help/matlab/data_analysis/detrending-data.html)
  if isempty( find(isnan(roi_vol)) )	% roi_volにNaNを含まない?�?�
    mean_vol = mean(roi_vol);		% ノイズ?恚資OのROI?M?�値の平均値
    denoised_data{roi}(scans,:) =...
	detrend(roi_vol,'linear') + ones(scans_num,1)*mean_vol;
  else					% ROI_VOLにNaNを含む?�?�
    % NaNを?怩｢たデ?[タでノイズ?恚�?��?を?sなう?B
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
