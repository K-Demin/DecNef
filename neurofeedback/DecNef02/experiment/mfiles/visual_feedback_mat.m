function [] = visual_feedback_mat(status)
% function [] = visual_feedback_mat(status)
% MATLABによるVisual feedback処理を行なう。
% statusの設定値に従いVisual feedback処理を実行する。
% 
% [input argument]
% status : Visual feedback処理条件

global gData

% 一旦、Visual feedbackの提示用のFigure Windowの
% 全てのオブジェクトを非表示化する。
if gData.data.feedback.window_id >= 0
  figure(gData.data.feedback.window_id);
  set(gData.data.feedback.gaze_frame, 'Visible', 'off');
  set(gData.data.feedback.gaze_fill, 'Visible', 'off');
  set(gData.data.feedback.sleep_fill, 'Visible', 'off');
  set(gData.data.feedback.max_score, 'Visible', 'off');
  set(gData.data.feedback.half_score, 'Visible', 'off');
  set(gData.data.feedback.score, 'Visible', 'off');
  set(gData.data.feedback.comment_text, 'Visible', 'off');
  set(gData.data.feedback.finished_comment_text, 'Visible', 'off');
  set(gData.data.feedback.score_text, 'Visible', 'off');
end

switch status
  case gData.define.feedback.INITIALIZE		% 初期化処理
    init_feedback();
  case gData.define.feedback.GAZE		% 注視点の描画処理
    gaze_feedback();
  case gData.define.feedback.PREP_REST1		% 前処理用のREST条件 その1
    prep_rest1_feedback();
  case gData.define.feedback.PREP_REST2		% 前処理用のREST条件 その2
    prep_rest2_feedback();
  case gData.define.feedback.REST		% REST条件
    rest_feedback();
  case gData.define.feedback.TEST		% TEST条件
    test_feedback();
  case gData.define.feedback.PREP_SCORE		% 得点提示までの条件
    prep_score_feedback();
  case gData.define.feedback.SCORE		% 得点提示
    score_feedback();
  case gData.define.feedback.NG_SCORE		% 得点の計算処理不可時の提示
    ng_score_feedback();
  case gData.define.feedback.SLEEP_CHECK	% 寝ていないかチェック条件
    sleep_check_feedback();
  case gData.define.feedback.FINISHED_BLOCK	% ブロック終了条件(平均点提示)
    finished_block_feedback();
  case gData.define.feedback.FINISH		% 終了処理
    finish_feedback();
  otherwise,
end	% <-- End of 'switch status'

% Visual feedbackの提示用のFigure Windowの描画を更新する。
drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function visual_feedback_mat()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = init_feedback()
% function [] = init_feedback()
% Visual feedbackの初期化処理

global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visual feedbackの提示用のFigure windowを生成する。
% (Figure windowのRendererプロパティをOpenGLに設定する)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows環境で実行されている場合、Visual feedback
  % 提示用のFigure windowは、フルスクリーンモードで
  % 表示する。
  % (視覚提示するscreen内にFigure windowを開いた後、
  %  フルスクリーンモードに切り替える。)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  MonitorPositions = get(0,'MonitorPositions');
  screen = gData.para.feedback.screen;  % 視覚提示するscreen番号
  width = MonitorPositions(screen,3) - MonitorPositions(screen,1) + 1;
  height = MonitorPositions(screen,4) - MonitorPositions(screen,2) + 1;
  bottom = MonitorPositions(1,4) - MonitorPositions(screen,4);
  left = MonitorPositions(screen,3) - width;
  
  pos = [left+50, bottom+50, 10, 10];
  gData.data.feedback.window_id =...
      figure('menubar','non','NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'WindowStyle', 'modal',...
      'Position', pos, 'Color', define.color.BG/255);
  if 0
    % maximize()関数でFigure windowをフルスクリーンモードに切り替える。
    maximize(gData.data.feedback.window_id);
  else
    % 'Position' propertyにフルスクリーンサイズを設定する。
    fprintf('set figure position(L:%d,B:%d,W:%d,H:%d)\n',...
	left, bottom, width, height);
    set(gData.data.feedback.window_id,...
	'Position', [left, bottom, width, height]);
  end
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows以外のOSで実行されている場合、Visual feedback
  % 提示用のFigure windowは、スクリーンの中央付近に
  % 固定サイズ(1280x1024)で表示する。
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  S = get(0,'ScreenSize');
  width = 1280;
  height= 1024;
  gData.data.feedback.window_id =...
      figure('NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'WindowStyle', 'modal',...
      'Position',[S(3)/2-width/2, S(4)/2-height/2, width, height],...
      'Color', define.color.BG/255);
