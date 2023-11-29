function [ng_scan] = set_ng_scan(corr_temple, FD,...
    corr_temple_threshold, FD_threshold)
% function [ng_scan] = set_ng_scan(corr_temple, FD,...
% 				corr_temple_threshold, FD_threshold)
% Scan中の脳の移動量を判定し、このscanの計測データを得点の計算に
% 採用 しない/する を管理する配列(ng_scan)を設定する。
% 
% [input argument]
% corr_temple : ROI templateデータとROIデータの相関係数を管理する配列
% FD : Scan中の脳の移動量を管理する配列
% corr_temple_threshold : ROI templateとROIの相関係数の閾値
% FD_threshold : Scan中の脳の移動量の閾値
% 
% [output argument]
% ng_scan : scanの計測データを得点の計算に採用 しない/する を管理する配列


% corr_err_scan = ROI templateデータとROIデータの相関係数が閾値未満ならTRUE
corr_err_scan = sum( corr_temple < corr_temple_threshold ,2) >= 1;
% fd_err_scans = Scan中の脳の移動量が閾値を超える場合TRUE
% ( 但し、Scan中の脳の移動量の閾値(FD_threshold)がNaNの場合、
%   scan中の脳の移動量の値を判定しない。(fd_err_scans(:) = FALSE) )
fd_err_scans = false( size(FD) );
if ~isnan(FD_threshold)
  fd_err_scans = FD>FD_threshold;
end
% nan_scan = ROI templateとROIの相関係数(corr_temple) か 
%            Scan中の脳の移動量(FD) にNaNが設定されている場合TRUE
% (試行を開始するまでのscanはNaNが設定される。)
TMP = [corr_temple, FD];
nan_scan = sum( isnan( TMP ), 2) >= 1;
% ng_scan = scan(=配列番号)の計測データを
%           得点の計算に採用 しない(true)/する(false)
ng_scan = corr_err_scan | fd_err_scans | nan_scan;
%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'set_ng_scan()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%
