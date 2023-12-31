function [gui_handles] = create_gui(this)
% dialog windowを作成する。

S = get(0,'ScreenSize');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dialog windowの大きさ
Width = 380;
Height = 400;


BorderH = 10;
BorderV = 5;


% 'Current directory' static text labelの大きさと位置
CurrentDirTextWidth = Width - 2*BorderH;
CurrentDirTextHeight = 20;
CurrentDirTextLeft = BorderH;
CurrentDirTextBottom = Height - CurrentDirTextHeight;

% current directoryを選択するpop-up menuの大きさと位置
CurrentDirPopupWidth = Width - 2*BorderH;
CurrentDirPopupHeight = 20;
CurrentDirPopupLeft = BorderH;
CurrentDirPopupBottom = CurrentDirTextBottom - CurrentDirPopupHeight;


% 'Extension' static text labelの大きさと位置
ExtensionTextWidth = 0.6*(CurrentDirPopupWidth/2);
ExtensionTextHeight = 20;
ExtensionTextLeft = BorderH;
ExtensionTextBottom = CurrentDirPopupBottom - (ExtensionTextHeight+BorderV);

% 拡張子を選択するpop-up menuの大きさと位置
ExtensionPopupWidth = CurrentDirPopupWidth/2 - ExtensionTextWidth;
ExtensionPopupHeight = ExtensionTextHeight;
ExtensionPopupLeft = ExtensionTextLeft + ExtensionTextWidth;
ExtensionPopupBottom = ExtensionTextBottom;


% 'Drive' static text labelの大きさと位置
DriveTextWidth = ExtensionTextWidth;
DriveTextHeight = ExtensionPopupHeight;
DriveTextLeft = ExtensionPopupLeft + ExtensionPopupWidth;
DriveTextBottom = ExtensionPopupBottom;

% Driveを選択するpop-up menuの大きさと位置
DrivePopupWidth = ExtensionPopupWidth;
DrivePopupHeight = DriveTextHeight;
DrivePopupLeft = DriveTextLeft + DriveTextWidth;
DrivePopupBottom = DriveTextBottom;


% panelの大きさと位置
PanelWidth = CurrentDirPopupWidth;
PanelHeighth = 270;
PanelLeft = BorderH;
PanelBottom = ExtensionTextBottom - (PanelHeighth+BorderV);


% MATLAB R14 SP2以降ならpanelを作成し、各GUIはpanelを親として作成する。
% panelを親として作成したcontrolの表示位置は、親panelの相対位置で指定する。
% また、親panelの'visible'を'off'にすると、子GUIも非表示化される。
% MATLAB R14より前のバージョンでは、panelがサポートされていない。
% またMATLABR14 SP1ではpanelの動作が不安定なので、frameを作成し各control
% はdialogを親として作成する。
% この場合、GUIが重なり合う領域は、後から作成したGUIが優先して表示される。
matlab_version = str2double( version('-release') );
description = version('-description');
if ~isempty(description)
  sp = sscanf(description, 'Service Pack %d');
  matlab_version = matlab_version + 0.1*sp;
end
if matlab_version < 14.2
  TmpLeft = PanelLeft;	TmpBottom = PanelBottom;
else
  TmpLeft = 0;	TmpBottom = 0;
end


% 'Directories' static text labelの大きさと位置
DirTextWidth = PanelWidth/2 - BorderH;
DirTextHeight = 20;
DirTextLeft = TmpLeft + BorderH;
DirTextBottom = TmpBottom + PanelHeighth - (DirTextHeight+BorderV);

% ディレクトリ一覧を表示するlist boxの大きさと位置
DirListWidth = DirTextWidth;
DirListHeight = 180;
DirListLeft = DirTextLeft;
DirListBottom = DirTextBottom - DirListHeight;


% 'Files' static text labelの大きさと位置
FnameTextWidth = DirTextWidth;
FnameTextHeight = DirTextHeight;
FnameTextLeft = DirTextLeft + DirTextWidth;
FnameTextBottom = DirTextBottom;

% ファイル名一覧を表示するlist boxの大きさと位置
FnameListWidth = DirListWidth;
FnameListHeight = DirListHeight;
FnameListLeft = FnameTextLeft;
FnameListBottom = DirListBottom;


% 'Select file' static text labelの大きさと位置
SelFnameTextWidth = PanelWidth - 2*BorderH;
SelFnameTextHeight = 20;
SelFnameTextLeft = TmpLeft + BorderH;
SelFnameTextBottom = DirListBottom - (SelFnameTextHeight+BorderV);

% 選択ファイル名を表示するedit textの大きさと位置
SelFnameEditWidth = SelFnameTextWidth;
SelFnameEditHeight = 20;
SelFnameEditLeft = SelFnameTextLeft;
SelFnameEditBottom = SelFnameTextBottom - SelFnameEditHeight;