end	% <-- End of 'if ispc ... else'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Figure windowにフォーカスがある状態での
% キーを押した時に呼び出されるコールバック関数 と
% キーを離した時に呼び出されるコールバック関数 と
% Figure window上のマウスのポインター(透明) を
% 設定する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
UserData = struct('key', '');
try
  set(gData.data.feedback.window_id, 'UserData', UserData,...
      'KeyPressFcn', @keypressfcn,...
      'WindowKeyPressFcn', @keypressfcn,...
      'KeyReleaseFcn', @keyreleasefcn,...
      'WindowKeyReleaseFcn', @keyreleasefcn,...
      'Pointer','custom','PointerShapeCData', nan(16,16) );
catch
  % 古いバージョンのMATLABでは、 'WindowKeyPressFcn' propertyと
  % 'WindowKeyReleaseFcn' propertyがサポートされていない。
  set(gData.data.feedback.window_id, 'UserData', UserData,...
      'KeyPressFcn', @keypressfcn, 'KeyReleaseFcn', @keyreleasefcn,...
      'Pointer','custom','PointerShapeCData', nan(16,16) );
end

if 0
  % ここでdrawnowをcallしないと、 この後の行で行なう
  % set関数で取得する 'Position' propertyの値が不正な
  % 場合がある。 (Windowの大きさが反映されていない)
  drawnow;	% おまじない...
  
  % Visual feedback Windowの大きさを獲得する。
  pos = get(gData.data.feedback.window_id, 'Position');
  gData.data.feedback.window_width = pos(3);
  gData.data.feedback.window_height= pos(4);
else
  gData.data.feedback.window_width = width;
  gData.data.feedback.window_height= height;
end

% (非表示状態の)Axesオブジェクトを作成する。
ax = axes('position',[0,0,1,1], 'Visible','off');
set(ax,...
    'DataAspectRatio', [1,1,1], 'DrawMode', 'fast',...
    'FontSize', define.FONT_SIZE,...
    'FontUnits', 'pixels', 'FontWeight', 'normal',...
    'Units', 'normalized',...
    'OuterPosition', [0,0,1,1], 'Position',[0,0,1,1],...
    'XLim', [0,gData.data.feedback.window_width],...
    'YLim', [0,gData.data.feedback.window_height],...
    'Visible', 'off');
try	% フォント名を指定する。
  set(gca, 'FontName', define.FONT_NAME);
end


% 視覚feedbackを提示用のWindowの中点の座標を設定する。
gData.data.feedback.window_center_x =...
    round(gData.data.feedback.window_width/2);
gData.data.feedback.window_center_y =...
    round(gData.data.feedback.window_height/2);


% コメント文字列のアンダースコア('_')をスペース(' ')に
% 置き換えた文字列を作成し、この文字列を改行文字列('\n')
% で分割したcell文字列を設定する。
% (create_global.m内のcreate_para()とcreate_data()の
%  コメント参照)
gData.data.feedback.prep_rest1_comment =...
    comment_string(gData.para.feedback.prep_rest1_comment);
gData.data.feedback.prep_rest2_comment =...
    comment_string(gData.para.feedback.prep_rest2_comment);
gData.data.feedback.rest_comment =...
    comment_string(gData.para.feedback.rest_comment);
gData.data.feedback.test_comment =...
    comment_string(gData.para.feedback.test_comment);
gData.data.feedback.prep_score_comment =...
    comment_string(gData.para.feedback.prep_score_comment);
gData.data.feedback.score_comment =...
    comment_string(gData.para.feedback.score_comment);
gData.data.feedback.ng_score_comment =...
    comment_string(gData.para.feedback.ng_score_comment);
gData.data.feedback.finished_block_comment =...
    comment_string(gData.para.feedback.finished_block_comment);


tmp = [0:0.1:2*pi]';

% 注視点(円弧 枠)のpatchオブジェクトを作成する。
% ( 注視点(円弧 枠)のZ座標は0.0を設定する )
R = gData.para.feedback.gaze_frame_r;
x = gData.data.feedback.window_center_x + R*cos(tmp)...
    + define.offset_mat.gaze(X_AXIS);
y = gData.data.feedback.window_center_y + R*sin(tmp)...
    + define.offset_mat.gaze(Y_AXIS);
