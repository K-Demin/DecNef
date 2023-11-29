function [scan_condition, calc_score_scan, score_target_scans] =...
    set_scan_condition_calibration(define, para)
% function [scan_condition, calc_score_scan, score_target_scans] =...
% 			set_scan_condition(define, para)
% �escan�̉ۑ�������Ǘ�����z�� �� 
% �e���s�̓��_���v�Z����ׂɕK�v��scan�f�[�^�����Ǘ�����z�� ��
% �e���s�̓��_�v�Z�Ώۂ�scan�̊J�n/�I���ԍ����Ǘ�����z��
% ��ݒ肷��B
% 
% [input argument]
% define : define�ϐ����Ǘ�����\����
% para   : �����p�����[�^�\����
% 
% [output argument]
% scan_condition : �escan�̉ۑ�������Ǘ�����z��
% calc_score_scan: �e���s�̓��_���v�Z����ׂɕK�v��scan�f�[�^�����Ǘ�����z��
%                  (create_global.m����create_para()�̃R�����g�Q��)
% score_target_scans : �e���s�̓��_�v�Z�Ώۂ�scan�̊J�n/�I���ԍ����Ǘ�����z��
%                  (create_global.m����create_para()�̃R�����g�Q��)
    
scan_condition = zeros(para.scans.total_scan_num,1);
calc_score_scan = nan(para.scans.trial_num,1);
score_target_scans = nan(para.scans.trial_num,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI�v���J�n��ŁA���s�J�n�O��Ԃ�scan��ݒ肷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scan_condition(1:para.scans.pre_trial_scan_num) =...
    define.scan_condition.PRE_TRIAL;
cnt = para.scans.pre_trial_scan_num;

for ii=1:para.scans.trial_num
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REST������scan��ݒ肷��B
  % -------------------------------------------------
  % 1���s�ڂ̏ꍇ�́APREP_REST1���� �� PREP_REST2���� 
  % �� REST������ݒ肵�A2���s�ڈȍ~�̏ꍇ�́AREST����
  % ��ݒ肷��B
  % (create_global.m����create_para()�̃R�����g�Q��)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ii == 1	% PREP REST������scan��ݒ肷��B (1���s��)
    % PREP REST1������scan��ݒ肷��B
    if para.scans.prep_rest1_scan_num
      scan_condition(cnt+1:cnt+para.scans.prep_rest1_scan_num) =...
	  define.scan_condition.PREP_REST1;
      cnt = cnt+para.scans.prep_rest1_scan_num;
    end
    % PREP REST2������scan��ݒ肷��B
    if para.scans.prep_rest2_scan_num
      scan_condition(cnt+1:cnt+para.scans.prep_rest2_scan_num) =...
	  define.scan_condition.PREP_REST2;
      cnt = cnt+para.scans.prep_rest2_scan_num;
    end
  end
  % REST������scan��ݒ肷��B
  if para.scans.rest_scan_num
    scan_condition(cnt+1:cnt+para.scans.rest_scan_num) =...
	define.scan_condition.REST;
    cnt = cnt+para.scans.rest_scan_num;
  end

  if para.scans.test_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST������scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.test_scan_num) =...
	define.scan_condition.TEST;
    test_start_scan = cnt+1;	% TEST������1scan�ڂ�scan�ԍ�
    cnt = cnt+para.scans.test_scan_num;
    % �e���s�̓��_���v�Z����ׂɕK�v��scan�f�[�^�� ��
    % (TEST�����I�����delay scan�̍ŏIscan�ԍ�)
    % �e���s�̓��_�v�Z�Ώۂ�scan�̊J�n/�I���ԍ�
    % ��ݒ肷��B
    if para.scans.calc_score_scan_num
      % (*)
      % ���_�v�Z������scan��(para.scans.calc_score_scan_num)��
      % 1�ȏ�̒l���ݒ肳��Ă���ꍇ�̂�calc_score_scan�z�� ��
      % score_target_scans�z�� ��ݒ肷��B
      % (���_�v�Z������scan����0�̏ꍇ�͓��_���v�Z���Ȃ�)
      % (create_global.m����create_para()�̃R�����g�Q��)
      calc_score_scan(ii) = cnt+para.scans.post_test_delay_scan_num;
      
      % ���_�v�Z�Ώ�scan�̊J�n�ԍ�
      score_target_scans(ii,1) =...
	  test_start_scan+para.scans.pre_test_delay_scan_num;
      % ���_�v�Z�Ώ�scan�̏I���ԍ�
      score_target_scans(ii,2) = cnt+para.scans.post_test_delay_scan_num;
    end
  end
  
  if para.scans.post_test_delay_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST�����I�����delay scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.post_test_delay_scan_num) =...
	define.scan_condition.DELAY;
    cnt = cnt+para.scans.post_test_delay_scan_num;
  end
  
  if para.scans.rating_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST�����I�����delay scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.rating_scan_num) =...
	define.scan_condition.RATING;
    cnt = cnt+para.scans.rating_scan_num;
  end
  
  if para.scans.rating_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST�����I�����delay scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.rating_scan_num) =...
	define.scan_condition.RATINGPAIN;
    cnt = cnt+para.scans.rating_scan_num;
  end
  
  if para.scans.post_test_delay_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST�����I�����delay scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1) =...
	define.scan_condition.DELAY;
    cnt = cnt+1;
  end
  
  if para.scans.rating_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST�����I�����delay scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.rating_scan_num) =...
	define.scan_condition.RATINGUNPL;
    cnt = cnt+para.scans.rating_scan_num;
  end
  
  if para.scans.post_test_delay_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST�����I�����delay scan��ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1) =...
	define.scan_condition.DELAY;
    cnt = cnt+1;
  end
  
  if para.scans.calc_score_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % ���_�v�Z������ݒ肷��B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.calc_score_scan_num) =...
	define.scan_condition.CALC_SCORE;
    cnt = cnt+para.scans.calc_score_scan_num;
  end
  
%   if para.scans.feedbk_score_scan_num
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % ���_�񎦏�����ݒ肷��B
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     scan_condition(cnt+1:cnt+para.scans.feedbk_score_scan_num) =...
% 	define.scan_condition.FEEDBACK_SCORE;
%     cnt = cnt+para.scans.feedbk_score_scan_num;
%   end
end	% <-- End of 'for ii=1:para.scans.trial_num'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_scan_condition()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