% 'Cancel' push buttonの大きさと位置
CancelWidth = CurrentDirPopupWidth/2;
CancelHeight = 35;
CancelLeft = BorderH;
CancelBottom = PanelBottom - (CancelHeight+BorderV);

% 'Done' push buttonの大きさと位置
DoneWidth = CancelWidth;
DoneHeight = CancelHeight;
DoneLeft = CancelLeft + CancelWidth;
DoneBottom = CancelBottom;


% GUIの色を求める。
dialog_color   = this.public.dialog_color;	% dialogのcolor
bgcol_panel = this.public.bgcol_panel;	% panelのbackground color
fgcol_panel = this.public.fgcol_panel;	% panelのforeground color
fgcol_text  = this.public.fgcol_text;	% static text labelのforeground color
bgcol_popup = this.public.bgcol_popup;	% pop-up menuのbackground color
fgcol_popup = this.public.fgcol_popup;	% pop-up menuのforeground color
bgcol_listbox = this.public.bgcol_listbox;	% list boxのbackground color
fgcol_listbox = this.public.fgcol_listbox;	% list boxのforeground color
bgcol_edit  = this.public.bgcol_edit;	% edit textのbackground color
fgcol_edit  = this.public.fgcol_edit;	% edit textのforeground color
bgcol_push  = this.public.bgcol_push;	% push buttonのbackground color
fgcol_push  = this.public.fgcol_push;	% push buttonのforeground color


% Save/Load file選択用Dialog windowを作成する。
if length(this.public.title)
  window_title_str = this.public.title;
else
  if this.public.save_mode,	window_title_str = 'select SAVE file';
  else				window_title_str = 'select LOAD file';
  end
end
dialog_handle = figure('Name', window_title_str, 'Tag', 'SelFileWin',...
    'MenuBar', 'none',...
    'NumberTitle', 'off',...
    'Color', dialog_color,...
    'Resize', 'off',...
    'Visible', 'off',...
    'IntegerHandle', 'off',...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'Units', 'Pixels',...
    'Position',...
    [S(3)/2-Width/2, S(4)/2-Height/2, Width, Height]);

% 'Current directory' static text labelを作成する。
uicontrol('Parent', dialog_handle, 'Style', 'text',...
    'String', 'Current directory',...
    'BackgroundColor', dialog_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left', 'FontSize', 12,...
    'Position',...
    [CurrentDirTextLeft, CurrentDirTextBottom,...
      CurrentDirTextWidth, CurrentDirTextHeight]);

% current directoryを選択するpop-up menuを作成する。
current_dir_popup_handle = uicontrol('Parent',dialog_handle,...
    'Style', 'popup', 'String', ' ', 'Value', 1,...
    'BackgroundColor', bgcol_popup, 'ForegroundColor', fgcol_popup,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@current_dir_popup, dialog_handle},...
    'Position',...
    [CurrentDirPopupLeft, CurrentDirPopupBottom,...
      CurrentDirPopupWidth, CurrentDirPopupHeight]);


% 'Extension' static text labelを作成する。
uicontrol('Parent', dialog_handle, 'Style', 'text',...
    'String', 'Extension',...
    'BackgroundColor', dialog_color, 'ForegroundColor', fgcol_text,...
    'FontSize', 12,...
    'Position',...
    [ExtensionTextLeft, ExtensionTextBottom,...
      ExtensionTextWidth, ExtensionTextHeight]);

% ファイルの拡張子を選択するpop-up menuを作成する。
% [注意]
% this.public.file_extensions{}が ''(NULL文字列)
% の場合、ディレクトリを検索対象とする。
% (init_public.mのコメントを参照)
file_extensions = this.public.file_extensions;
tmp = find( strcmpi(file_extensions, '') );
if ~isempty(tmp)
  file_extensions{ tmp } = 'DIR';	% ディレクトリを検索対象とする。
end
str = sprintf('|%s', file_extensions{:});	str(1) = [];
extension_popup_handle = uicontrol('Parent', dialog_handle,...
    'Style', 'popup', 'String', str, 'Value', this.public.default_extension,...
    'BackgroundColor', bgcol_popup, 'ForegroundColor', fgcol_popup,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@extension_popup, dialog_handle},...
    'Position',...
    [ExtensionPopupLeft, ExtensionPopupBottom,...
      ExtensionPopupWidth, ExtensionPopupHeight]);


% 'Drive' static text labelを作成する。
drive_text = uicontrol('Parent', dialog_handle, 'Style', 'text',...
    'String', 'Drive',...
    'BackgroundColor', dialog_color, 'ForegroundColor', fgcol_text,...
    'FontSize', 12,...
    'Position',...
    [DriveTextLeft, DriveTextBottom, DriveTextWidth, DriveTextHeight]);

