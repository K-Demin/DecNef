function [fig] = draw_roi_volume()
% function [fig] = draw_roi_volume()
% ROI���̑Svoxel��fMRI�f�[�^��Graph�\������B
% 
% [output argument]
% fig : Graph��plot����figure��handle

global gData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph�\���f�[�^���Ǘ�����\����(UserData)���쐬����B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROI�f�[�^���Ǘ�����\����
roi_data(1:gData.data.roi_num) = struct(...
    'roi_fname', '',...		% ROI file��
    'roi_threshold', 0,...	% ROI data��臒l
    'voxel_num', 0,...		% ROI��voxel��
    'roi_vol', [],...		% �m�C�Y���������O��ROI�f�[�^
    'roi_denoised_vol', []...	% �m�C�Y�����������ROI�f�[�^
    );
% Graph�\���f�[�^���Ǘ�����\����
UserData = struct(...
    'roi_epi_threshold',  0.0,...	% ROI EPI data��臒l
    'roi_data', roi_data...		% ROI�f�[�^���Ǘ�����\����
    );
UserData.roi_epi_threshold = gData.para.files.roi_epi_threshold;

for roi=1:gData.data.roi_num
  % ROI�f�[�^���Ǘ�����\���̂�ݒ肷��B
  UserData.roi_data(roi).roi_fname = gData.para.files.roi_fname{roi};
  UserData.roi_data(roi).roi_threshold = gData.para.files.roi_threshold{roi};
  UserData.roi_data(roi).voxel_num = gData.data.roi_vox_num(roi);
  UserData.roi_data(roi).roi_vol = gData.data.roi_vol{roi};
  UserData.roi_data(roi).roi_denoised_vol =...
      gData.data.roi_denoised_vol{roi};
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph figure window���쐬���AGraph�\������f�[�^���(Raw/Denoised)
% ��؂芷���郁�j���[���쐬����B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph figure window���쐬����B
fig_name = sprintf('%s_%s',...
    gData.para.save_name, gData.para.files.dicom_fnameB);
fig = figure('Name', fig_name, 'Tag', fig_name,...
    'DefaultTextInterpreter', 'none', 'UserData', UserData);

% �R���e�L�X�g ���j���[���쐬����B
cmenu = uicontextmenu;
uimenu(cmenu, 'label','Raw data','Callback', @raw_graph);
uimenu(cmenu, 'label','Denoised data','Callback', @denoised_graph);
set(fig,'uicontextmenu',cmenu);

% ���j���[ �o�[�Ƀ��j���[��ǉ�����B
bmenu = uimenu(fig, 'Label', 'Draw data');
uimenu(bmenu, 'Label', 'Raw data', 'Callback', @raw_graph);
uimenu(bmenu, 'Label', 'Denoised data', 'Callback', @denoised_graph);

% �m�C�Y�����������fMRI�g�`��Graph�\������B
denoised_graph();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function draw_roi_volume()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [] = raw_graph(varargin)
% function [] = raw_graph(varargin)
% �m�C�Y���������O��fMRI�g�`��Graph�\������B
% ( 'Raw data' menu��CallBack�֐� )
% 
% [input argument]
% varargin : ���g�p

UserData = get(gcf, 'UserData');
roi_num = length(UserData.roi_data);			% ROI�̐�
scan_num = size(UserData.roi_data(1).roi_vol,1);	% scan��
roi_epi_threshold = UserData.roi_epi_threshold;		% ROI EPI data��臒l

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
% �m�C�Y��������(���d���`��A�̎c��)���fMRI�g�`��Graph�\������B
% ( 'Denoised data' menu��CallBack�֐� )
% 
% [input argument]
% varargin : ���g�p

UserData = get(gcf, 'UserData');
roi_num = length(UserData.roi_data);			% ROI�̐�
scan_num=size(UserData.roi_data(1).roi_denoised_vol,1);	% scan��
roi_epi_threshold = UserData.roi_epi_threshold;		% ROI EPI data��臒l

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
