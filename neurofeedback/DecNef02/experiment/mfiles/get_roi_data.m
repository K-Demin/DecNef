function [roi_data] = get_roi_data(define, para)


roi_data = struct(...
    'roi_num', 0,...		
    'roi_mask', [],...		
    'roi_vox_num', [],...	
    'roi_template', [],...	
    'roi_weight', [],...	
    'wm_mask', [],...		
    'gs_mask', [],...		
    'csf_mask', []...		
    );

roi_data.roi_num = para.files.roi_fnum;		
roi_data.roi_mask = cell(1, roi_data.roi_num);
roi_data.roi_vox_num = zeros(1, roi_data.roi_num);
roi_data.roi_template = cell(1, roi_data.roi_num);
roi_data.roi_weight = cell(1, roi_data.roi_num);

NONZERO_ELEMENT_THRESHOLD = define.files.NONZERO_ELEMENT_THRESHOLD;

if roi_data.roi_num
  roi_epi_file = para.files.templ_nifti_fname{1};
  if exist(roi_epi_file, 'file')
    fprintf('ROI EPI = ''%s''\n', roi_epi_file );
    if ischar(para.files.roi_epi_threshold)
      fprintf('threshold=%s\n', para.files.roi_epi_threshold);
    else
      fprintf('threshold=%.3f\n', para.files.roi_epi_threshold);
    end
  else
    % ROI EPI file
    err_msg = sprintf('No such file or directory (''%s'')', roi_epi_file);
    errordlg(err_msg, 'Error Dialog', 'modal');
    error(err_msg);
  end
  % This will read the roi_epi_file which is the mean.nii file defined in temlpate_nifti_image
  roi_epi_img = spm_read_vols( spm_vol(roi_epi_file) );
  roi_epi = false( size(roi_epi_img) );
  
  % This function handles the nan values in the image according to the
  % NONZERO_ELEMENT_THRESHOLD.
  if strcmp( para.files.roi_epi_threshold, NONZERO_ELEMENT_THRESHOLD )
    roi_epi_img( find(isnan(roi_epi_img)) ) = 0;
    roi_epi( find(roi_epi_img) ) = true;
  else
    roi_epi_img( find(isnan(roi_epi_img)) ) = para.files.roi_epi_threshold-1;
    roi_epi( roi_epi_img >= para.files.roi_epi_threshold ) = true;
  end

  for roi=1:roi_data.roi_num
    % This is to select the data from the ROI.txt file in the mean.nii
    % file.
    ROIfName = fullfile(para.files.roi_dir, para.files.roi_fname{roi});
    
    [pathstr,name,ext] = fileparts( para.files.roi_fname{roi} );
    
    switch lower(ext)
      case '.txt'	
        [roi_data.roi_mask{roi}, roi_data.roi_template{roi},...
        roi_data.roi_weight{roi}, roi_data.roi_vox_num(roi)] =get_roi_array_text(ROIfName, roi_epi);
    
      case define.files.NIFTI_FILE_EXTENSION
        [roi_data.roi_mask{roi}, roi_img] = get_roi_array(ROIfName, roi_epi, para.files.roi_threshold{roi},NONZERO_ELEMENT_THRESHOLD);
        
        idx = find(roi_data.roi_mask{roi});
        roi_data.roi_vox_num(roi) = length(idx);
        % ROI template
        roi_data.roi_template{roi} =reshape(roi_epi_img(idx), 1, roi_data.roi_vox_num(roi));
        
        roi_data.roi_weight{roi} = zeros(1, roi_data.roi_vox_num(roi)+1);
        roi_data.roi_weight{roi}(1:roi_data.roi_vox_num(roi)) = reshape(roi_img(idx), 1, roi_data.roi_vox_num(roi));
    end	
	    
    if ischar(para.files.roi_threshold{roi})
      fprintf('ROI file%d = ''%s'' (%d voxel, threshfole=%s)\n',...
	  roi, para.files.roi_fname{roi}, roi_data.roi_vox_num(roi),...
	  para.files.roi_threshold{roi});
    else
      fprintf('ROI file%d = ''%s'' (%d voxel, threshfole=%.3f)\n',...
	  roi, para.files.roi_fname{roi}, roi_data.roi_vox_num(roi),...
	  para.files.roi_threshold{roi});
    end
  end	

  
  % WM
  if ~isempty( para.files.wm_fname )
    WMfName = fullfile(para.files.roi_dir, para.files.wm_fname);
    [roi_data.wm_mask, wm_img] = get_roi_array(WMfName, roi_epi,...
	para.files.wm_threshold, NONZERO_ELEMENT_THRESHOLD);
    if ischar(para.files.wm_threshold)
      fprintf('WM file = ''%s'' (%d voxel, threshfole=%s)\n',...
	  para.files.wm_fname, length( find(roi_data.wm_mask) ),...
	  para.files.wm_threshold);
    else
      fprintf('WM file = ''%s'' (%d voxel, threshfole=%.3f)\n',...
	  para.files.wm_fname, length( find(roi_data.wm_mask) ),...
	  para.files.wm_threshold);
    end
  end	

  
  % GS
  if ~isempty( para.files.gs_fname )
    GSfName = fullfile(para.files.roi_dir, para.files.gs_fname);
    [roi_data.gs_mask, gs_img] = get_roi_array(GSfName, roi_epi,...
	para.files.gs_threshold, NONZERO_ELEMENT_THRESHOLD);
    if ischar(para.files.gs_threshold)
      fprintf('GS file = ''%s'' (%d voxel, threshfole=%s)\n',...
	  para.files.gs_fname, length( find(roi_data.gs_mask) ),...
	  para.files.gs_threshold);
    else
      fprintf('GS file = ''%s'' (%d voxel, threshfole=%.3f)\n',...
	  para.files.gs_fname, length( find(roi_data.gs_mask) ),...
	  para.files.gs_threshold);
    end
  end	

  
  % CSF
  if ~isempty( para.files.csf_fname )
    CSFfName = fullfile(para.files.roi_dir, para.files.csf_fname);
    [roi_data.csf_mask, csf_img] = get_roi_array(CSFfName, roi_epi,...
	para.files.csf_threshold, NONZERO_ELEMENT_THRESHOLD);
    if ischar(para.files.csf_threshold)
      fprintf('CSF file = ''%s'' (%d voxel, threshfole=%s)\n',...
	  para.files.csf_fname, length( find(roi_data.csf_mask) ),...
	  para.files.csf_threshold);
    else
      fprintf('CSF file = ''%s'' (%d voxel, threshfole=%.3f)\n',...
	  para.files.csf_fname, length( find(roi_data.csf_mask) ),...
	  para.files.csf_threshold);
    end
  end	
  