z = zeros( size(tmp) );
color = define.color.GAZE/255;
bg_color = define.color.BG/255;
gData.data.feedback.gaze_frame =...
    patch(x, y, z, bg_color, 'Visible', 'off',...
    'EdgeColor', color, 'FaceAlpha', 0.0);

% 注視点(円弧 塗)のpatchオブジェクトを作成する。
% (注視点のZ座標は0.01を設定する)
R = gData.para.feedback.gaze_fill_r;
x = gData.data.feedback.window_center_x + R*cos(tmp)...
    + define.offset_mat.gaze(X_AXIS);
y = gData.data.feedback.window_center_y + R*sin(tmp)...
    + define.offset_mat.gaze(Y_AXIS);
z = 0.01*ones( size(tmp) );
color = define.color.GAZE/255;
gData.data.feedback.gaze_fill =...
    patch(x, y, z, color, 'Visible', 'off',...
    'EdgeColor', color, 'FaceAlpha', 1.0);

% 注視点の矩形(寝ていないかチェック用)のpatchオブジェクトを作成する。
% (注視点のZ座標は0.02を設定する)
R = gData.para.feedback.sleep_fill_r;
p = [...
      gData.data.feedback.window_center_x+R,...
      gData.data.feedback.window_center_y+R, 0.02;...
      gData.data.feedback.window_center_x+R,...
      gData.data.feedback.window_center_y-R, 0.02;...
      gData.data.feedback.window_center_x-R,...
      gData.data.feedback.window_center_y-R, 0.02;...
      gData.data.feedback.window_center_x-R,...
      gData.data.feedback.window_center_y+R, 0.02; ];
color = define.color.GAZE/255;
gData.data.feedback.sleep_fill = patch(...
    p(:,1)+ define.offset_mat.gaze(X_AXIS),...
    p(:,2)+ define.offset_mat.gaze(Y_AXIS),...
    p(:,3), color, 'Visible', 'off',...
    'EdgeColor', color, 'FaceAlpha', 1.0);

% 得点の上限値を取得時の円(枠)のpatchオブジェクトを作成する。
% (注視点のZ座標(0.0から0.02)より後ろに設定する。)
R = gData.para.feedback.max_score_r;
x = gData.data.feedback.window_center_x + R*cos(tmp)...
    + define.offset_mat.score_corcle(X_AXIS);
y = gData.data.feedback.window_center_y + R*sin(tmp)...
    + define.offset_mat.score_corcle(Y_AXIS);
z = -1.00*ones( size(tmp) );
color = define.color.MAX_SCORE_FRAME/255;
bg_color = define.color.BG/255;
gData.data.feedback.max_score =...
    patch(x, y, z, bg_color, 'Visible', 'off',...
    'EdgeColor', color, 'FaceAlpha', 0.0, 'LineWidth', 2.0);

% 得点の上限値の50%を取得時の円(枠)のpatchオブジェクトを作成する。
% (注視点のZ座標(0.0から0.02)より後ろに設定する。)
R = gData.para.feedback.max_score_r/2.0;
x = gData.data.feedback.window_center_x + R*cos(tmp)...
    + define.offset_mat.score_corcle(X_AXIS);
y = gData.data.feedback.window_center_y + R*sin(tmp)...
    + define.offset_mat.score_corcle(Y_AXIS);
z = -1.00*ones( size(tmp) );
color = define.color.HALF_SCORE_FRAME/255;
bg_color = define.color.BG/255;
gData.data.feedback.half_score =...
    patch(x, y, z, bg_color, 'Visible', 'off',...
    'EdgeColor', color, 'FaceAlpha', 0.0, 'LineWidth', 2.0);

% 得点の円(塗)のpatchオブジェクトを作成する。
% (注視点のZ座標(0.0から0.02)より後ろに設定する。)
R = gData.para.feedback.max_score_r;
x = gData.data.feedback.window_center_x + R*cos(tmp)...
    + define.offset_mat.score_corcle(X_AXIS);
y = gData.data.feedback.window_center_y + R*sin(tmp)...
    + define.offset_mat.score_corcle(Y_AXIS);
z = -1.01*ones( size(tmp) );
color = define.color.SCORE_CIRCLE/255;
gData.data.feedback.score =...
    patch(x, y, z, color, 'Visible', 'off',...
    'EdgeColor', color, 'FaceAlpha', 1.0);

