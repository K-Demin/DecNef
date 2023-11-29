function [] = save_binary_data()
% function [] = save_binary_data()
% 実験データをデータファイル(BINARY形式)に出力する。

global gData
% BINARY形式のデータファイルを作成する。
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

% 実験プロジェクトコード(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.version.decnef.project ), 'uint32');
% 実験プロジェクトのリリース情報(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.version.decnef.release ), 'uint32');
% 実験の日付情報(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.version.decnef.exp_date ), 'uint32');
% 実験の時間情報(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.version.decnef.exp_time ), 'uint32');

% Realignment parameterの配列数(32bit integer)を出力する。
fwrite(fd, int32( gData.define.default.REALIGN_VAL_NUM ), 'int32');

% ROIの数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.data.roi_num ), 'uint32');
% ROIのvoxel数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.data.roi_vox_num ), 'uint32');

% 試行数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.trial_num ), 'uint32');

% 試行を開始する迄のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.pre_trial_scan_num ), 'uint32');
% 1試行目の前処理用のREST条件その1のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.prep_rest1_scan_num ), 'uint32');
% 1試行目の前処理用のREST条件その2のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.prep_rest2_scan_num ), 'uint32');
% REST条件のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.rest_scan_num ), 'uint32');
% TEST条件のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.test_scan_num ), 'uint32');
% TEST条件開始後のdelay scan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.pre_test_delay_scan_num ), 'uint32');
% TEST条件終了後のdelay scan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.post_test_delay_scan_num ), 'uint32');
% 得点計算条件のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.calc_score_scan_num ), 'uint32');
% 得点提示条件のscan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.feedbk_score_scan_num ), 'uint32');
% 総Scan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.total_scan_num ), 'uint32');

% ノイズ除去処理のScan数(32bit unsigned integer)を出力する。
fwrite(fd, uint32( gData.para.scans.regress_scan_num ), 'uint32');

% 各scanの課題条件(32bit integer)を出力する。
fwrite(fd, int32( gData.data.scan_condition ), 'int32');

for ii=1:gData.data.roi_num
  % ROIのTemplateデータを出力する。
  fwrite(fd, gData.data.roi_template{ii}, 'double');
  % ROIの重み係数を出力する。
  fwrite(fd, gData.data.roi_weight{ii}, 'double');
  % ROIの全voxelの信号値を出力する。
  fwrite(fd, gData.data.roi_vol{ii}, 'double');
  % ROIの全voxelのノイズ除去後の信号値を出力する。
  fwrite(fd, gData.data.roi_denoised_vol{ii}, 'double');
  % ROIの全voxelのBASELINE REST条件のscanでの信号値の平均値を出力する。
  fwrite(fd, gData.data.roi_baseline_mean{ii}, 'double');
  % ROIの全voxelのBASELINE REST条件のscanでの信号値の標準偏差を出力する。
  fwrite(fd, gData.data.roi_baseline_std{ii}, 'double');
end
% 各scanでのWMの信号値の平均値を出力する。
fwrite(fd, gData.data.wm_signal, 'double');
% 各scanでのGSの信号値の平均値を出力する。
fwrite(fd, gData.data.gs_signal, 'double');
% 各scanでのCSFの信号値の平均値を出力する。
fwrite(fd, gData.data.csf_signal, 'double');
% 各scanでのrealignment parameterの平均値を出力する。
fwrite(fd, gData.data.realign_val, 'double');

% Scan中の脳の移動量を出力する。 [mm] (2016.02.01)
fwrite(fd, gData.data.FD, 'double');

% 各scanでのROIの信号値とROI templateデータの相関係数を出力する。
fwrite(fd, gData.data.corr_roi_template, 'double');

% Scanの計測データを得点の計算に採用 しない/する を出力する。(2017.07.25)
fwrite(fd, gData.data.ng_scan, 'logical');

% 各試行の各ROIのlabel値を出力する。
fwrite(fd, gData.data.label, 'double');
% 各試行の下限値と上限値内に補正前の得点を出力する。
fwrite(fd, gData.data.source_score, 'double');
% 各試行の下限値と上限値内に補正後の得点を出力する。
fwrite(fd, gData.data.score, 'double');

fclose(fd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_binary_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
