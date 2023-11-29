function [scan_condition, calc_score_scan, score_target_scans] =...
    set_scan_condition_calibration(define, para)
% function [scan_condition, calc_score_scan, score_target_scans] =...
% 			set_scan_condition(define, para)
% 各scanの課題条件を管理する配列 と 
% 各試行の得点を計算する為に必要なscanデータ数を管理する配列 と
% 各試行の得点計算対象のscanの開始/終了番号を管理する配列
% を設定する。
% 
% [input argument]
% define : define変数を管理する構造体
% para   : 実験パラメータ構造体
% 
% [output argument]
% scan_condition : 各scanの課題条件を管理する配列
% calc_score_scan: 各試行の得点を計算する為に必要なscanデータ数を管理する配列
%                  (create_global.m内のcreate_para()のコメント参照)
% score_target_scans : 各試行の得点計算対象のscanの開始/終了番号を管理する配列
%                  (create_global.m内のcreate_para()のコメント参照)
    
scan_condition = zeros(para.scans.total_scan_num,1);
calc_score_scan = nan(para.scans.trial_num,1);
score_target_scans = nan(para.scans.trial_num,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI計測開始後で、試行開始前状態のscanを設定する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scan_condition(1:para.scans.pre_trial_scan_num) =...
    define.scan_condition.PRE_TRIAL;
cnt = para.scans.pre_trial_scan_num;

for ii=1:para.scans.trial_num
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % REST条件のscanを設定する。
  % -------------------------------------------------
  % 1試行目の場合は、PREP_REST1条件 と PREP_REST2条件 
  % と REST条件を設定し、2試行目以降の場合は、REST条件
  % を設定する。
  % (create_global.m内のcreate_para()のコメント参照)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if ii == 1	% PREP REST条件のscanを設定する。 (1試行目)
    % PREP REST1条件のscanを設定する。
    if para.scans.prep_rest1_scan_num
      scan_condition(cnt+1:cnt+para.scans.prep_rest1_scan_num) =...
	  define.scan_condition.PREP_REST1;
      cnt = cnt+para.scans.prep_rest1_scan_num;
    end
    % PREP REST2条件のscanを設定する。
    if para.scans.prep_rest2_scan_num
      scan_condition(cnt+1:cnt+para.scans.prep_rest2_scan_num) =...
	  define.scan_condition.PREP_REST2;
      cnt = cnt+para.scans.prep_rest2_scan_num;
    end
  end
  % REST条件のscanを設定する。
  if para.scans.rest_scan_num
    scan_condition(cnt+1:cnt+para.scans.rest_scan_num) =...
	define.scan_condition.REST;
    cnt = cnt+para.scans.rest_scan_num;
  end

  if para.scans.test_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件のscanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.test_scan_num) =...
	define.scan_condition.TEST;
    test_start_scan = cnt+1;	% TEST条件の1scan目のscan番号
    cnt = cnt+para.scans.test_scan_num;
    % 各試行の得点を計算する為に必要なscanデータ数 と
    % (TEST条件終了後のdelay scanの最終scan番号)
    % 各試行の得点計算対象のscanの開始/終了番号
    % を設定する。
    if para.scans.calc_score_scan_num
      % (*)
      % 得点計算条件のscan数(para.scans.calc_score_scan_num)に
      % 1以上の値が設定されている場合のみcalc_score_scan配列 と
      % score_target_scans配列 を設定する。
      % (得点計算条件のscan数が0の場合は得点を計算しない)
      % (create_global.m内のcreate_para()のコメント参照)
      calc_score_scan(ii) = cnt+para.scans.post_test_delay_scan_num;
      
      % 得点計算対象scanの開始番号
      score_target_scans(ii,1) =...
	  test_start_scan+para.scans.pre_test_delay_scan_num;
      % 得点計算対象scanの終了番号
      score_target_scans(ii,2) = cnt+para.scans.post_test_delay_scan_num;
    end
  end
  
  if para.scans.post_test_delay_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件終了後のdelay scanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.post_test_delay_scan_num) =...
	define.scan_condition.DELAY;
    cnt = cnt+para.scans.post_test_delay_scan_num;
  end
  
  if para.scans.rating_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件終了後のdelay scanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.rating_scan_num) =...
	define.scan_condition.RATING;
    cnt = cnt+para.scans.rating_scan_num;
  end
  
  if para.scans.rating_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件終了後のdelay scanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.rating_scan_num) =...
	define.scan_condition.RATINGPAIN;
    cnt = cnt+para.scans.rating_scan_num;
  end
  
  if para.scans.post_test_delay_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件終了後のdelay scanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1) =...
	define.scan_condition.DELAY;
    cnt = cnt+1;
  end
  
  if para.scans.rating_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件終了後のdelay scanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.rating_scan_num) =...
	define.scan_condition.RATINGUNPL;
    cnt = cnt+para.scans.rating_scan_num;
  end
  
  if para.scans.post_test_delay_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TEST条件終了後のdelay scanを設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1) =...
	define.scan_condition.DELAY;
    cnt = cnt+1;
  end
  
  if para.scans.calc_score_scan_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 得点計算条件を設定する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scan_condition(cnt+1:cnt+para.scans.calc_score_scan_num) =...
	define.scan_condition.CALC_SCORE;
    cnt = cnt+para.scans.calc_score_scan_num;
  end
  
%   if para.scans.feedbk_score_scan_num
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     % 得点提示条件を設定する。
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     scan_condition(cnt+1:cnt+para.scans.feedbk_score_scan_num) =...
% 	define.scan_condition.FEEDBACK_SCORE;
%     cnt = cnt+para.scans.feedbk_score_scan_num;
%   end
end	% <-- End of 'for ii=1:para.scans.trial_num'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_scan_condition()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
