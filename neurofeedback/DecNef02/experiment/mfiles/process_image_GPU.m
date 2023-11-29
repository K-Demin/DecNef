function [success, receiver, dicom_fname, processTime]...
    =  process_image_GPU(version, define, para, data, scan, receiver_id,receiver,Def,mat,defs,DefNii,outDir) 

% Get the start time
startProcess = GetSecs;

% Ge the DICOM file
dicom_fname = sprintf('%s_%06d%s',para.files.dicom_fnameB, scan, define.files.DICOM_FILE_EXTENSION);
dicom_file_name = fullfile(para.files.dicom_dir, dicom_fname);

% DICOM file
if exist(dicom_file_name, 'file')
  pause(5/100);

  % get the header with spm_dicom_headers()
  while true
    hdr = spm_dicom_headers(dicom_file_name);
    if ~isempty(hdr),	break;
    else		fprintf('+');	pause(5/100);
    end
  end

  % differences as a function of the SPM versions
  switch version.spm.version
    case { 'SPM12', 'spm12' }	
      opts     = 'all';
      root_dir = 'flat';
      format   = spm_get_defaults('images.format');
      out_dir  = para.files.work_dir{receiver_id};	
      niiFile = spm_dicom_convert(hdr, opts, root_dir, format, out_dir);
      
    case { 'SPM8', 'spm8' }	
      niiFile = spm_dicom_convert(hdr);
      
    otherwise			
      msg = sprintf('SPM version missmach.\n(You are using spm version ''%s''.)',version.spm.version);
      errordlg(msg, 'Error Dialog', 'modal');
      error(msg);
      
  end
  
  % Get the nifti file name
  nifti_fname = niiFile.files{1};

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Realign, Reslice & Normalize
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  NI = nifti(nifti_fname);
  Ref = nifti(para.files.templ_nifti_fname{receiver_id});
  volumes = [];
  volumes(:,:,:,1) = Ref.dat;
  volumes(:,:,:,2) = NI.dat;
  voxel_size_x = 2.97;
  voxel_size_y = 2.97;
  voxel_size_z = 3;
  iterations = 5;
  opencl_platform = 0; %type GetOpenCLInfo
  opencl_device = 0;
  broccoli_location = [para.files.current_dir,'\toolbox\BROCCOLI-master\'];
  load([broccoli_location,'\filters\filters_for_linear_registration.mat'])
  
  % Relignment and reslincing is done here 
  [motion_corrected_volumes,motion_parameters] = MotionCorrectionMex(volumes,voxel_size_x,voxel_size_y,voxel_size_z,f1_parametric_registration,f2_parametric_registration,f3_parametric_registration,iterations,opencl_platform,opencl_device,broccoli_location);
  
  % select the 2nd volume (the first one is the reference image)
  NI.dat(:,:,:) = motion_corrected_volumes(:,:,:,2);

  % Normalization
  disp('Running normalization.')
  NO = spm_realtime_deformations(defs,NI,DefNii,outDir,Def,mat); 
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Get realignment parameter
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  realign_val = motion_parameters(2,:);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Now correlation with template
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  roi_vol = cell(1,data.roi_num);
  corr_roi_template = zeros(1,data.roi_num);
  for ii=1:data.roi_num
    roi_vol_idx = find( data.roi_mask{ii} );
    roi_vol{ii} = reshape( NO.dat(roi_vol_idx),  1, length(roi_vol_idx) );
    p = ~isnan( roi_vol{ii} );
    corr_roi_template(ii) = corr(roi_vol{ii}(p)', data.roi_template{ii}(p)');
  end
  
  % WM
  if isempty(data.wm_mask)
    wm_signal = NaN;
  else
    idx = find( data.wm_mask & ~isnan(vol) );
    wm_signal = mean( vol(idx) );
  end
  % GS
  if isempty(data.gs_mask)
    gs_signal = NaN;
  else
    idx = find( data.gs_mask & ~isnan(vol) );
    gs_signal = mean( vol(idx) );
  end
  % CSF
  if isempty(data.csf_mask)
    csf_signal = NaN;
  else
    idx = find( data.csf_mask & ~isnan(vol) );
    csf_signal = mean( vol(idx) );
  end
  
  success = true;
else	
    
  success = false;
  roi_vol = {};
  wm_signal = [];
  gs_signal = [];
  csf_signal = [];
  realign_val = []; 
  corr_roi_template = [];
  nifti_fname = '';
  processTime = 0;
  return
end	

processTime = GetSecs - startProcess;

% receiver
receiver = data.receiver_template;
receiver.scan = scan;			% scan
receiver.roi_vol = roi_vol;		% ROI
receiver.wm_signal = wm_signal;		% WM
receiver.gs_signal = gs_signal;		% GS
receiver.csf_signal = csf_signal;	% SCF
receiver.realign_val = realign_val;	% realignment parameter
receiver.corr_roi_template = corr_roi_template;% ROI templ
receiver.nifti_fnames = nifti_fname;	% NIfTI file

