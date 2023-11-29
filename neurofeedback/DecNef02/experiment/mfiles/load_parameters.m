function [define, para, err] = load_parameters(define, para)

% This will create the GUI for the user to input the prameter file.
% Then, the info will be imported from that file in order to update the
% gData structure.

% Then, the GUI to select the DICOM file, Template image file and ROI file.
% will be set in the set_dir_para() function below.
%
% Then many parameters such as para.scans.total_scan_num will be computed
% in the last fnction called here named set_parameters().
%
% See the parameter file for more info on each parameters.

err = struct('status', false, 'msg', []);

% This will create the section file_dialog in the gData file.
if define.files.STD_DIALOG_BOX	
  [fname, dname, index] = uigetfile(sprintf('%s%s*%s',para.files.para_dir, filesep, define.files.PARA_FILE_EXTENSION),'Select Parameter file');
else				
  file_extensions = { define.files.PARA_FILE_EXTENSION };
  % This will create the GUI for the user to input the prameter file.
  [index, dname, fname] =yoyo_file_dialog(para.files.para_dir, file_extensions,'Select Parameter file');
  if index
    % This is to get the name of the parameter file out of the the GUI
    % answer.
    fname = char( fname{1} );
  end
end

if index
  para.files.para_dir = dname;		
  para.files.para_fname = fname;	

  % Load_para() is defined below.
  [para, err] = load_para(define, para, err);

  % Ifyou want to load a file of sham scores to display.
  if err.status &&para.score.score_mode == define.score_mode.SHAM_SCORE_FILE
    [para, err] = load_sham_score(define, para, err);
  end
  if err.status
    % set_dir_para() is defined below.
    [para, err] = set_dir_para(define, para, err);
  end
  if err.status
    % set_parameters() is defined below.
    para = set_parameters(define, para);
  else
    errordlg(err.msg, 'Error Dialog', 'modal');
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_parameters()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para, err] = load_para(define, para, err)

%This function will load the parameter file and read the values in it.
kaigyo = sprintf('\n');	
kaigyo_dos = 13;	
comment = '#';

% Get the name of the parameter file and open it.
para_fname = fullfile(para.files.para_dir, para.files.para_fname);
fd = fopen(para_fname, 'r');
if fd == -1
  err_msg = sprintf('FOPEN cannot open the file(%s)', para_fname);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
  err.status = false;
end

line_no = 0;
err.status = true;
err.msg = sprintf('%sin ''%s''\n', err.msg, para_fname);

DecNef_Project = define.DECNEF_PROJECT;	

