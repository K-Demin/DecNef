function [data] = set_roi_data(para, data, roi_data)
% [data] = set_roi_data(data, roi)
% ROI情報を実験データ構造体に設定する。
% 
% [input argument]
% para     : 実験パラメータ構造体
% data     : 実験データ構造体
% roi_data : ROI情報を管理する構造体
% 
% [output argument]
% data : 実験データ構造体
data.roi_num = roi_data.roi_num;	% ROIの数
data.roi_mask = roi_data.roi_mask;	% ROI情報を管理するcell配列
data.roi_vox_num = roi_data.roi_vox_num;% % ROIのvoxel数を管理する配列
% ROIのfirst EPIデータを管理するcell配列
data.roi_template=roi_data.roi_template;% ROIのTemplate dataを管理するcell配列
data.roi_weight = roi_data.roi_weight;	% ROIの重み係数を管理するcell配列
data.wm_mask = roi_data.wm_mask;	% WM情報を管理する配列
data.gs_mask = roi_data.gs_mask;	% GS情報を管理する配列
data.csf_mask = roi_data.csf_mask;	% CSF情報を管理する配列

% 各scanでのROIの全voxelの信号値を管理するcell配列を用意する。
data.roi_vol = cell(1, data.roi_num);
data.roi_denoised_vol = cell(1, data.roi_num);
for ii=1:data.roi_num
  data.roi_vol{ii} =...
      nan(para.scans.total_scan_num, length(data.roi_template{ii}));
  data.roi_denoised_vol{ii} =...
      nan(para.scans.total_scan_num, length(data.roi_template{ii}));
end

% ROIの全voxelのBASELINE REST条件のscanでのMRIデータの
% 平均値 と 標準偏差 を管理するcell配列cell配列を用意する。
data.roi_baseline_mean = cell(1, data.roi_num);
data.roi_baseline_std  = cell(1, data.roi_num);
for ii=1:data.roi_num
  data.roi_baseline_mean{ii} = nan(1, length(find(data.roi_mask{ii})));
  data.roi_baseline_std{ii}  = nan(1, length(find(data.roi_mask{ii})));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function roi_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