% Driveを選択するpop-up menuを作成する。
drive_popup_handle = uicontrol('Parent',dialog_handle, 'Style', 'popup',...
    'String', ' ',...
    'BackgroundColor', bgcol_popup, 'ForegroundColor', fgcol_popup,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@drive_popup, dialog_handle},...
    'Position',...
    [DrivePopupLeft DrivePopupBottom DrivePopupWidth DrivePopupHeight]);



% panelを作成する。
if matlab_version < 14.2	% MATLAB R14 SP2以前のバージョン
  uicontrol('Parent', dialog_handle, 'Style', 'Frame',...
      'Position', [PanelLeft PanelBottom PanelWidth PanelHeighth],...
      'BackgroundColor', bgcol_panel, 'ForegroundColor', fgcol_panel);
  panel = [];
  parent = dialog_handle;
else	% MATLAB R14以降のバージョン
  panel = uipanel('Parent', dialog_handle, 'Title', '', 'FontSize', 12,...
      'Units', 'pixels',...
      'Position', [PanelLeft PanelBottom PanelWidth PanelHeighth],...
      'BackgroundColor', bgcol_panel, 'ForegroundColor', fgcol_panel);
  parent = panel;
end


% 'Directories' static text labelを作成する。
uicontrol('Parent', parent, 'Style', 'Text', 'String', 'Directories',...
    'BackgroundColor', bgcol_panel, 'ForegroundColor', fgcol_panel,...
    'HorizontalAlignment', 'Center', 'FontSize', 12,...
    'Position',[DirTextLeft DirTextBottom DirTextWidth DirTextHeight]);

% ディレクトリ一覧を表示するlist boxを作成する。
dir_listbox_handle = uicontrol('Parent', parent,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@dir_listbox, dialog_handle},...
    'Position', [DirListLeft DirListBottom DirListWidth DirListHeight]);


% 'Files' static text labelを作成する。
uicontrol('Parent', parent, 'Style', 'Text', 'String', 'Files',...
    'BackgroundColor', bgcol_panel, 'ForegroundColor', fgcol_panel,...
    'HorizontalAlignment', 'Center', 'FontSize', 12,...
    'Position',...
    [FnameTextLeft FnameTextBottom FnameTextWidth FnameTextHeight]);

% ファイル名一覧を表示するlist boxを作成する。
fname_listbox_handle = uicontrol('Parent', parent,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@fname_listbox, dialog_handle},...
    'Position',...
    [FnameListLeft FnameListBottom FnameListWidth FnameListHeight]);


% 'Select file' static text labelを作成する。
uicontrol('Parent', parent, 'Style', 'text', 'String', window_title_str,...
    'BackgroundColor', bgcol_panel, 'ForegroundColor', fgcol_panel,...
    'HorizontalAlignment', 'Left', 'FontSize', 12,...
    'Position',...
    [SelFnameTextLeft, SelFnameTextBottom,...
      SelFnameTextWidth, SelFnameTextHeight]);

% 選択ファイル名を表示するedit textを作成する。
sel_fname_edit = uicontrol('Parent', parent, 'Style', 'edit', 'String', '',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@fname_edit, dialog_handle},...
    'Position',...
    [SelFnameEditLeft,SelFnameEditBottom,...
      SelFnameEditWidth, SelFnameEditHeight]);


% 'Cancel' push buttonを作成する。
uicontrol('Parent', dialog_handle, 'Style', 'push', 'String', 'Cancel',...
    'FontWeight','bold', 'FontSize', 14, ...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@close_gui, dialog_handle, 'cancel'},...
    'Position', [CancelLeft CancelBottom CancelWidth CancelHeight]);


% 'Done' push buttonを作成する。
done_push = uicontrol('Parent', dialog_handle, 'Style', 'push',...
    'String', 'Done', 'FontSize', 14,...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'BusyAction', 'cancel',...
    'Interruptible', 'off',...
    'CallBack', {@close_gui, dialog_handle, 'done'},...
    'Position', [DoneLeft DoneBottom DoneWidth DoneHeight]);


% Save/Load file選択用Dialog windowを管理する構造体を設定する。
gui_handles = struct(...
    'dialog', dialog_handle,...
    'current_dir_popup', current_dir_popup_handle,...
    'panel', panel,...
    'extension_popup', extension_popup_handle,...
    'drive_text', drive_text,...
    'drive_popup', drive_popup_handle,...
    'dir_listbox', dir_listbox_handle,...
    'fname_listbox', fname_listbox_handle,...
    'sel_fname_edit', sel_fname_edit,...
    'done_push', done_push);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function create_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
