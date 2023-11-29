function [str1, str2] = make_parameter_string(define, para, data)
% function [str1, str2] = make_parameter_string(para, data)
% 実験パラメータ文字列を作成する。
% 
% [input argument]
% define : define変数を管理する構造体
% para : パラメータ構造体
% data : 実験データ構造体
% 
% [output argument]
% str1 : 主要な実験パラメータの文字列(cell配列)
% str2 : 全ての実験パラメータの文字列(cell配列)

% 主要な実験パラメータの文字列を作成する。
str1 = make_main_para_string(define, para, data);
% 全ての実験パラメータの文字列を作成する。
str2 = make_all_para_string(define, para, data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_parameter_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [str] = make_main_para_string(define, para, data)
% function [str] = make_main_para_string(para, data)
% 主要な実験パラメータの文字列を作成する。
% 
% [input argument]
% define : define変数を管理する構造体
% para : パラメータ構造体
% data : 実験データ構造体
% 
% [output argument]
% str : 実験パラメータ文字列(cell配列)

str = {};


% Block番号を示す文字列を作成する。
str{end+1} = sprintf('current_block = %d', para.current_block);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRIデータのノイズ除去処理方法を示す文字列を作成する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str{end+1} = sprintf('denoising_method = %s',...
    get_field_name(para.denoising_method, define.denoising_method));
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 得点モードの内容をを示す文字列を作成する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str{end+1} = sprintf('score_mode = %s',...
    get_field_name(para.score.score_mode, define.score_mode));
switch para.score.score_mode
  case define.score_mode.CALC_SCORE
    % 脳活動パターンから求めた得点を採用する。
  case define.score_mode.SHAM_RAND_SCORE
    % 正規分布乱数で求めた得点を採用する。
    str{end+1} = sprintf('normal random number(mu:%.2f, sigma:%.2f)',...
	para.score.normrnd_mu, para.score.normrnd_sigma);
  case define.score_mode.SHAM_SCORE_FILE
    % Sham scoreファイルの得点を採用する。
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
% 脳活動パターンから得点を計算条件 '以外‘の条件で
% ROI fileを指定していない場合。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if para.score.score_mode ~= define.score_mode.CALC_SCORE &...
      para.files.roi_fnum == 0
  if ispc
    str{end+1} = sprintf(...
	'WARNING : ROI fileを指定していないので、ROIの目標のパターンとの類似度は計算しません。\n');
  else
    str{end+1} = sprintf('WARNING : roi_fnum=%d.\n', para.files.roi_fnum);
  end
end


% 被検者が寝ていないかチェックする試行番号を示す文字列を作成する。
tmp = sprintf(' %d,', para.scans.sleep_check_trial);
str{end+1} = sprintf('sleep_check_trial =%s', tmp(1:end-1));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_main_para_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [str] = make_all_para_string(define, para, data)
% function [str] = make_all_para_string(define, para, data)
% 全ての実験パラメータの文字列を作成する。
% 
% [input argument]
% define : define変数を管理する構造体
% para : パラメータ構造体
% data : 実験データ構造体
% 
% [output argument]
% str : 実験パラメータ文字列(cell配列)


str = {};


% Block番号
str{end+1} = sprintf('current_block = %d', para.current_block);
% 被検者ID( '患者(被検者)名前_患者(被検者)ID' )
str{end+1} = sprintf('exp_id = %s', para.exp_id);
% 実験(撮影)実施日(YYMMDD)
str{end+1} = sprintf('exp_date = %s', para.exp_date);

str{end+1} = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRIデータのノイズ除去処理方法
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str{end+1} = sprintf('denoising_method = %s',...
    get_field_name(para.denoising_method, define.denoising_method));
    
str{end+1} = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File / Directory 情報
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter fileのdirectory
str{end+1} = sprintf('para_dir = %s', para.files.para_dir);
% Sham score fileのdirectory
str{end+1} = sprintf('sham_score_dir = %s', para.files.sham_score_dir);
% Data保存directory
str{end+1} = sprintf('save_dir = %s', para.files.save_dir);
% ROI fileのdirectory
str{end+1} = sprintf('roi_dir = %s', para.files.roi_dir);
% DICOM fileのdirectory
str{end+1} = sprintf('dicom_dir = %s', para.files.dicom_dir);
% Template image fileのdirectory
str{end+1} = sprintf('templ_image_dir = %s', para.files.templ_image_dir);
% Parameter file
str{end+1} = sprintf('para_fname = %s', para.files.para_fname);
% Sham score file
str{end+1} = sprintf('sham_score_fname = %s', para.files.sham_score_fname);
% ROI EPI dataの閾値
if ischar(para.files.roi_epi_threshold)
  str{end+1} = sprintf('roi_epi_threshold = %s',...
      para.files.roi_epi_threshold);
else
  str{end+1} = sprintf('roi_epi_threshold = %f',...
      para.files.roi_epi_threshold);
end
% ROIの数
str{end+1} = sprintf('roi_fnum = %d', para.files.roi_fnum);
for ii=1:para.files.roi_fnum
  % ROI file
  str{end+1} = sprintf('roi_fname[%d] = %s', ii, para.files.roi_fname{ii});
  % ROI dataの閾値
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
% WM dataの閾値
if ischar(para.files.wm_threshold)
  str{end+1} = sprintf('wm_threshold = %s', para.files.wm_threshold);
else
  str{end+1} = sprintf('wm_threshold = %f', para.files.wm_threshold);
end
% GS file
str{end+1} = sprintf('gs_fname = %s', para.files.gs_fname);
% GS dataの閾値
if ischar(para.files.gs_threshold)
  str{end+1} = sprintf('gs_threshold = %s', para.files.gs_threshold);
else
  str{end+1} = sprintf('gs_threshold = %f', para.files.gs_threshold);
end
% CSF file
str{end+1} = sprintf('csf_fname = %s', para.files.csf_fname);
% CSF dataの閾値
if ischar(para.files.csf_threshold)
  str{end+1} = sprintf('csf_threshold = %s', para.files.csf_threshold);
else
  str{end+1} = sprintf('csf_threshold = %f', para.files.csf_threshold);
end
% Template image file
str{end+1} = sprintf('templ_image_fname = %s', para.files.templ_image_fname);
% DICOM fileのfile名の前半部
str{end+1} = sprintf('dicom_fnameB = %s', para.files.dicom_fnameB);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRIのscan条件に関係するパラメータ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 試行数
str{end+1} = sprintf('trial_num = %d', para.scans.trial_num);
% 試行を開始する迄のscan数
str{end+1} = sprintf('pre_trial_scan_num = %d', para.scans.pre_trial_scan_num);
% 1試行目の前処理用REST条件その1のscan数
str{end+1} = sprintf('prep_rest1_scan_num = %d',...
    para.scans.prep_rest1_scan_num);
% 1試行目の前処理用REST条件その2のscan数
str{end+1} = sprintf('prep_rest2_scan_num = %d',...
    para.scans.prep_rest2_scan_num);
% REST条件のscan数
str{end+1} = sprintf('rest_scan_num = %d', para.scans.rest_scan_num);
% TEST条件のscan数
str{end+1} = sprintf('test_scan_num = %d', para.scans.test_scan_num);
% TEST条件開始後のdelay scan数
str{end+1} = sprintf('pre_test_delay_scan_num = %d',...
    para.scans.pre_test_delay_scan_num);
% TEST条件終了後のdelay scan数
str{end+1}=sprintf('post_test_delay_scan_num = %d',...
    para.scans.post_test_delay_scan_num);
% 得点計算条件のscan数
str{end+1} = sprintf('calc_score_scan_num = %d',...
    para.scans.calc_score_scan_num);
% 得点提示条件のscan数
str{end+1} = sprintf('feedbk_score_scan_num = %d',...
    para.scans.feedbk_score_scan_num);
% Scan間隔 (sec)
str{end+1} = sprintf('TR = %f [sec]', para.scans.TR);
% fMRIデータのノイズ除去処理に利用するscan数
str{end+1} = sprintf('regress_scan_num = %d',...
    para.scans.regress_scan_num);
% 被検者が寝ていないかをチェックする試行数
str{end+1} = sprintf('sleep_check_trial_num = %d',...
    para.scans.sleep_check_trial_num);
% 1試行目の一試行のscan数
str{end+1} = sprintf('first_trial_scan_num = %d',...
    para.scans.first_trial_scan_num);
% 2試行目以降の一試行のscan数
str{end+1} = sprintf('trial_scan_num = %d', para.scans.trial_scan_num);
% 総Scan数
str{end+1} = sprintf('total_scan_num = %d', para.scans.total_scan_num);
% 被検者が寝ていないかチェックする試行番号
for ii=1:para.scans.sleep_check_trial_num
  str{end+1} = sprintf('sleep_check_trial[%d] = %d',...
      ii, para.scans.sleep_check_trial(ii));
end

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 得点計算用パラメータ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 得点モード
str{end+1} = sprintf('score_mode = %s',...
    get_field_name(para.score.score_mode, define.score_mode));
% 脳の半径 (mm)
str{end+1} = sprintf('radius_of_brain = %f [mm]', para.score.radius_of_brain);
% Scan中の脳の移動量の閾値 (mm)
str{end+1} = sprintf('FD_threshold = %f [mm]', para.score.FD_threshold);
% ROI templateとROIの相関係数の閾値
str{end+1} = sprintf('corr_roi_template_threshold = %f',...
    para.score.corr_roi_template_threshold);
% 正規分布乱数の平均値
str{end+1} = sprintf('score_normrnd_mu = %f', para.score.normrnd_mu);
% 正規分布乱数の標準偏差
str{end+1} = sprintf('score_normrnd_sigma = %f', para.score.normrnd_sigma);
% Sham scoreファイルの得点
if para.score.score_mode == define.score_mode.SHAM_SCORE_FILE
  % Sham scoreファイルの得点(para.score.sham_score)は、
  % Sham scoreファイルの得点を採用する条件
  % (para.score.score_mode=SHAM_SCORE_FILE)の場合のみ設定される。
  % --------------------------------------------------------------
  % ( 他の実験条件ではpara.score.sham_score配列は空 )
  for trial=1:para.scans.trial_num
    str{end+1} = sprintf('sham_score[%d] = %f',...
	trial, para.score.sham_score(trial));
  end
end
% 得点の下限と上限の閾値
str{end+1} = sprintf('score_limit = (%.2f, %.2f)', para.score.score_limit);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 視覚feedbackパラメータ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 試行開始トリガー信号等の入力や視覚feedback出力先等の入出力用ツール
str{end+1} = sprintf('feedback_io_tool = %s',...
    get_field_name(para.feedback.io_tool, define.feedback.io_tool));
% 視覚feedbackの提示タイプ
str{end+1} = sprintf('feedback_type = %s',...
    get_field_name(para.feedback.feedback_type,...
    define.feedback.feedback_type));
% 得点を被検者に提示するタイミング
str{end+1} = sprintf('feedback_score_timing = %s',...
    get_field_name(para.feedback.feedback_score_timing,...
    define.feedback.feedback_score_timing));
% 視覚刺激を提示するscreen番号
str{end+1} = sprintf('feedback_screen = %d', para.feedback.screen);
% 1試行目の前処理用REST条件その1でのコメント文字列
str{end+1} = sprintf('feedback_prep_rest1_comment = %s',...
    para.feedback.prep_rest1_comment);
% 1試行目の前処理用REST条件その2でのコメント文字列
str{end+1} = sprintf('feedback_prep_rest2_comment = %s',...
    para.feedback.prep_rest2_comment);
% REST条件でのコメント文字列
str{end+1} = sprintf('feedback_rest_comment = %s', para.feedback.rest_comment);
% TEST条件でのコメント文字列
str{end+1} = sprintf('feedback_test_comment = %s', para.feedback.test_comment);
% TEST条件が終了した後、得点を提示するまでの間の条件でのコメント文字列
str{end+1} = sprintf('feedback_prep_score_comment = %s',...
    para.feedback.prep_score_comment);
% 得点提示条件でのコメント文字列
str{end+1} = sprintf('feedback_score_comment = %s',...
    para.feedback.score_comment);
% 得点の計算処理不可時のコメント文字列
str{end+1} = sprintf('feedback_ng_score_comment = %s',...
    para.feedback.ng_score_comment);
% ブロック終了条件でのコメント文字列
str{end+1} = sprintf('feedback_finished_block_comment = %s',...
    para.feedback.finished_block_comment);
% ブロック終了条件の視覚feedbackの提示時間 (sec)
str{end+1} = sprintf('feedback_finished_block_duration = %f [sec]',...
    para.feedback.finished_block_duration);
% 注視点の半径(円弧 枠)
str{end+1} = sprintf('feedback_gaze_frame_r = %d',...
    para.feedback.gaze_frame_r);
% 注視点の半径(円弧 塗)
str{end+1} = sprintf('feedback_gaze_fill_r = %d',...
    para.feedback.gaze_fill_r);
% 注視点の半径(被検者が寝ていないかチェック用)
str{end+1} = sprintf('feedback_sleep_fill_r = %d',...
    para.feedback.sleep_fill_r);
% 得点の上限値での得点を提示する円の半径
str{end+1} = sprintf('feedback_max_score_r = %d',...
    para.feedback.max_score_r);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford sleepiness scale(スタンフォード眠気尺度)
% に関するパラメータ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford眠気尺度質問フラグ
str{end+1} = sprintf('sss_flag = %d', para.sss.sss_flag);
% Stanford眠気尺度質問画像fileのdirectory
str{end+1} = sprintf('sss_image_dir = %s', para.sss.sss_image_dir);
% Stanford眠気尺度質問画像file名
str{end+1} = sprintf('sss_image_fname = %s', para.sss.sss_image_fname);

str{end+1} = '';


% ROI volume graph表示フラグ
str{end+1} = sprintf('roi_vol_graph_flag = %d', para.roi_vol_graph_flag);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOMファイルの撮影情報(dicom_info)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 患者(被検者)名前
str{end+1} = sprintf('dicom_info_patient_name = %s',...
    para.dicom_info.patient_name);
% 患者(被検者)ID
str{end+1} = sprintf('dicom_info_patient_id = %s',...
    para.dicom_info.patient_id);
% 検査(撮影)実施日 (YYMMDD)
str{end+1} = sprintf('dicom_info_study_date = %s',...
    para.dicom_info.study_date);
% 施設名
str{end+1} = sprintf('dicom_info_institution_name = %s',...
    para.dicom_info.institution_name);

str{end+1} = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 通信経路(msocket)に関するパラメータ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receiver数
str{end+1} = sprintf('receiver_num = %d', para.receiver_num);
% TCP/IP port番号
for ii=1:length(para.msocket.port)
  str{end+1} = sprintf('msocket_port[%d] = %d', ii, para.msocket.port(ii));
end
% msocket serverのhost名 (neurofeedbackプログラムのhost名)
str{end+1} = sprintf('msocket_server_name = %s', para.msocket.server_name);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_all_para_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
