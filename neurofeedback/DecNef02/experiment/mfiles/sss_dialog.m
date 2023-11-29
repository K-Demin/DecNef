function [sss_level, sss_comment] = sss_dialog()
% Stanford sleepiness scale(Stanford眠気尺度)
% の質問用のdialig windowを提示し、眠気尺度レベル
% を選択する。

global gData


% Stanford眠気尺度の質問時に被検者に提示する画像を表示する。
if isempty(gData.para.sss.sss_image_fname)
  % 質問画像file名を指定していないので、質問画像を提示しない。
  % (create_global.mのcreate_para()内のsss構造体のコメント参照)
  image_window_id = [];
else
  image_window_id = create_sss_image_window();
end

% Stanford眠気尺度の質問用のdialig windowのGUIを作成する。
gData.data.sss_gui = cleate_sss_dialog_gui(gData.define, image_window_id);

% Stanford眠気尺度の質問用のdialig windowを表示状態とし、
% dialig windowが閉じられるまで待つ。
set(gData.data.sss_gui.para_dialog, 'Resize','off', 'Visible', 'on');
uiwait(gData.data.sss_gui.para_dialog)

% Stanford眠気尺度Level と コメント文字列 を獲得する。
sss_level = gData.data.sss_gui.sss_level;
sss_comment = gData.data.sss_gui.sss_comment;

fprintf('\n');
fprintf('sss_level = %d\n', sss_level);
fprintf('sss_comment : %s\n', sss_comment);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function sss_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [window_id] = create_sss_image_window()
% function [window_id] = create_sss_image_window()
% Figure windowを開き、Stanford眠気尺度の質問時に
% 被検者に提示する画像を表示する。
% 
% [output argument]
% window_id : 画像を提示するFigure windowのhandle

global gData


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford眠気尺度の質問時に被検者に提示する
% 画像データを読み込む。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sss_image_fname = fullfile(...
    gData.para.files.para_dir,...
    gData.para.sss.sss_image_dir,...
    gData.para.sss.sss_image_fname);
try
  sss_image = imread(sss_image_fname);
catch
  % 画像データの読み込みに失敗したので画像は提示しない。
  fprintf('\n');
  fprintf('ERROR : Can''t open file ''%s'' for reading.\n', sss_image_fname);
  fprintf('ERROR : para_file_dir   = ''%s''\n', gData.para.files.para_dir);
  fprintf('ERROR : sss_image_dir   = ''%s''\n', gData.para.sss.sss_image_dir);
  fprintf('ERROR : sss_image_fname = ''%s''\n',gData.para.sss.sss_image_fname);
  window_id = [];
  return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford眠気尺度の質問時に被検者に提示する画像
