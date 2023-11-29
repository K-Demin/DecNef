function [fd, delta_realign_val] = calc_fd(realign_val, scans, para)
% function [fd, delta_realign_val] = calc_fd(realign_val, scans, para)
% Scan中の脳の移動量を求める。
% ( create_global.m内のcreate_para()のscore構造体のコメントを参照 )
% 
% [input argument]
% realign_val : Template DICOM fileからの脳の動きを表現する変数
%               (spm_realign関数で生成されるRealignment value)
% scans       : Scan中の脳の移動量を求めるscan番号
% para        : パラメータ構造体
% 
% [output argument]
% fd                : Scan中の脳の移動量 [mm]
% delta_realign_val : Scan中の脳の移動量/回転角度
%                     ( realign_val(:,1:3) = X,Y,Z軸方向の移動量 [mm]
%                       realign_val(:,4:6) = X,Y,Z軸まわりの回転角 [deg] )

% Scan中の脳の移動量/回転角度を求める。
% ( realign_val(:,1:3) = X,Y,Z軸方向の移動量 [mm]
%   realign_val(:,4:6) = X,Y,Z軸まわりの回転角 [deg] )
delta_realign_val = zeros( size( realign_val(scans,:) ) );
% 試行を開始する迄のscan(para.scans.pre_trial_scan_num)の
% データはNaNが設定されているので計算に採用しない。
tmp = find( scans > para.scans.pre_trial_scan_num+1 );
% scans(tmp-1)にアクセスするのでtmp=1は不可
tmp(tmp == 1) = [];	% <--- pre_trial_scan_num=0の場合の処置
% Scan中の脳の移動量/回転角度
delta_realign_val(tmp,:) =...
    realign_val(scans(tmp),:) - realign_val(scans(tmp-1),:);

% X,Y,Z軸まわりの回転角を移動量に変換する。
% ( 移動量 = 脳の半径 * 回転角度 ) [rad] -> [mm]
DELTA_REALIGN_VAL = delta_realign_val;
DELTA_REALIGN_VAL(:,4:6) =...
    para.score.radius_of_brain * DELTA_REALIGN_VAL(:,4:6);
% Scan中の脳の移動量を求める。 [mm]
fd = sum( abs(DELTA_REALIGN_VAL), 2 );

% 試行を開始する迄のscan(para.scans.pre_trial_scan_num)の
% Scan中の脳の移動量(fd, delta_realign_val)はNaNを設定する。
p = (scans <= para.scans.pre_trial_scan_num);
fd(p) = NaN;
delta_realign_val(p,:) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <-- 'End of function calc_fd()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
