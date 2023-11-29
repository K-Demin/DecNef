function [denoised_data] = denoising_fmri_data(scan, regress_scan_num)
% function [denoised_data] = denoising_fmri_data(scan)
% ROI�̑Svoxel��fMRI�f?[�^�̃m�C�Y?���?��?��?s�Ȃ�?B
% 
% [input argument]
% scan   : scan��?�
% regress_scan_num : fMRI�f?[�^�̃m�C�Y?���?��?�ɗ��p����scan?�
% 
% [output argument]
% denoised_data : �m�C�Y?������ROI�̑Svoxel��fMRI�f?[�^���Ǘ?����cell�z��

global gData


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scan���̔]�̈ړ��ʂ��?�߂�?B [mm]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SCANS = [gData.para.scans.pre_trial_scan_num+1:scan];
DELTA_REALIGN_VAL = nan( size( gData.data.realign_val ) );
[gData.data.FD(SCANS), DELTA_REALIGN_VAL(SCANS,:)] =...
    calc_fd(gData.data.realign_val, SCANS, gData.para);

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Scan���̔]�̈ړ��ʂ𔻒肵?A����scan�̌v���f?[�^�𓾓_�̌v�Z��
% ?̗p ���Ȃ�/���� ���Ǘ?����z��(gData.data.ng_scan)��?ݒ肷��?B
% ------------------------------------------------------------------
% gData.data.ng_scan(scan) = false; (�v�Z�̑�?�)
% gData.data.ng_scan(scan) = true;  (�v�Z�̑�?ۊO)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.ng_scan(SCANS) = set_ng_scan(...
    gData.data.corr_roi_template(SCANS,:), gData.data.FD(SCANS),...
    gData.para.score.corr_roi_template_threshold,...
    gData.para.score.FD_threshold);


switch gData.para.denoising_method
  case gData.define.denoising_method.REGRESS
    % ��?d?��`��A�̎c?�����fMRI�f?[�^�̃m�C�Y?���?��?��?s�Ȃ�
    denoised_data=regress_method(scan, DELTA_REALIGN_VAL,...
	gData.data.ng_scan, regress_scan_num);
  
  case  gData.define.denoising_method.DETREND
    % ?��`�g�����h?���?��?��fMRI�f?[�^�̃m�C�Y?���?��?��?s�Ȃ�
    denoised_data = detrend_method(scan);
    
end	% <-- End of 'switch gData.para.denoising_method'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function denoising_fmri_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [denoised_data] = regress_method(scan, DELTA_REALIGN_VAL,...
    NG_SCAN, regress_scan_num)
% function [denoised_data] = regress_method(scan, DELTA_REALIGN_VAL, NG_SCAN)
% ��?d?��`��A�̎c?�����ROI�̑Svoxel��fMRI�f?[�^�̃m�C�Y?���?��?��?s�Ȃ�?B
% 
% [input argument]
% scan   : scan��?�
% DELTA_REALIGN_VAL : Scan���̔]�̈ړ���/��]�p�x (�Sscan��ێ?)
% NG_SCAN           : �v�Z�̑�?ۊO�Ƃ���scan��?����Ǘ?����z�� (�Sscan��ێ?)
% regress_scan_num  : fMRI�f?[�^�̃m�C�Y?���?��?�ɗ��p����scan?�
% 
% [output argument]
% denoised_data : �m�C�Y?������ROI�̑Svoxel��fMRI�f?[�^���Ǘ?����cell�z��

global gData


% �m�C�Y?���?��?�ɗ��p����scan��?�
scans = scan-regress_scan_num+1:scan;
% ��?s���J�n���閘��scan��fMRI�f?[�^��?̗p���Ȃ�?B
scans(scans <= gData.para.scans.pre_trial_scan_num) = [];
% �m�C�Y?���?��?�ɗ��p����scan?�
scans_num = length(scans);


% NG_SCAN�z�� �� DELTA_REALIGN_VAL�z�� ����?A
% �m�C�Y?���?��?�ɗ��p����scan��?�������?؂�?o��?B
ng_scan = NG_SCAN(scans);	% �v�Z�̑�?ۊO(TRUE)/��?�(FALSE)��scan
delta_realign_val = DELTA_REALIGN_VAL(scans, :);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WM, GS, CSF�̈�̕��ϒl��scan�Ԃ̕ω��ʂ��?�߂�?B (2015.11.10)
% ------------------------------------------------------------
% ������?A��?s���J�n����scan(para.scans.pre_trial_scan_num+1)��
% WM?AGS?ACSF�̈�̕��ϒl�̑Oscan�Ƃ̕ω��ʂ�0.0�Ƃ���?B
% ( ��?s�J�n�̑O��scan(para.scans.pre_trial_scan_num)��?A�f?[�^
%   ���擾���Ă��Ȃ�(NaN��?ݒ肳��Ă���)�̂�?AROI�̈�̕��ϒl��
%   �Oscan�Ƃ̕ω��ʂ��?�߂邱�Ƃ��ł��Ȃ�?B )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
delta_wm_signal = gData.data.wm_signal(scans) - gData.data.wm_signal(scans-1);
delta_gs_signal = gData.data.gs_signal(scans) - gData.data.gs_signal(scans-1);
delta_csf_signal= gData.data.csf_signal(scans)- gData.data.csf_signal(scans-1);
% ��?s�J�nscan(para.scans.pre_trial_scan_num+1)�̕ω��ʂ�0�Ƃ���?B
tmp = find(scans==gData.para.scans.pre_trial_scan_num+1);
delta_wm_signal(tmp) = 0.0;
delta_gs_signal(tmp) = 0.0;
delta_csf_signal(tmp) = 0.0;



x = [...
      gData.data.realign_val(scans,:),...	% Template file����̔]�̓���
      delta_realign_val,...			% Scan���̔]�̈ړ���/��]�p�x
      gData.data.wm_signal(scans),...		% WM�̕��ϒl
      gData.data.gs_signal(scans),...		% GS�̕��ϒl
      gData.data.csf_signal(scans),...		% CSF�̕��ϒl
      delta_wm_signal,...			% WM�̕��ϒl��scan�Ԃ̕ω���
      delta_gs_signal,...			% GS�̕��ϒl��scan�Ԃ̕ω���
      delta_csf_signal];			% CSF�̕��ϒl��scan�Ԃ̕ω���

% �g�����h?�������? (2015.11.10)
% ----------------------------------------------------
% (�s�v�����O�̂��ߓ���Ă��邾��... by �R�c?�?�)
x = spm_detrend(x);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NG scan?��?s��(ng_mtx) �� ��?�?�(1.0) ��ǉ�����?B (2016.07.19)
% -------------------------------------------
% NG scan�t���O(ng_scan)��TRUE���܂�?�?�?B
%   -> NG scan��?����Ǘ?����?s��(ng_mtx)�ƒ�?�?�(1.0)��ǉ�����?B
%      ng_mtx �� NG scan��?���?s��1.0 ����0.0��?s���?ANG scan��
%      ��?�scan�ɋy��?�?�?A���?������炵��NG scan��?���?s��1.0��
%      ?ݒ肷��?B
%      ( ng_scan(10) �� ng_scan(12) ��TRUE��?A����FALSE��?�?�?A
%        ng_mtx(10,1)=1.0, ng_mtx(12,2)=1.0��?A����0.0��?s�� )
% NG scan�t���O(ng_scan)��TRUE���܂܂Ȃ�?�?�?B
%   -> ��?�?�(1.0)��ǉ�����?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if length( find(ng_scan == true) )
  % NG scan�t���O(ng_scan)��?ATRUE��scan���܂�?�?�?B
  % ( Scan���̔]�̈ړ���(FD)��?AScan���̔]�̈ړ��ʂ�
  %   臒l(para.score.FD_threshold)
  %   ���傫��Scan���܂܂�Ă���?B )
  % -----------------------------------------------
  %  NG scan?��?s��(ng_mtx) �� ��?�?�(1.0) ��ǉ�����?B
  ng_ptr = find(ng_scan == true);	% NG scan��?�
  ng_num = length( ng_ptr );		% NG scan?�
  ng_mtx = zeros(scans_num, ng_num);	% �m�C�Y?���?��?scan?� x NG scan?�
  % NG scan����?�scan�ɋy��?�?�?A���?������炵�Ȃ���?A 
  % NG scan��?���?s��1.0��?ݒ肷��?B
  for ii=1:ng_num
    ng_mtx(ng_ptr(ii), ii) = 1.0;
  end
  X = [x, ng_mtx, ones(scans_num,1)];    
else
  % NG scan�t���O(ng_scan)��?ATRUE��scan���܂܂Ȃ�?�?�?B
  % ( Scan���̔]�̈ړ���(FD)��?AScan���̔]�̈ړ��ʂ�
  %   臒l(para.score.FD_threshold)
  %   ���傫��Scan�͊܂܂�Ă��Ȃ�?B )
  % -----------------------------------------------
  %  ��?�?�(1.0)�̂ݒǉ�����?B
  X = [x, ones(scans_num,1) ];
end
			    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �m�C�Y?����f?[�^(��?d?��`��A�̎c?�)���?�߂�?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �R�c?�?��̃??[��(2017.03.03)���
% ----------------------------------------
% Y : bold signal matrix
%     ( gData.data.roi_vol{ROI}(scans,:) )
% X : regressors matrix
% B : beta(�W?�)
% B = pinv(X)*Y �Ȃ̂�
% �c?� = Y - X*pinv(X)*Y
denoised_data = cell(gData.data.roi_num,1);
for roi=1:gData.data.roi_num

  roi_vol = gData.data.roi_vol{roi}(scans,:);	% ROI�̑Svoxel��?M?��l
  roi_vox_num = gData.data.roi_vox_num(roi);	% ROI��voxel?�
  
  residuals = roi_vol - X*pinv(X)*roi_vol;

  % �m�C�Y?��� '�O' ��fMRI�f?[�^�̕��ϒl���l������?B
  if isempty( find(isnan(roi_vol)) )	% roi_vol��NaN���܂܂Ȃ�?�?�
    mean_vol = mean(roi_vol);
  else					% roi_vol��NaN���܂�?�?�
    % NaN��?������f?[�^�̕��ϒl���?�߂�?B
    mean_vol = zeros(1,roi_vox_num);
    for ii=1:roi_vox_num
      p = ~isnan( roi_vol(:,ii) );
      mean_vol(ii) = mean(roi_vol(p,ii));
    end
  end
  
  % �m�C�Y?����f?[�^ �� �m�C�Y?��� '�O' �̕��ϒl ��������?B
  % ------------------------------------------------------------
  % ( ��?d?��`��A�̎c?�(regress��?��̑�3�Ԃ�l�̃x�N�g��)
  %   �͕��ϒl��0.0�̔g�`��?o�͂����̂�?A
  %   �m�C�Y?����O�̕��ϒl��������?B )
  denoised_data{roi} = nan(scan, roi_vox_num);
  denoised_data{roi}(scans,:) = residuals + ones(scans_num,1)*mean_vol;
end	% <-- End of 'for ii=1:roi_vox_num'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function regress_method()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [denoised_data] = detrend_method(scan)
% function [denoised_data] = detrend_method(scan)
% ?��`�g�����h?���?��?��ROI�̑Svoxel��fMRI�f?[�^�̃m�C�Y?���?��?��?s�Ȃ�?B
% 
% [input argument]
% scan   : scan��?�
% 
% [output argument]
% denoised_data : �m�C�Y?������ROI�̑Svoxel��fMRI�f?[�^���Ǘ?����cell�z��

global gData

scans = 1:scan;
% ��?s���J�n���閘��scan��fMRI�f?[�^��?̗p���Ȃ�?B
scans(scans <= gData.para.scans.pre_trial_scan_num) = [];


scans_num = length(scans);		% ��?�scan��?�
denoised_data = cell(gData.data.roi_num,1);


% ROI��voxel����?A?��`�g�����h?����@��fMRI�f?[�^��
% �m�C�Y?����f?[�^���?�߂�?B
% ------------------------------------------------------------
% ( ?��`�g�����h?�����?Adetrend��?��ŋ?�߂�?B
%   Y = detrend(X,'linear');
%   ������?A
%   detrend��?��̑�1��?��̃x�N�g��X��NaN�̃t��?[�����܂܂��
%   ����?�?�?Adetrend��?��̑�3�Ԃ�l�̃x�N�g��Y��?A�S��NaN��
%   ?ݒ肳���?B������?ANaN?������f?[�^��p���ăm�C�Y?���?��?
%   ��?s�Ȃ�?B )
for roi=1:gData.data.roi_num
  roi_vol = gData.data.roi_vol{roi}(scans,:);	% ROI�̑Svoxel��?M?��l
  roi_vox_num = gData.data.roi_vox_num(roi);	% ROI��voxel?�
  
  if gData.GPU
      denoised_data{roi} = gpuArray(nan(scan, roi_vox_num));
  else
      denoised_data{roi} = nan(scan, roi_vox_num);
  end

  
  % ROI��voxel����?A?��`�g�����h?��������f?[�^��?A
  % �m�C�Y?��� '�O' �̕��ϒl��������?B
  % ------------------------------------------------------------
  % ?��`�g�����h?����f?[�^(detrend��?��̕Ԃ�l)�͕��ϒl��0.0��
  % �g�`��?o�͂����̂�?A�m�C�Y?����O�̕��ϒl��������?B
  % (http://jp.mathworks.com/help/matlab/data_analysis/detrending-data.html)
  if isempty( find(isnan(roi_vol)) )	% roi_vol��NaN���܂܂Ȃ�?�?�
    mean_vol = mean(roi_vol);		% �m�C�Y?����O��ROI?M?��l�̕��ϒl
    denoised_data{roi}(scans,:) =...
	detrend(roi_vol,'linear') + ones(scans_num,1)*mean_vol;
  else					% ROI_VOL��NaN���܂�?�?�
    % NaN��?������f?[�^�Ńm�C�Y?���?��?��?s�Ȃ�?B
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