% コメント文字列を作成する。
% (注視点のZ座標(0.0から0.02)より手前に設定する。)
color = define.color.TEXT/255;
gData.data.feedback.comment_text = text(...
    gData.data.feedback.window_center_x+...
    + define.offset_mat.condition_comment(X_AXIS),...
    gData.data.feedback.window_center_y+...
    + define.offset_mat.condition_comment(Y_AXIS),...
    1.00,...
    '', 'Color', color, 'Visible', 'off',...
    'FontSize', define.FONT_SIZE,...
    'HorizontalAlignment', 'center');
try	% フォント名を指定する。
  set(gData.data.feedback.comment_text, 'FontName', define.FONT_NAME);
end

% ブロック終了時のコメント文字列を作成する。
% (注視点のZ座標(0.0から0.02)より手前に設定する。)
color = define.color.TEXT/255;
gData.data.feedback.finished_comment_text = text(...
    gData.data.feedback.window_center_x...
    + define.offset_mat.finished_comment(X_AXIS),...
    gData.data.feedback.window_center_y...
    + define.offset_mat.finished_comment(Y_AXIS),...
    1.01,...
    '', 'Color', color, 'Visible', 'off',...
    'FontSize', define.FONT_SIZE,...
    'HorizontalAlignment', 'center');
try	% フォント名を指定する。
  set(gData.data.feedback.finished_comment_text, 'FontName', define.FONT_NAME);
end

% 得点文字列を作成する。
% (注視点のZ座標(0.0から0.2)より手前に設定する。)
color = define.color.TEXT/255;
gData.data.feedback.score_text = text(...
    gData.data.feedback.window_center_x...
    + define.offset_mat.score_text(X_AXIS),...
    gData.data.feedback.window_center_y...
    + define.offset_mat.score_text(Y_AXIS),...
    1.02,...
    '', 'Color', color, 'Visible', 'off',...
    'FontSize', define.FONT_SIZE,...
    'HorizontalAlignment', 'center');
try	% フォント名を指定する。
  set(gData.data.feedback.score_text, 'FontName', define.FONT_NAME);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dst] = comment_string(src)
% function [dst] = comment_string(src)
% コメント文字列のアンダースコア('_')をスペース(' ')
% に置き換えた文字列を作成し、この文字列を改行文字列
% ('\n')で分割したcell文字列を作成する。
% (create_global.m内のcreate_para()とcreate_data()の
% コメント参照)
% 
% [input argument]
% src : 変換前のコメント文字列
% 
% [input argument]
% dst : 変換後のコメント文字列(cell文字列)

% アンダースコア('_')をスペース(' ')に置き換える。
str = src;
str( findstr(str, '_') ) = ' ';

% 改行文字列('\n')で分割したcell文字列を作成する。
p = findstr(str, '\n');
p(end+1) = length(str)+1;
dst = cell(length(p),1);
s = 1;
for ii=1:length(p)
  dst{ii} = str(s:p(ii)-1);
  s = p(ii)+2;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function comment_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = gaze_feedback()
% function [] = gaze_feedback()
% 注視点の描画処理
global gData
% 注視点(円弧の中に塗った円)を表示状態にする。
set(gData.data.feedback.gaze_frame, 'Visible', 'on');
set(gData.data.feedback.gaze_fill, 'Visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function gaze_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = prep_rest1_feedback()
% function [] = prep_rest1_feedback()
% 1試行目の前処理用のREST条件その1の描画処理
global gData
% 1試行目の前処理用のREST条件その1のコメント文字列を表示する。
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.prep_rest1_comment, 'Visible', 'on');

gaze_feedback();	% 注視点を描画する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function prep_rest1_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = prep_rest2_feedback()
% function [] = prep_rest2_feedback()
% 1試行目の前処理用のREST条件その2の描画処理
global gData
% 1試行目の前処理用のREST条件その2のコメント文字列を表示する。
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.prep_rest2_comment, 'Visible', 'on');

gaze_feedback();	% 注視点を描画する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function prep_rest2_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = rest_feedback()
% function [] = rest_feedback()
% REST条件の描画処理
global gData
% REST条件のコメント文字列を表示する。
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.rest_comment, 'Visible', 'on');

gaze_feedback();	% 注視点を描画する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function rest_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = test_feedback()
% function [] = test_feedback()
% TEST条件の描画処理
global gData
% TEST条件のコメント文字列を表示する。
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.test_comment, 'Visible', 'on');

