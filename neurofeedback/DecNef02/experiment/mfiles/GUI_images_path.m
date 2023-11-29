function [define, para, err] = GUI_images_path(define, para)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This will create a GUI that will get the directories of the 
% DICOM file‚ Template DICOM file, ROI file
% This was previously in the load_parameters() function but
% I took it out so that it could fasten the execution of the other
% instances that also rely on the the load_parameter() function.
% -VTD-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
err = struct('status', true, 'msg', []);

if err.status
  if define.files.STD_DIALOG_BOX	% This is currently not used

    % DICOM fileÌdirectory
    ret = uigetdir(para.files.data_top_dir, 'Select DICOM directory');
    if ret
      para.files.dicom_dir = ret;
      ret = true;
    end
    % Template image file‚directory
    ret = uigetdir(para.files.roi_top_dir, 'Select Template image directory');
    if ret
      para.files.templ_image_dir = ret;
      ret = true;
    end
    % ROI file‚directory
    if ret & para.files.roi_fnum
      ret = uigetdir(para.files.roi_top_dir, 'Select ROI directory');
      if ret
	para.files.roi_dir = ret;
	ret = true;
      end
    end
  else	%dialog box‚
    file_extensions = { '' };
    % DICOM file‚directory
    [ret, para.files.dicom_dir, fname] =yoyo_file_dialog(para.files.data_top_dir, file_extensions,'Select DICOM directory');
    % Template image file
    [ret, para.files.templ_image_dir, fname] =yoyo_file_dialog(para.files.roi_top_dir, file_extensions,'Select Template image directory');
    % ROI file‚directory
    if ret & para.files.roi_fnum
      [ret, para.files.roi_dir, fname] =yoyo_file_dialog(para.files.roi_top_dir, file_extensions,'Select ROI directory');
    end
  end	% <-- End of 'if define.files.STD_DIALOG_BOX ... else ...'
  
  
  % Make sure that these directory exist.
  if exist(para.files.dicom_dir, 'dir') ~= 7
    err.status = false;
    err.msg = sprintf('%s\n No such DICOM directory (''%s'')',...
	err.msg, para.files.dicom_dir);
  end
  if exist(para.files.templ_image_dir, 'dir') ~= 7
    err.status = false;
    err.msg = sprintf('%s\n No such Template image directory (''%s'')',...
	err.msg, para.files.templ_image_dir);
  end
  if para.files.roi_fnum & exist(para.files.roi_dir, 'dir') ~= 7
    err.status = false;
    err.msg = sprintf('%s\n No such ROI directory (''%s'')',...
	err.msg, para.files.roi_dir);
  end
  
  % DICOM info
  para = set_dicom_info(define, para);
  % Save name
  para.save_name = sprintf('%s_%s', para.dicom_info.patient_name, para.dicom_info.study_date);
  
  para.exp_id = sprintf('%s_%s', para.dicom_info.patient_name, para.dicom_info.patient_id);
  
  para.exp_date = para.dicom_info.study_date;
end