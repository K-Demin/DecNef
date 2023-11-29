function [define, para, err] = load_parameters_calibration(define, para)
% function [define, para, err] = load_parameters(define, para)
% Parameter fileから実験パラメータをloadし、実験パラメータ構造体
% に設定する。
% 
% [input argument]
% define : define変数を管理する構造体
% para   : 実験パラメータ構造体
% 
% [output argument]
% define : define変数を管理する構造体
% para   : 実験パラメータ構造体
% err    : エラー情報
%       err.status : true(パラメータエラーなし)/false(パラメータエラーあり)
%       err.msg   : err.status=false時、エラー情報文字列を設定する。


% error情報を管理する構造体を作成する。
err = struct('status', false, 'msg', []);

% File dialogを用いてParameter fileを選択する。
if define.files.STD_DIALOG_BOX	% MATLAB標準のdialog boxを用いる
  [fname, dname, index] = uigetfile(...
      sprintf('%s%s*%s',...
      para.files.para_dir, filesep, define.files.PARA_FILE_EXTENSION),...
      'Select Parameter file');
else				% 独自開発のdialog boxを用いる
  file_extensions = { define.files.PARA_FILE_EXTENSION };
  [index, dname, fname] =...
      yoyo_file_dialog(para.files.para_dir, file_extensions,...
      'Select Parameter file');
  if index
    fname = char( fname{1} );	% cell配列から文字列に変換する。
  end
end

if index
  para.files.para_dir = dname;		% Parameter fileのdirectoryを更新
  para.files.para_fname = fname;	% Parameter file名を更新
  % Parameterファイルから実験パラメータを読む。
  [para, err] = load_para(define, para, err);

  if err.status &...
	para.score.score_mode == define.score_mode.SHAM_SCORE_FILE
    % Sham scoreファイルの得点を採用する条件
    % (para.score.score_mode=SHAM_SCORE_FILE)の場合、
    % File dialogを用いてSham scoreファイルを選択し、
    % Sham scoreファイルから得点を読む。
    [para, err] = load_sham_score(define, para, err);
  end
  if err.status
    % directoryに関係するパラメータを設定する。
    [para, err] = set_dir_para(define, para, err);
  end
  if err.status
    % 実験パラメータ構造体を更新する。
    para = set_parameters(define, para);
  else
    % パラメータ・エラーが発生した場合、
    % エラー・パネルにエラー情報を表示する。
    errordlg(err.msg, 'Error Dialog', 'modal');
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_parameters()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para, err] = load_para(define, para, err)
% function [para, err] = load_para(define, para, err)
% Parameterファイルから実験パラメータを読む。
% 
% [input argument]
% define : define変数を管理する構造体
% para : 実験パラメータ構造体
% err : エラー情報
% 
% [output argument]
% para : パラメータ値を設定後の実験パラメータ構造体
% err : エラー情報

kaigyo = sprintf('\n');		% 改行文字
kaigyo_dos = 13;		% 改行文字 (DOS)
comment = '#';			% コメント行の先頭文字

para_fname = fullfile(para.files.para_dir, para.files.para_fname);
fd = fopen(para_fname, 'r');
if fd == -1
  err_msg = sprintf('FOPEN cannot open the file(%s)', para_fname);
  errordlg(err_msg, 'Error Dialog', 'modal');
  error(err_msg);
  err.status = false;
end

line_no = 0;		% 行番号
err.status = true;
err.msg = sprintf('%sin ''%s''\n', err.msg, para_fname);

DecNef_Project = define.DECNEF_PROJECT;		% 実験プロジェクトコード

