function [str1, str2] = make_parameter_string(define, para, data)
% function [str1, str2] = make_parameter_string(para, data)
% �����p�����[�^��������쐬����B
% 
% [input argument]
% define : define�ϐ����Ǘ�����\����
% para : �p�����[�^�\����
% data : �����f�[�^�\����
% 
% [output argument]
% str1 : ��v�Ȏ����p�����[�^�̕�����(cell�z��)
% str2 : �S�Ă̎����p�����[�^�̕�����(cell�z��)

% ��v�Ȏ����p�����[�^�̕�������쐬����B
str1 = make_main_para_string(define, para, data);
% �S�Ă̎����p�����[�^�̕�������쐬����B
str2 = make_all_para_string(define, para, data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_parameter_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [str] = make_main_para_string(define, para, data)
% function [str] = make_main_para_string(para, data)
% ��v�Ȏ����p�����[�^�̕�������쐬����B
% 
% [input argument]
% define : define�ϐ����Ǘ�����\����
% para : �p�����[�^�\����
% data : �����f�[�^�\����
% 
% [output argument]
% str : �����p�����[�^������(cell�z��)

str = {};


% Block�ԍ���������������쐬����B
str{end+1} = sprintf('current_block = %d', para.current_block);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI�f�[�^�̃m�C�Y�����������@��������������쐬����B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str{end+1} = sprintf('denoising_method = %s',...
    get_field_name(para.denoising_method, define.denoising_method));
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���_���[�h�̓��e����������������쐬����B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str{end+1} = sprintf('score_mode = %s',...
    get_field_name(para.score.score_mode, define.score_mode));
switch para.score.score_mode
  case define.score_mode.CALC_SCORE
    % �]�����p�^�[�����狁�߂����_���̗p����B
  case define.score_mode.SHAM_RAND_SCORE
    % ���K���z�����ŋ��߂����_���̗p����B
    str{end+1} = sprintf('normal random number(mu:%.2f, sigma:%.2f)',...
	para.score.normrnd_mu, para.score.normrnd_sigma);
  case define.score_mode.SHAM_SCORE_FILE
    % Sham score�t�@�C���̓��_���̗p����B
    for trial=1:para.scans.trial_num
      str{end+1} = sprintf('sham_score[%d] = %f',...
	  trial, para.score.sham_score(trial));
    end
  otherwise
    error('Undefined : score_mode = %d', para.score.score_mode);
end

str{end+1} = sprintf('score_limit=(MIN:%.2f, MAX:%.2f)',...
    para.score.score_limit);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �]�����p�^�[�����瓾�_���v�Z���� '�ȊO�e�̏�����
% ROI file���w�肵�Ă��Ȃ��ꍇ�B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if para.score.score_mode ~= define.score_mode.CALC_SCORE &...
      para.files.roi_fnum == 0
  if ispc
    str{end+1} = sprintf(...
	'WARNING : ROI file���w�肵�Ă��Ȃ��̂ŁAROI�̖ڕW�̃p�^�[���Ƃ̗ގ��x�͌v�Z���܂���B\n');
  else
    str{end+1} = sprintf('WARNING : roi_fnum=%d.\n', para.files.roi_fnum);
  end
end


% �팟�҂��Q�Ă��Ȃ����`�F�b�N���鎎�s�ԍ���������������쐬����B
tmp = sprintf(' %d,', para.scans.sleep_check_trial);
str{end+1} = sprintf('sleep_check_trial =%s', tmp(1:end-1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_main_para_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [str] = make_all_para_string(define, para, data)
% function [str] = make_all_para_string(define, para, data)
% �S�Ă̎����p�����[�^�̕�������쐬����B
% 
% [input argument]
% define : define�ϐ����Ǘ�����\����
% para : �p�����[�^�\����
% data : �����f�[�^�\����
% 
% [output argument]
% str : �����p�����[�^������(cell�z��)


str = {};


% Block�ԍ�
str{end+1} = sprintf('current_block = %d', para.current_block);
% �팟��ID( '����(�팟��)���O_����(�팟��)ID' )
str{end+1} = sprintf('exp_id = %s', para.exp_id);
% ����(�B�e)���{��(YYMMDD)
str{end+1} = sprintf('exp_date = %s', para.exp_date);

str{end+1} = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI�f�[�^�̃m�C�Y�����������@
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str{end+1} = sprintf('denoising_method = %s',...
    get_field_name(para.denoising_method, define.denoising_method));
    
str{end+1} = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File / Directory ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter file��directory
str{end+1} = sprintf('para_dir = %s', para.files.para_dir);
% Sham score file��directory
str{end+1} = sprintf('sham_score_dir = %s', para.files.sham_score_dir);
% Data�ۑ�directory
str{end+1} = sprintf('save_dir = %s', para.files.save_dir);
% ROI file��directory
str{end+1} = sprintf('roi_dir = %s', para.files.roi_dir);
% DICOM file��directory
str{end+1} = sprintf('dicom_dir = %s', para.files.dicom_dir);
% Template image file��directory
str{end+1} = sprintf('templ_image_dir = %s', para.files.templ_image_dir);
% Parameter file
str{end+1} = sprintf('para_fname = %s', para.files.para_fname);
% Sham score file
str{end+1} = sprintf('sham_score_fname = %s', para.files.sham_score_fname);
% ROI EPI data��臒l
if ischar(para.files.roi_epi_threshold)
  str{end+1} = sprintf('roi_epi_threshold = %s',...
      para.files.roi_epi_threshold);
else
  str{end+1} = sprintf('roi_epi_threshold = %f',...
      para.files.roi_epi_threshold);
end
% ROI�̐�
str{end+1} = sprintf('roi_fnum = %d', para.files.roi_fnum);
for ii=1:para.files.roi_fnum
  % ROI file
  str{end+1} = sprintf('roi_fname[%d] = %s', ii, para.files.roi_fname{ii});
  % ROI data��臒l
  if ischar(para.files.roi_threshold{ii})
    str{end+1} = sprintf('roi_threshold[%d] = %s',...
	ii, para.files.roi_threshold{ii});
  else
    str{end+1} = sprintf('roi_threshold[%d] = %f',...
	ii, para.files.roi_threshold{ii});
  end
end
% WM file
str{end+1} = sprintf('wm_fname = %s', para.files.wm_fname);
% WM data��臒l
if ischar(para.files.wm_threshold)
  str{end+1} = sprintf('wm_threshold = %s', para.files.wm_threshold);
else
  str{end+1} = sprintf('wm_threshold = %f', para.files.wm_threshold);
end
% GS file
str{end+1} = sprintf('gs_fname = %s', para.files.gs_fname);
% GS data��臒l
if ischar(para.files.gs_threshold)
  str{end+1} = sprintf('gs_threshold = %s', para.files.gs_threshold);
else
  str{end+1} = sprintf('gs_threshold = %f', para.files.gs_threshold);
end
% CSF file
str{end+1} = sprintf('csf_fname = %s', para.files.csf_fname);
% CSF data��臒l
if ischar(para.files.csf_threshold)
  str{end+1} = sprintf('csf_threshold = %s', para.files.csf_threshold);
else
  str{end+1} = sprintf('csf_threshold = %f', para.files.csf_threshold);
end
% Template image file
str{end+1} = sprintf('templ_image_fname = %s', para.files.templ_image_fname);
% DICOM file��file���̑O����
str{end+1} = sprintf('dicom_fnameB = %s', para.files.dicom_fnameB);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI��scan�����Ɋ֌W����p�����[�^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���s��
str{end+1} = sprintf('trial_num = %d', para.scans.trial_num);
% ���s���J�n���閘��scan��
str{end+1} = sprintf('pre_trial_scan_num = %d', para.scans.pre_trial_scan_num);
% 1���s�ڂ̑O�����pREST��������1��scan��
str{end+1} = sprintf('prep_rest1_scan_num = %d',...
    para.scans.prep_rest1_scan_num);
% 1���s�ڂ̑O�����pREST��������2��scan��
str{end+1} = sprintf('prep_rest2_scan_num = %d',...
    para.scans.prep_rest2_scan_num);
% REST������scan��
str{end+1} = sprintf('rest_scan_num = %d', para.scans.rest_scan_num);
% TEST������scan��
str{end+1} = sprintf('test_scan_num = %d', para.scans.test_scan_num);
% TEST�����J�n���delay scan��
str{end+1} = sprintf('pre_test_delay_scan_num = %d',...
    para.scans.pre_test_delay_scan_num);
% TEST�����I�����delay scan��
str{end+1}=sprintf('post_test_delay_scan_num = %d',...
    para.scans.post_test_delay_scan_num);
% ���_�v�Z������scan��
str{end+1} = sprintf('calc_score_scan_num = %d',...
    para.scans.calc_score_scan_num);
% ���_�񎦏�����scan��
str{end+1} = sprintf('feedbk_score_scan_num = %d',...
    para.scans.feedbk_score_scan_num);
% Scan�Ԋu (sec)
str{end+1} = sprintf('TR = %f [sec]', para.scans.TR);
% fMRI�f�[�^�̃m�C�Y���������ɗ��p����scan��
str{end+1} = sprintf('regress_scan_num = %d',...
    para.scans.regress_scan_num);
% �팟�҂��Q�Ă��Ȃ������`�F�b�N���鎎�s��
str{end+1} = sprintf('sleep_check_trial_num = %d',...
    para.scans.sleep_check_trial_num);
% 1���s�ڂ̈ꎎ�s��scan��
str{end+1} = sprintf('first_trial_scan_num = %d',...
    para.scans.first_trial_scan_num);
% 2���s�ڈȍ~�̈ꎎ�s��scan��
str{end+1} = sprintf('trial_scan_num = %d', para.scans.trial_scan_num);
% ��Scan��
str{end+1} = sprintf('total_scan_num = %d', para.scans.total_scan_num);
% �팟�҂��Q�Ă��Ȃ����`�F�b�N���鎎�s�ԍ�
for ii=1:para.scans.sleep_check_trial_num
  str{end+1} = sprintf('sleep_check_trial[%d] = %d',...
      ii, para.scans.sleep_check_trial(ii));
end

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���_�v�Z�p�p�����[�^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���_���[�h
str{end+1} = sprintf('score_mode = %s',...
    get_field_name(para.score.score_mode, define.score_mode));
% �]�̔��a (mm)
str{end+1} = sprintf('radius_of_brain = %f [mm]', para.score.radius_of_brain);
% Scan���̔]�̈ړ��ʂ�臒l (mm)
str{end+1} = sprintf('FD_threshold = %f [mm]', para.score.FD_threshold);
% ROI template��ROI�̑��֌W����臒l
str{end+1} = sprintf('corr_roi_template_threshold = %f',...
    para.score.corr_roi_template_threshold);
% ���K���z�����̕��ϒl
str{end+1} = sprintf('score_normrnd_mu = %f', para.score.normrnd_mu);
% ���K���z�����̕W���΍�
str{end+1} = sprintf('score_normrnd_sigma = %f', para.score.normrnd_sigma);
% Sham score�t�@�C���̓��_
if para.score.score_mode == define.score_mode.SHAM_SCORE_FILE
  % Sham score�t�@�C���̓��_(para.score.sham_score)�́A
  % Sham score�t�@�C���̓��_���̗p�������
  % (para.score.score_mode=SHAM_SCORE_FILE)�̏ꍇ�̂ݐݒ肳���B
  % --------------------------------------------------------------
  % ( ���̎��������ł�para.score.sham_score�z��͋� )
  for trial=1:para.scans.trial_num
    str{end+1} = sprintf('sham_score[%d] = %f',...
	trial, para.score.sham_score(trial));
  end
end
% ���_�̉����Ə����臒l
str{end+1} = sprintf('score_limit = (%.2f, %.2f)', para.score.score_limit);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���ofeedback�p�����[�^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���s�J�n�g���K�[�M�����̓��͂⎋�ofeedback�o�͐擙�̓��o�͗p�c�[��
str{end+1} = sprintf('feedback_io_tool = %s',...
    get_field_name(para.feedback.io_tool, define.feedback.io_tool));
% ���ofeedback�̒񎦃^�C�v
str{end+1} = sprintf('feedback_type = %s',...
    get_field_name(para.feedback.feedback_type,...
    define.feedback.feedback_type));
% ���_��팟�҂ɒ񎦂���^�C�~���O
str{end+1} = sprintf('feedback_score_timing = %s',...
    get_field_name(para.feedback.feedback_score_timing,...
    define.feedback.feedback_score_timing));
% ���o�h����񎦂���screen�ԍ�
str{end+1} = sprintf('feedback_screen = %d', para.feedback.screen);
% 1���s�ڂ̑O�����pREST��������1�ł̃R�����g������
str{end+1} = sprintf('feedback_prep_rest1_comment = %s',...
    para.feedback.prep_rest1_comment);
% 1���s�ڂ̑O�����pREST��������2�ł̃R�����g������
str{end+1} = sprintf('feedback_prep_rest2_comment = %s',...
    para.feedback.prep_rest2_comment);
% REST�����ł̃R�����g������
str{end+1} = sprintf('feedback_rest_comment = %s', para.feedback.rest_comment);
% TEST�����ł̃R�����g������
str{end+1} = sprintf('feedback_test_comment = %s', para.feedback.test_comment);
% TEST�������I��������A���_��񎦂���܂ł̊Ԃ̏����ł̃R�����g������
str{end+1} = sprintf('feedback_prep_score_comment = %s',...
    para.feedback.prep_score_comment);
% ���_�񎦏����ł̃R�����g������
str{end+1} = sprintf('feedback_score_comment = %s',...
    para.feedback.score_comment);
% ���_�̌v�Z�����s���̃R�����g������
str{end+1} = sprintf('feedback_ng_score_comment = %s',...
    para.feedback.ng_score_comment);
% �u���b�N�I�������ł̃R�����g������
str{end+1} = sprintf('feedback_finished_block_comment = %s',...
    para.feedback.finished_block_comment);
% �u���b�N�I�������̎��ofeedback�̒񎦎��� (sec)
str{end+1} = sprintf('feedback_finished_block_duration = %f [sec]',...
    para.feedback.finished_block_duration);
% �����_�̔��a(�~�� �g)
str{end+1} = sprintf('feedback_gaze_frame_r = %d',...
    para.feedback.gaze_frame_r);
% �����_�̔��a(�~�� �h)
str{end+1} = sprintf('feedback_gaze_fill_r = %d',...
    para.feedback.gaze_fill_r);
% �����_�̔��a(�팟�҂��Q�Ă��Ȃ����`�F�b�N�p)
str{end+1} = sprintf('feedback_sleep_fill_r = %d',...
    para.feedback.sleep_fill_r);
% ���_�̏���l�ł̓��_��񎦂���~�̔��a
str{end+1} = sprintf('feedback_max_score_r = %d',...
    para.feedback.max_score_r);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford sleepiness scale(�X�^���t�H�[�h���C�ړx)
% �Ɋւ���p�����[�^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford���C�ړx����t���O
str{end+1} = sprintf('sss_flag = %d', para.sss.sss_flag);
% Stanford���C�ړx����摜file��directory
str{end+1} = sprintf('sss_image_dir = %s', para.sss.sss_image_dir);
% Stanford���C�ړx����摜file��
str{end+1} = sprintf('sss_image_fname = %s', para.sss.sss_image_fname);

str{end+1} = '';


% ROI volume graph�\���t���O
str{end+1} = sprintf('roi_vol_graph_flag = %d', para.roi_vol_graph_flag);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOM�t�@�C���̎B�e���(dicom_info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����(�팟��)���O
str{end+1} = sprintf('dicom_info_patient_name = %s',...
    para.dicom_info.patient_name);
% ����(�팟��)ID
str{end+1} = sprintf('dicom_info_patient_id = %s',...
    para.dicom_info.patient_id);
% ����(�B�e)���{�� (YYMMDD)
str{end+1} = sprintf('dicom_info_study_date = %s',...
    para.dicom_info.study_date);
% �{�ݖ�
str{end+1} = sprintf('dicom_info_institution_name = %s',...
    para.dicom_info.institution_name);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ʐM�o�H(msocket)�Ɋւ���p�����[�^
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receiver��
str{end+1} = sprintf('receiver_num = %d', para.receiver_num);
% TCP/IP port�ԍ�
for ii=1:length(para.msocket.port)
  str{end+1} = sprintf('msocket_port[%d] = %d', ii, para.msocket.port(ii));
end
% msocket server��host�� (neurofeedback�v���O������host��)
str{end+1} = sprintf('msocket_server_name = %s', para.msocket.server_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_all_para_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