% go through each line and get the info there.
while true
  str = fgets(fd);	
  line_no = line_no+1;	

  % If line is empty, break
  if str == -1, break;	% End of file
  else
    % Define if line is OK
    line_ok = false;
    
    if str(1) == comment | str(1) == kaigyo | str(1) == kaigyo_dos
      line_ok = true;
    end

    if strncmp(str, 'ProjectCode', length('ProjectCode'))
      value = yoyo_sscanf('ProjectCode=DecNef%d', str);
      if length(value)
	line_ok = true;
	DecNef_Project = value;
      end
    end	
    
    if strncmp(str, 'receiver_num', length('receiver_num'))
      value = yoyo_sscanf('receiver_num=%d', str);
      if length(value)
	line_ok = true;
	para.receiver_num = value;
      end
    end	
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % fMRI
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strncmp(str, 'denoising_method', length('denoising_method'))
      value = yoyo_sscanf('denoising_method=%s', str);
      if length(value)
	[denoising_method, ret] = get_field_value(value, define.denoising_method);
	if ret
	  line_ok = true;
	  para.denoising_method = denoising_method;
	end
      end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % directory
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'data_top_dir', length('data_top_dir'))
      % Data top directory (data_top_dir)
      value = yoyo_sscanf('data_top_dir=%s', str);
      if length(value)
	line_ok = true;
	para.files.data_top_dir = value;
      end
    end	
    if strncmp(str, 'roi_top_dir', length('roi_top_dir'))
      % ROI file‚Ìtop directory (roi_top_dir)
      value = yoyo_sscanf('roi_top_dir=%s', str);
      if length(value)
	line_ok = true;
	para.files.roi_top_dir = value;
      end
    end	
    if strncmp(str, 'save_dir', length('save_dir'))
      % Data store directory (save_dir)
      value = yoyo_sscanf('save_dir=%s', str);
      if length(value)
	line_ok = true;
	para.files.save_dir = value;
      end
    end	

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strncmp(str, 'roi_epi_threshold', length('roi_epi_threshold'))
      % ROI EPI data(roi_epi_threshold)
      value = yoyo_sscanf('roi_epi_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	line_ok = true;
	para.files.roi_epi_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('roi_epi_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.files.roi_epi_threshold = value;
      end
    end	
    
    if strncmp(str, 'roi_fname', length('roi_fname'))
      % ROI (fileroi_fname)
      value = array_of_struct('roi_fname[%d]=%s', str, 2)';
      if length(value) >= 2
	n = value(1);
	if n > para.files.roi_fnum	
	  roi_fname = cell(n,1);
	  for ii=1:para.files.roi_fnum
	    roi_fname{ii} = para.files.roi_fname{ii};
	  end
	  para.files.roi_fname = roi_fname;
	  roi_threshold = cell(n,1);
	  for ii=1:n
	    if ii<=para.files.roi_fnum
	      roi_threshold{ii} = para.files.roi_threshold{ii};
	    else
	      roi_threshold{ii} = define.files.ROI_THRESHOLD;
	    end
	  end
	  para.files.roi_threshold = roi_threshold;
	  para.files.roi_fnum = n;
    end	
    
	line_ok = true;
	para.files.roi_fname{n} = char(value(2:end));	
      end
    end	

    if strncmp(str, 'roi_threshold', length('roi_threshold'))
      flg = false;
      value = array_of_struct('roi_threshold[%d]=%s', str, 2);
      if length(value) >= 2
	if strncmp(char(value(2:end)),...
	      'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'));

	  n = value(1);					
	  threshold = define.files.ROI_THRESHOLD;	
	  flg = true;
	end
      end
      value = array_of_struct('roi_threshold[%d]=%f', str, 2);
      if length(value) == 2

	n = round(value(1));		
	threshold = value(2);		
	flg = true;
      end
      if flg
	if n > para.files.roi_fnum	

	  roi_fname = cell(n,1);
	  for ii=1:para.files.roi_fnum
	    roi_fname{ii} = para.files.roi_fname{ii};
	  end
	  para.files.roi_fname = roi_fname;

	  roi_threshold = cell(n,1);
	  for ii=1:n
	    if ii<=para.files.roi_fnum
	      roi_threshold{ii} = para.files.roi_threshold{ii};
	    else
	      roi_threshold{ii} = define.files.ROI_THRESHOLD;
	    end
	  end
	  para.files.roi_threshold = roi_threshold;

	  para.files.roi_fnum = n;
	end     
	line_ok = true;
	para.files.roi_threshold{n} = threshold;
      end	
    end	

    if strncmp(str, 'wm_fname', length('wm_fname'))
      value = yoyo_sscanf('wm_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.wm_fname = value;
      end
    end	
    
    if strncmp(str, 'wm_threshold', length('wm_threshold'))
      value = yoyo_sscanf('wm_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	line_ok = true;
	para.files.wm_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('wm_threshold=%f', str);
      if length(value)
	% Žw’è’lˆÈ?ã‚Ìvoxel‚ð?Ì—p‚·‚é?ðŒ?
	line_ok = true;
	para.files.wm_threshold = value;
      end
    end	% <-- End of 'wm_threshold'

    if strncmp(str, 'gs_fname', length('gs_fname'))
      % GS file–¼ (gs_fname)
      value = yoyo_sscanf('gs_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.gs_fname = value;
      end
    end	% <-- End of 'gs_fname'
    if strncmp(str, 'gs_threshold', length('gs_threshold'))
      % GS data‚Ìè‡’l (gs_threshold)
      value = yoyo_sscanf('gs_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% ”ñƒ[ƒ?—v‘f‚Ì‘S‚Ä‚Ìvoxel‚ð?Ì—p‚·‚é?ðŒ?
	line_ok = true;
	para.files.gs_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('gs_threshold=%f', str);
      if length(value)
	% Žw’è’lˆÈ?ã‚Ìvoxel‚ð?Ì—p‚·‚é?ðŒ?
	line_ok = true;
	para.files.gs_threshold = value;
      end
    end	% <-- End of 'gs_threshold'

    if strncmp(str, 'csf_fname', length('csf_fname'))
      % CSF file–¼ (csf_fname)
      value = yoyo_sscanf('csf_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.csf_fname = value;
      end
    end	% <-- End of 'csf_fname'
    if strncmp(str, 'csf_threshold', length('csf_threshold'))
      % CSF data‚Ìè‡’l (csf_threshold)
      value = yoyo_sscanf('csf_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% ”ñƒ[ƒ?—v‘f‚Ì‘S‚Ä‚Ìvoxel‚ð?Ì—p‚·‚é?ðŒ?
	line_ok = true;
	para.files.csf_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('csf_threshold=%f', str);
      if length(value)
	% Žw’è’lˆÈ?ã‚Ìvoxel‚ð?Ì—p‚·‚é?ðŒ?
	line_ok = true;
	para.files.csf_threshold = value;
      end
    end	% <-- End of 'csf_threshold'
    
    if strncmp(str, 'templ_image_fname', length('templ_image_fname'))
      % Template image file–¼ (templ_image_fname)
      value = yoyo_sscanf('templ_image_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.templ_image_fname = value;
      end
    end	% <-- End of 'templ_image_fname'
    
    if strncmp(str, 'MNI_trans_fname', length('MNI_trans_fname'))
      % MNI transformation file (VTD edit)
      value = yoyo_sscanf('MNI_trans_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.MNI_trans_fname = value;
      end
    end	% <-- End of 'MNI_trans_fname'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % fMRI‚Ìscan?ðŒ?‚ÉŠÖŒW‚·‚éƒpƒ‰ƒ??[ƒ^‚ðload‚·‚é?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'trial_num', length('trial_num'))
      % ŽŽ?s?” (trial_num)
      value = yoyo_sscanf('trial_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.trial_num = value;
      end
    end	% <-- End of 'trial_num'
    if strncmp(str, 'pre_trial_scan_num', length('pre_trial_scan_num'))
      % ŽŽ?s‚ðŠJŽn‚·‚é–˜‚Ìscan?” (pre_trial_scan_num)
      value = yoyo_sscanf('pre_trial_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.pre_trial_scan_num = value;
      end
    end	% <-- End of 'pre_trial_scan_num'
    if strncmp(str, 'prep_rest1_scan_num', length('prep_rest1_scan_num'))
      % 1ŽŽ?s–Ú‚Ì‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì1‚Ìscan?” (prep_rest1_scan_num)
      value = yoyo_sscanf('prep_rest1_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.prep_rest1_scan_num = value;
      end
    end	% <-- End of 'prep_rest1_scan_num'
    if strncmp(str, 'prep_rest2_scan_num', length('prep_rest2_scan_num'))
      % 1ŽŽ?s–Ú‚Ì‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì2‚Ìscan?” (prep_rest2_scan_num)
      value = yoyo_sscanf('prep_rest2_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.prep_rest2_scan_num = value;
      end
    end	% <-- End of 'prep_rest2_scan_num'
    if strncmp(str, 'rest_scan_num', length('rest_scan_num'))
      % REST?ðŒ?‚Ìscan?” (rest_scan_num)
      value = yoyo_sscanf('rest_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.rest_scan_num = value;
      end
    end	% <-- End of 'rest_scan_num'
    if strncmp(str, 'test_scan_num', length('test_scan_num'))
      % TEST?ðŒ?‚Ìscan?” (test_scan_num)
      value = yoyo_sscanf('test_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.test_scan_num = value;
      end
    end	% <-- End of 'test_scan_num'
    if strncmp(str, 'pre_test_delay_scan_num',...
	  length('pre_test_delay_scan_num'))
      % TEST?ðŒ?ŠJŽnŒã‚Ìdelay scan?” (pre_test_delay_scan_num)
      value = yoyo_sscanf('pre_test_delay_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.pre_test_delay_scan_num = value;
      end
    end	% <-- End of 'pre_test_delay_scan_num'
    if strncmp(str, 'post_test_delay_scan_num',...
	  length('post_test_delay_scan_num'))
      % TEST?ðŒ??I—¹Œã‚Ìdelay scan?” (post_test_delay_scan_num)
      value = yoyo_sscanf('post_test_delay_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.post_test_delay_scan_num = value;
      end
    end	% <-- End of 'post_test_delay_scan_num'
    if strncmp(str, 'calc_score_scan_num', length('calc_score_scan_num'))
      % “¾“_ŒvŽZ?ðŒ?‚Ìscan?” (calc_score_scan_num)
      value = yoyo_sscanf('calc_score_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.calc_score_scan_num = value;
      end
    end	% <-- End of 'calc_score_scan_num'
    if strncmp(str, 'feedbk_score_scan_num', length('feedbk_score_scan_num'))
      % “¾“_’ñŽ¦?ðŒ?‚Ìscan?” (feedbk_score_scan_num)
      value = yoyo_sscanf('feedbk_score_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.feedbk_score_scan_num = value;
      end
    end	% <-- End of 'feedbk_score_scan_num'
    if strncmp(str, 'TR', length('TR'))
      % ScanŠÔŠu (TR)
      value = yoyo_sscanf('TR=%f', str);
      if length(value)
	line_ok = true;
	para.scans.TR = value;
      end
    end	% <-- End of 'TR'
    if strncmp(str, 'regress_scan_num', length('regress_scan_num'))
      % fMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan?” (regress_scan_num)
      value = yoyo_sscanf('regress_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.regress_scan_num = value;
      end
    end	% <-- End of 'regress_scan_num'
    if strncmp(str, 'sleep_check_trial_num',...
	  length('sleep_check_trial_num'))
      % ”íŒŸŽÒ‚ª?Q‚Ä‚¢‚È‚¢‚©‚ðƒ`ƒFƒbƒN‚·‚éŽŽ?s?” (sleep_check_trial_num)
      value = yoyo_sscanf('sleep_check_trial_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.sleep_check_trial_num = value;
      end
    end	% <-- End of 'sleep_check_trial_num'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % “¾“_ŒvŽZ—pƒpƒ‰ƒ??[ƒ^‚ðload‚·‚é?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if strncmp(str, 'score_mode', length('score_mode'))
      % “¾“_ƒ‚?[ƒh (score_mode)
      value = yoyo_sscanf('score_mode=%s', str);
      if length(value)
	[score_mode, ret] = get_field_value(value, define.score_mode);
	if ret
	  line_ok = true;
	  para.score.score_mode = score_mode;
	end
      end
    end	% <-- End of 'score_mode'

    if strncmp(str, 'radius_of_brain', length('radius_of_brain'))
      % ”]‚Ì”¼Œa (radius_of_brain) (mm)
      value = yoyo_sscanf('radius_of_brain=%f', str);
      if length(value)
	line_ok = true;
	para.score.radius_of_brain = value;
      end
    end	% <-- End of 'radius_of_brain'
    
    if strncmp(str, 'FD_threshold',...
	  length('FD_threshold'))
      % Scan’†‚Ì”]‚ÌˆÚ“®—Ê‚Ìè‡’l (FD_threshold) (mm)
      value = yoyo_sscanf('FD_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.score.FD_threshold = value;
      end
    end	% <-- End of 'FD_threshold'
    
    if strncmp(str, 'corr_roi_template_threshold',...
	  length('corr_roi_template_threshold'))
      %  ROI template‚ÆROI‚Ì‘ŠŠÖŒW?”‚Ìè‡’l (corr_roi_template_threshold)
      value = yoyo_sscanf('corr_roi_template_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.score.corr_roi_template_threshold = value;
      end
    end	% <-- End of 'corr_roi_template_threshold'

    if strncmp(str, 'score_normrnd_mu', length('score_normrnd_mu'))
      % ?³‹K•ª•z—??”‚Ì•½‹Ï’lƒpƒ‰ƒ??[ƒ^ (normrnd_mu)
      value = yoyo_sscanf('score_normrnd_mu=%f', str);
      if length(value)
	line_ok = true;
	para.score.normrnd_mu = value;
      end
    end	% <-- End of 'score_normrnd_mu'
    if strncmp(str, 'score_normrnd_sigma', length('score_normrnd_sigma'))
      % ?³‹K•ª•z—??”‚Ì•W?€•Î?·ƒpƒ‰ƒ??[ƒ^ (normrnd_sigma)
      value = yoyo_sscanf('score_normrnd_sigma=%f', str);
      if length(value)
	line_ok = true;
	para.score.normrnd_sigma = value;
      end
    end	% <-- End of 'score_normrnd_sigma'
    if strncmp(str, 'score_limit', length('score_limit'))
      % “¾“_‚Ì‰ºŒÀ‚Æ?ãŒÀ‚Ìè‡’l (score_limit)
      value = yoyo_sscanf('score_limit=(%f,%f)', str);
      if length(value) == 2
	line_ok = true;
	para.score.score_limit(define.MIN) = min(value);
	para.score.score_limit(define.MAX) = max(value);
      end
    end	% <-- End of 'score_limit'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Ž‹Šofeedback‚ÉŠÖŒW‚·‚éƒpƒ‰ƒ??[ƒ^‚ðload‚·‚é?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'feedback_io_tool', length('feedback_io_tool'))
      % ŽŽ?sŠJŽnƒgƒŠƒK?[?M?†“™‚Ì“ü—Í‚âŽ‹Šofeedback?o—Í?æ“™‚Ì
      % “ü?o—Í—pƒc?[ƒ‹(feedback_io_tool)
      value = yoyo_sscanf('feedback_io_tool=%s', str);
      if length(value)
	[io_tool, ret] = get_field_value(value, define.feedback.io_tool);
	if ret
	  line_ok = true;
	  para.feedback.io_tool = io_tool;
	end
      end
    end	% <-- End of 'feedback_io_tool'

    if strncmp(str, 'feedback_type', length('feedback_type'))
      % Ž‹Šofeedback‚Ì’ñŽ¦ƒ^ƒCƒv (feedback_type)
      value = yoyo_sscanf('feedback_type=%s', str);
      if length(value)
	[feedback_type, ret] =...
	    get_field_value(value, define.feedback.feedback_type);
	if ret
	  line_ok = true;
	  para.feedback.feedback_type = feedback_type;
	end
      end
    end	% <-- End of 'feedback_type'
    if strncmp(str, 'feedback_score_timing', length('feedback_score_timing'))
      % “¾“_‚ð”íŒŸŽÒ‚É’ñŽ¦‚·‚éƒ^ƒCƒ~ƒ“ƒO (feedback_score_timing)
      value = yoyo_sscanf('feedback_score_timing=%s', str);
      if length(value)
	[feedback_score_timing, ret] =...
	    get_field_value(value, define.feedback.feedback_score_timing);
	if ret
	  line_ok = true;
	  para.feedback.feedback_score_timing = feedback_score_timing;
	end
      end
    end	% <-- End of 'feedback_score_timing'
    if strncmp(str, 'feedback_screen', length('feedback_screen'))
      % Ž‹ŠoŽhŒƒ‚ð’ñŽ¦‚·‚éscreen”Ô?† (feedback_screen)
      value = yoyo_sscanf('feedback_screen=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.screen = value;
      end
    end	% <-- End of 'feedback_screen'
    if strncmp(str, 'feedback_prep_rest1_comment',...
	  length('feedback_prep_rest1_comment'))
      % 1ŽŽ?s–Ú‚Ì‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì1‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ
      % (feedback_prep_rest1_comment)
      value = yoyo_sscanf('feedback_prep_rest1_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_rest1_comment = value;
      end
    end	% <-- End of 'feedback_prep_rest1_comment'
    if strncmp(str, 'feedback_prep_rest2_comment',...
	  length('feedback_prep_rest2_comment'))
      % 1ŽŽ?s–Ú‚Ì‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì2‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ
      % (feedback_prep_rest2_comment)
      value = yoyo_sscanf('feedback_prep_rest2_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_rest2_comment = value;
      end
    end	% <-- End of 'feedback_prep_rest2_comment'
    if strncmp(str, 'feedback_rest_comment', length('feedback_rest_comment'))
      % REST?ðŒ?‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ (feedback_rest_comment)
      value = yoyo_sscanf('feedback_rest_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.rest_comment = value;
      end
    end	% <-- End of 'feedback_rest_comment'
    if strncmp(str, 'feedback_test_comment', length('feedback_test_comment'))
      % TEST?ðŒ?‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ (feedback_test_comment)
      value = yoyo_sscanf('feedback_test_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.test_comment = value;
      end
    end	% <-- End of 'feedback_test_comment'
    if strncmp(str, 'feedback_prep_score_comment',...
	  length('feedback_prep_score_comment'))
      % TEST?ðŒ?‚ª?I—¹‚µ‚½Œã?A“¾“_‚ð’ñŽ¦‚·‚é‚Ü‚Å‚ÌŠÔ‚Ì
      % ?ðŒ?‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ (feedback_prep_score_comment)
      value = yoyo_sscanf('feedback_prep_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_score_comment = value;
      end
    end	% <-- End of 'feedback_prep_score_comment'
    if strncmp(str, 'feedback_score_comment', length('feedback_score_comment'))
      % “¾“_’ñŽ¦?ðŒ?‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ (feedback_score_comment)
      value = yoyo_sscanf('feedback_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.score_comment = value;
      end
    end	% <-- End of 'feedback_score_comment'
    if strncmp(str, 'feedback_ng_score_comment',...
	  length('feedback_ng_score_comment'))
      % “¾“_‚ÌŒvŽZ?ˆ—?•s‰ÂŽž‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ (feedback_ng_score_comment)
      value = yoyo_sscanf('feedback_ng_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.ng_score_comment = value;
      end
    end	% <-- End of 'feedback_ng_score_comment'
    if strncmp(str, 'feedback_finished_block_comment',...
	  length('feedback_finished_block_comment'))
      % ƒuƒ?ƒbƒN?I—¹?ðŒ?‚Å‚ÌƒRƒ?ƒ“ƒg•¶Žš—ñ (feedback_finished_block_comment)
      value = yoyo_sscanf('feedback_finished_block_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.finished_block_comment = value;
      end
    end	% <-- End of 'feedback_finished_block_comment'
    if strncmp(str, 'feedback_finished_block_duration',...
	  length('feedback_finished_block_duration'))
      % ƒuƒ?ƒbƒN?I—¹?ðŒ?‚ÌŽ‹Šofeedback‚Ì’ñŽ¦ŽžŠÔ(sec) (finished_block_duration)
      value = yoyo_sscanf('feedback_finished_block_duration=%f', str);
      if length(value)
	line_ok = true;
	para.feedback.finished_block_duration = value;
      end
    end	% <-- End of 'feedback_finished_block_duration'
    if strncmp(str, 'feedback_gaze_frame_r', length('feedback_gaze_frame_r'))
      % ’?Ž‹“_‚Ì”¼Œa(‰~ŒÊ ˜g) (feedback_gaze_frame_r)
      value = yoyo_sscanf('feedback_gaze_frame_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.gaze_frame_r = value;
      end
    end	% <-- End of 'feedback_gaze_frame_r'
    if strncmp(str, 'feedback_gaze_fill_r', length('feedback_gaze_fill_r'))
      % ’?Ž‹“_‚Ì”¼Œa(‰~ŒÊ “h) (feedback_gaze_fill_r)
      value = yoyo_sscanf('feedback_gaze_fill_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.gaze_fill_r = value;
      end
    end	% <-- End of 'feedback_gaze_fill_r'
    if strncmp(str, 'feedback_sleep_fill_r', length('feedback_sleep_fill_r'))
      % ’?Ž‹“_‚Ì”¼Œa(?Q‚Ä‚¢‚È‚¢‚©ƒ`ƒFƒbƒN—p) (feedback_sleep_fill_r)
      value = yoyo_sscanf('feedback_sleep_fill_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.sleep_fill_r = value;
      end
    end	% <-- End of 'feedback_sleep_fill_r'
    if strncmp(str, 'feedback_max_score_r', length('feedback_max_score_r'))
      % “¾“_‚Ì?ãŒÀ’l‚Å‚Ì“¾“_‚ð’ñŽ¦‚·‚é‰~‚Ì”¼Œa (feedback_max_score_r)
      value = yoyo_sscanf('feedback_max_score_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.max_score_r = value;
      end
    end	% <-- End of 'feedback_max_score_r'


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stanford sleepiness scale(ƒXƒ^ƒ“ƒtƒH?[ƒh–°‹CŽÚ“x)
    % ‚ÉŠÖŒW‚·‚éƒpƒ‰ƒ??[ƒ^‚ðload‚·‚é?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'sss_flag', length('sss_flag'))
      % Stanford–°‹CŽÚ“xŽ¿–âƒtƒ‰ƒO (sss_flag)
      value = yoyo_sscanf('sss_flag=%d', str);
      if length(value)
	line_ok = true;
	para.sss.sss_flag = logical(value);
      end
    end	% <-- End of 'sss_flag'
    if strncmp(str, 'sss_image_dir', length('sss_image_dir'))
      % Stanford–°‹CŽÚ“xŽ¿–â‰æ‘œfile‚Ìdirectory (sss_image_dir)
      value = yoyo_sscanf('sss_image_dir=%s', str);
      if length(value)
	line_ok = true;
	para.sss.sss_image_dir = value;
      end
    end	% <-- End of 'sss_image_dir'
    if strncmp(str, 'sss_image_fname', length('sss_image_fname'))
      % Stanford–°‹CŽÚ“xŽ¿–â‰æ‘œfile–¼ (sss_image_fname)
      value = yoyo_sscanf('sss_image_fname=%s', str);
      if length(value)
	line_ok = true;
	para.sss.sss_image_fname = value;
      end
    end	% <-- End of 'sss_image_fname'


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    if strncmp(str, 'roi_vol_graph_flag', length('roi_vol_graph_flag'))
      % ROI volume graph•\Ž¦ƒtƒ‰ƒO (roi_vol_graph_flag)
      value = yoyo_sscanf('roi_vol_graph_flag=%d', str);
      if length(value)
	line_ok = true;
	para.roi_vol_graph_flag = logical(value);
      end
    end	% <-- End of 'roi_vol_graph_flag'
    
    
    if line_ok == false		% •s?³‚È?s‚ð”­Œ©‚µ‚½?B
      % ƒGƒ‰?[ƒ?ƒbƒZ?[ƒW‚ð?X?V‚·‚é?B
      err.status = false;
      err.msg = sprintf('%s ERROR %3d : %s', err.msg, line_no, str);
    end
  end	% <-- End of 'if str == -1 ... else'
end	% <-- End of 'while(true)'

fclose(fd);


if err.status
  % Parameterƒtƒ@ƒCƒ‹‚É‹L?q‚³‚ê‚Ä‚¢‚éŽÀŒ±ƒpƒ‰ƒ??[ƒ^‚Ì?®?‡?«‚ðŒŸ?Ø‚·‚é?B

  if DecNef_Project ~= define.DECNEF_PROJECT;
    % DecNefŽÀŒ±ƒvƒ?ƒWƒFƒNƒgƒR?[ƒh‚É•s?³’l‚ð?Ý’è‚µ‚½?B
    err.status = false;
    err.msg = sprintf(...
	'%s ERROR : Invalid value is set for ''ProjectCode''.\n',...
	err.msg);
    err.msg = sprintf('%s \t ProjectCode = DecNef%d\n',...
	err.msg, DecNef_Project);
  end	% <-- End of 'if DecNef_Project ~= define.DECNEF_PROJECT'


  if para.denoising_method == define.denoising_method.REGRESS
    % fMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚ð‘½?d?üŒ`‰ñ‹A‚ÌŽc?·
    % (regressŠÖ?”‚ð—˜—p‚·‚é)‚Å?s‚È‚¤?ðŒ?‚Ìƒpƒ‰ƒ??[ƒ^
    % ‚ðƒ`ƒFƒbƒN‚·‚é?B

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 'ƒmƒCƒY?œ‹Ž?ˆ—?‚ð‘½?d?üŒ`‰ñ‹A‚ÌŽc?·‚Å?s‚È‚¤?ðŒ?' ‚Å
    % '”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ‚·‚é?ðŒ?' ‚Ì?ê?‡
    % 	-> WM file, GS file, CSF file‚ðŽw’è‚µ‚È‚¯‚ê‚Î‚È‚ç‚È‚¢
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if para.score.score_mode == define.score_mode.CALC_SCORE &... 
	  isempty( para.files.wm_fname)
      % '”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ‚·‚é?ðŒ?' ‚Å 'WM file–¼‚ª–¢?Ý’è' ‚Ì?ê?‡
      err.status = false;
      err.msg = sprintf('%s ERROR : ''wm_fname'' is not set..\n',...
	  err.msg);
      err.msg = sprintf(...
	  '%s ERROR : For REGRESS condition(denoising_method=%s)\n',...
	  err.msg,...
	  get_field_name(para.denoising_method, define.denoising_method));
      err.msg = sprintf(...
	  '%s ERROR : the WM file must be specified.\n', err.msg);
      err.msg = sprintf('%s \t wm_fname = ''%s''\n',...
	  err.msg, para.files.wm_fname);
    end	% <-- End of 'if score_mode==CALC_SCORE&isempty( para.files.wm_fname)'
    if para.score.score_mode == define.score_mode.CALC_SCORE &... 
	  isempty( para.files.gs_fname)
      % '”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ‚·‚é?ðŒ?' ‚Å 'GS file–¼‚ª–¢?Ý’è' ‚Ì?ê?‡
      err.status = false;
      err.msg = sprintf('%s ERROR : ''gs_fname'' is not set..\n',...
	  err.msg);
      err.msg = sprintf(...
	  '%s ERROR : For REGRESS condition(denoising_method=%s)\n',...
	  err.msg,...
	  get_field_name(para.denoising_method, define.denoising_method));
      err.msg = sprintf(...
	  '%s ERROR : the GS file must be specified.\n', err.msg);
      err.msg = sprintf('%s \t wm_fname = ''%s''\n',...
	  err.msg, para.files.wm_fname);
    end	% <-- End of 'if score_mode==CALC_SCORE&isempty( para.files.gs_fname)'
    if para.score.score_mode == define.score_mode.CALC_SCORE &... 
	  isempty( para.files.csf_fname)
      % '”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ‚·‚é?ðŒ?' ‚Å 'CSF file–¼‚ª–¢?Ý’è' ‚Ì?ê?‡
      err.status = false;
      err.msg = sprintf('%s ERROR : ''csf_fname'' is not set..\n',...
	  err.msg);
      err.msg = sprintf(...
	  '%s ERROR : For REGRESS condition(denoising_method=%s)\n',...
	  err.msg,...
	  get_field_name(para.denoising_method, define.denoising_method));
      err.msg = sprintf(...
	  '%s ERROR : the CSF file must be specified.\n', err.msg);
      err.msg = sprintf('%s \t wm_fname = ''%s''\n',...
	  err.msg, para.files.wm_fname);
    end	% <-- End of 'if score_mode==CALC_SCORE&isempty( para.files.csf_fname)'

    
    if para.scans.regress_scan_num <...
	  para.scans.prep_rest1_scan_num +...
	  para.scans.prep_rest2_scan_num +...
	  para.scans.rest_scan_num +...
	  para.scans.test_scan_num +...
	  para.scans.post_test_delay_scan_num
      % fMRIƒf?[ƒ^‚ÌƒmƒCƒY?œ‹Ž?ˆ—?‚É—˜—p‚·‚éscan?”‚É•s?³’l‚ð?Ý’è‚µ‚½?B
      % ‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì1‚Ìscan?”(prep_rest1_scan_num) + 
      % ‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì2‚Ìscan?”(prep_rest2_scan_num) + 
      % REST?ðŒ?‚Ìscan?”(rest_scan_num) + 
      % TEST?ðŒ?‚Ìscan?”(test_scan_num) +
      % TEST?ðŒ??I—¹Œã‚Ìdelay scan?”(post_test_delay_scan_num)
      % ˆÈ?ã‚Å‚È‚¯‚ê‚Î‚È‚ç‚È‚¢?B
      % ( create_global.m“à‚Ìcreate_para()‚ÌƒRƒ?ƒ“ƒg‚ðŽQ?Æ )
      err.status = false;
      err.msg = sprintf(...
	  '%s ERROR : Invalid value is set for ''regress_scan_num''.\n',...
	  err.msg);
      err.msg = sprintf(...
	  '%s ERROR : ''prep_rest1_scan_num'' + ''prep_rest2_scan_num'' + ''rest_scan_num'' + ''test_scan_num'' + ''post_test_delay_scan_num''\n',...
	  err.msg);
      err.msg = sprintf('%s ERROR : Please set a value above the above value.\n', err.msg);
      err.msg = sprintf('%s \t regress_scan_num = %d\n',...
	  err.msg, para.scans.regress_scan_num);
      err.msg = sprintf('%s \t prep_rest1_scan_num = %d\n',...
	  err.msg, para.scans.prep_rest1_scan_num);
      err.msg = sprintf('%s \t prep_rest2_scan_num = %d\n',...
	  err.msg, para.scans.prep_rest2_scan_num);
      err.msg = sprintf('%s \t rest_scan_num = %d\n',...
	  err.msg, para.scans.rest_scan_num);
      err.msg = sprintf('%s \t test_scan_num = %d\n',...
	  err.msg, para.scans.test_scan_num);
      err.msg = sprintf('%s \t post_test_delay_scan_num = %d\n',...
	  err.msg, para.scans.post_test_delay_scan_num);
    end	% <-- End of 'para.scans.regress_scan_num <...'
  
  end	% <-- End of 'if para.denoising_method == REGRESS'
  
  
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ROI file‚Ì?”‚ðƒ`ƒFƒbƒN‚·‚é?B
  % ------------------------------------------------------------
  % ”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ‚·‚é?ðŒ?
  % (para.score.score_mode=CALC_SCORE)‚Ì?ê?‡
  % 	-> ROI file‚ðŽw’è‚µ‚È‚¯‚ê‚Î‚È‚ç‚È‚¢?B
  % ”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ?ðŒ? 'ˆÈŠO'‚Ì?ðŒ?‚Ì?ê?‡
  % 	-> ROI file‚ðŽw’è‚µ‚Ä‚¢‚È‚­‚Ä‚à‚æ‚¢?B
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if para.score.score_mode == define.score_mode.CALC_SCORE &... 
      para.files.roi_fnum == 0
    % ”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ‚·‚é?ðŒ?(para.score.score_mode=CALC_SCORE)
    % ‚ÅROI file‚ðŽw’è‚µ‚Ä‚¢‚È‚¢(ROI file?”‚ª0)
    err.status = false;
    err.msg = sprintf(...
	'%s ERROR : Invalid value is set for ''roi_fnum''.\n', err.msg);
    err.msg = sprintf(...
	'%s ERROR : For the CALC_SCORE condition(score_mode=CALC_SCORE), \n',...
	err.msg);
    err.msg = sprintf(...
	'%s ERROR : you must specify the ROI file.\n', err.msg);
    err.msg = sprintf('%s \t roi_fnum = %d\n', err.msg, para.files.roi_fnum);
  end	% <-- End of 'if score_mode == CALC_SCORE & para.files.roi_fnum == 0'

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % ROI file‚ÌŠg’£Žq‚ðƒ`ƒFƒbƒN‚·‚é?B
  %  ------------------------------------------------------------
  % ROI file‚ÌŠg’£Žq‚Æ‚µ‚Ä‹–‰Â‚³‚ê‚½•¶Žš—ñ‚Í?A
  % define.files.ROI_FILE_EXTENSION‚É?Ý’è‚³‚ê‚Ä‚¢‚é?B
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for roi=1:para.files.roi_fnum
    if isempty(para.files.roi_fname{roi})
      % ROI file‚ðŽw’è‚µ‚Ä‚¢‚È‚¢?B
      err.status = false;
      err.msg = sprintf(...
	  '%s ERROR : ''roi_fname[%d]'' is not set..\n',err.msg, roi);
    else
      % ROI file‚ÌŠg’£Žq‚ðŠl“¾‚·‚é?B
      [pathstr,name,ext] = fileparts( para.files.roi_fname{roi} );
      if length( find( strcmpi(ext , define.files.ROI_FILE_EXTENSION) ) )==0
	% ROI file–¼‚ÌŠg’£Žq‚É•s?³‚È•¶Žš—ñ‚ðŽw’è‚µ‚Ä‚¢‚é?B
	err.status = false;
	err.msg = sprintf(...
	    '%s ERROR : ''Invalid value is set for roi_fname[%d]''.\n',...
	    err.msg, roi);
	extension = sprintf('''%s'', ', define.files.ROI_FILE_EXTENSION{:});
	err.msg = sprintf(...
	    '%s ERROR : Please specify the extension of ROI file from %s.\n',...
	    err.msg, extension(1:end-2));
	    
	err.msg = sprintf('%s \t roi_fname[%d] = %s\n',...
	    err.msg, roi, para.files.roi_fname{roi});
      end
    end	% <-- End of 'if isempty(para.files.roi_fname{roi}) ... else'
  end	% <-- End of 'for roi=1:para.files.roi_fnum'
  

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Template imageƒtƒ@ƒCƒ‹‚ÌŠg’£Žq‚ðƒ`ƒFƒbƒN‚·‚é?B
  %  ------------------------------------------------------------
  % Template imageƒtƒ@ƒCƒ‹‚Í
  % DICOM file(Šg’£Žq:define.files.DICOM_FILE_EXTENSION) ‚©
  % NIfTI file(Šg’£Žq:define.files.NIFTI_FILE_EXTENSION)
  % ‚Å‚È‚¯‚ê‚Î‚È‚ç‚È‚¢
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [pathstr, templ_name, templ_ext] = fileparts(para.files.templ_image_fname);
  tmp = sum( strcmp(templ_ext, define.files.DICOM_FILE_EXTENSION) ) +...
      sum( strcmp(templ_ext, define.files.NIFTI_FILE_EXTENSION) );
  if tmp == 0
    err.status = false;
    % Template image file‚ÌŠg’£Žq‚ª•s?³
    err.msg = sprintf(...
	'%s ERROR : The extension of the templ_image_fname is invalid.\n',...
	err.msg);
    err.msg = sprintf(...
	'%s ERROR : The templ_image_fname must be in DICOM or NIfTI format. \n',...
	err.msg);
    err.msg = sprintf('%s \t templ_image_fname = %s\n',...
	err.msg, para.files.templ_image_fname);
  end
  

  if para.scans.sleep_check_trial_num > para.scans.trial_num
    % ”íŒŸŽÒ‚ª?Q‚Ä‚¢‚È‚¢‚©‚ðƒ`ƒFƒbƒN‚·‚éŽŽ?s?”‚É•s?³’l‚ð?Ý’è‚µ‚½?B
    % (ŽŽ?s?”‚æ‚è‘å‚«‚È’l‚ð?Ý’è‚µ‚Ä‚¢‚é?B)
    err.status = false;
    err.msg = sprintf(...
	'%s ERROR : Invalid value is set for ''sleep_check_trial_num''.\n',...
	err.msg);
    err.msg = sprintf(...
	'%s ERROR : A larger value than ''trial_num'' is set..\n',...
	err.msg);
    err.msg = sprintf('%s \t sleep_check_trial_num = %d\n',...
	err.msg, para.scans.sleep_check_trial_num);
    err.msg = sprintf('%s \t trial_num = %d\n',...
	err.msg, para.scans.trial_num);
  end	% <-- End of 'if sleep_check_trial_num > trial_num'
  
  % Ž‹ŠoŽhŒƒ‚ð’ñŽ¦‚·‚éscreen”Ô?†‚ðƒ`ƒFƒbƒN‚·‚é?B
  % (PC‚É?Ú‘±‚³‚ê‚Ä‚¢‚éScreen?”‚ðŠl“¾‚µ?AŽ‹ŠoŽhŒƒ
  %  ‚ð’ñŽ¦‚·‚éscreen”Ô?†‚ð”»’è‚·‚é?B)
  switch para.feedback.io_tool
    case define.feedback.io_tool.PSYCHTOOLBOX
      % ŽŽ?sŠJŽnƒgƒŠƒK?[?M?†“™‚Ì“ü—Í‚âŽ‹Šofeedback?o—Í?æ“™‚Ì
      % “ü?o—Í—pƒc?[ƒ‹‚ÉPsychtoolbox‚ð—˜—p‚·‚é
      screenNumber = max( Screen('Screens') );
    case define.feedback.io_tool.MATLAB
      % ŽŽ?sŠJŽnƒgƒŠƒK?[?M?†“™‚Ì“ü—Í‚âŽ‹Šofeedback?o—Í?æ“™‚Ì
      % “ü?o—Í—pƒc?[ƒ‹‚ÉMATLAB‚ð—˜—p‚·‚é
      screenNumber = size( get(0, 'MonitorPositions'), 1 );
    case define.feedback.io_tool.DO_NOT_USE
      % ŽŽ?sŠJŽnƒgƒŠƒK?[?M?†“™‚Ì“ü—Í‚âŽ‹Šofeedback?o—Í‚ð
      % ?s‚È‚í‚È‚¢
      screenNumber = intmax;	% ?®?”‚Ì?Å‘å’l‚ð‘ã“ü‚µ‚Ä‚¨‚­?B
  end	% <-- End of 'para.feedback.io_tool'
  if para.feedback.screen < 0 | para.feedback.screen > 2
    % Ž‹ŠoŽhŒƒ‚ð’ñŽ¦‚·‚éscreen”Ô?†‚É”ÍˆÍŠO‚Ì’l‚ð?Ý’è‚µ‚½?B
    err.status = false;
    err.msg = sprintf(...
	'%s ERROR : ''feedback_screen'' is illegal value.\n', err.msg);
    err.msg = sprintf('%s \t feedback_screen = %d\n',...
	err.msg, para.feedback.screen);
    err.msg = sprintf('%s \t permit limit (%d - %d)\n', err.msg,...
	1,  screenNumber);
    err.msg = sprintf('%s \t number of Screen = %d\n',...
	err.msg, screenNumber);
  end
  
end	% <-- End of 'if err.status'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_para()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [value] = array_of_struct(format, str, num)
% function [value] = array_of_struct(format, str, num)
% ?\‘¢‘Ì”z—ñ—pƒpƒ‰ƒ??[ƒ^•¶Žš—ñ(str)‚ª•¶Žš—ñ?ðŒ?(format)‚É
% ˆê’v‚·‚é‚©Šm”F‚·‚é?B
% 
% ?\‘¢‘Ì”z—ñ—pƒpƒ‰ƒ??[ƒ^•¶Žš—ñ‚Í?A
% 
% [1] ?\‘¢‘Ì–¼[”z—ñ”Ô?†]=’l
%   str = 'SwitchDuration[4]=0.75'
%   format = 'SwitchDuration[%d]=%f'
%     -> value = [4.0, 0.75]
% 
% [2] ?\‘¢‘Ì–¼[”z—ñ”Ô?†].ƒ?ƒ“ƒo•Ï?”–¼=’l
%   str = 'sequence[1].dynamics=DYNAMICS5'
%   format = 'sequence[%d].dynamics=DYNAMICS%d'
%     -> value = [1, 5]
% 
% [3] ?\‘¢‘Ì–¼[”z—ñ”Ô?†]=(’l1,’l2)
%   str = 'target_pos_task[1]=(0.000,-0.10)'
%   format = 'target_pos_task[%d]=(%f,%f)'
%     -> value = [1.0, 0.0, -0.1]
% 
% [4] ?\‘¢‘Ì–¼[”z—ñ”Ô?†].ƒ?ƒ“ƒo•Ï?”–¼=(’l1,’l2)
%   str = 'tsequence[1].start_target=(4, 3)'
%   format = 'tsequence[%d].start_target=(%d,%d)'
%     -> value = [1, 4, 3]
% 
% ‚ÌŒ^Ž®‚Å‹L?q‚³‚Ä‚¢‚é‚à‚Ì‚Æ‚·‚é?B
% ?¬Œ÷‚Ì?ê?‡?A•Ô‚è’l(value)‚É‚ÍnumŒÂ‚Ì?”’l‚ª?Ý’è‚³‚ê‚é?B
% 1ŒÂ–Ú‚ª”z—ñ”Ô?†?A2ŒÂ–ÚˆÈ?~‚ª?Ý’è’l
% 
% 
%
% **** ’?ˆÓ!! ****
% •¶Žš—ñ?ðŒ?(format)‚Ì'='‚Ì‘OŒã‚ÉƒXƒy?[ƒX‚ð‘}“ü‚µ‚Ä‚Í‚¢‚¯‚È‚¢?B
% 
% **** ’?ˆÓ!! ****
% array_of_struct()“à‚Å?A•¶Žš—ñ(str)“à‚Ì '=' , '[' , ']' , '(' , ')' •¶Žš
% ‚Ì‘OŒã‚ÌƒXƒy?[ƒX‚ð?í?œ‚·‚é?B
% 
% [input argument]
% format : •¶Žš—ñ?ðŒ?
%          sprintf()‚Ì•¶Žš—ñ?ðŒ?Ž®‚Æ“¯—l‚ÌŒ`Ž®‚¾‚ª?A
%          •¶Žš—ñ?ðŒ?(format)‚Ì '=','[',']','(',')'‚Ì‘OŒã‚ÉƒXƒy?[ƒX
%          ‚ð‘}“ü‚µ‚Ä‚Í‚¢‚¯‚È‚¢?B
% str : ?\‘¢‘Ì”z—ñ—pƒpƒ‰ƒ??[ƒ^•¶Žš—ñ
% num : ƒpƒ‰ƒ??[ƒ^’l‚Ì?”
% 
% [output argument]
% value : ƒpƒ‰ƒ??[ƒ^’l

value = sscanf(str, format);
% •¶Žš—ñ?ðŒ?(format)‚Éˆê’v‚µ‚È‚¢?ê?‡?A•¶Žš—ñ(str)“à‚Ì
% '=' , '[' , ']' , '(' , ')' •¶Žš‚Ì‘OŒã‚ÌƒXƒy?[ƒX‚ð?í?œ‚µ‚ÄŒŸ?õ‚·‚é?B
% str = 'sequence[ 0 ].trial_num = 1' -> 'sequence[0].trial_num=1'
if length(value) < num & findstr(str,' =')
  str( findstr(str,' =') ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,'= ')
  str( findstr(str,'= ')+1 ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,' [')
  str( findstr(str,' [') ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,'[ ')
  str( findstr(str,'[ ')+1 ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,' ]')
  str( findstr(str,' ]') ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,'] ')
  str( findstr(str,'] ')+1 ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,' (')
  str( findstr(str,' (') ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,'( ')
  str( findstr(str,'( ')+1 ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,' )')
  str( findstr(str,' )') ) = [];
  value = array_of_struct(format, str, num);
end
if length(value) < num & findstr(str,') ')
  str( findstr(str,') ')+1 ) = [];
  value = array_of_struct(format, str, num);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function array_of_struct()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para, err] = load_sham_score(define, para, err)
% function [para, err] = load_sham_score(define, para, err)
% File dialog‚ð—p‚¢‚ÄSham scoreƒtƒ@ƒCƒ‹‚ð‘I‘ð‚µ?A
% Sham scoreƒtƒ@ƒCƒ‹‚©‚ç“¾“_‚ð“Ç‚Þ?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% para : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% err : ƒGƒ‰?[?î•ñ
% 
% [output argument]
% para : ƒpƒ‰ƒ??[ƒ^’l‚ð?Ý’èŒã‚ÌŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% err : ƒGƒ‰?[?î•ñ

kaigyo = sprintf('\n');		% ‰ü?s•¶Žš
kaigyo_dos = 13;		% ‰ü?s•¶Žš (DOS)
comment = '#';			% ƒRƒ?ƒ“ƒg?s‚Ì?æ“ª•¶Žš

% File dialog‚ð—p‚¢‚ÄSham score file‚ð‘I‘ð‚·‚é?B
if define.files.STD_DIALOG_BOX  % MATLAB•W?€‚Ìdialog box‚ð—p‚¢‚é
  [fname, dname, index] = uigetfile(...
      sprintf('%s%s*%s',...
      para.files.para_dir, filesep, define.files.SHAM_SCORE_FILE_EXTENSION),...
      'Select Sham score file');
else				% “ÆŽ©ŠJ”­‚Ìdialog box‚ð—p‚¢‚é
  file_extensions = { define.files.SHAM_SCORE_FILE_EXTENSION };
  [index, dname, fname] =...
      yoyo_file_dialog(para.files.para_dir, file_extensions,...
      'Select Sham score file');
  if index
    fname = char( fname{1} );	% cell”z—ñ‚©‚ç•¶Žš—ñ‚É•ÏŠ·‚·‚é?B
  end
end

% Sham score file‚Ìdirectory–¼‚Æfile–¼‚ð?X?V‚·‚é?B
if index
  para.files.sham_score_dir = dname;
  para.files.sham_score_fname = fname;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sham scoreƒtƒ@ƒCƒ‹‚©‚ç“¾“_‚ð“Ç‚Þ?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sham_score_filename =...
    fullfile(para.files.sham_score_dir, para.files.sham_score_fname);
fd = fopen(sham_score_filename, 'r');
if fd == -1
  err.msg = sprintf(...
      '%s ERROR : FOPEN cannot open the Sham score file(''%s'')\n',...
      err.msg, sham_score_filename);
  err.status = false;
else
  line_no = 0;		% ?s”Ô?†
  err.msg = sprintf('%sin ''%s''\n', err.msg, sham_score_filename);
  
  para.score.sham_score = nan(para.scans.trial_num, 1);
  
  while true
    str = fgets(fd);		% 1?s“Ç‚Ý?o‚·?B
    line_no = line_no+1;	% ?s”Ô?†‚ð?X?V‚·‚é?B
    
    if str == -1, break;	% End of file
    else
      line_ok = false;
      
      if str(1) == comment | str(1) == kaigyo | str(1) == kaigyo_dos
	line_ok = true;	% ƒRƒ?ƒ“ƒg?s, ‹ó”’?s
      end
      
      if strncmp(str, 'sham_score', length('sham_score'))
	value = array_of_struct('sham_score[%d]=%f', str, 2);
	if length(value) == 2
	  n = round(value(1));				% ŽŽ?s”Ô?†
	  if n <= para.scans.trial_num
	    para.score.sham_score(n) = value(2);	% “¾“_
	  end
	  line_ok = true;
	end
      end
      
      if line_ok == false		% •s?³‚È?s‚ð”­Œ©‚µ‚½?B
	% ƒGƒ‰?[ƒ?ƒbƒZ?[ƒW‚ð?X?V‚·‚é?B
	err.status = false;
	err.msg = sprintf('%s ERROR %3d : %s', err.msg, line_no, str);
      end
    end	% <-- End of 'if str == -1 ... else'
  end	% <-- End of 'while(true)'
  
  fclose(fd);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_sham_score()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para, err] = set_dir_para(define, para, err)
% function [para, err] = set_dir_para(define, para, err)
% directory‚ÉŠÖŒW‚·‚éƒpƒ‰ƒ??[ƒ^‚ð?Ý’è‚·‚é?B
% 
% Parameterƒtƒ@ƒCƒ‹‚©‚ç“Ç‚Ý?ž‚ñ‚¾directory‚ÉŠÖŒW‚·‚é
% ƒpƒ‰ƒ??[ƒ^‚Ì?®?‡?«ƒ`ƒFƒbƒN(Directory‚ª‘¶?Ý‚·‚é‚©)‚Æ?A
% DICOM file, Template image file‚ÆROI file‚Ìdirectory
% ‚ð?Ý’è‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% para : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% err : ƒGƒ‰?[?î•ñ
% 
% [output argument]
% para : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% err : ƒGƒ‰?[?î•ñ

err.msg = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data_top_dir–¼‚ð?â‘ÎƒpƒX‚É•ÏŠ·‚·‚é?B
[status, pathinfo] = fileattrib(para.files.data_top_dir);
if status
  para.files.data_top_dir = pathinfo.Name;
else
  % ƒGƒ‰?[ƒ?ƒbƒZ?[ƒW‚ð?X?V‚·‚é?B
  err.status = false;
  err.msg = sprintf('%s\n %s (data_top_dir : ''%s'')',err.msg, pathinfo, para.files.data_top_dir);
end
% ROI top directory‚ð?â‘ÎƒpƒX‚É•ÏŠ·‚·‚é?B
[status, pathinfo] = fileattrib(para.files.roi_top_dir);
if status
  para.files.roi_top_dir = pathinfo.Name;
else
  err.status = false;
  err.msg = sprintf('%s\n %s (roi_top_dir : ''%s'')',err.msg, pathinfo, para.files.roi_top_dir);
end
% Data store directory
[status, pathinfo] = fileattrib(para.files.save_dir);
if status
  para.files.save_dir = pathinfo.Name;
else
  err.status = false;
  err.msg = sprintf('%s\n %s (save_dir : ''%s'')',err.msg, pathinfo, para.files.save_dir);
end

if exist(para.files.save_dir, 'dir') ~= 7
    err.status = false;
    err.msg = sprintf('%s\n No such Save directory (''%s'')',...
    err.msg, para.files.save_dir);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VTD edit the next commented out section is to get the DICOM directory
% the template directory, and the ROI directory. This only need to be known
% by the Collector. No need to prompt every time we open other display for
% instance. So I remove this section and now include it only in the
% execution of the collector.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % DICOM file‚Ìdirectory, Template DICOM file, 
% % ROI file‚Ìdirectory ‚ðdialog box‚Å‘I‘ð‚·‚é?B
% % ROI file‚ðŽw’è‚µ‚È‚¢?ê?‡(para.files.roi_fnum=0)?AROI file
% % ‚Ìdirectory‚Ì‘I‘ð‚Í?È—ª‚·‚é?B
% % ----------------------------------------------------------
% % ( ”]Šˆ“®ƒpƒ^?[ƒ“‚©‚ç“¾“_‚ðŒvŽZ(para.score.score_mode==CALC_SCORE)
% %   'ˆÈŠO' ‚Ì?ðŒ?‚Å‚Í?AROI file‚ðŽw’è‚µ‚È‚Ä‚à—Ç‚¢?B
% %   create_global.m“à‚Ìcreate_para()‚Ìfiles?\‘¢‘Ì‚ÌƒRƒ?ƒ“ƒg
% %   ‚ðŽQ?Æ )
% % ----------------------------------------------------------
% % Œ‹?‡neurofeedback(DecCNef)ŽÀŒ±‚Å‚Í?A‚±‚±‚ÅTemplate image
% % file‚Ìdirectory‚ð‘I‘ð‚·‚é•K—v‚Í‚È‚¢‚ª?ADecoded neurofeedback
% % (DecNef)ŽÀŒ±‚Å‚Í?Aroi_top_dir‚Ì‰º‚ÌŠK‘w‚Ìdirectory‚ð
% % dialog box‚Å‘I‘ð‚µ?A‘I‘ð‚µ‚½directory–¼‚ðtempl_image_dir
% % ‚É?Ý’è‚·‚é?B
% % ( create_global.m“à‚Ìcreate_paraa()‚Ìfiles?\‘¢‘Ì‚ÌƒRƒ?ƒ“ƒg
% %   ‚ðŽQ?Æ )
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if err.status
%   if define.files.STD_DIALOG_BOX	% MATLAB•W?€‚Ìdialog box‚ð—p‚¢‚é
%     % MATLAB•W?€‚Ìdialog box‚Ì?ˆ—?ŠÖ?” uigetdir() ‚Í
%     % 'Cancel' button‚ð‘I‘ð‚µ‚½?ê?‡‚Í0‚ð
%     % 'OK' button‚ð‘I‘ð‚µ‚½?ê?‡‚Ídirectory‚ð•Ô‚·?B
% 
%     % DICOM file‚Ìdirectory‚ð?Ý’è‚·‚é?B
%     ret = uigetdir(para.files.data_top_dir, 'Select DICOM directory');
%     if ret
%       para.files.dicom_dir = ret;
%       ret = true;
%     end
%     % Template image file‚Ìdirectory‚ð?Ý’è‚·‚é?B
%     ret = uigetdir(para.files.roi_top_dir, 'Select Template image directory');
%     if ret
%       para.files.templ_image_dir = ret;
%       ret = true;
%     end
%     % ROI file‚Ìdirectory‚ð?Ý’è‚·‚é?B
%     if ret & para.files.roi_fnum
%       ret = uigetdir(para.files.roi_top_dir, 'Select ROI directory');
%       if ret
% 	para.files.roi_dir = ret;
% 	ret = true;
%       end
%     end
%   else				% “ÆŽ©ŠJ”­‚Ìdialog box‚ð—p‚¢‚é
%     file_extensions = { '' };
%     % DICOM file‚Ìdirectory
%     [ret, para.files.dicom_dir, fname] =yoyo_file_dialog(para.files.data_top_dir, file_extensions,'Select DICOM directory');
%     % Template image file
%     [ret, para.files.templ_image_dir, fname] =yoyo_file_dialog(para.files.roi_top_dir, file_extensions,'Select Template image directory');
%     % ROI file‚Ìdirectory
%     if ret & para.files.roi_fnum
%       [ret, para.files.roi_dir, fname] =yoyo_file_dialog(para.files.roi_top_dir, file_extensions,'Select ROI directory');
%     end
%   end	% <-- End of 'if define.files.STD_DIALOG_BOX ... else ...'
%   
%   
%   % Žw’è‚µ‚½directory‚ª‘¶?Ý‚·‚é‚©ƒ`ƒFƒbƒN‚·‚é?B
%   if exist(para.files.save_dir, 'dir') ~= 7
%     err.status = false;
%     err.msg = sprintf('%s\n No such Save directory (''%s'')',...
% 	err.msg, para.files.save_dir);
%   end
%   if exist(para.files.dicom_dir, 'dir') ~= 7
%     err.status = false;
%     err.msg = sprintf('%s\n No such DICOM directory (''%s'')',...
% 	err.msg, para.files.dicom_dir);
%   end
%   if exist(para.files.templ_image_dir, 'dir') ~= 7
%     err.status = false;
%     err.msg = sprintf('%s\n No such Template image directory (''%s'')',...
% 	err.msg, para.files.templ_image_dir);
%   end
%   if para.files.roi_fnum & exist(para.files.roi_dir, 'dir') ~= 7
%     err.status = false;
%     err.msg = sprintf('%s\n No such ROI directory (''%s'')',...
% 	err.msg, para.files.roi_dir);
%   end
%end	% <-- End of 'if err.status'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dir_para()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para] = set_parameters(define, para)
% function [para] = set_parameters(define, para)
% ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì‚ð?X?V‚·‚é?B
% 
% Parameterƒtƒ@ƒCƒ‹‚©‚ç“Ç‚Ý?ž‚ñ‚¾ŽÀŒ±ƒpƒ‰ƒ??[ƒ^‚©‚ç
% ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì‚ð?X?V‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% para   : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% 
% [output argument]
% para  : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì

% 1ŽŽ?s–Ú‚ÌˆêŽŽ?s‚Ìscan?”‚ð‹?‚ß‚é?B
para.scans.first_trial_scan_num =...
    para.scans.prep_rest1_scan_num +...	% ‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì1‚Ìscan?”
    para.scans.prep_rest2_scan_num +...	% ‘O?ˆ—?—p‚ÌREST?ðŒ?‚»‚Ì2‚Ìscan?”
    para.scans.rest_scan_num +...      	% REST?ðŒ?‚Ìscan?”
    para.scans.test_scan_num +...	% TEST?ðŒ?‚Ìscan?”
    para.scans.post_test_delay_scan_num +...	% TEST?ðŒ??I—¹Œã‚Ìdelay scan?”
    para.scans.calc_score_scan_num +...	% “¾“_ŒvŽZ?ðŒ?‚Ìscan?”
    para.scans.feedbk_score_scan_num;	% “¾“_’ñŽ¦?ðŒ?‚Ìscan?”
% 2ŽŽ?s–ÚˆÈ?~‚ÌˆêŽŽ?s‚Ìscan?”‚ð‹?‚ß‚é?B
para.scans.trial_scan_num =...
    para.scans.rest_scan_num +...	% REST?ðŒ?‚Ìscan?”
    para.scans.test_scan_num +...	% TEST?ðŒ?‚Ìscan?”
    para.scans.post_test_delay_scan_num +...	% TEST?ðŒ??I—¹Œã‚Ìdelay scan?”
    para.scans.calc_score_scan_num +...	% “¾“_ŒvŽZ?ðŒ?‚Ìscan?”
    para.scans.feedbk_score_scan_num;	% “¾“_’ñŽ¦?ðŒ?‚Ìscan?”
% ‘?Scan?”‚ð‹?‚ß‚é?B
para.scans.total_scan_num =...
    para.scans.pre_trial_scan_num +...
    para.scans.first_trial_scan_num + ...
    para.scans.trial_scan_num*(para.scans.trial_num - 1);
% ”íŒŸŽÒ‚ª?Q‚Ä‚¢‚È‚¢‚©‚ðƒ`ƒFƒbƒN‚·‚éŽŽ?s”Ô?†‚ð?Ý’è‚·‚é”z—ñ‚ð—pˆÓ‚·‚é?B
% (define.key.SLEEP_CHECK_KEY‚ÅŽw’è‚µ‚½ƒL?[‚ð“ü—Í‚³‚¹‚é)
[tmp, rand_trial] = sort( rand(para.scans.trial_num, 1) );
para.scans.sleep_check_trial =...
    find( rand_trial <= para.scans.sleep_check_trial_num );


% Šescan‚ÌNIfTI file–¼‚ð?Ý’è‚·‚écell”z—ñ‚ð?ì?¬‚·‚é?B
para.files.nifti_fnames = cell(para.scans.total_scan_num,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ž‹Šo’ñŽ¦‚âƒgƒŠƒK?[“ü—Í‚µ‚È‚¢?ðŒ?(feedback.io_tool = DO_NOT_USE)
% ‚Ì?ê?‡?AStanford–°‹CŽÚ“x‚ÍŽ¿–â‚µ‚È‚¢?B
% (create_global.m“à‚Ìset_parameters()‚Ìsss?\‘¢‘Ì‚ÌƒRƒ?ƒ“ƒgŽQ?Æ)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if para.feedback.io_tool == define.feedback.io_tool.DO_NOT_USE
  para.sss.sss_flag = false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_parameters()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
