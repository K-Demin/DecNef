function [fig] = draw_roi_volume()
% function [fig] = draw_roi_volume()
% ROI内の全voxelのfMRIデータをGraph表示する。
% 
% [output argument]
% fig : Graphをplotしたfigureのhandle

global gData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph表示データを管理する構造体(UserData)を作成する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROIデータを管理する構造体
roi_data(1:gData.data.roi_num) = struct(...
    'roi_fname', '',...		% ROI file名
    'roi_threshold', 0,...	% ROI dataの閾値
    'voxel_num', 0,...		% ROIのvoxel数
    'roi_vol', [],...		% ノイズ除去処理前のROIデータ
    'roi_denoised_vol', []...	% ノイズ除去処理後のROIデータ
    );
% Graph表示データを管理する構造体
UserData = struct(...
    'roi_epi_threshold',  0.0,...	% ROI EPI dataの閾値
    'roi_data', roi_data...		% ROIデータを管理する構造体
    );
UserData.roi_epi_threshold = gData.para.files.roi_epi_threshold;

for roi=1:gData.data.roi_num
  % ROIデータを管理する構造体を設定する。
  UserData.roi_data(roi).roi_fname = gData.para.files.roi_fname{roi};
  UserData.roi_data(roi).roi_threshold = gData.para.files.roi_threshold{roi};
  UserData.roi_data(roi).voxel_num = gData.data.roi_vox_num(roi);
  UserData.roi_data(roi).roi_vol = gData.data.roi_vol{roi};
  UserData.roi_data(roi).roi_denoised_vol =...
      gData.data.roi_denoised_vol{roi};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph figure windowを作成し、Graph表示するデータ種別(Raw/Denoised)
% を切り換えるメニューを作成する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph figure windowを作成する。
fig_name = sprintf('%s_%s',...
    gData.para.save_name, gData.para.files.dicom_fnameB);
fig = figure('Name', fig_name, 'Tag', fig_name,...
    'DefaultTextInterpreter', 'none', 'UserData', UserData);

% コンテキスト メニューを作成する。
cmenu = uicontextmenu;
uimenu(cmenu, 'label','Raw data','Callback', @raw_graph);
uimenu(cmenu, 'label','Denoised data','Callback', @denoised_graph);
set(fig,'uicontextmenu',cmenu);

% メニュー バーにメニューを追加する。
bmenu = uimenu(fig, 'Label', 'Draw data');
uimenu(bmenu, 'Label', 'Raw data', 'Callback', @raw_graph);
uimenu(bmenu, 'Label', 'Denoised data', 'Callback', @denoised_graph);

% ノイズ除去処理後のfMRI波形をGraph表示する。
denoised_graph();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function draw_roi_volume()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [] = raw_graph(varargin)
% function [] = raw_graph(varargin)
% ノイズ除去処理前のfMRI波形をGraph表示する。
% ( 'Raw data' menuのCallBack関数 )
% 
% [input argument]
% varargin : 未使用

UserData = get(gcf, 'UserData');
roi_num = length(UserData.roi_data);			% ROIの数
scan_num = size(UserData.roi_data(1).roi_vol,1);	% scan数
roi_epi_threshold = UserData.roi_epi_threshold;		% ROI EPI dataの閾値

for roi=1:roi_num
  subplot(roi_num, 1, roi);
  hold off;
  plot(UserData.roi_data(roi).roi_vol);
  hold on;
  xlim([0, scan_num])
  
  str = sprintf('ROI%d(%d voxels) ''%s''',...
      roi, UserData.roi_data(roi).voxel_num, UserData.roi_data(roi).roi_fname);
  title( str );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function raw_graph()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = denoised_graph(varargin)
% function [] = denoised_graph(varargin)
% ノイズ除去処理(多重線形回帰の残差)後のfMRI波形をGraph表示する。
% ( 'Denoised data' menuのCallBack関数 )
% 
% [input argument]
% varargin : 未使用

UserData = get(gcf, 'UserData');
roi_num = length(UserData.roi_data);			% ROIの数
scan_num=size(UserData.roi_data(1).roi_denoised_vol,1);	% scan数
roi_epi_threshold = UserData.roi_epi_threshold;		% ROI EPI dataの閾値

for roi=1:roi_num
  subplot(roi_num, 1, roi);
  hold off;
  plot(UserData.roi_data(roi).roi_denoised_vol);
  hold on;
  xlim([0, scan_num])

  str = sprintf('ROI%d(%d voxels) ''%s''',...
      roi, UserData.roi_data(roi).voxel_num, UserData.roi_data(roi).roi_fname);
  title( str );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function denoised_graph()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