% 提示用のFigure windowを生成する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows環境で実行されている場合、画像提示用の
  % Figure windowは、フルスクリーンモードで表示する。
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
  window_id = figure('menubar','non','NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'Position', pos);
  if 0	% maximize()関数でFigure windowをフルスクリーンモードに切り替える。
    maximize(window_id);
  else	% 'Position' propertyにフルスクリーンサイズを設定する。
    set(window_id, 'Position', [left, bottom, width, height]);
  end
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows以外のOSで実行されている場合、画像提示用の
  % Figure windowは、スクリーンの中央付近に固定サイズ
  % (1280x1024)で表示する。
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  S = get(0,'ScreenSize');
  width = 1280;
  height= 1024;
  window_id = figure('NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'Position',[S(3)/2-width/2, S(4)/2-height/2, width, height]);
end	% <-- End of 'if ispc ... else'


% (非表示状態の)Axesオブジェクトを作成する。
[h, w, x] = size(sss_image);
set(gca,...
    'DataAspectRatio', [1,1,1], 'DrawMode', 'fast',...
    'FontUnits', 'pixels', 'FontWeight', 'normal',...
    'Units', 'normalized',...
    'OuterPosition', [0,0,1,1], 'Position',[0,0,1,1],...
    'XLim', [0,w], 'YLim', [0,h], 'Visible', 'off');

% Figure windowに、Stanford眠気尺度の質問時に被検者に
% 見せる画像を提示する。
image(sss_image);
set(gca, 'XTick', [], 'YTick', []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'create_sss_image_window()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [gui] = cleate_sss_dialog_gui(define, image_fig)
% function [] = cleate_sss_dialog_gui(define, image_fig)
% Stanford眠気尺度の質問用のdialig windowのGUIを作成する。
% 
% [input argument]
% image_fig : 画像を提示するFigure windowのhandle
% define    : define変数を管理する構造体
% 
% [output argument]
% gui : Stanford眠気尺度の質問用のdialig windowのGUIを管理する構造体


S = get(0,'ScreenSize');


Width = 320;	% dialig windowの幅
Height = 170;	% dialig windowの高さ

BorderH = 10;	% 縁幅
BorderV = 10;	% 縁高さ


% 'Stanford sleepiness scale Level' static text labelの大きさと位置
LevelTextWidth = 240;
LevelTextHeight = 25;
LevelTextLeft = BorderH;
LevelTextBottom = Height - (LevelTextHeight+BorderV);

% Stanford眠気尺度Levelを選択するpop-up menuの大きさと位置
LevelPopupWidth = Width - 2*BorderH - LevelTextWidth;
LevelPopupHeight = LevelTextHeight;
LevelPopupLeft = LevelTextLeft + LevelTextWidth;
LevelPopupBottom = LevelTextBottom;


% 'Comment' static text labelの大きさと位置
CommentTextWidth = 100;
CommentTextHeight = 25;
CommentTextLeft = BorderH;
CommentTextBottom = LevelPopupBottom - (CommentTextHeight+BorderV);

% コメントを入力するedit textの大きさと位置
CommentEditWidth = Width - 2*BorderH;
CommentEditHeight = 30;
CommentEditLeft = BorderH;
CommentEditBottom = CommentTextBottom - CommentEditHeight;


% 'OK' push buttonの大きさと位置
OkWidth = 200;
OkHeight = 30;
OkLeft = (Width - OkWidth)/2;
OkBottom = BorderV;


% GUIの色
window_color = define.gui.window_color;		% windowのcolor
fgcol_text = define.gui.fgcol_text;		% static textのforeground
bgcol_popup = define.gui.bgcol_popup;		% pop-up menuのbackground
fgcol_popup = define.gui.fgcol_popup;		% pop-up menuのforeground
bgcol_edit = define.gui.bgcol_edit;		% edit textのbackground
fgcol_edit = define.gui.fgcol_edit;		% edit textのforeground
bgcol_push = define.gui.bgcol_push;		% push buttonのbackground
fgcol_push = define.gui.fgcol_push;		% push buttonのforeground


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialig windowを作成する。
fig = figure('Name','Stanford sleepiness scale','Tag','Parameters',...
    'MenuBar','none', 'NumberTitle','off', 'HandleVisibility','off',...
    'WindowStyle', 'modal',...
    'Color', window_color, 'Resize','off', 'Visible', 'off',...
    'Units','Pixels','IntegerHandle','off', ...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CloseRequestFcn' ,@doDelete,...
    'Position', [S(3)/2-Width/2 S(4)/2-Height/2 Width Height]);


%%%%%%%%%%%%%%%%%%%%%
% 'Stanford sleepiness scale Level' static text labelを作成する。
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'Stanford sleepiness scale Level',...
    'FontSize', 12, 'FontWeight','normal',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left',...
    'Position',...
    [LevelTextLeft, LevelTextBottom, LevelTextWidth, LevelTextHeight]);

% Stanford眠気尺度Levelを選択するpop-up menuを作成する。
str = sprintf('%d|', [1:define.default.SSS_MAX_LEVEL]);
str = sprintf('%s ----', str);
level_popup = uicontrol('Parent', fig, 'Style', 'popup',...
    'FontSize', 9, 'String', str,...
    'Value', define.default.SSS_MAX_LEVEL+1, 'Units', 'pixels',...
    'BackgroundColor', bgcol_popup, 'ForegroundColor', fgcol_popup,...
    'Position',...
    [LevelPopupLeft, LevelPopupBottom, LevelPopupWidth, LevelPopupHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off');


%%%%%%%%%%%%%%%%%%%%%
% 'Comment' static text labelを作成する。
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'Comment', 'FontSize', 12, 'FontWeight','normal',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left',...
    'Position',...
    [CommentTextLeft, CommentTextBottom, CommentTextWidth, CommentTextHeight]);

% コメントを入力するedit textを作成する。
comment_edit = uicontrol('Parent', fig, 'Style','edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',9,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'HorizontalAlignment', 'Left',...
    'Position',...
    [CommentEditLeft CommentEditBottom CommentEditWidth CommentEditHeight]);


% 'OK' push buttonを作成する。
ok_push = uicontrol('Parent', fig,...
    'Style', 'push', 'String', 'OK',...
    'FontSize', 14, 'FontWeight','bold',...
    'Units', 'pixels',...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'Position', [OkLeft OkBottom OkWidth OkHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CallBack', @okCallback);


% Stanford眠気尺度の質問用のdialig windowのGUIを管理する構造体を作成する。
gui = struct(...
    'image_fig', image_fig,...		% 画像を提示するFigure windowのhandle
    'para_dialog', fig,...		% SSS質問用のdialig windowのhandle
    'level_popup', level_popup,...	% SSS Level選択するpop-up menuのhandle
    'comment_edit', comment_edit,...	% コメントを入力するedit textのhandle
    'ok_push', ok_push,...		% 'OK' push buttonのhandle
    'sss_level', NaN,...		% Stanford眠気尺度Level
    'sss_comment', ''...		% Stanford眠気尺度コメント文字列
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleate_sss_dialog_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = doDelete(varargin)
% function [] = doDelete(varargin)
% Stanford眠気尺度の質問用のdialig windowのCloseRequestFcn関数
% (Windowを閉じるときに実行される)
% 
% [input argument]
% varargin : 未使用
global gData
delete(gData.data.sss_gui.para_dialog);
if ~isempty(gData.data.sss_gui.image_fig)
  % 画像を提示するFigure windowを閉じる。
  close(gData.data.sss_gui.image_fig)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function doDelete()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = okCallback(varargin)
% function [] = okCallback(varargin)
% 'OK' push buttonのCallBack関数
% 
% [input argument]
% varargin : 未使用
global gData
% Stanford眠気尺度Level と コメント文字列 を獲得し、
% Stanford眠気尺度の質問用のdialig windowを閉じる。
sss_level = get(gData.data.sss_gui.level_popup, 'value');
if sss_level <= gData.define.default.SSS_MAX_LEVEL
  gData.data.sss_gui.sss_level = sss_level;
else
  gData.data.sss_gui.sss_level = NaN;	% Stanford眠気尺度Levelが未選択状態
end
gData.data.sss_gui.sss_comment =...
    get(gData.data.sss_gui.comment_edit, 'String');
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function okCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