while true
  str = fgets(fd);	% 1行読み出す。
  line_no = line_no+1;	% 行番号を更新する。

  if str == -1, break;	% End of file
  else
    line_ok = false;
    
    if str(1) == comment | str(1) == kaigyo | str(1) == kaigyo_dos
      line_ok = true;	% コメント行, 空白行
    end

    
    if strncmp(str, 'ProjectCode', length('ProjectCode'))
      % DecNef実験プロジェクトコード (DecNef_Project)
      value = yoyo_sscanf('ProjectCode=DecNef%d', str);
      if length(value)
	line_ok = true;
	DecNef_Project = value;
      end
    end	% <-- End of 'ProjectCode'
    
    if strncmp(str, 'receiver_num', length('receiver_num'))
      % receiverプログラムの数 (receiver_num)
      value = yoyo_sscanf('receiver_num=%d', str);
      if length(value)
	line_ok = true;
	para.receiver_num = value;
      end
    end	% <-- End of 'receiver_num'
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % fMRIデータのノイズ除去処理方法
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strncmp(str, 'denoising_method', length('denoising_method'))
      % MRIデータのノイズ除去方法(denoising_method)
      value = yoyo_sscanf('denoising_method=%s', str);
      if length(value)
	[denoising_method, ret] =...
	    get_field_value(value, define.denoising_method);
	if ret
	  line_ok = true;
	  para.denoising_method = denoising_method;
	end
      end
    end	% <-- End of 'denoising_method'
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % directoryに関係するパラメータをloadする。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'data_top_dir', length('data_top_dir'))
      % Data top directory (data_top_dir)
      value = yoyo_sscanf('data_top_dir=%s', str);
      if length(value)
	line_ok = true;
	para.files.data_top_dir = value;
      end
    end	% <-- End of 'data_top_dir'
    if strncmp(str, 'roi_top_dir', length('roi_top_dir'))
      % ROI fileのtop directory (roi_top_dir)
      value = yoyo_sscanf('roi_top_dir=%s', str);
      if length(value)
	line_ok = true;
	para.files.roi_top_dir = value;
      end
    end	% <-- End of 'roi_top_dir'
    if strncmp(str, 'save_dir', length('save_dir'))
      % Data store directory (save_dir)
      value = yoyo_sscanf('save_dir=%s', str);
      if length(value)
	line_ok = true;
	para.files.save_dir = value;
      end
    end	% <-- End of 'save_dir'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % file名に関係するパラメータをloadする。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'roi_epi_threshold', length('roi_epi_threshold'))
      % ROI EPI dataの閾値 (roi_epi_threshold)
      value = yoyo_sscanf('roi_epi_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% 非ゼロ要素の全てのvoxelを採用する条件
	line_ok = true;
	para.files.roi_epi_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('roi_epi_threshold=%f', str);
      if length(value)
	% 指定値以上のvoxelを採用する条件
	line_ok = true;
	para.files.roi_epi_threshold = value;
      end
    end	% <-- End of 'roi_epi_threshold'
    
    if strncmp(str, 'roi_fname', length('roi_fname'))
      % ROI file名 (roi_fname)
      value = array_of_struct('roi_fname[%d]=%s', str, 2)';
      if length(value) >= 2
	n = value(1);			% ROI番号
	if n > para.files.roi_fnum	% ROI番号が登録済のROI file数より大きい
	  % ROI file名を管理するcell配列を拡張する。
	  roi_fname = cell(n,1);
	  for ii=1:para.files.roi_fnum
	    roi_fname{ii} = para.files.roi_fname{ii};
	  end
	  para.files.roi_fname = roi_fname;
	  % ROI dataの閾値を管理するcell配列を拡張する。
	  roi_threshold = cell(n,1);
	  for ii=1:n
	    if ii<=para.files.roi_fnum
	      roi_threshold{ii} = para.files.roi_threshold{ii};
	    else
	      roi_threshold{ii} = define.files.ROI_THRESHOLD;
	    end
	  end
	  para.files.roi_threshold = roi_threshold;
	  % ROI file数を更新する。
	  para.files.roi_fnum = n;
	end	% <-- End of 'if n > para.files.roi_fnum'
	line_ok = true;
	para.files.roi_fname{n} = char(value(2:end));	% ROI file名を登録する
      end
    end	% <-- End of 'roi_fname'

    if strncmp(str, 'roi_threshold', length('roi_threshold'))
      % ROI dataの閾値 (roi_threshold)
      flg = false;
      value = array_of_struct('roi_threshold[%d]=%s', str, 2);
      if length(value) >= 2
	if strncmp(char(value(2:end)),...
	      'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'));
	  % 非ゼロ要素の全てのvoxelを採用する条件
	  n = value(1);					% ROI番号
	  threshold = define.files.ROI_THRESHOLD;	% 閾値
	  flg = true;
	end
      end
      value = array_of_struct('roi_threshold[%d]=%f', str, 2);
      if length(value) == 2
	% 指定値以上のvoxelを採用する条件
	n = round(value(1));		% ROI番号
	threshold = value(2);		% 閾値
	flg = true;
      end
      if flg
	if n > para.files.roi_fnum	% ROI番号が登録済のROI file数より大きい
	  % ROI file名を管理するcell配列を拡張する。
	  roi_fname = cell(n,1);
	  for ii=1:para.files.roi_fnum
	    roi_fname{ii} = para.files.roi_fname{ii};
	  end
	  para.files.roi_fname = roi_fname;
	  % ROI dataの閾値を管理するcell配列を拡張する。
	  roi_threshold = cell(n,1);
	  for ii=1:n
	    if ii<=para.files.roi_fnum
	      roi_threshold{ii} = para.files.roi_threshold{ii};
	    else
	      roi_threshold{ii} = define.files.ROI_THRESHOLD;
	    end
	  end
	  para.files.roi_threshold = roi_threshold;
	  % ROI file数を更新する。
	  para.files.roi_fnum = n;
	end     % <-- End of 'if n > para.files.roi_fnum'
	line_ok = true;
	para.files.roi_threshold{n} = threshold;        % 閾値を登録する
      end	% <-- End of 'if flg'
    end	% <-- End of 'roi_threshold'

    if strncmp(str, 'wm_fname', length('wm_fname'))
      % WM file名 (wm_fname)
      value = yoyo_sscanf('wm_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.wm_fname = value;
      end
    end	% <-- End of 'wm_fname'
    if strncmp(str, 'wm_threshold', length('wm_threshold'))
      % WM dataの閾値 (wm_threshold)
      value = yoyo_sscanf('wm_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% 非ゼロ要素の全てのvoxelを採用する条件
	line_ok = true;
	para.files.wm_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('wm_threshold=%f', str);
      if length(value)
	% 指定値以上のvoxelを採用する条件
	line_ok = true;
	para.files.wm_threshold = value;
      end
    end	% <-- End of 'wm_threshold'

    if strncmp(str, 'gs_fname', length('gs_fname'))
      % GS file名 (gs_fname)
      value = yoyo_sscanf('gs_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.gs_fname = value;
      end
    end	% <-- End of 'gs_fname'
    if strncmp(str, 'gs_threshold', length('gs_threshold'))
      % GS dataの閾値 (gs_threshold)
      value = yoyo_sscanf('gs_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% 非ゼロ要素の全てのvoxelを採用する条件
	line_ok = true;
	para.files.gs_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('gs_threshold=%f', str);
      if length(value)
	% 指定値以上のvoxelを採用する条件
	line_ok = true;
	para.files.gs_threshold = value;
      end
    end	% <-- End of 'gs_threshold'

    if strncmp(str, 'csf_fname', length('csf_fname'))
      % CSF file名 (csf_fname)
      value = yoyo_sscanf('csf_fname=%s', str);
      if length(value)
	line_ok = true;
	para.files.csf_fname = value;
      end
    end	% <-- End of 'csf_fname'
    if strncmp(str, 'csf_threshold', length('csf_threshold'))
      % CSF dataの閾値 (csf_threshold)
      value = yoyo_sscanf('csf_threshold=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% 非ゼロ要素の全てのvoxelを採用する条件
	line_ok = true;
	para.files.csf_threshold = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('csf_threshold=%f', str);
      if length(value)
	% 指定値以上のvoxelを採用する条件
	line_ok = true;
	para.files.csf_threshold = value;
      end
    end	% <-- End of 'csf_threshold'
    
    if strncmp(str, 'templ_image_fname', length('templ_image_fname'))
      % Template image file名 (templ_image_fname)
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
    % fMRIのscan条件に関係するパラメータをloadする。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'trial_num', length('trial_num'))
      % 試行数 (trial_num)
      value = yoyo_sscanf('trial_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.trial_num = value;
      end
    end	% <-- End of 'trial_num'
    if strncmp(str, 'pre_trial_scan_num', length('pre_trial_scan_num'))
      % 試行を開始する迄のscan数 (pre_trial_scan_num)
      value = yoyo_sscanf('pre_trial_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.pre_trial_scan_num = value;
      end
    end	% <-- End of 'pre_trial_scan_num'
    if strncmp(str, 'prep_rest1_scan_num', length('prep_rest1_scan_num'))
      % 1試行目の前処理用のREST条件その1のscan数 (prep_rest1_scan_num)
      value = yoyo_sscanf('prep_rest1_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.prep_rest1_scan_num = value;
      end
    end	% <-- End of 'prep_rest1_scan_num'
    if strncmp(str, 'prep_rest2_scan_num', length('prep_rest2_scan_num'))
      % 1試行目の前処理用のREST条件その2のscan数 (prep_rest2_scan_num)
      value = yoyo_sscanf('prep_rest2_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.prep_rest2_scan_num = value;
      end
    end	% <-- End of 'prep_rest2_scan_num'
    if strncmp(str, 'rest_scan_num', length('rest_scan_num'))
      % REST条件のscan数 (rest_scan_num)
      value = yoyo_sscanf('rest_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.rest_scan_num = value;
      end
    end	% <-- End of 'rest_scan_num'
    if strncmp(str, 'test_scan_num', length('test_scan_num'))
      % TEST条件のscan数 (test_scan_num)
      value = yoyo_sscanf('test_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.test_scan_num = value;
      end
    end	% <-- End of 'test_scan_num'
    if strncmp(str, 'pre_test_delay_scan_num',...
	  length('pre_test_delay_scan_num'))
      % TEST条件開始後のdelay scan数 (pre_test_delay_scan_num)
      value = yoyo_sscanf('pre_test_delay_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.pre_test_delay_scan_num = value;
      end
    end	% <-- End of 'pre_test_delay_scan_num'
    if strncmp(str, 'post_test_delay_scan_num',...
	  length('post_test_delay_scan_num'))
      % TEST条件終了後のdelay scan数 (post_test_delay_scan_num)
      value = yoyo_sscanf('post_test_delay_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.post_test_delay_scan_num = value;
      end
    end	% <-- End of 'post_test_delay_scan_num'
    if strncmp(str, 'calc_score_scan_num', length('calc_score_scan_num'))
      % 得点計算条件のscan数 (calc_score_scan_num)
      value = yoyo_sscanf('calc_score_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.calc_score_scan_num = value;
      end
    end	% <-- End of 'calc_score_scan_num'
    if strncmp(str, 'feedbk_score_scan_num', length('feedbk_score_scan_num'))
      % 得点提示条件のscan数 (feedbk_score_scan_num)
      value = yoyo_sscanf('feedbk_score_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.feedbk_score_scan_num = value;
      end
    end	% <-- End of 'feedbk_score_scan_num'
    if strncmp(str, 'TR', length('TR'))
      % Scan間隔 (TR)
      value = yoyo_sscanf('TR=%f', str);
      if length(value)
	line_ok = true;
	para.scans.TR = value;
      end
    end	% <-- End of 'TR'
    if strncmp(str, 'regress_scan_num', length('regress_scan_num'))
      % fMRIデータのノイズ除去処理に利用するscan数 (regress_scan_num)
      value = yoyo_sscanf('regress_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.regress_scan_num = value;
      end
    end	% <-- End of 'regress_scan_num'
    if strncmp(str, 'sleep_check_trial_num',...
	  length('sleep_check_trial_num'))
      % 被検者が寝ていないかをチェックする試行数 (sleep_check_trial_num)
      value = yoyo_sscanf('sleep_check_trial_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.sleep_check_trial_num = value;
      end
    end	% <-- End of 'sleep_check_trial_num'
    if strncmp(str, 'rating_scan_num', length('rating_scan_num'))
      % REST条件のscan数 (rating_scan_num)
      value = yoyo_sscanf('rating_scan_num=%d', str);
      if length(value)
	line_ok = true;
	para.scans.rating_scan_num = value;
      end
    end	% <-- End of 'rating_scan_num'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 得点計算用パラメータをloadする。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if strncmp(str, 'score_mode', length('score_mode'))
      % 得点モード (score_mode)
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
      % 脳の半径 (radius_of_brain) (mm)
      value = yoyo_sscanf('radius_of_brain=%f', str);
      if length(value)
	line_ok = true;
	para.score.radius_of_brain = value;
      end
    end	% <-- End of 'radius_of_brain'
    
    if strncmp(str, 'FD_threshold',...
	  length('FD_threshold'))
      % Scan中の脳の移動量の閾値 (FD_threshold) (mm)
      value = yoyo_sscanf('FD_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.score.FD_threshold = value;
      end
    end	% <-- End of 'FD_threshold'
    
    if strncmp(str, 'corr_roi_template_threshold',...
	  length('corr_roi_template_threshold'))
      %  ROI templateとROIの相関係数の閾値 (corr_roi_template_threshold)
      value = yoyo_sscanf('corr_roi_template_threshold=%f', str);
      if length(value)
	line_ok = true;
	para.score.corr_roi_template_threshold = value;
      end
    end	% <-- End of 'corr_roi_template_threshold'

    if strncmp(str, 'score_normrnd_mu', length('score_normrnd_mu'))
      % 正規分布乱数の平均値パラメータ (normrnd_mu)
      value = yoyo_sscanf('score_normrnd_mu=%f', str);
      if length(value)
	line_ok = true;
	para.score.normrnd_mu = value;
      end
    end	% <-- End of 'score_normrnd_mu'
    if strncmp(str, 'score_normrnd_sigma', length('score_normrnd_sigma'))
      % 正規分布乱数の標準偏差パラメータ (normrnd_sigma)
      value = yoyo_sscanf('score_normrnd_sigma=%f', str);
      if length(value)
	line_ok = true;
	para.score.normrnd_sigma = value;
      end
    end	% <-- End of 'score_normrnd_sigma'
    if strncmp(str, 'score_limit', length('score_limit'))
      % 得点の下限と上限の閾値 (score_limit)
      value = yoyo_sscanf('score_limit=(%f,%f)', str);
      if length(value) == 2
	line_ok = true;
	para.score.score_limit(define.MIN) = min(value);
	para.score.score_limit(define.MAX) = max(value);
      end
    end	% <-- End of 'score_limit'

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 視覚feedbackに関係するパラメータをloadする。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'feedback_io_tool', length('feedback_io_tool'))
      % 試行開始トリガー信号等の入力や視覚feedback出力先等の
      % 入出力用ツール(feedback_io_tool)
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
      % 視覚feedbackの提示タイプ (feedback_type)
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
      % 得点を被検者に提示するタイミング (feedback_score_timing)
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
      % 視覚刺激を提示するscreen番号 (feedback_screen)
      value = yoyo_sscanf('feedback_screen=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.screen = value;
      end
    end	% <-- End of 'feedback_screen'
    if strncmp(str, 'feedback_prep_rest1_comment',...
	  length('feedback_prep_rest1_comment'))
      % 1試行目の前処理用のREST条件その1でのコメント文字列
      % (feedback_prep_rest1_comment)
      value = yoyo_sscanf('feedback_prep_rest1_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_rest1_comment = value;
      end
    end	% <-- End of 'feedback_prep_rest1_comment'
    if strncmp(str, 'feedback_prep_rest2_comment',...
	  length('feedback_prep_rest2_comment'))
      % 1試行目の前処理用のREST条件その2でのコメント文字列
      % (feedback_prep_rest2_comment)
      value = yoyo_sscanf('feedback_prep_rest2_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_rest2_comment = value;
      end
    end	% <-- End of 'feedback_prep_rest2_comment'
    if strncmp(str, 'feedback_rest_comment', length('feedback_rest_comment'))
      % REST条件でのコメント文字列 (feedback_rest_comment)
      value = yoyo_sscanf('feedback_rest_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.rest_comment = value;
      end
    end	% <-- End of 'feedback_rest_comment'
    if strncmp(str, 'feedback_test_comment', length('feedback_test_comment'))
      % TEST条件でのコメント文字列 (feedback_test_comment)
      value = yoyo_sscanf('feedback_test_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.test_comment = value;
      end
    end	% <-- End of 'feedback_test_comment'
    if strncmp(str, 'feedback_prep_score_comment',...
	  length('feedback_prep_score_comment'))
      % TEST条件が終了した後、得点を提示するまでの間の
      % 条件でのコメント文字列 (feedback_prep_score_comment)
      value = yoyo_sscanf('feedback_prep_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.prep_score_comment = value;
      end
    end	% <-- End of 'feedback_prep_score_comment'
    if strncmp(str, 'feedback_score_comment', length('feedback_score_comment'))
      % 得点提示条件でのコメント文字列 (feedback_score_comment)
      value = yoyo_sscanf('feedback_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.score_comment = value;
      end
    end	% <-- End of 'feedback_score_comment'
    if strncmp(str, 'feedback_ng_score_comment',...
	  length('feedback_ng_score_comment'))
      % 得点の計算処理不可時のコメント文字列 (feedback_ng_score_comment)
      value = yoyo_sscanf('feedback_ng_score_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.ng_score_comment = value;
      end
    end	% <-- End of 'feedback_ng_score_comment'
    if strncmp(str, 'feedback_finished_block_comment',...
	  length('feedback_finished_block_comment'))
      % ブロック終了条件でのコメント文字列 (feedback_finished_block_comment)
      value = yoyo_sscanf('feedback_finished_block_comment=%s', str);
      if length(value)
	line_ok = true;
	para.feedback.finished_block_comment = value;
      end
    end	% <-- End of 'feedback_finished_block_comment'
    if strncmp(str, 'feedback_finished_block_duration',...
	  length('feedback_finished_block_duration'))
      % ブロック終了条件の視覚feedbackの提示時間(sec) (finished_block_duration)
      value = yoyo_sscanf('feedback_finished_block_duration=%f', str);
      if length(value)
	line_ok = true;
	para.feedback.finished_block_duration = value;
      end
    end	% <-- End of 'feedback_finished_block_duration'
    if strncmp(str, 'feedback_gaze_frame_r', length('feedback_gaze_frame_r'))
      % 注視点の半径(円弧 枠) (feedback_gaze_frame_r)
      value = yoyo_sscanf('feedback_gaze_frame_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.gaze_frame_r = value;
      end
    end	% <-- End of 'feedback_gaze_frame_r'
    if strncmp(str, 'feedback_gaze_fill_r', length('feedback_gaze_fill_r'))
      % 注視点の半径(円弧 塗) (feedback_gaze_fill_r)
      value = yoyo_sscanf('feedback_gaze_fill_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.gaze_fill_r = value;
      end
    end	% <-- End of 'feedback_gaze_fill_r'
    if strncmp(str, 'feedback_sleep_fill_r', length('feedback_sleep_fill_r'))
      % 注視点の半径(寝ていないかチェック用) (feedback_sleep_fill_r)
      value = yoyo_sscanf('feedback_sleep_fill_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.sleep_fill_r = value;
      end
    end	% <-- End of 'feedback_sleep_fill_r'
    if strncmp(str, 'feedback_max_score_r', length('feedback_max_score_r'))
      % 得点の上限値での得点を提示する円の半径 (feedback_max_score_r)
      value = yoyo_sscanf('feedback_max_score_r=%d', str);
      if length(value)
	line_ok = true;
	para.feedback.max_score_r = value;
      end
    end	% <-- End of 'feedback_max_score_r'


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Stanford sleepiness scale(スタンフォード眠気尺度)
    % に関係するパラメータをloadする。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strncmp(str, 'sss_flag', length('sss_flag'))
      % Stanford眠気尺度質問フラグ (sss_flag)
      value = yoyo_sscanf('sss_flag=%d', str);
      if length(value)
	line_ok = true;
	para.sss.sss_flag = logical(value);
      end
    end	% <-- End of 'sss_flag'
    if strncmp(str, 'sss_image_dir', length('sss_image_dir'))
      % Stanford眠気尺度質問画像fileのdirectory (sss_image_dir)
      value = yoyo_sscanf('sss_image_dir=%s', str);
      if length(value)
	line_ok = true;
	para.sss.sss_image_dir = value;
      end
    end	% <-- End of 'sss_image_dir'
    if strncmp(str, 'sss_image_fname', length('sss_image_fname'))
      % Stanford眠気尺度質問画像file名 (sss_image_fname)
      value = yoyo_sscanf('sss_image_fname=%s', str);
      if length(value)
	line_ok = true;
	para.sss.sss_image_fname = value;
      end
    end	% <-- End of 'sss_image_fname'


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    if strncmp(str, 'roi_vol_graph_flag', length('roi_vol_graph_flag'))
      % ROI volume graph表示フラグ (roi_vol_graph_flag)
      value = yoyo_sscanf('roi_vol_graph_flag=%d', str);
      if length(value)
	line_ok = true;
	para.roi_vol_graph_flag = logical(value);
      end
    end	% <-- End of 'roi_vol_graph_flag'
    
    
    if line_ok == false		% 不正な行を発見した。
      % エラーメッセージを更新する。
      err.status = false;
      err.msg = sprintf('%s ERROR %3d : %s', err.msg, line_no, str);
    end
  end	% <-- End of 'if str == -1 ... else'
end	% <-- End of 'while(true)'

fclose(fd);


if err.status
  % Parameterファイルに記述されている実験パラメータの整合性を検証する。

  if DecNef_Project ~= define.DECNEF_PROJECT;
    % DecNef実験プロジェクトコードに不正値を設定した。
    err.status = false;
    err.msg = sprintf(...
	'%s ERROR : Invalid value is set for ''ProjectCode''.\n',...
	err.msg);
    err.msg = sprintf('%s \t ProjectCode = DecNef%d\n',...
	err.msg, DecNef_Project);
  end	% <-- End of 'if DecNef_Project ~= define.DECNEF_PROJECT'


  if para.denoising_method == define.denoising_method.REGRESS
    % fMRIデータのノイズ除去処理を多重線形回帰の残差
    % (regress関数を利用する)で行なう条件のパラメータ
    % をチェックする。

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 'ノイズ除去処理を多重線形回帰の残差で行なう条件' で
    % '脳活動パターンから得点を計算する条件' の場合
    % 	-> WM file, GS file, CSF fileを指定しなければならない
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if para.score.score_mode == define.score_mode.CALC_SCORE &... 
	  isempty( para.files.wm_fname)
      % '脳活動パターンから得点を計算する条件' で 'WM file名が未設定' の場合
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
      % '脳活動パターンから得点を計算する条件' で 'GS file名が未設定' の場合
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
      % '脳活動パターンから得点を計算する条件' で 'CSF file名が未設定' の場合
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
      % fMRIデータのノイズ除去処理に利用するscan数に不正値を設定した。
      % 前処理用のREST条件その1のscan数(prep_rest1_scan_num) + 
      % 前処理用のREST条件その2のscan数(prep_rest2_scan_num) + 
      % REST条件のscan数(rest_scan_num) + 
      % TEST条件のscan数(test_scan_num) +
      % TEST条件終了後のdelay scan数(post_test_delay_scan_num)
      % 以上でなければならない。
      % ( create_global.m内のcreate_para()のコメントを参照 )
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
  % ROI fileの数をチェックする。
  % ------------------------------------------------------------
  % 脳活動パターンから得点を計算する条件
  % (para.score.score_mode=CALC_SCORE)の場合
  % 	-> ROI fileを指定しなければならない。
  % 脳活動パターンから得点を計算条件 '以外'の条件の場合
  % 	-> ROI fileを指定していなくてもよい。
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if para.score.score_mode == define.score_mode.CALC_SCORE &... 
      para.files.roi_fnum == 0
    % 脳活動パターンから得点を計算する条件(para.score.score_mode=CALC_SCORE)
    % でROI fileを指定していない(ROI file数が0)
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
  % ROI fileの拡張子をチェックする。
  %  ------------------------------------------------------------
  % ROI fileの拡張子として許可された文字列は、
  % define.files.ROI_FILE_EXTENSIONに設定されている。
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for roi=1:para.files.roi_fnum
    if isempty(para.files.roi_fname{roi})
      % ROI fileを指定していない。
      err.status = false;
      err.msg = sprintf(...
	  '%s ERROR : ''roi_fname[%d]'' is not set..\n',err.msg, roi);
    else
      % ROI fileの拡張子を獲得する。
      [pathstr,name,ext] = fileparts( para.files.roi_fname{roi} );
      if length( find( strcmpi(ext , define.files.ROI_FILE_EXTENSION) ) )==0
	% ROI file名の拡張子に不正な文字列を指定している。
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
  % Template imageファイルの拡張子をチェックする。
  %  ------------------------------------------------------------
  % Template imageファイルは
  % DICOM file(拡張子:define.files.DICOM_FILE_EXTENSION) か
  % NIfTI file(拡張子:define.files.NIFTI_FILE_EXTENSION)
  % でなければならない
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [pathstr, templ_name, templ_ext] = fileparts(para.files.templ_image_fname);
  tmp = sum( strcmp(templ_ext, define.files.DICOM_FILE_EXTENSION) ) +...
      sum( strcmp(templ_ext, define.files.NIFTI_FILE_EXTENSION) );
  if tmp == 0
    err.status = false;
    % Template image fileの拡張子が不正
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
    % 被検者が寝ていないかをチェックする試行数に不正値を設定した。
    % (試行数より大きな値を設定している。)
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
  
  % 視覚刺激を提示するscreen番号をチェックする。
  % (PCに接続されているScreen数を獲得し、視覚刺激
  %  を提示するscreen番号を判定する。)
  switch para.feedback.io_tool
    case define.feedback.io_tool.PSYCHTOOLBOX
      % 試行開始トリガー信号等の入力や視覚feedback出力先等の
      % 入出力用ツールにPsychtoolboxを利用する
      screenNumber = max( Screen('Screens') );
    case define.feedback.io_tool.MATLAB
      % 試行開始トリガー信号等の入力や視覚feedback出力先等の
      % 入出力用ツールにMATLABを利用する
      screenNumber = size( get(0, 'MonitorPositions'), 1 );
    case define.feedback.io_tool.DO_NOT_USE
      % 試行開始トリガー信号等の入力や視覚feedback出力を
      % 行なわない
      screenNumber = intmax;	% 整数の最大値を代入しておく。
  end	% <-- End of 'para.feedback.io_tool'
  if para.feedback.screen < 1 | para.feedback.screen > screenNumber
    % 視覚刺激を提示するscreen番号に範囲外の値を設定した。
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
% 構造体配列用パラメータ文字列(str)が文字列条件(format)に
% 一致するか確認する。
% 
% 構造体配列用パラメータ文字列は、
% 
% [1] 構造体名[配列番号]=値
%   str = 'SwitchDuration[4]=0.75'
%   format = 'SwitchDuration[%d]=%f'
%     -> value = [4.0, 0.75]
% 
% [2] 構造体名[配列番号].メンバ変数名=値
%   str = 'sequence[1].dynamics=DYNAMICS5'
%   format = 'sequence[%d].dynamics=DYNAMICS%d'
%     -> value = [1, 5]
% 
% [3] 構造体名[配列番号]=(値1,値2)
%   str = 'target_pos_task[1]=(0.000,-0.10)'
%   format = 'target_pos_task[%d]=(%f,%f)'
%     -> value = [1.0, 0.0, -0.1]
% 
% [4] 構造体名[配列番号].メンバ変数名=(値1,値2)
%   str = 'tsequence[1].start_target=(4, 3)'
%   format = 'tsequence[%d].start_target=(%d,%d)'
%     -> value = [1, 4, 3]
% 
% の型式で記述さているものとする。
% 成功の場合、返り値(value)にはnum個の数値が設定される。
% 1個目が配列番号、2個目以降が設定値
% 
% 
%
% **** 注意!! ****
% 文字列条件(format)の'='の前後にスペースを挿入してはいけない。
% 
% **** 注意!! ****
% array_of_struct()内で、文字列(str)内の '=' , '[' , ']' , '(' , ')' 文字
% の前後のスペースを削除する。
% 
% [input argument]
% format : 文字列条件
%          sprintf()の文字列条件式と同様の形式だが、
%          文字列条件(format)の '=','[',']','(',')'の前後にスペース
%          を挿入してはいけない。
% str : 構造体配列用パラメータ文字列
% num : パラメータ値の数
% 
% [output argument]
% value : パラメータ値

value = sscanf(str, format);
% 文字列条件(format)に一致しない場合、文字列(str)内の
% '=' , '[' , ']' , '(' , ')' 文字の前後のスペースを削除して検索する。
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
% File dialogを用いてSham scoreファイルを選択し、
% Sham scoreファイルから得点を読む。
% 
% [input argument]
% define : define変数を管理する構造体
% para : 実験パラメータ構造体
% err : エラー情報
% 
% [output argument]
% para : パラメータ値を設定後の実験パラメータ構造体
% err : エラー情報

kaigyo = sprintf('\n');		% 改行文字
kaigyo_dos = 13;		% 改行文字 (DOS)
comment = '#';			% コメント行の先頭文字

% File dialogを用いてSham score fileを選択する。
if define.files.STD_DIALOG_BOX  % MATLAB標準のdialog boxを用いる
  [fname, dname, index] = uigetfile(...
      sprintf('%s%s*%s',...
      para.files.para_dir, filesep, define.files.SHAM_SCORE_FILE_EXTENSION),...
      'Select Sham score file');
else				% 独自開発のdialog boxを用いる
  file_extensions = { define.files.SHAM_SCORE_FILE_EXTENSION };
  [index, dname, fname] =...
      yoyo_file_dialog(para.files.para_dir, file_extensions,...
      'Select Sham score file');
  if index
    fname = char( fname{1} );	% cell配列から文字列に変換する。
  end
end

% Sham score fileのdirectory名とfile名を更新する。
if index
  para.files.sham_score_dir = dname;
  para.files.sham_score_fname = fname;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sham scoreファイルから得点を読む。
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
  line_no = 0;		% 行番号
  err.msg = sprintf('%sin ''%s''\n', err.msg, sham_score_filename);
  
  para.score.sham_score = nan(para.scans.trial_num, 1);
  
  while true
    str = fgets(fd);		% 1行読み出す。
    line_no = line_no+1;	% 行番号を更新する。
    
    if str == -1, break;	% End of file
    else
      line_ok = false;
      
      if str(1) == comment | str(1) == kaigyo | str(1) == kaigyo_dos
	line_ok = true;	% コメント行, 空白行
      end
      
      if strncmp(str, 'sham_score', length('sham_score'))
	value = array_of_struct('sham_score[%d]=%f', str, 2);
	if length(value) == 2
	  n = round(value(1));				% 試行番号
	  if n <= para.scans.trial_num
	    para.score.sham_score(n) = value(2);	% 得点
	  end
	  line_ok = true;
	end
      end
      
      if line_ok == false		% 不正な行を発見した。
	% エラーメッセージを更新する。
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
% directoryに関係するパラメータを設定する。
% 
% Parameterファイルから読み込んだdirectoryに関係する
% パラメータの整合性チェック(Directoryが存在するか)と、
% DICOM file, Template image fileとROI fileのdirectory
% を設定する。
% 
% [input argument]
% define : define変数を管理する構造体
% para : 実験パラメータ構造体
% err : エラー情報
% 
% [output argument]
% para : 実験パラメータ構造体
% err : エラー情報

err.msg = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% data_top_dir名を絶対パスに変換する。
[status, pathinfo] = fileattrib(para.files.data_top_dir);
if status
  para.files.data_top_dir = pathinfo.Name;
else
  % エラーメッセージを更新する。
  err.status = false;
  err.msg = sprintf('%s\n %s (data_top_dir : ''%s'')',...
      err.msg, pathinfo, para.files.data_top_dir);
end
% ROI top directoryを絶対パスに変換する。
[status, pathinfo] = fileattrib(para.files.roi_top_dir);
if status
  para.files.roi_top_dir = pathinfo.Name;
else
  % エラーメッセージを更新する。
  err.status = false;
  err.msg = sprintf('%s\n %s (roi_top_dir : ''%s'')',...
      err.msg, pathinfo, para.files.roi_top_dir);
end
% Data store directoryを絶対パスに変換する。
[status, pathinfo] = fileattrib(para.files.save_dir);
if status
  para.files.save_dir = pathinfo.Name;
else
  % エラーメッセージを更新する。
  err.status = false;
  err.msg = sprintf('%s\n %s (save_dir : ''%s'')',...
      err.msg, pathinfo, para.files.save_dir);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOM fileのdirectory, Template DICOM file, 
% ROI fileのdirectory をdialog boxで選択する。
% ROI fileを指定しない場合(para.files.roi_fnum=0)、ROI file
% のdirectoryの選択は省略する。
% ----------------------------------------------------------
% ( 脳活動パターンから得点を計算(para.score.score_mode==CALC_SCORE)
%   '以外' の条件では、ROI fileを指定しなても良い。
%   create_global.m内のcreate_para()のfiles構造体のコメント
%   を参照 )
% ----------------------------------------------------------
% 結合neurofeedback(DecCNef)実験では、ここでTemplate image
% fileのdirectoryを選択する必要はないが、Decoded neurofeedback
% (DecNef)実験では、roi_top_dirの下の階層のdirectoryを
% dialog boxで選択し、選択したdirectory名をtempl_image_dir
% に設定する。
% ( create_global.m内のcreate_paraa()のfiles構造体のコメント
%   を参照 )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if err.status
  if define.files.STD_DIALOG_BOX	% MATLAB標準のdialog boxを用いる
    % MATLAB標準のdialog boxの処理関数 uigetdir() は
    % 'Cancel' buttonを選択した場合は0を
    % 'OK' buttonを選択した場合はdirectoryを返す。

    % DICOM fileのdirectoryを設定する。
    ret = uigetdir(para.files.data_top_dir, 'Select DICOM directory');
    if ret
      para.files.dicom_dir = ret;
      ret = true;
    end
    % Template image fileのdirectoryを設定する。
    ret = uigetdir(para.files.roi_top_dir, 'Select Template image directory');
    if ret
      para.files.templ_image_dir = ret;
      ret = true;
    end
    % ROI fileのdirectoryを設定する。
    if ret & para.files.roi_fnum
      ret = uigetdir(para.files.roi_top_dir, 'Select ROI directory');
      if ret
	para.files.roi_dir = ret;
	ret = true;
      end
    end
  else				% 独自開発のdialog boxを用いる
    file_extensions = { '' };
    % DICOM fileのdirectoryを設定する。
    [ret, para.files.dicom_dir, fname] =...
	yoyo_file_dialog(para.files.data_top_dir, file_extensions,...
	'Select DICOM directory');
    % Template image fileのdirectoryを設定する。
    [ret, para.files.templ_image_dir, fname] =...
	yoyo_file_dialog(para.files.roi_top_dir, file_extensions,...
	'Select Template image directory');
    % ROI fileのdirectoryを設定する。
    if ret & para.files.roi_fnum
      [ret, para.files.roi_dir, fname] =...
	  yoyo_file_dialog(para.files.roi_top_dir, file_extensions,...
	  'Select ROI directory');
    end
  end	% <-- End of 'if define.files.STD_DIALOG_BOX ... else ...'
  
  
  % 指定したdirectoryが存在するかチェックする。
  if exist(para.files.save_dir, 'dir') ~= 7
    err.status = false;
    err.msg = sprintf('%s\n No such Save directory (''%s'')',...
	err.msg, para.files.save_dir);
  end
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
end	% <-- End of 'if err.status'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dir_para()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [para] = set_parameters(define, para)
% function [para] = set_parameters(define, para)
% 実験パラメータ構造体を更新する。
% 
% Parameterファイルから読み込んだ実験パラメータから
% 実験パラメータ構造体を更新する。
% 
% [input argument]
% define : define変数を管理する構造体
% para   : 実験パラメータ構造体
% 
% [output argument]
% para  : 実験パラメータ構造体

% 1試行目の一試行のscan数を求める。
para.scans.first_trial_scan_num =...
    para.scans.prep_rest1_scan_num +...	% 前処理用のREST条件その1のscan数
    para.scans.prep_rest2_scan_num +...	% 前処理用のREST条件その2のscan数
    para.scans.rest_scan_num +...      	% REST条件のscan数
    para.scans.test_scan_num +...	% TEST条件のscan数
    para.scans.post_test_delay_scan_num +...	% TEST条件終了後のdelay scan数
    para.scans.calc_score_scan_num +...	% 得点計算条件のscan数
    para.scans.feedbk_score_scan_num;	% 得点提示条件のscan数
% 2試行目以降の一試行のscan数を求める。
para.scans.trial_scan_num =...
    para.scans.rest_scan_num +...	% REST条件のscan数
    para.scans.test_scan_num +...	% TEST条件のscan数
    para.scans.post_test_delay_scan_num +...	% TEST条件終了後のdelay scan数
    para.scans.calc_score_scan_num +...	% 得点計算条件のscan数
    para.scans.feedbk_score_scan_num;	% 得点提示条件のscan数
% 総Scan数を求める。
para.scans.total_scan_num =...
    para.scans.pre_trial_scan_num +...
    para.scans.first_trial_scan_num + ...
    para.scans.trial_scan_num*(para.scans.trial_num - 1);
% 被検者が寝ていないかをチェックする試行番号を設定する配列を用意する。
% (define.key.SLEEP_CHECK_KEYで指定したキーを入力させる)
[tmp, rand_trial] = sort( rand(para.scans.trial_num, 1) );
para.scans.sleep_check_trial =...
    find( rand_trial <= para.scans.sleep_check_trial_num );


% 各scanのNIfTI file名を設定するcell配列を作成する。
para.files.nifti_fnames = cell(para.scans.total_scan_num,1);

% DICOMファイルの撮影情報を設定する。
para = set_dicom_info(define, para);
% Save name( '患者(被検者)名前_検査(撮影)実施日' )を設定する。
para.save_name = sprintf('%s_%s',...
    para.dicom_info.patient_name, para.dicom_info.study_date);
% 実験被検者ID( '患者(被検者)名前_患者(被検者)ID' )を設定する。
para.exp_id = sprintf('%s_%s',...
    para.dicom_info.patient_name, para.dicom_info.patient_id);
% 実験(撮影)実施日(YYMMDD)を設定する。
para.exp_date = para.dicom_info.study_date;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 視覚提示やトリガー入力しない条件(feedback.io_tool = DO_NOT_USE)
% の場合、Stanford眠気尺度は質問しない。
% (create_global.m内のset_parameters()のsss構造体のコメント参照)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if para.feedback.io_tool == define.feedback.io_tool.DO_NOT_USE
  para.sss.sss_flag = false;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_parameters()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
