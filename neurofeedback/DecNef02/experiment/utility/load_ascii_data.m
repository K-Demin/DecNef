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

% ASCII形式のデータファイルからバージョン情報を読む。
version = load_version_value(fd);
% ASCII形式のデータファイルからdefine変数を読む。
define = load_define_para(fd);
% ASCII形式のデータファイルから実験パラメータを読む。
[DECNEF_PROJECT, para] = load_para_data(fd, define);
% ASCII形式のデータファイルから実験データを読む。
exp_data = load_data_para(fd, para);

fclose(fd);

% 実験データ構造体を作成する。
nfb_data = struct(...
    'DECNEF_PROJECT',DECNEF_PROJECT,...	% DecNef実験プロジェクトコード
    'version', version,...		% バージョン情報を管理する構造体
    'define', define,...		% define変数を管理する構造体
    'para', para,...			% 実験パラメータを管理する構造体
    'data', exp_data...			% 実験データを管理する構造体
    );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load関数 と データファイルの整合性をチェックする。
% ---------------------------------------------------------
% ( 実験プロジェクトコード と 実験プロジェクトリリース日 が、
%   Load関数 と データファイル で一致しなければならない。 )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 実験プロジェクトコード(version.decnef_project) と
% 実験プロジェクトリリース日(version.decnef_release) が
% 実験データに設定されていない場合、初期値(NaN)を設定しておく。
if isfield(nfb_data.version, 'decnef_project') == false
  nfb_data.version.decnef_project = NaN;
end
if isfield(nfb_data.version, 'decnef_release') == false
  nfb_data.version.decnef_release = NaN;
end
% Load関数の 実験プロジェクトコード(DecNef_Project) と 
% 実験プロジェクトリリース日(DecNef_ReleaseData) を獲得する。
[DecNef_Project, DecNef_ReleaseData] = release_info();
if nfb_data.version.decnef_project ~= DecNef_Project |...
      nfb_data.version.decnef_release ~= DecNef_ReleaseData
  % Load関数 と データファイル の
  % 実験プロジェクトコード と 実験プロジェクトリリース日 が一致しない。
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
% ASCII形式のデータファイルからバージョン情報を読む。
% 
% [input argument]
% fd : ASCII形式のデータファイルのファイル識別子
% 
% [output argument]
% version : バージョン情報を管理する構造体

version = [];

fseek(fd,0,-1);		% ファイルポインタをファイルの先頭にする。
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
% ASCII形式のデータファイルからdefine変数を読む。
% 
% [input argument]
% fd : ASCII形式のデータファイルのファイル識別子
% 
% [output argument]
% define : define変数を管理する構造体

scan_condition = [];
define = [];

fseek(fd,0,-1);		% ファイルポインタをファイルの先頭にする。
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
% ASCII形式のデータファイルから実験パラメータを読む。
% 
% [input argument]
% fd : ASCII形式のデータファイルのファイル識別子
% define : define変数を管理する構造体
% 
% [output argument]
% DECNEF_PROJECT : DecNef実験プロジェクトコード
% para           : 実験パラメータを管理する構造体


DECNEF_PROJECT = -1;
para = [];
files = [];
scans = [];
score = [];
feedback = [];
sss = [];
dicom_info = [];
msocket = [];

