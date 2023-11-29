function [ret] = para_dialog()

global gData


gData.data.para_gui = cleate_para_dialog_gui(gData.define);


[str1, str2] = make_parameter_string(gData.define, gData.para, gData.data);

set(gData.data.para_gui.main_para_listbox, 'String', str1);
set(gData.data.para_gui.all_para_listbox, 'String', str2);
    

set(gData.data.para_gui.para_dialog, 'Resize','off', 'Visible', 'on');
uiwait(gData.data.para_gui.para_dialog)

ret = gData.data.para_gui.exp_start;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function para_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [gui] = cleate_para_dialog_gui(define)

S = get(0,'ScreenSize');


Width = 500;	% ����?��?�̊m�F�pdialig window�̕?
Height = 650;	% ����?��?�̊m�F�pdialig window��?���

BorderH = 5;	% �?�?
BorderV = 10;	% �??���


% ��v�Ȏ����p���??[�^��\������list box�̑傫���ƈʒu
MainParaListboxWidth = Width - 2*BorderH;
MainParaListboxHeight = 150;
MainParaListboxLeft = BorderH;
MainParaListboxBottom = Height - (MainParaListboxHeight+BorderV);


% �S�Ă̎���?��?��\������list box�̑傫���ƈʒu
AllParaListboxWidth = MainParaListboxWidth;
AllParaListboxHeight = 430;
AllParaListboxLeft = MainParaListboxLeft;
AllParaListboxBottom =...
    MainParaListboxBottom - (AllParaListboxHeight+BorderV);


% 'Exit' push button�̑傫���ƈʒu
ExitWidth = 120;
ExitHeight = 30;
ExitLeft = Width/2 - (ExitWidth+BorderH);
ExitBottom = BorderV;

% 'OK' push button�̑傫���ƈʒu
OkWidth = ExitWidth;
OkHeight = ExitHeight;
OkLeft = ExitLeft + ExitWidth + 2*BorderH;
OkBottom = ExitBottom;


% GUI��?F
window_color = define.gui.window_color;		% window��color
bgcol_listbox = define.gui.bgcol_listbox;	% list box��background
fgcol_listbox = define.gui.fgcol_listbox;	% list box��foreground
bgcol_push = define.gui.bgcol_push;		% push button��background
fgcol_push = define.gui.fgcol_push;		% push button��foreground


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����?��?�̊m�F�pdialig window��?�?�����?B
fig = figure('Name','Parameters','Tag','Parameters',...
    'MenuBar','none', 'NumberTitle','off', 'HandleVisibility','off',...
    'WindowStyle', 'modal',...
    'Color', window_color, 'Resize','off', 'Visible', 'off',...
    'Units','Pixels','IntegerHandle','off', ...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CloseRequestFcn' ,@doDelete,...
    'Position', [S(3)/2-Width/2 S(4)/2-Height/2 Width Height]);


% ��v�Ȏ���?��?��\������list box��?�?�����?B
main_para_listbox = uicontrol('Parent', fig,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'Position',...
    [MainParaListboxLeft, MainParaListboxBottom,...
      MainParaListboxWidth, MainParaListboxHeight]);


% �S�Ă̎���?��?��\������list box��?�?�����?B
all_para_listbox = uicontrol('Parent', fig,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'Position',...
    [AllParaListboxLeft, AllParaListboxBottom,...
      AllParaListboxWidth, AllParaListboxHeight]);


% 'EXIT' push button��?�?�����?B
exit_push = uicontrol('Parent', fig,...
    'Style', 'push', 'String', 'EXIT',...
    'FontSize', 14, 'FontWeight','bold',...
    'Units', 'pixels',...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'Position', [ExitLeft ExitBottom ExitWidth ExitHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CallBack', @exitCallback);


% 'OK' push button��?�?�����?B
ok_push = uicontrol('Parent', fig,...
    'Style', 'push', 'String', 'OK',...
    'FontSize', 14, 'FontWeight','bold',...
    'Units', 'pixels',...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'Position', [OkLeft OkBottom OkWidth OkHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CallBack', @okCallback);


% ����?��?�̊m�F�pdialig window��GUI���Ǘ?����?\���̂�?�?�����?B
gui = struct(...
    'para_dialog', fig,...			% dialig window��handle
    'main_para_listbox', main_para_listbox,...	% ��v?��?�\��list box��handle
    'all_para_listbox', all_para_listbox,...	% �S?��?�\��list box��handle
    'exit_push', exit_push,...			% 'EXIT' push button��handle
    'ok_push', ok_push,...			% 'OK' push button��handle
    'exp_start', false...			% 1:OK�{�^��/0:Exit�{�^��
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleate_para_dialog_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = doDelete(varargin)
% function [] = doDelete(varargin)
% ����?��?�̊m�F�pdialig window��CloseRequestFcn��?�
% (Window�����Ƃ��Ɏ�?s�����)
% 
% [input argument]
% varargin : ���g�p
global gData
delete(gData.data.para_gui.para_dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function doDelete()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = okCallback(varargin)
% function [] = okCallback(varargin)
% 'OK' push button��CallBack��?�
% 
% [input argument]
% varargin : ���g�p
global gData
% �����J�n�t���O��true(�����J�n)��?ݒ肵?A
% ����?��?�̊m�F�pdialig window�����?B
gData.data.para_gui.exp_start = true;
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function okCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = exitCallback(varargin)
% function [] = exitCallback(varargin)
% 'EXIT' push button��CallBack��?�
% 
% [input argument]
% varargin : ���g�p
global gData
% �����J�n�t���O��false(�������~)��?ݒ肵?A
% ����?��?�̊m�F�pdialig window�����?B
gData.data.para_gui.exp_start = false;
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function exitCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
