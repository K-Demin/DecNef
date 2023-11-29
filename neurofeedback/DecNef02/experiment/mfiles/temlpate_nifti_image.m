function [templ_nifti_fname] =temlpate_nifti_image(version, define, para, rcv_cnt)
% Essentially this will get the template image.
% If the image is specified as a .nii. Nothing much is done except setting
% the parameters of that file.
% If it is a DICOM, it is converted to nifti first.
% Rgiht now, I fee the image mean.nii.

fprintf('template image dir = ''%s''\n', para.files.templ_image_dir);
fprintf('template image file = ''%s''\n', para.files.templ_image_fname);
fprintf('Work Dir = ''%s''\n', para.files.work_dir{rcv_cnt});


if exist(para.files.work_dir{rcv_cnt}, 'dir') ~= 7
  mkdir(para.files.work_dir{rcv_cnt});
end

% Template image
templ_image_fname =fullfile(para.files.templ_image_dir, para.files.templ_image_fname);

[pathstr, templ_name, templ_ext] = fileparts(para.files.templ_image_fname);

% If the template image exists
if exist(templ_image_fname, 'file')
  switch templ_ext	
    % If it is a DICOM
    case define.files.DICOM_FILE_EXTENSION	
      templ_nifti_fname =dicom2nifti(version.spm.version, para, rcv_cnt, templ_image_fname);
    % If it is a NIFTI
    case define.files.NIFTI_FILE_EXTENSION
      for ii=1:length(define.files.NIFTI_FILE_EXTENSION)
        source_file = fullfile( para.files.templ_image_dir,sprintf('%s%s',templ_name,define.files.NIFTI_FILE_EXTENSION{ii}) );
        out_dir  = para.files.work_dir{rcv_cnt};
        if exist(source_file, 'file')
             copyfile(source_file, out_dir)
        end
      end
      templ_nifti_fname = fullfile(out_dir, para.files.templ_image_fname);

  end	% <-- End of 'switch templ_ext'
  
else
  % Template image
  err_msg = sprintf('No such file or directory (''%s'')', templ_image_fname);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
end



function [nifti_fname] = dicom2nifti(spm_version, para, rcv_cnt, dicom_fname)
hdr = spm_dicom_headers(dicom_fname);
switch spm_version
  case { 'SPM12', 'spm12' }	% SPM12
    opts     = 'all';
    root_dir = 'flat';
    format   = spm_get_defaults('images.format');
    out_dir  = para.files.work_dir{rcv_cnt}; 
    nifti = spm_dicom_convert(hdr, opts, root_dir, format, out_dir);
      
  case { 'SPM8', 'spm8' }	% SPM8
    cd(para.files.work_dir{rcv_cnt});	
    nifti = spm_dicom_convert(hdr);
    cd(para.files.current_dir);		
      
  otherwise	
    msg = sprintf(...
	'SPM version missmach.\n(You are using spm version ''%s''.)',...
	spm_version);
    errordlg(msg, 'Error Dialog', 'modal');
    error(msg);
      
end	
nifti_fname = nifti.files{1};

% Realign & Reslice
FnameNameArray = strvcat(nifti_fname, nifti_fname);
spm_realign(FnameNameArray);
spm_reslice(FnameNameArray, para.spm_reslice_flags);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function dicom2nifti()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
