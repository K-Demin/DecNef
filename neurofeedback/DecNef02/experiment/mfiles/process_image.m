function [success, receiver, dicom_fname,TR_Test, Skip, CorrFormat,processTime]...
    =  process_image(version, define, para, data, scan, receiver_id, receiver, TR_Test) 
% function [success, receiverm, dicom_fname] =...
% 		process_image(version, define, para, data, scan) 
% receiver�v�?�O���� ���� neurofeedback�v�?�O�����ւ�
% ��?M�f?[�^���Ǘ?����?\����(Receiver data?\����)��?ݒ肷��?B
% 
% [input argument]
% version : �o?[�W����?����Ǘ?����?\����
% define  : define��?����Ǘ?����?\����
% para    : �����p���??[�^?\����
% data    : �����f?[�^?\����
% scan    : Scan��?�
% receiver_id : receiver�v�?�O������ID (receiver ID)
%               (create_global.m��create_version()�̃R�?���g�Q?�)
%
% [output argument]
% success     : true(����)/false(���s:DICOM file��?�?�����Ă��Ȃ�)
% receiver    : Receiver data?\����
% dicom_fname : DICOM file��

startProcess = GetSecs;

% DICOM�t�@�C����
dicom_fname = sprintf('%s_%06d%s',...
    para.files.dicom_fnameB, scan, define.files.DICOM_FILE_EXTENSION);
dicom_file_name = fullfile(para.files.dicom_dir, dicom_fname);

% DICOM file��?�?�����Ă��邩�m�F����?B
if exist(dicom_file_name, 'file')
  % dicom_dir�f�B���N�g����DICOM file���m�F����Ă�?A
  % DICOM file����?����Ă��Ȃ�?�?���?l����?A��50ms�҂�?B
  pause(5/100);
  % This is to keep the images during the Test in a buffer
  TimeAccum = GetSecs - data.start_time;
  
  % spm_dicom_headers()�ŃG��?[����?�����?�?�(hdr����)?A
  % DICOM file����?����Ă��Ȃ��̂�?A��50ms�҂�?Ē�?킷��?B
  while true
    hdr = spm_dicom_headers(dicom_file_name);
    if ~isempty(hdr),	break;
    else		fprintf('+');	pause(5/100);
    end
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DICOM�`������NIfTI�`���ɕϊ�����?B
  % ----------------------------------------------------
  % ( ���p����SPM�̃o?[�W�����ɂ��?Aspm_dicom_convert()
  %   �̃I�v�V�������قȂ�?B )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  switch version.spm.version
    case { 'SPM12', 'spm12' }	% SPM12��?�?�
      % NIfTI file��?o�̓f�B���N�g����Work directory���w�肷��?B
      % (���̕�?��͑S�ăf�t�H���g�l��?ݒ肵�Ă���?B)
      opts     = 'all';
      root_dir = 'flat';
      format   = spm_get_defaults('images.format');
      out_dir  = para.files.work_dir{receiver_id};	% ?o��?���w�肷��?B
      nifti = spm_dicom_convert(hdr, opts, root_dir, format, out_dir);
      
    case { 'SPM8', 'spm8' }	% SPM8��?�?�
      % SPM8�ł�?A NIfTI file��?o�̓f�B���N�g�����w��ł��Ȃ��̂�?A
      % receiver()����Work directory�Ɉړ���ɂ��̊�?���call��?A
      % DICOM�`������NIfTI�`���ɕϊ�����?B
      nifti = spm_dicom_convert(hdr);
      
    otherwise			% SPM�o?[�W�������s��v
      msg = sprintf(...
	  'SPM version missmach.\n(You are using spm version ''%s''.)',...
	  version.spm.version);
      errordlg(msg, 'Error Dialog', 'modal');
      error(msg);
      
  end	% <-- End of 'switch version.spm.version'
  nifti_fname = nifti.files{1};

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Realign & Reslice
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  TempfNameArray = strvcat(para.files.templ_nifti_fname{receiver_id}, nifti_fname);
  spm_realign(TempfNameArray);
  spm_reslice(TempfNameArray, para.spm_reslice_flags);
  
  % This can be used to normalise to the MNI space. 
  % (if you want to do this, you also need to load the w....nii image below
  % instead of the image in the native space).
  %
  MNI_trans_fname = fullfile(para.files.templ_image_dir, para.files.MNI_trans_fname);

  matlabbatch{1}.spm.spatial.normalise.write.subj.def = {MNI_trans_fname};
  matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {nifti_fname};
  matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                              78 76 85];
  matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
  matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
  matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';
  % Run
  spm_jobman('run',matlabbatch);


%   
%   defs.comp{1}.def         = {'/Users/VincentTD/Desktop/Share/y_r20160727_124608MPRAGEtripleiPAT2s011a1001.nii'};
%   defs.out{1}.pull.fnames  = {'/Users/VincentTD/Desktop/Share/r20160801_115757ep2dSeqAsc212RESTPAs004a001.nii,1'};
%   defs.comp{2}.idbbvox.vox = [2 2 2];
%   defs.comp{2}.idbbvox.bb  = [-78 -112 -70
%                               78 76 85];
%   defs.out{1}.pull.fnames  = '';
%   defs.out{1}.pull.savedir.savesrc = 1;
%   defs.out{1}.pull.interp  = 4;
%   defs.out{1}.pull.mask    = 1;
%   defs.out{1}.pull.fwhm    = [0 0 0];
%   defs.out{1}.pull.prefix  = 'w';
% 
%   Nii = nifti(defs.comp{1}.def);
%   vx  = sqrt(sum(Nii.mat(1:3,1:3).^2));
%   if det(Nii.mat(1:3,1:3))<0, vx(1) = -vx(1); end
% 
%   o   = Nii.mat\[0 0 0 1]';
%   o   = o(1:3)';
%   dm  = size(Nii.dat);
%   bb  = [-vx.*(o-1) ; vx.*(dm(1:3)-o)];
% 
%   defs.comp{2}.idbbvox.vox(~isfinite(defs.comp{2}.idbbvox.vox)) = vx(~isfinite(defs.comp{2}.idbbvox.vox));
%   defs.comp{2}.idbbvox.bb(~isfinite(defs.comp{2}.idbbvox.bb)) = bb(~isfinite(defs.comp{2}.idbbvox.bb));
%   spm_deformations(defs);
 

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Realign & Reslice�ϊ����voxel�摜��
  % Realignment parameter���?�߂�?B
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [my_path, my_name, extension] = fileparts(deblank(nifti_fname));
  vol = spm_read_vols( spm_vol([my_path,'/w', my_name, extension]) );	% voxel�摜��Load����?B
  % Realignment parameter��Load����?B
  [pathstr, name, ext] =...
      fileparts(para.files.templ_nifti_fname{receiver_id});
  realign_val_fname = fullfile(pathstr,...
      sprintf('%s%s.txt', define.files.REALIG_PARA_FNAME_PREFIX_CODE, name));
  if exist(realign_val_fname, 'file')
    tmp = textread( realign_val_fname,...
	'%f', 2*define.default.REALIGN_VAL_NUM)';
    realign_val = tmp(define.default.REALIGN_VAL_NUM+1:end);
  else
    realign_val = nan(1, define.default.REALIGN_VAL_NUM);
  end


  roi_vol = cell(1,data.roi_num);
  corr_roi_template = zeros(1,data.roi_num);
  for ii=1:data.roi_num
    % ii�Ԗڂ�ROI�̈�̑Svoxel��?M?��l
    % ---------------------------------------------
    % NaN���v�����ꂽvoxel���܂߂�?AROI�̑Svoxel��
    % fMRI?M?���?ݒ肷��?B
    % (create_global.m����create_data()�̃R�?���g�Q?�)
    roi_vol_idx = find( data.roi_mask{ii} );
    roi_vol{ii} = reshape( vol(roi_vol_idx),  1, length(roi_vol_idx) );
    % ii�Ԗڂ�ROI�f?[�^ �� ROI template�f?[�^ �̑��֌W?����v�Z����?B
    % ---------------------------------------------
    % NaN���v�����ꂽvoxel��?�����voxel��fMRI?M?�
    % �̑��֌W?����v�Z����?B
    % (create_global.m����create_data()�̃R�?���g�Q?�)
    p = ~isnan( roi_vol{ii} );
    corr_roi_template(ii) = corr(roi_vol{ii}(p)', data.roi_template{ii}(p)');
  end
  
  % WM�̈��?M?��l�̕��ς��?�߂�?B
  if isempty(data.wm_mask)
    wm_signal = NaN;
  else
    idx = find( data.wm_mask & ~isnan(vol) );
    wm_signal = mean( vol(idx) );
  end
  % GS�̈��?M?��l�̕��ς��?�߂�?B
  if isempty(data.gs_mask)
    gs_signal = NaN;
  else
    idx = find( data.gs_mask & ~isnan(vol) );
    gs_signal = mean( vol(idx) );
  end
  % CSF�̈��?M?��l�̕��ς��?�߂�?B
  if isempty(data.csf_mask)
    csf_signal = NaN;
  else
    idx = find( data.csf_mask & ~isnan(vol) );
    csf_signal = mean( vol(idx) );
  end
  
  success = true;
else	% <-- End of 'exist(dicom_file_name, 'file')'
  success = false;
  roi_vol = {};
  wm_signal = [];
  gs_signal = [];
  csf_signal = [];
  realign_val = []; 
  corr_roi_template = [];
  nifti_fname = '';
end	% <-- End of 'exist(dicom_file_name, 'file') ... else'

processTime = GetSecs - startProcess;

receiver = data.receiver_template;
receiver.scan = scan;			% scan��?�
receiver.roi_vol = roi_vol;		% ROI�̑Svoxel��?M?���?ݒ肷��cell�z��
receiver.wm_signal = wm_signal;		% WM��?M?��l�̕��ς�?ݒ肷��z��
receiver.gs_signal = gs_signal;		% GS��?M?��l�̕��ς�?ݒ肷��z��
receiver.csf_signal = csf_signal;	% SCF��?M?��l�̕��ς�?ݒ肷��z��
receiver.realign_val = realign_val;	% realignment parameter��?ݒ肷��z��
receiver.corr_roi_template = corr_roi_template;% ROI templ��ROI�̑��֌W?��z��
receiver.nifti_fnames = nifti_fname;	% NIfTI file
TR_Test = 1;
Skip = 0;
CorrFormat = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function process_image()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