end	

function [roi_mask, roi_img] = get_roi_array(roi_fname, roi_epi,roi_threshold, NONZERO_ELEMENT_THRESHOLD)
% This function load directly the decoder from a .nii file.
% it returns roi_mask: a boolean mask of the decoder and roi_img which
% actually includes the values of the weights.
err_msg = '';
if exist(roi_fname, 'file')
  roi_img = spm_read_vols( spm_vol(roi_fname) );

  % if the loaded image roi_img do not have the same dimension as the
  % roi_epi image (could remove this part to use MNI space decoders).
  if sum( size(roi_img) ~= size(roi_epi) )
    err1 = sprintf('Matrix dimensions must agree.\n');
    err2 = sprintf('  ROI EPI file dim = [%3d,%3d,%3d]\n', size(roi_epi));
    [pathstr, name, ext] = fileparts(roi_fname);
    err3 = sprintf('  ROI file(%s%s) dim  = [%3d,%3d,%3d]\n',...
	name, ext, size(roi_img));
    err_msg = [err1,err2,err3];
    ret = false;
  else
    %Handle nan values.
    if strcmp(roi_threshold, NONZERO_ELEMENT_THRESHOLD)
      roi_img( find(isnan(roi_img)) ) = 0;
      idx = find( roi_img & roi_epi );
    else
      roi_img( find(isnan(roi_img)) ) = roi_threshold-1;
      idx = find( roi_img >= roi_threshold & roi_epi );
    end
    roi_mask = false(size(roi_img));
    roi_mask(idx) = true;
    ret = true;
  end
else	
  err_msg = sprintf('No such file or directory (''%s'')', roi_fname);
  ret = false;
end	

if ret == false

  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end


function [roi_mask, roi_template, roi_weight, roi_vox_num] =get_roi_array_text(roi_fname, roi_epi)
% This function will read the ROI.txt file and create 3D matrices as a
% function of the dimensions in the header and by going through the voxels
% listed in the file. 

% The generated 3D images will be:
% ROI_weight: that include the weights of the decoder.
% ROI_template: includes the mean values to perform the online correlation.
% ROI mask: Just a matrix to indicate where the voxels included in the ROI are.

% [input argument]
% roi_fname	: ROI filename: 'ROI.txt'
% roi_epi	: ROI EPI
% 
% [output argument]
% roi_mask	:     Just a mask indicating where the ROI is.
% roi_template	: ROI‚Template
% roi_weight	: ROI weights
% roi_vox_num   : ROI voxel number
% 
err_msg = '';
if exist(roi_fname, 'file')
  fd = fopen(roi_fname, 'r');
  dim = sscanf( fgets(fd), '%d %d %d')';	
  vox_num = sscanf( fgets(fd), '%d');		
  
  roi_mask = false(dim);
  roi_weight_img = zeros(dim);
  roi_template_img = zeros(dim);

  for ii=1:vox_num
    % ii”Ô–Ú‚Ì ROI weigth ‚Æ ROI template ‚ð“Ç‚Þ?B
    tmp = sscanf( fgets(fd), '%d %d %d %f %f');
    d1 = round( tmp(1) );			% ROI‚Ì”z—ñ”Ô?†
    d2 = round( tmp(2) );			% ROI‚Ì”z—ñ”Ô?†
    d3 = round( tmp(3) );			% ROI‚Ì”z—ñ”Ô?†
    % VTD edit: I removed the if loop to make sure to get all the voxels.
    % (In the MNI space, the voxels of the mean.nii files are not the same
    % as those used for decoding).
    %if roi_epi(d1, d2, d3)
	roi_mask(d1, d2, d3) = true;
	roi_weight_img(d1, d2, d3) = tmp(4);	% ROI weigth’s
	roi_template_img(d1, d2, d3) = tmp(5);	% ROI template’s
    %end
  end
  
  % The last line includes the model intercept in the 4th column.
  tmp = sscanf( fgets(fd), '%d %d %d %f %f');	
  weigth_const = tmp(4);
  fclose(fd);

  idx = find(roi_mask);
  roi_vox_num = length(idx);
  
  % Reshape the template and weights data
  roi_template = reshape(roi_template_img(idx), 1, roi_vox_num);

  roi_weight = zeros(1, roi_vox_num+1);
  roi_weight(1:roi_vox_num) =reshape(roi_weight_img(idx), 1, roi_vox_num);
  roi_weight(end) = weigth_const;
  ret = true;
  %end
else
  err_msg = sprintf('No such file or directory (''%s'')', roi_fname);
  ret = false;
end

if ret == false
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end

