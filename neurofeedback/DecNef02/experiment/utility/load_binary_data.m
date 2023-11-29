function [nfb_data] = load_binary_data(load_dir, load_fname)
% function [nfb_data] = load_binary_data(load_dir, load_fname)
% Load the dataset of neurofeedback experiment. (BINARY format)
% 
% [input argument]
% load_dir   : directory name
% load_fname : experiment data file name (BINARY format)
% 
% [output argument]
% nfb_data : Experimental data structure
% 
% ----------------------------------------------------------
% Copyright 2013 All Rights Reserved.
% ATR Brain Information Communication Research Lab Group.
% ----------------------------------------------------------
% Toshinori YOSHIOKA
% 2-2-2 Hikaridai, Seika-cho, Sorakugun, Kyoto,
% 619-0288, Japan (Keihanna Science city)


load_file_name = fullfile(load_dir, load_fname);
fprintf('Load online neurofeedback data (BINARY format)\n');
fprintf('  Data load dir  = ''%s''\n', load_dir);
fprintf('  Data load file = ''%s''\n', load_fname);

nfb_data = struct(...
    'data_flag', false,...		% データ有効/無効フラグ (0:無効/1:有効)
    'decnef_project', -1,...		% DecNef実験プロジェクトコード
    'decnef_release', -1,...		% DecNef実験プロジェクトのリリース情報
    'decnef_exp_date', -1,...		% 実験の日付情報
    'decnef_exp_time', -1,...		% 実験の時間情報
    'dir_name', load_dir,...		% 実験データfileのdirectory
    'file_name', load_fname,...		% BINARY形式の実験データfile
    'roi_num', 0,...			% ROIの数
    'roi_vox_num', [],...		% ROIのvoxel数
    'trial_num', 0,...			% 試行数
    'pre_trial_scan_num', 1,...		% 試行を開始する迄のscan数
    'prep_rest1_scan_num', 1,...	% 前処理用のREST条件その1のscan数
    'prep_rest2_scan_num', 1,...	% 前処理用のREST条件その2のscan数
    'rest_scan_num', 1,...		% REST条件のscan数
    'test_scan_num', 1,...		% TEST条件のscan数
    'pre_test_delay_scan_num', 1,...	% TEST条件開始後のdelay scan数
    'post_test_delay_scan_num', 1,...	% TEST条件終了後のdelay scan数
    'calc_score_scan_num', 1,...	% 得点計算条件のscan数
    'feedbk_score_scan_num', 1,...	% 得点提示条件のscan数
    'regress_scan_num', 1,...		% ノイズ除去処理に利用するscan数
    'total_scan_num', 0,...		% 総Scan数
    'received_scan_num', 0,...		% 受信処理が完了したScan数
    'scan_condition', [],...	% 各scanの課題条件
    'roi_template', [],...	% ROIのTemplateデータを管理するcell配列
    'roi_weight', [],...	% ROIの重み係数を管理するcell配列
    'roi_vol', [],...		% 各scanのROIの全voxel信号を管理するcell配列
    'roi_denoised_vol', [],...	% 各scanのROIのノイズvoxel信号管理するcell配列
    'roi_baseline_mean', [],...	% ROIのBASELINE平均値を管理するcell配列
    'roi_baseline_std', [],...	% ROIのBASELINE標準偏差を管理するcell配列
    'wm_signal', [],...		% 各scanでのWMの信号値の平均値
    'gs_signal', [],...		% 各scanでのGMの信号値の平均値
    'csf_signal', [],...	% 各scanでのCSFの信号値の平均値
    'realign_val', [],...	% 各scanでのrealignment parameterの平均値
    'FD', [],...		% Scan中の脳の移動量 [mm]
    'corr_roi_template', [],...	% 各scanのROI dataとROI template dataの相関係数
    'ng_scan', [],...		% 各scanの計測データを得点計算に採用しない/する
    'label', [],...		% 各ROIのlabel値
    'source_score', [],...	% 各試行の下限値と上限値内に補正前の得点
    'score', []...		% 各試行の下限値と上限値内に補正後の得点
    );


fd = fopen(load_file_name, 'r');
if fd == -1	% 実験データfileが存在しない。
  % データ有効/無効フラグを更新する。
  nfb_data.data_flag = false;	% データが無効
