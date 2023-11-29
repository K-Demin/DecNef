function [define] = load_default_value(define, current_dir)
% function [define] = load_default_value(define, current_dir)
% default設定ファイルの設定値で、neurofeedback実験プログラム
% のdefault値を更新する。
% 
% default設定ファイルが存在しない場合は、neurofeedback実験
% プログラムのdefault値は更新しない。(WARNING)
% 
% default設定ファイルに記述不備を発見した場合は、neurofeedback
% 実験を中止する。(ERROR)
% 
% [input argument]
% define      : define変数を管理する構造体
% current_dir : Current directory
% 
% [output argument]
% define : define変数を管理する構造体


kaigyo = sprintf('\n');		% 改行文字
kaigyo_dos = 13;		% 改行文字 (DOS)
comment = '#';			% コメント行の先頭文字

defualt_set_fname = fullfile(current_dir, define.default.DEFUALT_SET_FNAME);
fd = fopen(defualt_set_fname, 'r');
if fd == -1
  % default設定ファイルが存在しない場合は、neurofeedback実験
  % プログラムのdefault値は更新しない。(WARNING)
  msg = sprintf('FOPEN cannot open the file(''%s'').', defualt_set_fname);
  warning( msg );
  return;
end

line_no = 0;		% 行番号

while true
  str = fgets(fd);	% 1行読み出す。
  line_no = line_no+1;	% 行番号を更新する。

  if str == -1, break;	% End of file
  else
    line_ok = false;
    
    if str(1) == comment | str(1) == kaigyo | str(1) == kaigyo_dos
      line_ok = true;	% コメント行, 空白行
    end

    
    if strncmp(str, 'DEFAULT_CURRENT_BLOCK', length('DEFAULT_CURRENT_BLOCK'))
      % Block番号のdefault値 (DEFAULT_CURRENT_BLOCK)
      value = yoyo_sscanf('DEFAULT_CURRENT_BLOCK=%d', str);
      if length(value)
	line_ok = true;
	define.default.CURRENT_BLOCK = value;
      end
    end	% <-- End of 'DEFAULT_CURRENT_BLOCK'
    if strncmp(str, 'QUIT_KEY_INUM', length('QUIT_KEY_INUM'))
      % 中止キー文字の入力要求数 (QUIT_KEY_INUM)
      value = yoyo_sscanf('QUIT_KEY_INUM=%d', str);
      if length(value)
	line_ok = true;
	define.default.QUIT_KEY_INUM = value;
      end
    end	% <-- End of 'QUIT_KEY_INUM'
    if strncmp(str, 'REALIGN_VAL_NUM', length('REALIGN_VAL_NUM'))
      % Realignment parameterの配列数 (REALIGN_VAL_NUM)
      value = yoyo_sscanf('REALIGN_VAL_NUM=%d', str);
      if length(value)
	line_ok = true;
	define.default.REALIGN_VAL_NUM = value;
      end
    end	% <-- End of 'REALIGN_VAL_NUM'
    if strncmp(str, 'SSS_MAX_LEVEL', length('SSS_MAX_LEVEL'))
      % Stanford眠気尺度の最大レベル (SSS_MAX_LEVEL)
      value = yoyo_sscanf('SSS_MAX_LEVEL=%d', str);
      if length(value)
	line_ok = true;
	define.default.SSS_MAX_LEVEL = value;
      end
    end	% <-- End of 'SSS_MAX_LEVEL'
    if strncmp(str, 'NG_SCORE_DISPLAY_TIME', length('NG_SCORE_DISPLAY_TIME'))
      % 得点計算不可時の視覚feedback提示時間 (NG_SCORE_DISPLAY_TIME)
      value = yoyo_sscanf('NG_SCORE_DISPLAY_TIME=%f', str);
      if length(value)
	line_ok = true;
	define.default.NG_SCORE_DISPLAY_TIME = value;
      end
    end	% <-- End of 'NG_SCORE_DISPLAY_TIME'
    if strncmp(str, 'CAUTION_MSG_DELAY_SCAN_NUM',...
	  length('CAUTION_MSG_DELAY_SCAN_NUM'))
      % 警告メッセージを出力する処理遅れのscan数 (CAUTION_MSG_DELAY_SCAN_NUM)
      value = yoyo_sscanf('CAUTION_MSG_DELAY_SCAN_NUM=%d', str);
      if length(value)
	line_ok = true;
	define.default.CAUTION_MSG_DELAY_SCAN_NUM = value;
      end
    end	% <-- End of 'CAUTION_MSG_DELAY_SCAN_NUM'
    if strncmp(str, 'CACHE_FNAME', length('CACHE_FNAME'))
      % Cache file名 (CACHE_FNAME)
      value = yoyo_sscanf('CACHE_FNAME=%s', str);
      if length(value)
	line_ok = true;
	define.default.CACHE_FNAME = value;
      end
    end	% <-- End of 'CACHE_FNAME'
    
    if strncmp(str, 'REALIG_PARA_FNAME_PREFIX_CODE',...
	  length('REALIG_PARA_FNAME_PREFIX_CODE'))
      % Realignment para fileの接頭文字 (REALIG_PARA_FNAME_PREFIX_CODE)
      value = yoyo_sscanf('REALIG_PARA_FNAME_PREFIX_CODE=%s', str);
      if length(value)
	line_ok = true;
	define.files.REALIG_PARA_FNAME_PREFIX_CODE = value;
      end
    end	% <-- End of 'REALIG_PARA_FNAME_PREFIX_CODE'

    if strncmp(str, 'ROI_EPI_THRESHOLD', length('ROI_EPI_THRESHOLD'))
      % ROI EPI dataの閾値のdefault値 (ROI_EPI_THRESHOLD)
      value = yoyo_sscanf('ROI_EPI_THRESHOLD=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% 非ゼロ要素の全てのvoxelを採用する条件
	line_ok = true;
	define.files.ROI_EPI_THRESHOLD =...
	    define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('ROI_EPI_THRESHOLD=%f', str);
      if length(value)
	% 指定値以上のvoxelを採用する条件
	line_ok = true;
	define.files.ROI_EPI_THRESHOLD = value;
      end
    end	% <-- End of 'ROI_EPI_THRESHOLD'
    if strncmp(str, 'ROI_THRESHOLD', length('ROI_THRESHOLD'))
      % ROI,WM,GS,CSF dataの閾値のdefault値 (ROI_THRESHOLD)
      value = yoyo_sscanf('ROI_THRESHOLD=%s', str);
      if length(value) &...
	    strncmp(value, 'NONZERO_ELEMENTS', length('NONZERO_ELEMENTS'))
	% 非ゼロ要素の全てのvoxelを採用する条件
	line_ok = true;
	define.files.ROI_THRESHOLD = define.files.NONZERO_ELEMENT_THRESHOLD;
      end
      value = yoyo_sscanf('ROI_THRESHOLD=%f', str);
      if length(value)
	% 指定値以上のvoxelを採用する条件
	line_ok = true;
	define.files.ROI_THRESHOLD = value;
      end
    end	% <-- End of 'ROI_THRESHOLD'

    if strncmp(str, 'CLEANUP_WORK_FILES', length('CLEANUP_WORK_FILES'))
      % work_dir内の作業ファイルの削除フラグ (CLEANUP_WORK_FILES)
      value = yoyo_sscanf('CLEANUP_WORK_FILES=%d', str);
      if length(value)
	line_ok = true;
	define.files.CLEANUP_WORK_FILES = logical(value);
      end
    end	% <-- End of 'CLEANUP_WORK_FILES'
    if strncmp(str, 'STD_DIALOG_BOX', length('STD_DIALOG_BOX'))
      % dialog box選択フラグ (STD_DIALOG_BOX)
      value = yoyo_sscanf('STD_DIALOG_BOX=%d', str);
      if length(value)
	line_ok = true;
	define.files.STD_DIALOG_BOX = logical(value);
      end
    end	% <-- End of 'STD_DIALOG_BOX'
	
    if strncmp(str, 'DEFAULT_MSOCKET_PORT', length('DEFAULT_MSOCKET_PORT'))
      % msocket用TCP/IP portのdefault値 (DEFAULMSOCKET_PORT)
      value = yoyo_sscanf('DEFAULT_MSOCKET_PORT=%d', str);
      if length(value)
	line_ok = true;
	define.msocket.MSOCKET_PORT = value;
      end
    end	% <-- End of 'DEFAULT_MSOCKET_PORT'
    if strncmp(str, 'DEFAULT_MSOCKET_TIMEOUT',...
	  length('DEFAULT_MSOCKET_TIMEOUT'))
      % timeout時間 (DEFAULT_MSOCKET_TIMEOUT)
      value = yoyo_sscanf('DEFAULT_MSOCKET_TIMEOUT=%f', str);
      if length(value)
	line_ok = true;
	define.msocket.TIMEOUT = value;
      end
    end	% <-- End of 'DEFAULT_MSOCKET_TIMEOUT'
    
    if strncmp(str, 'FONT_NAME', length('FONT_NAME'))
      % フォント名 (FONT_NAME)
      value = yoyo_sscanf('FONT_NAME=%s', str);
      if length(value)
	line_ok = true;
	% アンダースコア('_')をスペース(' ')に置き換える。
	value( findstr(value, '_') ) = ' ';
	define.feedback.FONT_NAME = value;
      end
    end	% <-- End of 'FONT_NAME'
    if strncmp(str, 'FONT_SIZE', length('FONT_SIZE'))
      % フォントサイズ (FONT_SIZE)
      value = yoyo_sscanf('FONT_SIZE=%d', str);
      if length(value)
	line_ok = true;
	define.feedback.FONT_SIZE = value;
      end
    end	% <-- End of 'FONT_SIZE'
    
    if strncmp(str, 'FEEDBACK_BG_COLOR', length('FEEDBACK_BG_COLOR'))
      % 背景色 (FEEDBACK_BG_COLOR)
      value = yoyo_sscanf('FEEDBACK_BG_COLOR=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.BG = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_BG_COLOR'
    if strncmp(str, 'FEEDBACK_TEXT_COLOR', length('FEEDBACK_TEXT_COLOR'))
      % テキストの色 (FEEDBACK_TEXT_COLOR)
      value = yoyo_sscanf('FEEDBACK_TEXT_COLOR=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.TEXT = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_TEXT_COLOR'
    if strncmp(str, 'FEEDBACK_GAZE_COLOR', length('FEEDBACK_GAZE_COLOR'))
      % 注視点の色 (FEEDBACK_GAZE_COLOR)
      value = yoyo_sscanf('FEEDBACK_GAZE_COLOR=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.GAZE = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_GAZE_COLOR'
    if strncmp(str, 'FEEDBACK_SCORE_CIRCLE_COLOR',...
	  length('FEEDBACK_SCORE_CIRCLE_COLOR'))
      % 獲得した得点の円(塗)の色 (標準) (FEEDBACK_SCORE_CIRCLE_COLOR)
      value = yoyo_sscanf('FEEDBACK_SCORE_CIRCLE_COLOR=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.SCORE_CIRCLE = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_SCORE_CIRCLE_COLOR'
    if strncmp(str, 'FEEDBACK_SCORE_CIRCLE_COLOR_PLUS',...
	  length('FEEDBACK_SCORE_CIRCLE_COLOR_PLUS'))
      % 獲得した得点の円(塗)の色 (0点以上) (FEEDBACK_SCORE_CIRCLE_COLOR_PLUS)
      value = yoyo_sscanf('FEEDBACK_SCORE_CIRCLE_COLOR_PLUS=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.SCORE_CIRCLE_PLUS = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_SCORE_CIRCLE_COLOR_PLUS'
    if strncmp(str, 'FEEDBACK_SCORE_CIRCLE_COLOR_MINUS',...
	  length('FEEDBACK_SCORE_CIRCLE_COLOR_MINUS'))
      % 獲得した得点の円(塗)の色 (0点未満) (FEEDBACK_SCORE_CIRCLE_COLOR_MINUS)
      value = yoyo_sscanf('FEEDBACK_SCORE_CIRCLE_COLOR_MINUS=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.SCORE_CIRCLE_MINUS = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_SCORE_CIRCLE_COLOR_MINUS'
    if strncmp(str, 'FEEDBACK_MAX_SCORE_FRAME_COLOR',...
	  length('FEEDBACK_MAX_SCORE_FRAME_COLOR'))
      % 得点の上限の円(枠)の色 (FEEDBACK_MAX_SCORE_FRAME_COLOR)
      value = yoyo_sscanf('FEEDBACK_MAX_SCORE_FRAME_COLOR=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.MAX_SCORE_FRAME = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_MAX_SCORE_FRAME_COLOR'
    if strncmp(str, 'FEEDBACK_HALF_SCORE_FRAME_COLOR',...
	  length('FEEDBACK_HALF_SCORE_FRAME_COLOR'))
      % 得点の上限の50%の円(枠)の色 (FEEDBACK_HALF_SCORE_FRAME_COLOR)
      value = yoyo_sscanf('FEEDBACK_HALF_SCORE_FRAME_COLOR=(%d,%d,%d)', str);
      if length(value)==3
	line_ok = true;
	define.feedback.color.HALF_SCORE_FRAME = reshape(value,1,3);
      end
    end	% <-- End of 'FEEDBACK_HALF_SCORE_FRAME_COLOR'

    if strncmp(str, 'FEEDBACK_CONDITION_COMMENT_OFFSET',...
	  length('FEEDBACK_CONDITION_COMMENT_OFFSET'))
      % 試行条件を告知するコメント文字列の表示位置 (FEEDBACK_COMMENT_OFFSET)
      value = yoyo_sscanf('FEEDBACK_CONDITION_COMMENT_OFFSET=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.condition_comment = reshape(value,1,2);
	define.feedback.offset_mat.condition_comment = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_CONDITION_COMMENT_OFFSET_PSYCHTOOLBOX=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.condition_comment = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_CONDITION_COMMENT_OFFSET_MATLAB=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_mat.condition_comment = reshape(value,1,2);
      end
    end	% <-- End of 'FEEDBACK_COMMENT_OFFSET'
    if strncmp(str, 'FEEDBACK_FINISHED_COMMENT_OFFSET',...
	  length('FEEDBACK_FINISHED_COMMENT_OFFSET'))
      % ブロック終了時のコメント文字列の表示位置
      % (FEEDBACK_FINISHED_COMMENT_OFFSET)
      value = yoyo_sscanf('FEEDBACK_FINISHED_COMMENT_OFFSET=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.finished_comment = reshape(value,1,2);
	define.feedback.offset_mat.finished_comment = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_FINISHED_COMMENT_OFFSET_PSYCHTOOLBOX=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.finished_comment = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_FINISHED_COMMENT_OFFSET_MATLAB=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_mat.finished_comment = reshape(value,1,2);
      end
    end	% <-- End of 'FEEDBACK_FINISHED_COMMENT_OFFSET'
    if strncmp(str, 'FEEDBACK_SCORE_TEXT_OFFSET',...
	  length('FEEDBACK_SCORE_TEXT_OFFSET'))
      % 得点文字列の表示位置 (FEEDBACK_SCORE_TEXT_OFFSET)
      value = yoyo_sscanf('FEEDBACK_SCORE_TEXT_OFFSET=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.score_text = reshape(value,1,2);
	define.feedback.offset_mat.score_text = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_SCORE_TEXT_OFFSET_PSYCHTOOLBOX=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.score_text = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_SCORE_TEXT_OFFSET_MATLAB=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_mat.score_text = reshape(value,1,2);
      end
    end	% <-- End of 'FEEDBACK_SCORE_TEXT_OFFSET'
    if strncmp(str, 'FEEDBACK_GAZE_OFFSET',...
	  length('FEEDBACK_GAZE_OFFSET'))
      % 注視点の表示位置 (FEEDBACK_GAZE_OFFSET)
      value = yoyo_sscanf('FEEDBACK_GAZE_OFFSET=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.gaze = reshape(value,1,2);
	define.feedback.offset_mat.gaze = reshape(value,1,2);
      end
      value = yoyo_sscanf('FEEDBACK_GAZE_OFFSET_PSYCHTOOLBOX=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.gaze = reshape(value,1,2);
      end
      value = yoyo_sscanf('FEEDBACK_GAZE_OFFSET_MATLAB=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_mat.gaze = reshape(value,1,2);
      end
    end	% <-- End of 'FEEDBACK_GAZE_OFFSET'
    if strncmp(str, 'FEEDBACK_SCORE_CORCLE_OFFSET',...
	  length('FEEDBACK_SCORE_CORCLE_OFFSET'))
      % 得点の円の表示位置 (FEEDBACK_SCORE_CORCLE)
      value = yoyo_sscanf('FEEDBACK_SCORE_CORCLE_OFFSET=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.score_corcle = reshape(value,1,2);
	define.feedback.offset_mat.score_corcle = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_SCORE_CORCLE_OFFSET_PSYCHTOOLBOX=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_ptb.score_corcle = reshape(value,1,2);
      end
      value = yoyo_sscanf(...
	  'FEEDBACK_SCORE_CORCLE_OFFSET_MATLAB=(%d,%d)', str);
      if length(value)==2
	line_ok = true;
	define.feedback.offset_mat.score_corcle = reshape(value,1,2);
      end
    end	% <-- End of 'FEEDBACK_SCORE_CORCLE_OFFSET'

    if strncmp(str, 'QUIT_KEY', length('QUIT_KEY'))
      % 実験を途中で中止させるキー文字 (QUIT_KEY)
      value = yoyo_sscanf('QUIT_KEY=%s', str);
      if length(value)
	line_ok = true;
	define.key.QUIT_KEY = value;
      end
    end	% <-- End of 'QUIT_KEY'
    if strncmp(str, 'FMRI_TRIGGER_KEY', length('FMRI_TRIGGER_KEY'))
      % fMRI装置からのScan開始信号のキー文字 (FMRI_TRIGGER_KEY)
      value = yoyo_sscanf('FMRI_TRIGGER_KEY=%s', str);
      if length(value)
	line_ok = true;
	define.key.FMRI_TRIGGER_KEY = value;
      end
    end	% <-- End of 'FMRI_TRIGGER_KEY'
    if strncmp(str, 'SLEEP_CHECK_KEY', length('SLEEP_CHECK_KEY'))
      % 被検者が寝ていないかのチェック用のキー文字 (SLEEP_CHECK_KEY)
      value = yoyo_sscanf('SLEEP_CHECK_KEY=%s', str);
      if length(value)
	line_ok = true;
	define.key.SLEEP_CHECK_KEY = value;
      end
    end	% <-- End of 'SLEEP_CHECK_KEY'
    
    if line_ok == false		% 不正な行を発見した。
      % default設定ファイルに記述不備を発見した場合は、neurofeedback
      % 実験を中止する。(エラーメッセージを出力する。)
      err_msg = sprintf('in ''%s''\nERROR %3d : %s',...
	  defualt_set_fname, line_no, str);
      errordlg(err_msg, 'Error Dialog', 'modal');
      error(err_msg);
    end
  end	% <-- End of 'if str == -1 ... else'
end	% <-- End of 'while(true)'

fclose(fd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_default_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