gaze_feedback();	% 注視点を描画する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function test_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = prep_score_feedback()
% function [] = prep_score_feedback()
% TEST条件が終了した後、得点提示までの条件の描画処理
global gData
% 得点提示までの条件のコメント文字列を表示する。
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.prep_score_comment, 'Visible', 'on');

sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &...
      gData.data.sleep_check(sleep_check_count) == false
  % '被検者が寝ていないかのチェック条件の試行' で
  % 'チェック用のキー文字が未入力状態'
  % -> 被検者が寝ていないかチェック用の描画処理
  sleep_check_feedback();
else
  % 注視点の描画処理
  gaze_feedback();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function prep_score_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = score_feedback()
% function [] = score_feedback()
% 得点を提示する。
global gData
switch gData.para.feedback.feedback_type
  case gData.define.feedback.feedback_type.TEXT_MODE
    % 視覚feedbackの提示タイプ が テキスト方式 の場合
    score_text_mode();
  case gData.define.feedback.feedback_type.CIRCLE_MODE
    % 視覚feedbackの提示タイプ が 円弧方式 の場合
    score_circle_mode();
  otherwise
end

sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &...
      gData.data.sleep_check(sleep_check_count) == false
  % '被検者が寝ていないかのチェック条件の試行' で
  % 'チェック用のキー文字が未入力状態'
  % -> 被検者が寝ていないかチェック用の描画処理
  sleep_check_feedback();
else
  % 注視点の描画処理
  gaze_feedback();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function score_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = score_text_mode()
% function [] = score_text_mode()
% 得点をテキストで表示する
global gData

