function [data] = set_roi_data(para, data, roi_data)
% [data] = set_roi_data(data, roi)
% ROI���������f�[�^�\���̂ɐݒ肷��B
% 
% [input argument]
% para     : �����p�����[�^�\����
% data     : �����f�[�^�\����
% roi_data : ROI�����Ǘ�����\����
% 
% [output argument]
% data : �����f�[�^�\����
data.roi_num = roi_data.roi_num;	% ROI�̐�
data.roi_mask = roi_data.roi_mask;	% ROI�����Ǘ�����cell�z��
data.roi_vox_num = roi_data.roi_vox_num;% % ROI��voxel�����Ǘ�����z��
% ROI��first EPI�f�[�^���Ǘ�����cell�z��
data.roi_template=roi_data.roi_template;% ROI��Template data���Ǘ�����cell�z��
data.roi_weight = roi_data.roi_weight;	% ROI�̏d�݌W�����Ǘ�����cell�z��
data.wm_mask = roi_data.wm_mask;	% WM�����Ǘ�����z��
data.gs_mask = roi_data.gs_mask;	% GS�����Ǘ�����z��
data.csf_mask = roi_data.csf_mask;	% CSF�����Ǘ�����z��

% �escan�ł�ROI�̑Svoxel�̐M���l���Ǘ�����cell�z���p�ӂ���B
data.roi_vol = cell(1, data.roi_num);
data.roi_denoised_vol = cell(1, data.roi_num);
for ii=1:data.roi_num
  data.roi_vol{ii} =...
      nan(para.scans.total_scan_num, length(data.roi_template{ii}));
  data.roi_denoised_vol{ii} =...
      nan(para.scans.total_scan_num, length(data.roi_template{ii}));
end

% ROI�̑Svoxel��BASELINE REST������scan�ł�MRI�f�[�^��
% ���ϒl �� �W���΍� ���Ǘ�����cell�z��cell�z���p�ӂ���B
data.roi_baseline_mean = cell(1, data.roi_num);
data.roi_baseline_std  = cell(1, data.roi_num);
for ii=1:data.roi_num
  data.roi_baseline_mean{ii} = nan(1, length(find(data.roi_mask{ii})));
  data.roi_baseline_std{ii}  = nan(1, length(find(data.roi_mask{ii})));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function roi_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
