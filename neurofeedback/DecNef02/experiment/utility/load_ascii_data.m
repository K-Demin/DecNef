function [nfb_data] = load_ascii_data(load_dir, load_fname)
% function [nfb_data] = load_ascii_data(load_dir, load_fname)
% Load the dataset of neurofeedback experiment. (ASCII format)
% 
% [input argument]
% load_dir   : directory name
% load_fname : experiment data file name (ASCII format)
% 
% [output argument]
% nfb_data : Experimental data structure
% 
% ----------------------------------------------------------
% Copyright 2013 All Rights Reserved.
% ATR Brain Information Communication Research Lab Group.
% ----------------------------------------------------------
% Toshinori YOSHIOKA
% 2-2-2 Hikaridai, Seika-cho, Sorakugun, Kyoto,
% 619-0288, Japan (Keihanna Science city)


load_file_name = fullfile(load_dir, load_fname);
fprintf('Load online neurofeedback data (ASCII format)\n');
fprintf('  Data load dir  = ''%s''\n', load_dir);
fprintf('  Data load file = ''%s''\n', load_fname);

fd = fopen(load_file_name, 'r');
if fd == -1
  error( sprintf('FOPEN cannot open the file(%s)', load_file_name) );
end

% ASCII�`���̃f�[�^�t�@�C������o�[�W��������ǂށB
version = load_version_value(fd);
% ASCII�`���̃f�[�^�t�@�C������define�ϐ���ǂށB
define = load_define_para(fd);
% ASCII�`���̃f�[�^�t�@�C����������p�����[�^��ǂށB
[DECNEF_PROJECT, para] = load_para_data(fd, define);
% ASCII�`���̃f�[�^�t�@�C����������f�[�^��ǂށB
exp_data = load_data_para(fd, para);

fclose(fd);

% �����f�[�^�\���̂��쐬����B
nfb_data = struct(...
    'DECNEF_PROJECT',DECNEF_PROJECT,...	% DecNef�����v���W�F�N�g�R�[�h
    'version', version,...		% �o�[�W���������Ǘ�����\����
    'define', define,...		% define�ϐ����Ǘ�����\����
    'para', para,...			% �����p�����[�^���Ǘ�����\����
    'data', exp_data...			% �����f�[�^���Ǘ�����\����
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load�֐� �� �f�[�^�t�@�C���̐��������`�F�b�N����B
% ---------------------------------------------------------
% ( �����v���W�F�N�g�R�[�h �� �����v���W�F�N�g�����[�X�� ���A
%   Load�֐� �� �f�[�^�t�@�C�� �ň�v���Ȃ���΂Ȃ�Ȃ��B )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �����v���W�F�N�g�R�[�h(version.decnef_project) ��
% �����v���W�F�N�g�����[�X��(version.decnef_release) ��
% �����f�[�^�ɐݒ肳��Ă��Ȃ��ꍇ�A�����l(NaN)��ݒ肵�Ă����B
if isfield(nfb_data.version, 'decnef_project') == false
  nfb_data.version.decnef_project = NaN;
end
if isfield(nfb_data.version, 'decnef_release') == false
  nfb_data.version.decnef_release = NaN;
end
% Load�֐��� �����v���W�F�N�g�R�[�h(DecNef_Project) �� 
% �����v���W�F�N�g�����[�X��(DecNef_ReleaseData) ���l������B
[DecNef_Project, DecNef_ReleaseData] = release_info();
if nfb_data.version.decnef_project ~= DecNef_Project |...
      nfb_data.version.decnef_release ~= DecNef_ReleaseData
  % Load�֐� �� �f�[�^�t�@�C�� ��
  % �����v���W�F�N�g�R�[�h �� �����v���W�F�N�g�����[�X�� ����v���Ȃ��B
  str = sprintf(' [DecNef project information mismatch]\n');
  str = sprintf('%s Function (%s)\n', str, mfilename);
  str = sprintf('%s \t decnef_project = %d\n', str, DecNef_Project);
  str = sprintf('%s \t decnef_release = %d\n', str, DecNef_ReleaseData);
  str = sprintf('%s Data file (%s)\n', str, load_fname);
  str = sprintf('%s \t decnef_project = %d\n',...
      str, nfb_data.version.decnef_project);
  str = sprintf('%s \t decnef_release = %d\n',...
      str, nfb_data.version.decnef_release);
  error(str);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_ascii_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [version] = load_version_value(fd)
% function [version] = load_version_value(fd)
% ASCII�`���̃f�[�^�t�@�C������o�[�W��������ǂށB
% 
% [input argument]
% fd : ASCII�`���̃f�[�^�t�@�C���̃t�@�C�����ʎq
% 
% [output argument]
% version : �o�[�W���������Ǘ�����\����

version = [];

fseek(fd,0,-1);		% �t�@�C���|�C���^���t�@�C���̐擪�ɂ���B
while true
  str = fgets(fd);
  if str == -1, break;	% End of file
  else
    tmp = sscanf(str, 'version.decnef_project = %d');
    if ~isempty(tmp),	version.decnef_project = tmp;	end
    tmp = sscanf(str, 'version.decnef_release = %d');
    if ~isempty(tmp),	version.decnef_release = tmp;	end
    tmp = sscanf(str, 'version.decnef_exp_date = %d');
    if ~isempty(tmp),	version.decnef_exp_date = tmp;	end
    tmp = sscanf(str, 'version.decnef_exp_time = %d');
    if ~isempty(tmp),	version.decnef_exp_time = tmp;	end
			
    tmp = sscanf(str, 'version.matlab_version = %s');
    if ~isempty(tmp),	version.matlab_version = tmp;	end
    tmp = sscanf(str, 'version.matlab_release = %s');
    if ~isempty(tmp),	version.matlab_release = tmp;	end
					  
    tmp = sscanf(str, 'version.spm_version = %s');
    if ~isempty(tmp),	version.spm_version = tmp;	end
    tmp = sscanf(str, 'version.spm_release = %d');
    if ~isempty(tmp),	version.spm_release = tmp;	end
  end	% <-- End of 'if str == -1, break ... else'
end     % <-- End of 'while true'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_version_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [define] = load_define_para(fd)
% function [define] = load_define_para(fd)
% ASCII�`���̃f�[�^�t�@�C������define�ϐ���ǂށB
% 
% [input argument]
% fd : ASCII�`���̃f�[�^�t�@�C���̃t�@�C�����ʎq
% 
% [output argument]
% define : define�ϐ����Ǘ�����\����

scan_condition = [];
define = [];

fseek(fd,0,-1);		% �t�@�C���|�C���^���t�@�C���̐擪�ɂ���B
while true
  str = fgets(fd);
  if str == -1, break;	% End of file
  else
    tmp = sscanf(str, 'define.REALIGN_VAL_NUM = %d');
    if ~isempty(tmp),	define.REALIGN_VAL_NUM = tmp;	end
    tmp = sscanf(str, 'define.REALIG_PARA_FNAME_PREFIX_CODE = %s');
    if ~isempty(tmp),	define.REALIG_PARA_FNAME_PREFIX_CODE = tmp;	end

    tmp = sscanf(str, 'define.ASCII_DATA_EXTENSION = %s');
    if ~isempty(tmp),	define.ASCII_DATA_EXTENSION = tmp;	end
    tmp = sscanf(str, 'define.BINARY_DATA_EXTENSION = %s');
    if ~isempty(tmp),	define.BINARY_DATA_EXTENSION = tmp;	end
    
    tmp = sscanf(str, 'define.scan_condition.IDLING = %d');
    if ~isempty(tmp),	scan_condition.IDLING = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.PRE_TRIAL = %d');
    if ~isempty(tmp),	scan_condition.PRE_TRIAL = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.PREP_REST1 = %d');
    if ~isempty(tmp),	scan_condition.PREP_REST1 = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.PREP_REST2 = %d');
    if ~isempty(tmp),	scan_condition.PREP_REST2 = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.REST = %d');
    if ~isempty(tmp),	scan_condition.REST = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.TEST = %d');
    if ~isempty(tmp),	scan_condition.TEST = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.DELAY = %d');
    if ~isempty(tmp),	scan_condition.DELAY = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.CALC_SCORE = %d');
    if ~isempty(tmp),	scan_condition.CALC_SCORE = tmp;	end
    tmp = sscanf(str, 'define.scan_condition.FEEDBACK_SCORE = %d');
    if ~isempty(tmp),	scan_condition.FEEDBACK_SCORE = tmp; end
    tmp = sscanf(str, 'define.scan_condition.FINISH = %d');
    if ~isempty(tmp),	scan_condition.FINISH = tmp;	end
  end	% <-- End of 'if str == -1, break ... else'
end	% <-- End of 'while true'

define.scan_condition = scan_condition;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_define_para()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [DECNEF_PROJECT, para] = load_para_data(fd, define)
% function [define] = load_para_data(fd)
% ASCII�`���̃f�[�^�t�@�C����������p�����[�^��ǂށB
% 
% [input argument]
% fd : ASCII�`���̃f�[�^�t�@�C���̃t�@�C�����ʎq
% define : define�ϐ����Ǘ�����\����
% 
% [output argument]
% DECNEF_PROJECT : DecNef�����v���W�F�N�g�R�[�h
% para           : �����p�����[�^���Ǘ�����\����


DECNEF_PROJECT = -1;
para = [];
files = [];
scans = [];
score = [];
feedback = [];
sss = [];
dicom_info = [];
msocket = [];

fseek(fd,0,-1);		% �t�@�C���|�C���^���t�@�C���̐擪�ɂ���B
while true
  str = fgets(fd);
  if str == -1, break;	% End of file
  else
    % DecNef�����v���W�F�N�g�R�[�h
    tmp = sscanf(str, 'ProjectCode = DecNef%d');
    if ~isempty(tmp)	DECNEF_PROJECT = tmp;	end

    
    % Block�ԍ�
    tmp = sscanf(str, 'current_block = %d');
    if ~isempty(tmp),	para.current_block = tmp;	end
    % �팟��ID
    tmp = sscanf(str, 'exp_id = %s');
    if ~isempty(tmp),	para.exp_id = tmp;	end
    % ����(�B�e)���{�� (YYMMDD)
    tmp = sscanf(str, 'exp_date = %s');
    if ~isempty(tmp),	para.exp_date = tmp;	end
    
    % Parameter file��directory
    tmp = sscanf(str, 'para_dir = %s');
    if ~isempty(tmp),	files.para_dir = tmp;	end
    % Sham score file��directory
    tmp = sscanf(str, 'sham_score_dir = %s');
    if ~isempty(tmp),	files.sham_score_dir = tmp;	end
    % Data�ۑ�directory
    tmp = sscanf(str, 'save_dir = %s');
    if ~isempty(tmp),	files.save_dir = tmp;	end
    % ROI file��directory
    tmp = sscanf(str, 'roi_dir = %s');
    if ~isempty(tmp),	files.roi_dir = tmp;	end
    % DICOM file��directory
    tmp = sscanf(str, 'dicom_dir = %s');
    if ~isempty(tmp),	files.dicom_dir = tmp;	end
    % Template image file��directory
    tmp = sscanf(str, 'templ_image_dir = %s');
    if ~isempty(tmp),	files.templ_image_dir = tmp;	end
    % Parameter file
    tmp = sscanf(str, 'para_fname = %s');
    if ~isempty(tmp),	files.para_fname = tmp;	end
    % Sham score file
    tmp = sscanf(str, 'sham_score_fname = %s');
    if ~isempty(tmp),	files.sham_score_fname = tmp;	end
    % ROI EPI data��臒l
    tmp = sscanf(str, 'roi_epi_threshold = %f');
    if ~isempty(tmp),	files.roi_epi_threshold = tmp;	end
    % ROI�̐�
    tmp = sscanf(str, 'roi_fnum = %d');
    if ~isempty(tmp),	files.roi_fnum = tmp;	end
    % ROI file
    tmp = sscanf(str, 'roi_fname[%d] = %s');
    if length(tmp)>2,	files.roi_fname{tmp(1),1} = char(tmp(2:end)');	end
    % ROI data��臒l
    tmp = sscanf(str, 'roi_threshold[%d]');
    if ~isempty(tmp)
      tmp = sscanf(str, 'roi_threshold[%d] = %f');
      if length(tmp)==2
	files.roi_threshold{round(tmp(1)), 1} = tmp(2);
      else
	tmp = sscanf(str, 'roi_threshold[%d] = %s');
	files.roi_threshold{round(tmp(1)), 1} = char(tmp(2:end)');
      end
    end
    % WM file
    tmp = sscanf(str, 'wm_fname = %s');
    if ~isempty(tmp),	files.wm_fname = tmp;	end
    % WM data��臒l
    if strncmpi(str, 'wm_threshold', length('wm_threshold'))
      tmp = sscanf(str, 'wm_threshold = %f');
      if ~isempty(tmp),	files.wm_threshold = tmp;
      else
	tmp = sscanf(str, 'wm_threshold = %s');
	if ~isempty(tmp),	files.wm_threshold = tmp;	end
      end
    end
    % GS file
    tmp = sscanf(str, 'gs_fname = %s');
    if ~isempty(tmp),	files.gs_fname = tmp;	end
    % GS data��臒l
    if strncmpi(str, 'gs_threshold', length('gs_threshold'))
      tmp = sscanf(str, 'gs_threshold = %f');
      if ~isempty(tmp),	files.gs_threshold = tmp;
      else
	tmp = sscanf(str, 'gs_threshold = %s');
	if ~isempty(tmp),	files.gs_threshold = tmp;	end
      end
    end
    % CSF file
    tmp = sscanf(str, 'csf_fname = %s');
    if ~isempty(tmp),	files.csf_fname = tmp;	end
    % CSF data��臒l
    if strncmpi(str, 'csf_threshold', length('csf_threshold'))
      tmp = sscanf(str, 'csf_threshold = %f');
      if ~isempty(tmp),	files.csf_threshold = tmp;
      else
	tmp = sscanf(str, 'csf_threshold = %s');
	if ~isempty(tmp),	files.csf_threshold = tmp;	end
      end
    end
    % Template image file
    tmp = sscanf(str, 'templ_image_fname = %s');
    if ~isempty(tmp),	files.templ_image_fname = tmp;	end
    % DICOM file��file���̑O����
    tmp = sscanf(str, 'dicom_fnameB = %s');
    if ~isempty(tmp),	files.dicom_fnameB = tmp;	end

    % ���s��
    tmp = sscanf(str, 'trial_num = %d');
    if ~isempty(tmp),	scans.trial_num = tmp;	end
    % ���s���J�n���閘��scan��
    tmp = sscanf(str, 'pre_trial_scan_num = %d');
    if ~isempty(tmp),	scans.pre_trial_scan_num = tmp;	end
    % 1���s�ڂ̑O�����p��REST��������1��scan��
    tmp = sscanf(str, 'prep_rest1_scan_num = %d');
    if ~isempty(tmp),	scans.prep_rest1_scan_num = tmp;	end
    % 1���s�ڂ̑O�����p��REST��������2��scan��
    tmp = sscanf(str, 'prep_rest2_scan_num = %d');
    if ~isempty(tmp),	scans.prep_rest2_scan_num = tmp;	end
    % REST������scan��
    tmp = sscanf(str, 'rest_scan_num = %d');
    if ~isempty(tmp),	scans.rest_scan_num = tmp;	end
    % TEST������scan��
    tmp = sscanf(str, 'test_scan_num = %d');
    if ~isempty(tmp),	scans.test_scan_num = tmp;	end
    % TEST�����J�n���delay scan��
    tmp = sscanf(str, 'pre_test_delay_scan_num = %d');
    if ~isempty(tmp),	scans.pre_test_delay_scan_num = tmp;	end
    % TEST�����I�����delay scan��
    tmp = sscanf(str, 'post_test_delay_scan_num = %d');
    if ~isempty(tmp),	scans.post_test_delay_scan_num = tmp;	end
    % ���_�v�Z������scan��
    tmp = sscanf(str, 'calc_score_scan_num = %d');
    if ~isempty(tmp),	scans.calc_score_scan_num = tmp;	end
    % ���_�񎦏�����scan��
    tmp = sscanf(str, 'feedbk_score_scan_num = %d');
    if ~isempty(tmp),	scans.feedbk_score_scan_num = tmp;	end
    % Scan�Ԋu (sec)
    tmp = sscanf(str, 'TR = %f');
    if ~isempty(tmp),	scans.TR = tmp;	end
    % fMRI�f�[�^�̃m�C�Y����������scan��
    tmp = sscanf(str, 'regress_scan_num = %d');
    if ~isempty(tmp),	scans.regress_scan_num = tmp;	end
    % �팟�҂��Q�Ă��Ȃ������`�F�b�N���鎎�s��
    tmp = sscanf(str, 'sleep_check_trial_num = %d');
    if ~isempty(tmp)
      scans.sleep_check_trial_num = tmp;
      scans.sleep_check_trial = zeros(tmp,1);
    end
    % 1���s�ڂ̈ꎎ�s��scan��
    tmp = sscanf(str, 'first_trial_scan_num = %d');
    if ~isempty(tmp),	scans.first_trial_scan_num = tmp;	end
    % 2���s�ڈȍ~�̈ꎎ�s��scan��
    tmp = sscanf(str, 'trial_scan_num = %d');
    if ~isempty(tmp),	scans.trial_scan_num = tmp;	end
    % ��Scan��
    tmp = sscanf(str, 'total_scan_num = %d');
    if ~isempty(tmp),	scans.total_scan_num = tmp;	end
    % �팟�҂��Q�Ă��Ȃ����`�F�b�N���鎎�s�ԍ�
    tmp = sscanf(str, 'sleep_check_trial[%d] = %d');
    if length(tmp)==2,	scans.sleep_check_trial(tmp(1)) = tmp(2);	end

    % ���_���[�h
    tmp = sscanf(str, 'score_mode = %s');
    if ~isempty(tmp),	score.score_mode = tmp;	end

    % �]�̔��a (mm)
    tmp = sscanf(str, 'radius_of_brain = %f');
    if ~isempty(tmp),	score.radius_of_brain = tmp;	end
    % Scan���̔]�̈ړ��ʂ�臒l (mm)
    tmp = sscanf(str, 'FD_threshold = %f');
    if ~isempty(tmp),	score.FD_threshold = tmp;	end
    
    % ROI template��ROI�̑��֌W����臒l
    tmp = sscanf(str, 'corr_roi_template_threshold = %f');
    if ~isempty(tmp),	corr_roi_template_threshold = tmp;	end

    % ���K���z�����̕��ϒl
    tmp = sscanf(str, 'score_normrnd_mu = %f');
    if ~isempty(tmp),	score.normrnd_mu = tmp;	end
    % ���K���z�����̕W���΍�
    tmp = sscanf(str, 'score_normrnd_sigma = %f');
    if ~isempty(tmp),	score.normrnd_sigma = tmp;	end
    % Sham score�t�@�C���̓��_
    tmp = sscanf(str, 'sham_score[%d] = %f');
    if length(tmp) == 2
      n = round(tmp(1));
      score.sham_score(n,:) = tmp(2);
    end
    % ���_�̉����Ə����臒l
    tmp = sscanf(str, 'score_limit = (%f, %f)')';
    if length(tmp)==2,	score.score_limit = tmp;	end
    
    % ���s�J�n�g���K�[�M�����̓��͂⎋�ofeedback�o�͐擙�̓��o�͗p�c�[��
    tmp = sscanf(str, 'feedback_io_tool = %s');
    if ~isempty(tmp),	feedback.io_tool = tmp;	end
    % ���ofeedback�̒񎦃^�C�v
    tmp = sscanf(str, 'feedback_type = %s');
    if ~isempty(tmp),	feedback.feedback_type = tmp;	end
    % ���o�h����񎦂���screen�ԍ�
    tmp = sscanf(str, 'feedback_screen = %d');
    if ~isempty(tmp),	feedback.screen = tmp;	end
    % ���_��팟�҂ɒ񎦂���^�C�~���O
    tmp = sscanf(str, 'feedback_score_timing = %s');
    if ~isempty(tmp),	feedback.feedback_score_timing = tmp;	end
    % 1���s�ڂ̑O�����p��REST��������1�ł̃R�����g������
    tmp = sscanf(str, 'feedback_prep_rest1_comment = %s');
    if ~isempty(tmp),	feedback.prep_rest1_comment = tmp;	end
    % 1���s�ڂ̑O�����p��REST��������2�ł̃R�����g������
    tmp = sscanf(str, 'feedback_prep_rest2_comment = %s');
    if ~isempty(tmp),	feedback.prep_rest2_comment = tmp;	end
    % REST�����ł̃R�����g������
    tmp = sscanf(str, 'feedback_rest_comment = %s');
    if ~isempty(tmp),	feedback.rest_comment = tmp;	end
    % TEST�����ł̃R�����g������
    tmp = sscanf(str, 'feedback_test_comment = %s');
    if ~isempty(tmp),	feedback.test_comment = tmp;	end
    % TEST�������I��������A���_��񎦂���܂ł̊Ԃ̏����ł̃R�����g������
    tmp = sscanf(str, 'feedback_prep_score_comment = %s');
    if ~isempty(tmp),	feedback.prep_score_comment = tmp;	end
    % ���_�񎦏����ł̃R�����g������
    tmp = sscanf(str, 'feedback_score_comment = %s');
    if ~isempty(tmp),	feedback.score_comment = tmp;	end
    % ���_�̌v�Z�����s���̃R�����g������
    tmp = sscanf(str, 'feedback_ng_score_comment = %s');
    if ~isempty(tmp),	feedback.ng_score_comment = tmp;	end
    % �u���b�N�I�������ł̃R�����g������
    tmp = sscanf(str, 'feedback_finished_block_comment = %s');
    if ~isempty(tmp),	feedback.feedback_finished_block_comment = tmp;	end
    % �u���b�N�I�������̎��ofeedback�̒񎦎��� (sec)
    tmp = sscanf(str, 'feedback_finished_block_duration = %f');
    if ~isempty(tmp),	feedback.finished_block_duration = tmp;	end
    % �����_�̔��a(�~�� �g)
    tmp = sscanf(str, 'feedback_gaze_frame_r = %d');
    if ~isempty(tmp),	feedback.gaze_frame_r = tmp;	end
    % �����_�̔��a(�~�� �h)
    tmp = sscanf(str, 'feedback_gaze_fill_r = %d');
    if ~isempty(tmp),	feedback.gaze_fill_r = tmp;	end
    % �����_�̔��a(�팟�҂��Q�Ă��Ȃ����`�F�b�N�p)
    tmp = sscanf(str, 'feedback_sleep_fill_r = %d');
    if ~isempty(tmp),	feedback.sleep_fill_r = tmp;	end
    % ���_�̏���l�ł̓��_��񎦂���~�̔��a
    tmp = sscanf(str, 'feedback_max_score_r = %d');
    if ~isempty(tmp),	feedback.max_score_r = tmp;	end

    % Stanford���C�ړx����t���O
    tmp = sscanf(str, 'sss_flag = %d');
    if ~isempty(tmp),	sss.sss_flag = tmp;	end
    % Stanford���C�ړx����摜file��directory
    tmp = sscanf(str, 'sss_image_dir = %s');
    if ~isempty(tmp),	sss.sss_image_dir = tmp;	end
    % Stanford���C�ړx����摜file��
    tmp = sscanf(str, 'sss_image_fname = %s');
    if ~isempty(tmp),	sss.sss_image_fname = tmp;	end
    
    % ROI volume graph�\���t���O
    tmp = sscanf(str, 'roi_vol_graph_flag = %d');
    if ~isempty(tmp),	para.roi_vol_graph_flag = tmp;	end

    % ����(�팟��)���O
    tmp = sscanf(str, 'dicom_info_patient_name = %s');
    if ~isempty(tmp),	dicom_info.patient_name = tmp;	end
    % ����(�팟��)ID
    tmp = sscanf(str, 'dicom_info_patient_id = %s');
    if ~isempty(tmp),	dicom_info.patient_id = tmp;	end
    % ����(�B�e)���{�� (YYMMDD)
    tmp = sscanf(str, 'dicom_info_study_date = %s');
    if ~isempty(tmp),	dicom_info.study_date = tmp;	end
    % �{�ݖ�
    tmp = sscanf(str, 'dicom_info_institution_name = %s');
    if ~isempty(tmp),	dicom_info.institution_name = tmp;	end
	    
    % receiver��
    tmp = sscanf(str, 'receiver_num = %d');
    if ~isempty(tmp),	para.receiver_num = tmp;	end
    % TCP/IP port�ԍ�
    tmp = sscanf(str, 'msocket_port[%d] = %d');
    if length(tmp),	msocket.port(tmp(1),1) = tmp(2);	end
    % server�̃z�X�g��
    tmp = sscanf(str, 'msocket_server_name = %s');
    if ~isempty(tmp),	msocket.server_name = tmp;	end

  end	% <-- End of 'if str == -1, break ... else'
end	% <-- End of 'while true'

para.files = files;
para.scans = scans;
para.score = score;
para.feedback = feedback;
para.sss = sss;
para.dicom_info = dicom_info;
para.msocket = msocket;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_para_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [data] = load_data_para(fd, para)
% ASCII�`���̃f�[�^�t�@�C����������f�[�^��ǂށB
% function [exp_data] = load_data_para(fd, para)
% 
% [input argument]
% fd   : ASCII�`���̃f�[�^�t�@�C���̃t�@�C�����ʎq
% para : �����p�����[�^���Ǘ�����\����
% 
% [output argument]
% data : �����p�����[�^���Ǘ�����\����


data = [];

fseek(fd,0,-1);		% �t�@�C���|�C���^���t�@�C���̐擪�ɂ���B
while true
  str = fgets(fd);
  if str == -1, break;	% End of file
  else
    % ��M��������������Scan��
    tmp = sscanf(str, 'received_scan_num = %d');
    if length(tmp),	data.received_scan_num = tmp;	end
    % ROI��voxel��
    tmp = sscanf(str, 'roi_vox_num[%d] = %d');
    if length(tmp)==2,	data.roi_vox_num(tmp(1)) = tmp(2);	end
    % WM�f�[�^��voxel��
    tmp = sscanf(str, 'wm_vox_num = %d');
    if length(tmp),	data.wm_vox_num = tmp;	end
    % GS�f�[�^��voxel��
    tmp = sscanf(str, 'gs_vox_num = %d');
    if length(tmp),	data.gs_vox_num = tmp;	end
    % CSF�f�[�^��voxel��
    tmp = sscanf(str, 'csf_vox_num = %d');
    if length(tmp),	data.csf_vox_num = tmp;	end
    % �escan�ł�WM�̐M���l�̕��ϒl
    tmp = sscanf(str, 'wm_signal[%d] = %f');
    if length(tmp)==2,	data.wm_signal( round(tmp(1)), 1 ) = tmp(2);	end
    % �escan�ł�GS�̐M���l�̕��ϒl
    tmp = sscanf(str, 'gs_signal[%d] = %f');
    if length(tmp)==2,	data.gs_signal( round(tmp(1)), 1 ) = tmp(2);	end
    % �escan�ł�CSF�̐M���l�̕��ϒl
    tmp = sscanf(str, 'csf_signal[%d] = %f');
    if length(tmp)==2,	data.csf_signal( round(tmp(1)), 1 ) = tmp(2);	end
    tmp = sscanf(str, 'realign_val[%d]');
    % �escan�ł�realignment parameter
    if ~isempty(tmp),
      s = length( sprintf('realign_val[%d] = ', tmp) )+1;
      tmp2 = sscanf(str(s:end), '%e ');
      if ~isempty(tmp2),	data.realign_val(tmp,:) = tmp2;	end
    end

    % Scan���̔]�̈ړ��� [mm]
    tmp = sscanf(str, 'FD[%d] = %f');
    if length(tmp)==2,	data.FD( round(tmp(1)), 1 ) = tmp(2);	end
    
    % �escan�ł�ROI�̐M���l��ROI Template�f�[�^�̑��֌W��
    tmp = sscanf(str, 'corr_roi_template[%d]');
    if ~isempty(tmp),
      s = length( sprintf('corr_roi_template[%d] = ', tmp) )+1;
      tmp2 = sscanf(str(s:end), '%f ');
      if ~isempty(tmp2),	data.corr_roi_template(tmp,:) = tmp2;	end
    end

    % Scan�̌v���f�[�^�𓾓_�̌v�Z�ɍ̗p ���Ȃ�/����
    tmp = sscanf(str, 'ng_scan[%d] = %f');
    if length(tmp)==2
      data.ng_scan( round(tmp(1)), 1 ) = logical( tmp(2) );
    end
    
    % Stanford���C�ړxLevel
    tmp = sscanf(str, 'sss_level = %d');
    if length(tmp),	data.sss_level = tmp;	end
    if strncmpi(str, 'sss_level = nan', length('sss_level = nan'));
      data.sss_level = NaN;
    end
    % Stanford���C�ړx�Ɋւ���R�����g������
    if strncmp(str, 'sss_comment = ', length('sss_comment = '))
      % �Ō�̉��s����(str(end))�͏���
      data.sss_comment = str( length('sss_comment = ')+1:end-1 );
    end
    
    % �팟�҂��Q�Ă��Ȃ����̃`�F�b�N(1:OK.0:NG)����
    tmp = sscanf(str, 'sleep_check(%d) = %d');
    if length(tmp)==2,	data.sleep_check(tmp(1),1) = tmp(2);	end

    % �e���s��label�l
    tmp = sscanf(str, 'label_ROI%d[%d] = %f');
    if length(tmp)==3
      roi = round(tmp(1));
      trial = round(tmp(2));
      data.label(trial, roi) = tmp(3);
    end
    % �e���s�̓��_
    tmp = sscanf(str, 'source_score[%d] = %f');
    if length(tmp)==2,	data.source_score( round(tmp(1)), 1 ) = tmp(2);	end
    tmp = sscanf(str, 'score[%d] = %f');
    if length(tmp)==2,	data.score( round(tmp(1)), 1 ) = tmp(2);	end
  end	% <-- End of 'if str == -1, ... else ...'
end	% <-- End of 'while(true)'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_data_para()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
