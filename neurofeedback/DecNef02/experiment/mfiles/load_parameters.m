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
      % ROI file��top directory (roi_top_dir)
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
	% �w��l��?��voxel��?̗p����?��?
	line_ok = true;
	para.files.wm_threshold = value;
      end
    end	% <-- End of 'wm_threshold'

    if strncmp(str, 'gs_fname', length('gs_fname'))
      % GS file�� (gs_fname)
      value = yoyo_sscanf('gs_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.gs_fname = value;
      end
    end	% <-- End of 'gs_fname'
    if strncmp(str, 'gs_threshold', length('gs_threshold'))
      % GS data��臒l (gs_threshold)
      value = yoyo_sscanf('gs_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% ��[�?�v�f�̑S�Ă�voxel��?̗p����?��?
	line_ok = true;
	para.files.gs_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('gs_threshold=%f', str);
      if length(value)
	% �w��l��?��voxel��?̗p����?��?
	line_ok = true;
	para.files.gs_threshold = value;
      end
    end	% <-- End of 'gs_threshold'

    if strncmp(str, 'csf_fname', length('csf_fname'))
      % CSF file�� (csf_fname)
      value = yoyo_sscanf('csf_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.csf_fname = value;
      end
    end	% <-- End of 'csf_fname'
    if strncmp(str, 'csf_threshold', length('csf_threshold'))
      % CSF data��臒l (csf_threshold)
      value = yoyo_sscanf('csf_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% ��[�?�v�f�̑S�Ă�voxel��?̗p����?��?
	line_ok = true;
	para.files.csf_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('csf_threshold=%f', str);
      if length(value)
	% �w��l��?��voxel��?̗p����?��?
	line_ok = true;
	para.files.csf_threshold = value;
      end
    end	% <-- End of 'csf_threshold'
    
    if strncmp(str, 'templ_image_fname', length('templ_image_fname'))
      % Template image file�� (templ_image_fname)
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
    % fMRI��scan?��?�Ɋ֌W����p���??[�^��load����?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'trial_num', length('trial_num'))
      % ��?s?� (trial_num)
      value = yoyo_sscanf('trial_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.trial_num = value;
      end
    end	% <-- End of 'trial_num'
    if strncmp(str, 'pre_trial_scan_num', length('pre_trial_scan_num'))
      % ��?s���J�n���閘��scan?� (pre_trial_scan_num)
      value = yoyo_sscanf('pre_trial_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.pre_trial_scan_num = value;
      end
    end	% <-- End of 'pre_trial_scan_num'
    if strncmp(str, 'prep_rest1_scan_num', length('prep_rest1_scan_num'))
      % 1��?s�ڂ̑O?��?�p��REST?��?����1��scan?� (prep_rest1_scan_num)
      value = yoyo_sscanf('prep_rest1_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.prep_rest1_scan_num = value;
      end
    end	% <-- End of 'prep_rest1_scan_num'
    if strncmp(str, 'prep_rest2_scan_num', length('prep_rest2_scan_num'))
      % 1��?s�ڂ̑O?��?�p��REST?��?����2��scan?� (prep_rest2_scan_num)
      value = yoyo_sscanf('prep_rest2_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.prep_rest2_scan_num = value;
      end
    end	% <-- End of 'prep_rest2_scan_num'
    if strncmp(str, 'rest_scan_num', length('rest_scan_num'))
      % REST?��?��scan?� (rest_scan_num)
      value = yoyo_sscanf('rest_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.rest_scan_num = value;
      end
    end	% <-- End of 'rest_scan_num'
    if strncmp(str, 'test_scan_num', length('test_scan_num'))
      % TEST?��?��scan?� (test_scan_num)
      value = yoyo_sscanf('test_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.test_scan_num = value;
      end
    end	% <-- End of 'test_scan_num'
    if strncmp(str, 'pre_test_delay_scan_num',...
	  length('pre_test_delay_scan_num'))
      % TEST?��?�J�n���delay scan?� (pre_test_delay_scan_num)
      value = yoyo_sscanf('pre_test_delay_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.pre_test_delay_scan_num = value;
      end
    end	% <-- End of 'pre_test_delay_scan_num'
    if strncmp(str, 'post_test_delay_scan_num',...
	  length('post_test_delay_scan_num'))
      % TEST?��??I�����delay scan?� (post_test_delay_scan_num)
      value = yoyo_sscanf('post_test_delay_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.post_test_delay_scan_num = value;
      end
    end	% <-- End of 'post_test_delay_scan_num'
    if strncmp(str, 'calc_score_scan_num', length('calc_score_scan_num'))
      % ���_�v�Z?��?��scan?� (calc_score_scan_num)
      value = yoyo_sscanf('calc_score_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.calc_score_scan_num = value;
      end
    end	% <-- End of 'calc_score_scan_num'
    if strncmp(str, 'feedbk_score_scan_num', length('feedbk_score_scan_num'))
      % ���_��?��?��scan?� (feedbk_score_scan_num)
      value = yoyo_sscanf('feedbk_score_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.feedbk_score_scan_num = value;
      end
    end	% <-- End of 'feedbk_score_scan_num'
    if strncmp(str, 'TR', length('TR'))
      % Scan�Ԋu (TR)
      value = yoyo_sscanf('TR=%f', str);
      if length(value)
	line_ok = true;
	para.scans.TR = value;
      end
    end	% <-- End of 'TR'
    if strncmp(str, 'regress_scan_num', length('regress_scan_num'))
      % fMRI�f?[�^�̃m�C�Y?���?��?�ɗ��p����scan?� (regress_scan_num)
      value = yoyo_sscanf('regress_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.regress_scan_num = value;
      end
    end	% <-- End of 'regress_scan_num'
    if strncmp(str, 'sleep_check_trial_num',...
	  length('sleep_check_trial_num'))
      % �팟�҂�?Q�Ă��Ȃ������`�F�b�N���鎎?s?� (sleep_check_trial_num)
      value = yoyo_sscanf('sleep_check_trial_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.sleep_check_trial_num = value;
      end
    end	% <-- End of 'sleep_check_trial_num'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ���_�v�Z�p�p���??[�^��load����?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if strncmp(str, 'score_mode', length('score_mode'))
      % ���_��?[�h (score_mode)
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
      % �]�̔��a (radius_of_brain) (mm)
      value = yoyo_sscanf('radius_of_brain=%f', str);
      if length(value)
	line_ok = true;
	para.score.radius_of_brain = value;
      end
    end	% <-- End of 'radius_of_brain'
    
    if strncmp(str, 'FD_threshold',...
	  length('FD_threshold'))
      % Scan���̔]�̈ړ��ʂ�臒l (FD_threshold) (mm)
      value = yoyo_sscanf('FD_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.score.FD_threshold = value;
      end
    end	% <-- End of 'FD_threshold'
    
    if strncmp(str, 'corr_roi_template_threshold',...
	  length('corr_roi_template_threshold'))
      %  ROI template��ROI�̑��֌W?���臒l (corr_roi_template_threshold)
      value = yoyo_sscanf('corr_roi_template_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.score.corr_roi_template_threshold = value;
      end
    end	% <-- End of 'corr_roi_template_threshold'

    if strncmp(str, 'score_normrnd_mu', length('score_normrnd_mu'))
      % ?��K���z�??��̕��ϒl�p���??[�^ (normrnd_mu)
      value = yoyo_sscanf('score_normrnd_mu=%f', str);
      if length(value)
	line_ok = true;
	para.score.normrnd_mu = value;
      end
    end	% <-- End of 'score_normrnd_mu'
    if strncmp(str, 'score_normrnd_sigma', length('score_normrnd_sigma'))
      % ?��K���z�??��̕W?���?��p���??[�^ (normrnd_sigma)
      value = yoyo_sscanf('score_normrnd_sigma=%f', str);
      if length(value)
	line_ok = true;
	para.score.normrnd_sigma = value;
      end
    end	% <-- End of 'score_normrnd_sigma'
    if strncmp(str, 'score_limit', length('score_limit'))
      % ���_�̉�����?����臒l (score_limit)
      value = yoyo_sscanf('score_limit=(%f,%f)', str);
      if length(value) == 2
	line_ok = true;
	para.score.score_limit(define.MIN) = min(value);
	para.score.score_limit(define.MAX) = max(value);
      end
    end	% <-- End of 'score_limit'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ���ofeedback�Ɋ֌W����p���??[�^��load����?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'feedback_io_tool', length('feedback_io_tool'))
      % ��?s�J�n�g���K?[?M?����̓��͂⎋�ofeedback?o��?擙��
      % ��?o�͗p�c?[��(feedback_io_tool)
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
      % ���ofeedback�̒񎦃^�C�v (feedback_type)
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
      % ���_��팟�҂ɒ񎦂���^�C�~���O (feedback_score_timing)
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
      % ���o�h����񎦂���screen��?� (feedback_screen)
      value = yoyo_sscanf('feedback_screen=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.screen = value;
      end
    end	% <-- End of 'feedback_screen'
    if strncmp(str, 'feedback_prep_rest1_comment',...
	  length('feedback_prep_rest1_comment'))
      % 1��?s�ڂ̑O?��?�p��REST?��?����1�ł̃R�?���g������
      % (feedback_prep_rest1_comment)
      value = yoyo_sscanf('feedback_prep_rest1_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_rest1_comment = value;
      end
    end	% <-- End of 'feedback_prep_rest1_comment'
    if strncmp(str, 'feedback_prep_rest2_comment',...
	  length('feedback_prep_rest2_comment'))
      % 1��?s�ڂ̑O?��?�p��REST?��?����2�ł̃R�?���g������
      % (feedback_prep_rest2_comment)
      value = yoyo_sscanf('feedback_prep_rest2_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_rest2_comment = value;
      end
    end	% <-- End of 'feedback_prep_rest2_comment'
    if strncmp(str, 'feedback_rest_comment', length('feedback_rest_comment'))
      % REST?��?�ł̃R�?���g������ (feedback_rest_comment)
      value = yoyo_sscanf('feedback_rest_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.rest_comment = value;
      end
    end	% <-- End of 'feedback_rest_comment'
    if strncmp(str, 'feedback_test_comment', length('feedback_test_comment'))
      % TEST?��?�ł̃R�?���g������ (feedback_test_comment)
      value = yoyo_sscanf('feedback_test_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.test_comment = value;
      end
    end	% <-- End of 'feedback_test_comment'
    if strncmp(str, 'feedback_prep_score_comment',...
	  length('feedback_prep_score_comment'))
      % TEST?��?��?I��������?A���_��񎦂���܂ł̊Ԃ�
      % ?��?�ł̃R�?���g������ (feedback_prep_score_comment)
      value = yoyo_sscanf('feedback_prep_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_score_comment = value;
      end
    end	% <-- End of 'feedback_prep_score_comment'
    if strncmp(str, 'feedback_score_comment', length('feedback_score_comment'))
      % ���_��?��?�ł̃R�?���g������ (feedback_score_comment)
      value = yoyo_sscanf('feedback_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.score_comment = value;
      end
    end	% <-- End of 'feedback_score_comment'
    if strncmp(str, 'feedback_ng_score_comment',...
	  length('feedback_ng_score_comment'))
      % ���_�̌v�Z?��?�s���̃R�?���g������ (feedback_ng_score_comment)
      value = yoyo_sscanf('feedback_ng_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.ng_score_comment = value;
      end
    end	% <-- End of 'feedback_ng_score_comment'
    if strncmp(str, 'feedback_finished_block_comment',...
	  length('feedback_finished_block_comment'))
      % �u�?�b�N?I��?��?�ł̃R�?���g������ (feedback_finished_block_comment)
      value = yoyo_sscanf('feedback_finished_block_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.finished_block_comment = value;
      end
    end	% <-- End of 'feedback_finished_block_comment'
    if strncmp(str, 'feedback_finished_block_duration',...
	  length('feedback_finished_block_duration'))
      % �u�?�b�N?I��?��?�̎��ofeedback�̒񎦎���(sec) (finished_block_duration)
      value = yoyo_sscanf('feedback_finished_block_duration=%f', str);
      if length(value)
	line_ok = true;
	para.feedback.finished_block_duration = value;
      end
    end	% <-- End of 'feedback_finished_block_duration'
    if strncmp(str, 'feedback_gaze_frame_r', length('feedback_gaze_frame_r'))
      % �?���_�̔��a(�~�� �g) (feedback_gaze_frame_r)
      value = yoyo_sscanf('feedback_gaze_frame_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.gaze_frame_r = value;
      end
    end	% <-- End of 'feedback_gaze_frame_r'
    if strncmp(str, 'feedback_gaze_fill_r', length('feedback_gaze_fill_r'))
      % �?���_�̔��a(�~�� �h) (feedback_gaze_fill_r)
      value = yoyo_sscanf('feedback_gaze_fill_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.gaze_fill_r = value;
      end
    end	% <-- End of 'feedback_gaze_fill_r'
    if strncmp(str, 'feedback_sleep_fill_r', length('feedback_sleep_fill_r'))
      % �?���_�̔��a(?Q�Ă��Ȃ����`�F�b�N�p) (feedback_sleep_fill_r)
      value = yoyo_sscanf('feedback_sleep_fill_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.sleep_fill_r = value;
      end
    end	% <-- End of 'feedback_sleep_fill_r'
    if strncmp(str, 'feedback_max_score_r', length('feedback_max_score_r'))
      % ���_��?���l�ł̓��_��񎦂���~�̔��a (feedback_max_score_r)
      value = yoyo_sscanf('feedback_max_score_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.max_score_r = value;
      end
    end	% <-- End of 'feedback_max_score_r'


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stanford sleepiness scale(�X�^���t�H?[�h���C�ړx)
    % �Ɋ֌W����p���??[�^��load����?B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'sss_flag', length('sss_flag'))
      % Stanford���C�ړx����t���O (sss_flag)
      value = yoyo_sscanf('sss_flag=%d', str);
      if length(value)
	line_ok = true;
	para.sss.sss_flag = logical(value);
      end
    end	% <-- End of 'sss_flag'
    if strncmp(str, 'sss_image_dir', length('sss_image_dir'))
      % Stanford���C�ړx����摜file��directory (sss_image_dir)
      value = yoyo_sscanf('sss_image_dir=%s', str);
      if length(value)
	line_ok = true;
	para.sss.sss_image_dir = value;
      end
    end	% <-- End of 'sss_image_dir'
    if strncmp(str, 'sss_image_fname', length('sss_image_fname'))
      % Stanford���C�ړx����摜file�� (sss_image_fname)
      value = yoyo_sscanf('sss_image_fname=%s', str);
      if length(value)
	line_ok = true;
	para.sss.sss_image_fname = value;
      end
    end	% <-- End of 'sss_image_fname'


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    if strncmp(str, 'roi_vol_graph_flag', length('roi_vol_graph_flag'))
      % ROI volume graph�\���t���O (roi_vol_graph_flag)
      value = yoyo_sscanf('roi_vol_graph_flag=%d', str);
      if length(value)
	line_ok = true;
	para.roi_vol_graph_flag = logical(value);
      end
    end	% <-- End of 'roi_vol_graph_flag'
    
    
    if line_ok == false		% �s?���?s�𔭌�����?B
      % �G��?[�?�b�Z?[�W��?X?V����?B
      err.status = false;
      err.msg = sprintf('%s ERROR %3d : %s', err.msg, line_no, str);
    end
  end	% <-- End of 'if str == -1 ... else'
end	% <-- End of 'while(true)'

fclose(fd);


if err.status
  % Parameter�t�@�C���ɋL?q����Ă�������p���??[�^��?�?�?�����?؂���?B

  if DecNef_Project ~= define.DECNEF_PROJECT;
    % DecNef�����v�?�W�F�N�g�R?[�h�ɕs?��l��?ݒ肵��?B
    err.status = false;
    err.msg = sprintf(...
	'%s ERROR : Invalid value is set for ''ProjectCode''.\n',...
	err.msg);
    err.msg = sprintf('%s \t ProjectCode = DecNef%d\n',...
	err.msg, DecNef_Project);
  end	% <-- End of 'if DecNef_Project ~= define.DECNEF_PROJECT'


  if para.denoising_method == define.denoising_method.REGRESS
    % fMRI�f?[�^�̃m�C�Y?���?��?��?d?��`��A�̎c?�
    % (regress��?��𗘗p����)��?s�Ȃ�?��?�̃p���??[�^
    % ���`�F�b�N����?B

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % '�m�C�Y?���?��?��?d?��`��A�̎c?���?s�Ȃ�?��?' ��
    % '�]�����p�^?[�����瓾�_���v�Z����?��?' ��?�?�
    % 	-> WM file, GS file, CSF file���w�肵�Ȃ���΂Ȃ�Ȃ�
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if para.score.score_mode == define.score_mode.CALC_SCORE &... 
	  isempty( para.files.wm_fname)
      % '�]�����p�^?[�����瓾�_���v�Z����?��?' �� 'WM file������?ݒ�' ��?�?�
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
      % '�]�����p�^?[�����瓾�_���v�Z����?��?' �� 'GS file������?ݒ�' ��?�?�
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
      % '�]�����p�^?[�����瓾�_���v�Z����?��?' �� 'CSF file������?ݒ�' ��?�?�
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
      % fMRI�f?[�^�̃m�C�Y?���?��?�ɗ��p����scan?��ɕs?��l��?ݒ肵��?B
      % �O?��?�p��REST?��?����1��scan?�(prep_rest1_scan_num) + 
      % �O?��?�p��REST?��?����2��scan?�(prep_rest2_scan_num) + 
      % REST?��?��scan?�(rest_scan_num) + 
      % TEST?��?��scan?�(test_scan_num) +
      % TEST?��??I�����delay scan?�(post_test_delay_scan_num)
      % ��?�łȂ���΂Ȃ�Ȃ�?B
      % ( create_global.m����create_para()�̃R�?���g���Q?� )
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
  % ROI file��?����`�F�b�N����?B
  % ------------------------------------------------------------
  % �]�����p�^?[�����瓾�_���v�Z����?��?
  % (para.score.score_mode=CALC_SCORE)��?�?�
  % 	-> ROI file���w�肵�Ȃ���΂Ȃ�Ȃ�?B
  % �]�����p�^?[�����瓾�_���v�Z?��? '�ȊO'��?��?��?�?�
  % 	-> ROI file���w�肵�Ă��Ȃ��Ă��悢?B
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if para.score.score_mode == define.score_mode.CALC_SCORE &... 
      para.files.roi_fnum == 0
    % �]�����p�^?[�����瓾�_���v�Z����?��?(para.score.score_mode=CALC_SCORE)
    % ��ROI file���w�肵�Ă��Ȃ�(ROI file?���0)
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
  % ROI file�̊g���q���`�F�b�N����?B
  %  ------------------------------------------------------------
  % ROI file�̊g���q�Ƃ��ċ����ꂽ�������?A
  % define.files.ROI_FILE_EXTENSION��?ݒ肳��Ă���?B
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for roi=1:para.files.roi_fnum
    if isempty(para.files.roi_fname{roi})
      % ROI file���w�肵�Ă��Ȃ�?B
      err.status = false;
      err.msg = sprintf(...
	  '%s ERROR : ''roi_fname[%d]'' is not set..\n',err.msg, roi);
    else
      % ROI file�̊g���q���l������?B
      [pathstr,name,ext] = fileparts( para.files.roi_fname{roi} );
      if length( find( strcmpi(ext , define.files.ROI_FILE_EXTENSION) ) )==0
	% ROI file���̊g���q�ɕs?��ȕ�������w�肵�Ă���?B
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
  % Template image�t�@�C���̊g���q���`�F�b�N����?B
  %  ------------------------------------------------------------
  % Template image�t�@�C����
  % DICOM file(�g���q:define.files.DICOM_FILE_EXTENSION) ��
  % NIfTI file(�g���q:define.files.NIFTI_FILE_EXTENSION)
  % �łȂ���΂Ȃ�Ȃ�
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [pathstr, templ_name, templ_ext] = fileparts(para.files.templ_image_fname);
  tmp = sum( strcmp(templ_ext, define.files.DICOM_FILE_EXTENSION) ) +...
      sum( strcmp(templ_ext, define.files.NIFTI_FILE_EXTENSION) );
  if tmp == 0
    err.status = false;
    % Template image file�̊g���q���s?�
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
    % �팟�҂�?Q�Ă��Ȃ������`�F�b�N���鎎?s?��ɕs?��l��?ݒ肵��?B
    % (��?s?����傫�Ȓl��?ݒ肵�Ă���?B)
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
  
  % ���o�h����񎦂���screen��?����`�F�b�N����?B
  % (PC��?ڑ�����Ă���Screen?����l����?A���o�h��
  %  ��񎦂���screen��?��𔻒肷��?B)
  switch para.feedback.io_tool
    case define.feedback.io_tool.PSYCHTOOLBOX
      % ��?s�J�n�g���K?[?M?����̓��͂⎋�ofeedback?o��?擙��
      % ��?o�͗p�c?[����Psychtoolbox�𗘗p����
      screenNumber = max( Screen('Screens') );
    case define.feedback.io_tool.MATLAB
      % ��?s�J�n�g���K?[?M?����̓��͂⎋�ofeedback?o��?擙��
      % ��?o�͗p�c?[����MATLAB�𗘗p����
      screenNumber = size( get(0, 'MonitorPositions'), 1 );
    case define.feedback.io_tool.DO_NOT_USE
      % ��?s�J�n�g���K?[?M?����̓��͂⎋�ofeedback?o�͂�
      % ?s�Ȃ�Ȃ�
      screenNumber = intmax;	% ?�?���?ő�l�������Ă���?B
  end	% <-- End of 'para.feedback.io_tool'
  if para.feedback.screen < 0 | para.feedback.screen > 2
    % ���o�h����񎦂���screen��?��ɔ͈͊O�̒l��?ݒ肵��?B
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
% ?\���̔z��p�p���??[�^������(str)��������?��?(format)��
% ��v���邩�m�F����?B
% 
% ?\���̔z��p�p���??[�^�������?A
% 
% [1] ?\���̖�[�z���?�]=�l
%   str = 'SwitchDuration[4]=0.75'
%   format = 'SwitchDuration[%d]=%f'
%     -> value = [4.0, 0.75]
% 
% [2] ?\���̖�[�z���?�].�?���o��?���=�l
%   str = 'sequence[1].dynamics=DYNAMICS5'
%   format = 'sequence[%d].dynamics=DYNAMICS%d'
%     -> value = [1, 5]
% 
% [3] ?\���̖�[�z���?�]=(�l1,�l2)
%   str = 'target_pos_task[1]=(0.000,-0.10)'
%   format = 'target_pos_task[%d]=(%f,%f)'
%     -> value = [1.0, 0.0, -0.1]
% 
% [4] ?\���̖�[�z���?�].�?���o��?���=(�l1,�l2)
%   str = 'tsequence[1].start_target=(4, 3)'
%   format = 'tsequence[%d].start_target=(%d,%d)'
%     -> value = [1, 4, 3]
% 
% �̌^���ŋL?q���Ă�����̂Ƃ���?B
% ?�����?�?�?A�Ԃ�l(value)�ɂ�num��?��l��?ݒ肳���?B
% 1�ڂ��z���?�?A2�ڈ�?~��?ݒ�l
% 
% 
%
% **** �?��!! ****
% ������?��?(format)��'='�̑O��ɃX�y?[�X��}�����Ă͂����Ȃ�?B
% 
% **** �?��!! ****
% array_of_struct()����?A������(str)���� '=' , '[' , ']' , '(' , ')' ����
% �̑O��̃X�y?[�X��?�?�����?B
% 
% [input argument]
% format : ������?��?
%          sprintf()�̕�����?��?���Ɠ��l�̌`������?A
%          ������?��?(format)�� '=','[',']','(',')'�̑O��ɃX�y?[�X
%          ��}�����Ă͂����Ȃ�?B
% str : ?\���̔z��p�p���??[�^������
% num : �p���??[�^�l��?�
% 
% [output argument]
% value : �p���??[�^�l

value = sscanf(str, format);
% ������?��?(format)�Ɉ�v���Ȃ�?�?�?A������(str)����
% '=' , '[' , ']' , '(' , ')' �����̑O��̃X�y?[�X��?�?����Č�?�����?B
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
% File dialog��p����Sham score�t�@�C����I����?A
% Sham score�t�@�C�����瓾�_��ǂ�?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% para : �����p���??[�^?\����
% err : �G��?[?��
% 
% [output argument]
% para : �p���??[�^�l��?ݒ��̎����p���??[�^?\����
% err : �G��?[?��

kaigyo = sprintf('\n');		% ��?s����
kaigyo_dos = 13;		% ��?s���� (DOS)
comment = '#';			% �R�?���g?s��?擪����

% File dialog��p����Sham score file��I������?B
if define.files.STD_DIALOG_BOX  % MATLAB�W?���dialog box��p����
  [fname, dname, index] = uigetfile(...
      sprintf('%s%s*%s',...
      para.files.para_dir, filesep, define.files.SHAM_SCORE_FILE_EXTENSION),...
      'Select Sham score file');
else				% �Ǝ��J����dialog box��p����
  file_extensions = { define.files.SHAM_SCORE_FILE_EXTENSION };
  [index, dname, fname] =...
      yoyo_file_dialog(para.files.para_dir, file_extensions,...
      'Select Sham score file');
  if index
    fname = char( fname{1} );	% cell�z�񂩂當����ɕϊ�����?B
  end
end

% Sham score file��directory����file����?X?V����?B
if index
  para.files.sham_score_dir = dname;
  para.files.sham_score_fname = fname;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sham score�t�@�C�����瓾�_��ǂ�?B
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
  line_no = 0;		% ?s��?�
  err.msg = sprintf('%sin ''%s''\n', err.msg, sham_score_filename);
  
  para.score.sham_score = nan(para.scans.trial_num, 1);
  
  while true
    str = fgets(fd);		% 1?s�ǂ�?o��?B
    line_no = line_no+1;	% ?s��?���?X?V����?B
    
    if str == -1, break;	% End of file
    else
      line_ok = false;
      
      if str(1) == comment | str(1) == kaigyo | str(1) == kaigyo_dos
	line_ok = true;	% �R�?���g?s, ��?s
      end
      
      if strncmp(str, 'sham_score', length('sham_score'))
	value = array_of_struct('sham_score[%d]=%f', str, 2);
	if length(value) == 2
	  n = round(value(1));				% ��?s��?�
	  if n <= para.scans.trial_num
	    para.score.sham_score(n) = value(2);	% ���_
	  end
	  line_ok = true;
	end
      end
      
      if line_ok == false		% �s?���?s�𔭌�����?B
	% �G��?[�?�b�Z?[�W��?X?V����?B
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
% directory�Ɋ֌W����p���??[�^��?ݒ肷��?B
% 
% Parameter�t�@�C������ǂ�?���directory�Ɋ֌W����
% �p���??[�^��?�?�?��`�F�b�N(Directory����?݂��邩)��?A
% DICOM file, Template image file��ROI file��directory
% ��?ݒ肷��?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% para : �����p���??[�^?\����
% err : �G��?[?��
% 
% [output argument]
% para : �����p���??[�^?\����
% err : �G��?[?��

err.msg = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data_top_dir����?�΃p�X�ɕϊ�����?B
[status, pathinfo] = fileattrib(para.files.data_top_dir);
if status
  para.files.data_top_dir = pathinfo.Name;
else
  % �G��?[�?�b�Z?[�W��?X?V����?B
  err.status = false;
  err.msg = sprintf('%s\n %s (data_top_dir : ''%s'')',err.msg, pathinfo, para.files.data_top_dir);
end
% ROI top directory��?�΃p�X�ɕϊ�����?B
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
% % DICOM file��directory, Template DICOM file, 
% % ROI file��directory ��dialog box�őI������?B
% % ROI file���w�肵�Ȃ�?�?�(para.files.roi_fnum=0)?AROI file
% % ��directory�̑I����?ȗ�����?B
% % ----------------------------------------------------------
% % ( �]�����p�^?[�����瓾�_���v�Z(para.score.score_mode==CALC_SCORE)
% %   '�ȊO' ��?��?�ł�?AROI file���w�肵�ȂĂ��ǂ�?B
% %   create_global.m����create_para()��files?\���̂̃R�?���g
% %   ���Q?� )
% % ----------------------------------------------------------
% % ��?�neurofeedback(DecCNef)�����ł�?A������Template image
% % file��directory��I������K�v�͂Ȃ���?ADecoded neurofeedback
% % (DecNef)�����ł�?Aroi_top_dir�̉��̊K�w��directory��
% % dialog box�őI����?A�I������directory����templ_image_dir
% % ��?ݒ肷��?B
% % ( create_global.m����create_paraa()��files?\���̂̃R�?���g
% %   ���Q?� )
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if err.status
%   if define.files.STD_DIALOG_BOX	% MATLAB�W?���dialog box��p����
%     % MATLAB�W?���dialog box��?��?��?� uigetdir() ��
%     % 'Cancel' button��I������?�?���0��
%     % 'OK' button��I������?�?���directory��Ԃ�?B
% 
%     % DICOM file��directory��?ݒ肷��?B
%     ret = uigetdir(para.files.data_top_dir, 'Select DICOM directory');
%     if ret
%       para.files.dicom_dir = ret;
%       ret = true;
%     end
%     % Template image file��directory��?ݒ肷��?B
%     ret = uigetdir(para.files.roi_top_dir, 'Select Template image directory');
%     if ret
%       para.files.templ_image_dir = ret;
%       ret = true;
%     end
%     % ROI file��directory��?ݒ肷��?B
%     if ret & para.files.roi_fnum
%       ret = uigetdir(para.files.roi_top_dir, 'Select ROI directory');
%       if ret
% 	para.files.roi_dir = ret;
% 	ret = true;
%       end
%     end
%   else				% �Ǝ��J����dialog box��p����
%     file_extensions = { '' };
%     % DICOM file��directory
%     [ret, para.files.dicom_dir, fname] =yoyo_file_dialog(para.files.data_top_dir, file_extensions,'Select DICOM directory');
%     % Template image file
%     [ret, para.files.templ_image_dir, fname] =yoyo_file_dialog(para.files.roi_top_dir, file_extensions,'Select Template image directory');
%     % ROI file��directory
%     if ret & para.files.roi_fnum
%       [ret, para.files.roi_dir, fname] =yoyo_file_dialog(para.files.roi_top_dir, file_extensions,'Select ROI directory');
%     end
%   end	% <-- End of 'if define.files.STD_DIALOG_BOX ... else ...'
%   
%   
%   % �w�肵��directory����?݂��邩�`�F�b�N����?B
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
% �����p���??[�^?\���̂�?X?V����?B
% 
% Parameter�t�@�C������ǂ�?��񂾎����p���??[�^����
% �����p���??[�^?\���̂�?X?V����?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% para   : �����p���??[�^?\����
% 
% [output argument]
% para  : �����p���??[�^?\����

% 1��?s�ڂ̈ꎎ?s��scan?����?�߂�?B
para.scans.first_trial_scan_num =...
    para.scans.prep_rest1_scan_num +...	% �O?��?�p��REST?��?����1��scan?�
    para.scans.prep_rest2_scan_num +...	% �O?��?�p��REST?��?����2��scan?�
    para.scans.rest_scan_num +...      	% REST?��?��scan?�
    para.scans.test_scan_num +...	% TEST?��?��scan?�
    para.scans.post_test_delay_scan_num +...	% TEST?��??I�����delay scan?�
    para.scans.calc_score_scan_num +...	% ���_�v�Z?��?��scan?�
    para.scans.feedbk_score_scan_num;	% ���_��?��?��scan?�
% 2��?s�ڈ�?~�̈ꎎ?s��scan?����?�߂�?B
para.scans.trial_scan_num =...
    para.scans.rest_scan_num +...	% REST?��?��scan?�
    para.scans.test_scan_num +...	% TEST?��?��scan?�
    para.scans.post_test_delay_scan_num +...	% TEST?��??I�����delay scan?�
    para.scans.calc_score_scan_num +...	% ���_�v�Z?��?��scan?�
    para.scans.feedbk_score_scan_num;	% ���_��?��?��scan?�
% �?Scan?����?�߂�?B
para.scans.total_scan_num =...
    para.scans.pre_trial_scan_num +...
    para.scans.first_trial_scan_num + ...
    para.scans.trial_scan_num*(para.scans.trial_num - 1);
% �팟�҂�?Q�Ă��Ȃ������`�F�b�N���鎎?s��?���?ݒ肷��z���p�ӂ���?B
% (define.key.SLEEP_CHECK_KEY�Ŏw�肵���L?[����͂�����)
[tmp, rand_trial] = sort( rand(para.scans.trial_num, 1) );
para.scans.sleep_check_trial =...
    find( rand_trial <= para.scans.sleep_check_trial_num );


% �escan��NIfTI file����?ݒ肷��cell�z���?�?�����?B
para.files.nifti_fnames = cell(para.scans.total_scan_num,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���o�񎦂�g���K?[���͂��Ȃ�?��?(feedback.io_tool = DO_NOT_USE)
% ��?�?�?AStanford���C�ړx�͎��₵�Ȃ�?B
% (create_global.m����set_parameters()��sss?\���̂̃R�?���g�Q?�)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if para.feedback.io_tool == define.feedback.io_tool.DO_NOT_USE
  para.sss.sss_flag = false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_parameters()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