else		% 実験データfileが存在しない。
  % データ有効性フラグを更新する。
  nfb_data.data_flag = true;	% データが有効
  
  % DecNef実験プロジェクトコード(32bit unsigned integer)を獲得する。
  nfb_data.decnef_project = fread(fd, 1, 'uint32');
  % DecNef実験プロジェクトのリリース情報(32bit unsigned integer)を獲得する。
  nfb_data.decnef_release = fread(fd, 1, 'uint32');
  % 実験の日付情報(32bit unsigned integer)を獲得する。
  nfb_data.decnef_exp_date = fread(fd, 1, 'uint32');
  % 実験の時間情報(32bit unsigned integer)を獲得する。
  nfb_data.decnef_exp_time = fread(fd, 1, 'uint32');
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load関数 と データファイルの整合性をチェックする。
  % ---------------------------------------------------------
  % ( 実験プロジェクトコード と 実験プロジェクトリリース日 が、
  %   Load関数 と データファイル で一致しなければならない。 )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Load関数の 実験プロジェクトコード(DecNef_Project) と 
  % 実験プロジェクトリリース日(DecNef_ReleaseData) を獲得する。
  [DecNef_Project, DecNef_ReleaseData] = release_info();
  if nfb_data.decnef_project ~= DecNef_Project |...
	nfb_data.decnef_release ~= DecNef_ReleaseData
    % Load関数 と データファイル の
    % 実験プロジェクトコード と 実験プロジェクトリリース日 が一致しない。
    str = sprintf(' [Decnef project information mismatch]\n');
    str = sprintf('%s Function (%s)\n', str, mfilename);
    str = sprintf('%s \t decnef_project = %d\n', str, DecNef_Project);
    str = sprintf('%s \t decnef_release = %d\n', str, DecNef_ReleaseData);
    str = sprintf('%s Data file (%s)\n', str, load_fname);
    str = sprintf('%s \t decnef_project = %d\n',...
	str, nfb_data.decnef_project);
    str = sprintf('%s \t decnef_release = %d\n',...
	str, nfb_data.decnef_release);
    error(str);
  end
  
  
  % Realignment parameterの配列数(32bit unsigned integer)を獲得する。
  REALIGN_VAL_NUM = fread(fd, 1, 'uint32');

  % ROIの数(32bit unsigned integer)を獲得する。
  nfb_data.roi_num = fread(fd, 1, 'uint32');
  % ROIのvoxel数(32bit unsigned integer)を獲得する。
  nfb_data.roi_vox_num = fread(fd, [1,nfb_data.roi_num], 'uint32');

  % 試行数(32bit unsigned integer)を獲得する。
  nfb_data.trial_num = fread(fd, 1, 'uint32');

  % 試行を開始する迄のscan数(32bit unsigned integer)を獲得する。
  nfb_data.pre_trial_scan_num = fread(fd, 1, 'uint32');
  % 前処理用のREST条件その1のscan数(32bit unsigned integer)を獲得する。
  nfb_data.prep_rest1_scan_num = fread(fd, 1, 'uint32');
  % 前処理用のREST条件その2のscan数(32bit unsigned integer)を獲得する。
  nfb_data.prep_rest2_scan_num = fread(fd, 1, 'uint32');
  % REST条件のscan数(32bit unsigned integer)を獲得する。
  nfb_data.rest_scan_num = fread(fd, 1, 'uint32');
  % TEST条件のscan数(32bit unsigned integer)を獲得する。
  nfb_data.test_scan_num = fread(fd, 1, 'uint32');
  % TEST条件開始後のdelay scan数(32bit unsigned integer)を獲得する。
  nfb_data.pre_test_delay_scan_num = fread(fd, 1, 'uint32');
  % TEST条件終了後のdelay scan数(32bit unsigned integer)を獲得する。
  nfb_data.post_test_delay_scan_num = fread(fd, 1, 'uint32');
  % 得点計算条件のscan数(32bit unsigned integer)を獲得する。
  nfb_data.calc_score_scan_num = fread(fd, 1, 'uint32');
  % 得点提示条件のscan数(32bit unsigned integer)を獲得する。
  nfb_data.feedbk_score_scan_num = fread(fd, 1, 'uint32');
  % 総Scan数(32bit unsigned integer)を獲得する。
  nfb_data.total_scan_num = fread(fd, 1, 'uint32');

  % ノイズ除去処理に利用するScan数(32bit unsigned integer)を獲得する。
  nfb_data.regress_scan_num = fread(fd, 1, 'uint32');
  
  % 各scanの課題条件を設定する配列を用意する。
  nfb_data.scan_condition = zeros(nfb_data.total_scan_num, 1);

  % ROIのTemplateデータを管理するcell配列を用意する。
  nfb_data.roi_template = cell(1, nfb_data.roi_num);
  % ROIの重み係数を管理するcell配列を用意する。
  nfb_data.roi_weight = cell(1, nfb_data.roi_num);
  % 各scanのROIの全voxel信号を管理するcell配列を用意する。
  nfb_data.roi_vol = cell(1, nfb_data.roi_num);
  % 各scanのROIのノイズ除去後の全voxel信号を管理するcell配列を用意する。
  nfb_data.roi_denoised_vol = cell(1, nfb_data.roi_num);
  % ROIのBASELINE平均値を管理するcell配列を用意する。
  nfb_data.roi_baseline_mean = cell(1, nfb_data.roi_num);
  % ROIのBASELINE標準偏差を管理するcell配列を用意する。
  nfb_data.roi_baseline_std = cell(1, nfb_data.roi_num);
  % 各scanでのWMの信号値の平均値を設定する配列を用意する。
  nfb_data.wm_signal = zeros(nfb_data.total_scan_num, 1);
  % 各scanでのGMの信号値の平均値を設定する配列を用意する。
  nfb_data.gs_signal = zeros(nfb_data.total_scan_num, 1);
  % 各scanでのCSFの信号値の平均値を設定する配列を用意する。
  nfb_data.csf_signal = zeros(nfb_data.total_scan_num, 1);
  % 各scanのrealignment parameterを設定する配列を用意する。
  nfb_data.realign_val = zeros(nfb_data.total_scan_num, REALIGN_VAL_NUM);
  % Scan中の脳の移動量を設定する配列を用意する。 [mm]
  nfb_data.FD = zeros(nfb_data.total_scan_num, 1);
  % 各scanでのROIの信号値とROI templateデータの相関係数
  % を設定する配列を用意する。
  nfb_data.corr_roi_template=zeros(nfb_data.total_scan_num, nfb_data.roi_num);
  % Scanの計測データを得点の計算に採用 しない/する を設定する配列を用意する。
  nfb_data.ng_scan = false(nfb_data.total_scan_num, 1);
  % 各ROIのlabel値を保存する配列を用意する。
  nfb_data.label = zeros(nfb_data.trial_num, nfb_data.roi_num);
  % 各試行での下限値と上限値内に補正前の得点を保存する配列を用意する。
  nfb_data.source_score = zeros(nfb_data.trial_num, 1);
  % 各試行での下限値と上限値内に補正後の得点を保存する配列を用意する。
  nfb_data.score = zeros(nfb_data.trial_num, 1);

  % 各scanの課題条件(32bit integer)を獲得する。
  nfb_data.scan_condition = fread(fd, nfb_data.total_scan_num, 'int32');

  for ii=1:nfb_data.roi_num
    roi_vol_num = nfb_data.roi_vox_num(ii);		% ROIのvoxel数
    % ROIのTemplateデータを獲得する。
    nfb_data.roi_template{ii} = fread(fd, [1, roi_vol_num], 'double');
    % ROIの重み係数を獲得する。 (ROIのvoxel数+1)
    nfb_data.roi_weight{ii} = fread(fd, [1, roi_vol_num+1], 'double');
    % ROIの全voxelのノイズ除去後の信号値を獲得する。
    nfb_data.roi_vol{ii} =...
	fread(fd, [nfb_data.total_scan_num, roi_vol_num], 'double');
    % ROIの全voxelの信号値を獲得する。
    nfb_data.roi_denoised_vol{ii} =...
	fread(fd, [nfb_data.total_scan_num, roi_vol_num], 'double');
    % ROIの全voxelのBASELINE REST条件のscanでの信号値の平均値を獲得する。
    nfb_data.roi_baseline_mean{ii} = fread(fd, [1, roi_vol_num], 'double');
    % ROIの全voxelのBASELINE REST条件のscanでの信号値の標準偏差を獲得する。
    nfb_data.roi_baseline_std{ii} = fread(fd, [1, roi_vol_num], 'double');
  end
  % 各scanでのWMの信号値の平均値を獲得する。
  nfb_data.wm_signal = fread(fd, nfb_data.total_scan_num, 'double');
  % 各scanでのGMの信号値の平均値を獲得する。
  nfb_data.gs_signal = fread(fd, nfb_data.total_scan_num, 'double');
  % 各scanでのCSFの信号値の平均値を獲得する。
  nfb_data.csf_signal = fread(fd, nfb_data.total_scan_num, 'double');
  % 各scanでのrealignment parameterの平均値を獲得する。
  nfb_data.realign_val =...
      fread(fd, [nfb_data.total_scan_num, REALIGN_VAL_NUM], 'double');

  % Scan中の脳の移動量を獲得する。 [mm]
  nfb_data.FD = fread(fd, [nfb_data.total_scan_num, 1], 'double');
  
  % 各scanでのROIの信号値とROI templateの相関係数を獲得する。
  nfb_data.corr_roi_template =...
      fread(fd, [nfb_data.total_scan_num, nfb_data.roi_num], 'double');

  % Scanの計測データを得点の計算に採用 しない/する を獲得する。
  nfb_data.ng_scan = fread(fd, [nfb_data.total_scan_num, 1], 'logical');
  
  % 各ROIのlabel値を獲得する。
  nfb_data.label = fread(fd, [nfb_data.trial_num, nfb_data.roi_num], 'double');
  % 各試行の下限値と上限値内に補正前の得点を獲得する。
  nfb_data.source_score = fread(fd, nfb_data.trial_num, 'double');
  % 各試行の下限値と上限値内に補正後の得点を獲得する。
  nfb_data.score = fread(fd, nfb_data.trial_num, 'double');

  fclose(fd);
  
  % 受信処理が完了しているScan数を求める。
  % (wm_signal配列がNaNでないデータの数)
  nfb_data.received_scan_num = length( find( ~isnan(nfb_data.wm_signal) ) );
end	% <-- End of 'if fd == -1 ... else'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_binary_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