score = gData.data.score(gData.data.current_trial);
if ~isnan(score)
  % 得点(score)がNaNの場合、得点が未計算のため表示しない。
    
  % 得点提示条件のコメント文字列を表示する。
  set(gData.data.feedback.comment_text,...
      'String', gData.data.feedback.score_comment, 'Visible', 'on');
	        
  % 現在の試行の得点を表示する。
  set(gData.data.feedback.score_text,...
      'String', sprintf('%d', score), 'Visible', 'on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function score_text_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = score_circle_mode()
% function [] = score_circle_mode()
% 得点を円の大きさで表示する
global gData

score = gData.data.score(gData.data.current_trial);
if ~isnan(score)
  % 得点(score)がNaNの場合、得点が未計算のため表示しない。

  X_AXIS = 1;
  Y_AXIS = 2;
  define = gData.define.feedback;
    
  % 得点の上限値を取得時の円(枠)を表示状態にする。
  set(gData.data.feedback.max_score, 'Visible', 'on');
  % 得点の上限値の50%を取得時の円(枠)を表示状態にする。
  set(gData.data.feedback.half_score, 'Visible', 'on');
  
  % 得点の円(塗)を描画する。
  if sum( isnan(gData.para.score.score_limit) )
    % score_limitにNaNを含む(下限と上限の閾値は無効値)
    % ・ 得点が0点以上なら
    %     -> 円弧の色 : SCORE_CIRCLE_PLUS
    %     -> 最小円弧 : +0点
    %     -> 最大円弧 : +100点
    %  ・ 得点が0点未満なら
    %     -> 円弧の色 : SCORE_CIRCLE_MINUS
    %     -> 最小円弧 : -0点
    %     -> 最大円弧 : -100点
    tmp = abs(score)/100.0;
    R = round( tmp * gData.para.feedback.max_score_r );
    if score >= 0,	color = define.color.SCORE_CIRCLE_PLUS/255;
    else		color = define.color.SCORE_CIRCLE_MINUS/255;
    end
  else
    % score_limitにNaNは含まない
    %     -> 円弧の色 : SCORE_CIRCLE
    %     -> 最小円弧 : 下限の閾値の得点
    %     -> 最大円弧 : 上限の閾値の得点
    score_limit = gData.para.score.score_limit;
    tmp = (score - score_limit(gData.define.MIN))/diff(score_limit);
    R = round( tmp * gData.para.feedback.max_score_r );
    color = define.color.SCORE_CIRCLE/255;
  end
  tmp = [0:0.1:2*pi]';
  x = gData.data.feedback.window_center_x + R*cos(tmp)...
      + define.offset_mat.score_corcle(X_AXIS);
  y = gData.data.feedback.window_center_y + R*sin(tmp)...
      + define.offset_mat.score_corcle(Y_AXIS);
  set(gData.data.feedback.score,...
      'XData', x, 'YData', y, 'FaceColor', color,...
      'EdgeColor', color, 'Visible', 'on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function score_circle_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = ng_score_feedback()
% function [] = ng_score_feedback()
% 得点の計算処理不可時の提示
global gData
% 得点の計算処理不可時のコメント文字列を表示する。
set(gData.data.feedback.score_text,...
    'String', gData.data.feedback.ng_score_comment, 'Visible', 'on');

sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &...
      gData.data.sleep_check(sleep_check_count) == false
  % '被検者が寝ていないかのチェック条件の試行' で
  % 'チェック用のキー文字が未入力状態'
  % -> 被検者が寝ていないかチェック用の描画処理
  sleep_check_feedback();
else
  % 注視点の描画処理
  gaze_feedback();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function ng_score_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = sleep_check_feedback()
% function [] = sleep_check_feedback()
% 被検者が寝ていないかのチェック条件の描画処理
global gData
% 注視点の矩形(寝ていないかチェック用)を表示状態にする。
set(gData.data.feedback.sleep_fill, 'Visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function sleep_check_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = finished_block_feedback()
% function [] = finished_block_feedback()
% ブロック終了条件(ブロックの平均得点提示)の描画処理
global gData
% ブロックの平均得点を表示する。
switch gData.para.feedback.feedback_type
  case gData.define.feedback.feedback_type.TEXT_MODE
    % 視覚feedbackの提示タイプ が テキスト方式 の場合
    ave_score_text_mode();
  case gData.define.feedback.feedback_type.CIRCLE_MODE
    % 視覚feedbackの提示タイプ が 円弧方式 の場合
    ave_score_circle_mode();
  otherwise
end

% ブロック終了のコメント文字列を表示する。
set(gData.data.feedback.finished_comment_text,...
    'String', gData.data.feedback.finished_block_comment, 'Visible', 'on');

gaze_feedback();	% 注視点を描画する。  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function finished_block_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = ave_score_text_mode()
% function [] = ave_score_text_mode()
% ブロックの平均得点をテキストで表示する。
global gData

% ブロックの平均得点を表示する。
tmp = 1:gData.para.scans.trial_num;
tmp( isnan(gData.data.score) ) = [];
Score = round( mean( gData.data.score(tmp) ) );
set(gData.data.feedback.score_text,...
    'String',  sprintf('%d', Score), 'Visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function ave_score_text_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = ave_score_circle_mode()
% function [] = ave_score_circle_mode()
% ブロックの平均得点を円の大きさで表示する
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;
    
% 得点の上限値を取得時の円(枠)を表示状態にする。
set(gData.data.feedback.max_score, 'Visible', 'on');
% 得点の上限値の50%を取得時の円(枠)を表示状態にする。
set(gData.data.feedback.half_score, 'Visible', 'on');

tmp = 1:gData.para.scans.trial_num;
tmp( isnan(gData.data.score) ) = [];
score = round( mean( gData.data.score(tmp) ) );
% ブロックの平均得点の円(塗)を描画する。
score_limit = gData.para.score.score_limit;
tmp = (score - score_limit(gData.define.MIN))/diff(score_limit);
R = round( tmp * gData.para.feedback.max_score_r );
tmp = [0:0.1:2*pi]';
x = gData.data.feedback.window_center_x + R*cos(tmp)...
    + define.offset_mat.score_corcle(X_AXIS);
y = gData.data.feedback.window_center_y + R*sin(tmp)...
    + define.offset_mat.score_corcle(Y_AXIS);
set(gData.data.feedback.score,...
    'XData', x, 'YData', y, 'Visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function ave_score_circle_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = finish_feedback()
% function [] = finish_feedback()
% Visual feedbackの終了処理
global gData
% Visual feedbackの提示用のFigure windowを閉じる。
close(gData.data.feedback.window_id);
% Visual feedbackの提示用のWindow IDを初期値(無効値)に戻す。
gData.data.feedback.window_id = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function finish_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = keypressfcn(src,event)
% function [] = keypressfcn(src,event)
% Visual feedback提示用のFigure windowの
% キーを押した時に呼び出されるコールバック関数
% (入力文字を保持する。)
UserData = get(src, 'UserData');
UserData.key = event.Key;
set(src, 'UserData', UserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function keypressfcn()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = keyreleasefcn(src,event)
% function [] = keypressfcn(src,event)
% Visual feedback提示用のFigure windowの
% キーを離した時に呼び出されるコールバック関数
% (入力文字を初期化する。)
UserData = get(src, 'UserData');
UserData.key = '';
set(src, 'UserData', UserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function keyreleasefcn()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