fseek(fd,0,-1);		% ファイルポインタをファイルの先頭にする。
while true
  str = fgets(fd);
  if str == -1, break;	% End of file
  else
    % DecNef実験プロジェクトコード
    tmp = sscanf(str, 'ProjectCode = DecNef%d');
    if ~isempty(tmp)	DECNEF_PROJECT = tmp;	end

    
    % Block番号
    tmp = sscanf(str, 'current_block = %d');
    if ~isempty(tmp),	para.current_block = tmp;	end
    % 被検者ID
    tmp = sscanf(str, 'exp_id = %s');
    if ~isempty(tmp),	para.exp_id = tmp;	end
    % 実験(撮影)実施日 (YYMMDD)
    tmp = sscanf(str, 'exp_date = %s');
    if ~isempty(tmp),	para.exp_date = tmp;	end
    
    % Parameter fileのdirectory
    tmp = sscanf(str, 'para_dir = %s');
    if ~isempty(tmp),	files.para_dir = tmp;	end
    % Sham score fileのdirectory
    tmp = sscanf(str, 'sham_score_dir = %s');
    if ~isempty(tmp),	files.sham_score_dir = tmp;	end
    % Data保存directory
    tmp = sscanf(str, 'save_dir = %s');
    if ~isempty(tmp),	files.save_dir = tmp;	end
    % ROI fileのdirectory
    tmp = sscanf(str, 'roi_dir = %s');
    if ~isempty(tmp),	files.roi_dir = tmp;	end
    % DICOM fileのdirectory
    tmp = sscanf(str, 'dicom_dir = %s');
    if ~isempty(tmp),	files.dicom_dir = tmp;	end
    % Template image fileのdirectory
    tmp = sscanf(str, 'templ_image_dir = %s');
    if ~isempty(tmp),	files.templ_image_dir = tmp;	end
    % Parameter file
    tmp = sscanf(str, 'para_fname = %s');
    if ~isempty(tmp),	files.para_fname = tmp;	end
    % Sham score file
    tmp = sscanf(str, 'sham_score_fname = %s');
    if ~isempty(tmp),	files.sham_score_fname = tmp;	end
    % ROI EPI dataの閾値
    tmp = sscanf(str, 'roi_epi_threshold = %f');
    if ~isempty(tmp),	files.roi_epi_threshold = tmp;	end
    % ROIの数
    tmp = sscanf(str, 'roi_fnum = %d');
    if ~isempty(tmp),	files.roi_fnum = tmp;	end
    % ROI file
    tmp = sscanf(str, 'roi_fname[%d] = %s');
    if length(tmp)>2,	files.roi_fname{tmp(1),1} = char(tmp(2:end)');	end
    % ROI dataの閾値
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
    % WM dataの閾値
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
    % GS dataの閾値
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
    % CSF dataの閾値
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
    % DICOM fileのfile名の前半部
    tmp = sscanf(str, 'dicom_fnameB = %s');
    if ~isempty(tmp),	files.dicom_fnameB = tmp;	end

    % 試行数
    tmp = sscanf(str, 'trial_num = %d');
    if ~isempty(tmp),	scans.trial_num = tmp;	end
    % 試行を開始する迄のscan数
    tmp = sscanf(str, 'pre_trial_scan_num = %d');
    if ~isempty(tmp),	scans.pre_trial_scan_num = tmp;	end
    % 1試行目の前処理用のREST条件その1のscan数
    tmp = sscanf(str, 'prep_rest1_scan_num = %d');
    if ~isempty(tmp),	scans.prep_rest1_scan_num = tmp;	end
    % 1試行目の前処理用のREST条件その2のscan数
    tmp = sscanf(str, 'prep_rest2_scan_num = %d');
    if ~isempty(tmp),	scans.prep_rest2_scan_num = tmp;	end
    % REST条件のscan数
    tmp = sscanf(str, 'rest_scan_num = %d');
    if ~isempty(tmp),	scans.rest_scan_num = tmp;	end
    % TEST条件のscan数
    tmp = sscanf(str, 'test_scan_num = %d');
    if ~isempty(tmp),	scans.test_scan_num = tmp;	end
    % TEST条件開始後のdelay scan数
    tmp = sscanf(str, 'pre_test_delay_scan_num = %d');
    if ~isempty(tmp),	scans.pre_test_delay_scan_num = tmp;	end
    % TEST条件終了後のdelay scan数
    tmp = sscanf(str, 'post_test_delay_scan_num = %d');
    if ~isempty(tmp),	scans.post_test_delay_scan_num = tmp;	end
    % 得点計算条件のscan数
    tmp = sscanf(str, 'calc_score_scan_num = %d');
    if ~isempty(tmp),	scans.calc_score_scan_num = tmp;	end
    % 得点提示条件のscan数
    tmp = sscanf(str, 'feedbk_score_scan_num = %d');
    if ~isempty(tmp),	scans.feedbk_score_scan_num = tmp;	end
    % Scan間隔 (sec)
    tmp = sscanf(str, 'TR = %f');
    if ~isempty(tmp),	scans.TR = tmp;	end
    % fMRIデータのノイズ除去処理のscan数
    tmp = sscanf(str, 'regress_scan_num = %d');
    if ~isempty(tmp),	scans.regress_scan_num = tmp;	end
    % 被検者が寝ていないかをチェックする試行数
    tmp = sscanf(str, 'sleep_check_trial_num = %d');
    if ~isempty(tmp)
      scans.sleep_check_trial_num = tmp;
      scans.sleep_check_trial = zeros(tmp,1);
    end
    % 1試行目の一試行のscan数
    tmp = sscanf(str, 'first_trial_scan_num = %d');
    if ~isempty(tmp),	scans.first_trial_scan_num = tmp;	end
    % 2試行目以降の一試行のscan数
    tmp = sscanf(str, 'trial_scan_num = %d');
    if ~isempty(tmp),	scans.trial_scan_num = tmp;	end
    % 総Scan数
    tmp = sscanf(str, 'total_scan_num = %d');
    if ~isempty(tmp),	scans.total_scan_num = tmp;	end
    % 被検者が寝ていないかチェックする試行番号
    tmp = sscanf(str, 'sleep_check_trial[%d] = %d');
    if length(tmp)==2,	scans.sleep_check_trial(tmp(1)) = tmp(2);	end

    % 得点モード
    tmp = sscanf(str, 'score_mode = %s');
    if ~isempty(tmp),	score.score_mode = tmp;	end

    % 脳の半径 (mm)
    tmp = sscanf(str, 'radius_of_brain = %f');
    if ~isempty(tmp),	score.radius_of_brain = tmp;	end
    % Scan中の脳の移動量の閾値 (mm)
    tmp = sscanf(str, 'FD_threshold = %f');
    if ~isempty(tmp),	score.FD_threshold = tmp;	end
    
    % ROI templateとROIの相関係数の閾値
    tmp = sscanf(str, 'corr_roi_template_threshold = %f');
    if ~isempty(tmp),	corr_roi_template_threshold = tmp;	end

    % 正規分布乱数の平均値
    tmp = sscanf(str, 'score_normrnd_mu = %f');
    if ~isempty(tmp),	score.normrnd_mu = tmp;	end
    % 正規分布乱数の標準偏差
    tmp = sscanf(str, 'score_normrnd_sigma = %f');
    if ~isempty(tmp),	score.normrnd_sigma = tmp;	end
    % Sham scoreファイルの得点
    tmp = sscanf(str, 'sham_score[%d] = %f');
    if length(tmp) == 2
      n = round(tmp(1));
      score.sham_score(n,:) = tmp(2);
    end
    % 得点の下限と上限の閾値
    tmp = sscanf(str, 'score_limit = (%f, %f)')';
    if length(tmp)==2,	score.score_limit = tmp;	end
    
    % 試行開始トリガー信号等の入力や視覚feedback出力先等の入出力用ツール
    tmp = sscanf(str, 'feedback_io_tool = %s');
    if ~isempty(tmp),	feedback.io_tool = tmp;	end
    % 視覚feedbackの提示タイプ
    tmp = sscanf(str, 'feedback_type = %s');
    if ~isempty(tmp),	feedback.feedback_type = tmp;	end
    % 視覚刺激を提示するscreen番号
    tmp = sscanf(str, 'feedback_screen = %d');
    if ~isempty(tmp),	feedback.screen = tmp;	end
    % 得点を被検者に提示するタイミング
    tmp = sscanf(str, 'feedback_score_timing = %s');
    if ~isempty(tmp),	feedback.feedback_score_timing = tmp;	end
    % 1試行目の前処理用のREST条件その1でのコメント文字列
    tmp = sscanf(str, 'feedback_prep_rest1_comment = %s');
    if ~isempty(tmp),	feedback.prep_rest1_comment = tmp;	end
    % 1試行目の前処理用のREST条件その2でのコメント文字列
    tmp = sscanf(str, 'feedback_prep_rest2_comment = %s');
    if ~isempty(tmp),	feedback.prep_rest2_comment = tmp;	end
    % REST条件でのコメント文字列
    tmp = sscanf(str, 'feedback_rest_comment = %s');
    if ~isempty(tmp),	feedback.rest_comment = tmp;	end
    % TEST条件でのコメント文字列
    tmp = sscanf(str, 'feedback_test_comment = %s');
    if ~isempty(tmp),	feedback.test_comment = tmp;	end
    % TEST条件が終了した後、得点を提示するまでの間の条件でのコメント文字列
    tmp = sscanf(str, 'feedback_prep_score_comment = %s');
    if ~isempty(tmp),	feedback.prep_score_comment = tmp;	end
    % 得点提示条件でのコメント文字列
    tmp = sscanf(str, 'feedback_score_comment = %s');
    if ~isempty(tmp),	feedback.score_comment = tmp;	end
    % 得点の計算処理不可時のコメント文字列
    tmp = sscanf(str, 'feedback_ng_score_comment = %s');
    if ~isempty(tmp),	feedback.ng_score_comment = tmp;	end
    % ブロック終了条件でのコメント文字列
    tmp = sscanf(str, 'feedback_finished_block_comment = %s');
    if ~isempty(tmp),	feedback.feedback_finished_block_comment = tmp;	end
    % ブロック終了条件の視覚feedbackの提示時間 (sec)
    tmp = sscanf(str, 'feedback_finished_block_duration = %f');
    if ~isempty(tmp),	feedback.finished_block_duration = tmp;	end
    % 注視点の半径(円弧 枠)
    tmp = sscanf(str, 'feedback_gaze_frame_r = %d');
    if ~isempty(tmp),	feedback.gaze_frame_r = tmp;	end
    % 注視点の半径(円弧 塗)
    tmp = sscanf(str, 'feedback_gaze_fill_r = %d');
    if ~isempty(tmp),	feedback.gaze_fill_r = tmp;	end
    % 注視点の半径(被検者が寝ていないかチェック用)
    tmp = sscanf(str, 'feedback_sleep_fill_r = %d');
    if ~isempty(tmp),	feedback.sleep_fill_r = tmp;	end
    % 得点の上限値での得点を提示する円の半径
    tmp = sscanf(str, 'feedback_max_score_r = %d');
    if ~isempty(tmp),	feedback.max_score_r = tmp;	end

    % Stanford眠気尺度質問フラグ
    tmp = sscanf(str, 'sss_flag = %d');
    if ~isempty(tmp),	sss.sss_flag = tmp;	end
    % Stanford眠気尺度質問画像fileのdirectory
    tmp = sscanf(str, 'sss_image_dir = %s');
    if ~isempty(tmp),	sss.sss_image_dir = tmp;	end
    % Stanford眠気尺度質問画像file名
    tmp = sscanf(str, 'sss_image_fname = %s');
    if ~isempty(tmp),	sss.sss_image_fname = tmp;	end
    
    % ROI volume graph表示フラグ
    tmp = sscanf(str, 'roi_vol_graph_flag = %d');
    if ~isempty(tmp),	para.roi_vol_graph_flag = tmp;	end

    % 患者(被検者)名前
    tmp = sscanf(str, 'dicom_info_patient_name = %s');
    if ~isempty(tmp),	dicom_info.patient_name = tmp;	end
    % 患者(被検者)ID
    tmp = sscanf(str, 'dicom_info_patient_id = %s');
    if ~isempty(tmp),	dicom_info.patient_id = tmp;	end
    % 検査(撮影)実施日 (YYMMDD)
    tmp = sscanf(str, 'dicom_info_study_date = %s');
    if ~isempty(tmp),	dicom_info.study_date = tmp;	end
    % 施設名
    tmp = sscanf(str, 'dicom_info_institution_name = %s');
    if ~isempty(tmp),	dicom_info.institution_name = tmp;	end
	    
    % receiver数
    tmp = sscanf(str, 'receiver_num = %d');
    if ~isempty(tmp),	para.receiver_num = tmp;	end
    % TCP/IP port番号
    tmp = sscanf(str, 'msocket_port[%d] = %d');
    if length(tmp),	msocket.port(tmp(1),1) = tmp(2);	end
    % serverのホスト名
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
% ASCII形式のデータファイルから実験データを読む。
% function [exp_data] = load_data_para(fd, para)
% 
% [input argument]
% fd   : ASCII形式のデータファイルのファイル識別子
% para : 実験パラメータを管理する構造体
% 
% [output argument]
% data : 実験パラメータを管理する構造体


data = [];

fseek(fd,0,-1);		% ファイルポインタをファイルの先頭にする。
while true
  str = fgets(fd);
  if str == -1, break;	% End of file
  else
    % 受信処理が完了したScan数
    tmp = sscanf(str, 'received_scan_num = %d');
    if length(tmp),	data.received_scan_num = tmp;	end
    % ROIのvoxel数
    tmp = sscanf(str, 'roi_vox_num[%d] = %d');
    if length(tmp)==2,	data.roi_vox_num(tmp(1)) = tmp(2);	end
    % WMデータのvoxel数
    tmp = sscanf(str, 'wm_vox_num = %d');
    if length(tmp),	data.wm_vox_num = tmp;	end
    % GSデータのvoxel数
    tmp = sscanf(str, 'gs_vox_num = %d');
    if length(tmp),	data.gs_vox_num = tmp;	end
    % CSFデータのvoxel数
    tmp = sscanf(str, 'csf_vox_num = %d');
    if length(tmp),	data.csf_vox_num = tmp;	end
    % 各scanでのWMの信号値の平均値
    tmp = sscanf(str, 'wm_signal[%d] = %f');
    if length(tmp)==2,	data.wm_signal( round(tmp(1)), 1 ) = tmp(2);	end
    % 各scanでのGSの信号値の平均値
    tmp = sscanf(str, 'gs_signal[%d] = %f');
    if length(tmp)==2,	data.gs_signal( round(tmp(1)), 1 ) = tmp(2);	end
    % 各scanでのCSFの信号値の平均値
    tmp = sscanf(str, 'csf_signal[%d] = %f');
    if length(tmp)==2,	data.csf_signal( round(tmp(1)), 1 ) = tmp(2);	end
    tmp = sscanf(str, 'realign_val[%d]');
    % 各scanでのrealignment parameter
    if ~isempty(tmp),
      s = length( sprintf('realign_val[%d] = ', tmp) )+1;
      tmp2 = sscanf(str(s:end), '%e ');
      if ~isempty(tmp2),	data.realign_val(tmp,:) = tmp2;	end
    end

    % Scan中の脳の移動量 [mm]
    tmp = sscanf(str, 'FD[%d] = %f');
    if length(tmp)==2,	data.FD( round(tmp(1)), 1 ) = tmp(2);	end
    
    % 各scanでのROIの信号値とROI Templateデータの相関係数
    tmp = sscanf(str, 'corr_roi_template[%d]');
    if ~isempty(tmp),
      s = length( sprintf('corr_roi_template[%d] = ', tmp) )+1;
      tmp2 = sscanf(str(s:end), '%f ');
      if ~isempty(tmp2),	data.corr_roi_template(tmp,:) = tmp2;	end
    end

    % Scanの計測データを得点の計算に採用 しない/する
    tmp = sscanf(str, 'ng_scan[%d] = %f');
    if length(tmp)==2
      data.ng_scan( round(tmp(1)), 1 ) = logical( tmp(2) );
    end
    
    % Stanford眠気尺度Level
    tmp = sscanf(str, 'sss_level = %d');
    if length(tmp),	data.sss_level = tmp;	end
    if strncmpi(str, 'sss_level = nan', length('sss_level = nan'));
      data.sss_level = NaN;
    end
    % Stanford眠気尺度に関するコメント文字列
    if strncmp(str, 'sss_comment = ', length('sss_comment = '))
      % 最後の改行文字(str(end))は除く
      data.sss_comment = str( length('sss_comment = ')+1:end-1 );
    end
    
    % 被検者が寝ていないかのチェック(1:OK.0:NG)結果
    tmp = sscanf(str, 'sleep_check(%d) = %d');
    if length(tmp)==2,	data.sleep_check(tmp(1),1) = tmp(2);	end

    % 各試行のlabel値
    tmp = sscanf(str, 'label_ROI%d[%d] = %f');
    if length(tmp)==3
      roi = round(tmp(1));
      trial = round(tmp(2));
      data.label(trial, roi) = tmp(3);
    end
    % 各試行の得点
    tmp = sscanf(str, 'source_score[%d] = %f');
    if length(tmp)==2,	data.source_score( round(tmp(1)), 1 ) = tmp(2);	end
    tmp = sscanf(str, 'score[%d] = %f');
    if length(tmp)==2,	data.score( round(tmp(1)), 1 ) = tmp(2);	end
  end	% <-- End of 'if str == -1, ... else ...'
end	% <-- End of 'while(true)'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_data_para()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
