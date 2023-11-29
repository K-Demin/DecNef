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


Width = 500;	% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚Ì•?
Height = 650;	% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚Ì?‚‚³

BorderH = 5;	% ‰?•?
BorderV = 10;	% ‰??‚‚³


% Žå—v‚ÈŽÀŒ±ƒpƒ‰ƒ??[ƒ^‚ð•\Ž¦‚·‚élist box‚Ì‘å‚«‚³‚ÆˆÊ’u
MainParaListboxWidth = Width - 2*BorderH;
MainParaListboxHeight = 150;
MainParaListboxLeft = BorderH;
MainParaListboxBottom = Height - (MainParaListboxHeight+BorderV);


% ‘S‚Ä‚ÌŽÀŒ±?ðŒ?‚ð•\Ž¦‚·‚élist box‚Ì‘å‚«‚³‚ÆˆÊ’u
AllParaListboxWidth = MainParaListboxWidth;
AllParaListboxHeight = 430;
AllParaListboxLeft = MainParaListboxLeft;
AllParaListboxBottom =...
    MainParaListboxBottom - (AllParaListboxHeight+BorderV);


% 'Exit' push button‚Ì‘å‚«‚³‚ÆˆÊ’u
ExitWidth = 120;
ExitHeight = 30;
ExitLeft = Width/2 - (ExitWidth+BorderH);
ExitBottom = BorderV;

% 'OK' push button‚Ì‘å‚«‚³‚ÆˆÊ’u
OkWidth = ExitWidth;
OkHeight = ExitHeight;
OkLeft = ExitLeft + ExitWidth + 2*BorderH;
OkBottom = ExitBottom;


% GUI‚Ì?F
window_color = define.gui.window_color;		% window‚Ìcolor
bgcol_listbox = define.gui.bgcol_listbox;	% list box‚Ìbackground
fgcol_listbox = define.gui.fgcol_listbox;	% list box‚Ìforeground
bgcol_push = define.gui.bgcol_push;		% push button‚Ìbackground
fgcol_push = define.gui.fgcol_push;		% push button‚Ìforeground


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚ð?ì?¬‚·‚é?B
fig = figure('Name','Parameters','Tag','Parameters',...
    'MenuBar','none', 'NumberTitle','off', 'HandleVisibility','off',...
    'WindowStyle', 'modal',...
    'Color', window_color, 'Resize','off', 'Visible', 'off',...
    'Units','Pixels','IntegerHandle','off', ...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CloseRequestFcn' ,@doDelete,...
    'Position', [S(3)/2-Width/2 S(4)/2-Height/2 Width Height]);


% Žå—v‚ÈŽÀŒ±?ðŒ?‚ð•\Ž¦‚·‚élist box‚ð?ì?¬‚·‚é?B
main_para_listbox = uicontrol('Parent', fig,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'Position',...
    [MainParaListboxLeft, MainParaListboxBottom,...
      MainParaListboxWidth, MainParaListboxHeight]);


% ‘S‚Ä‚ÌŽÀŒ±?ðŒ?‚ð•\Ž¦‚·‚élist box‚ð?ì?¬‚·‚é?B
all_para_listbox = uicontrol('Parent', fig,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'Position',...
    [AllParaListboxLeft, AllParaListboxBottom,...
      AllParaListboxWidth, AllParaListboxHeight]);


% 'EXIT' push button‚ð?ì?¬‚·‚é?B
exit_push = uicontrol('Parent', fig,...
    'Style', 'push', 'String', 'EXIT',...
    'FontSize', 14, 'FontWeight','bold',...
    'Units', 'pixels',...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'Position', [ExitLeft ExitBottom ExitWidth ExitHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CallBack', @exitCallback);


% 'OK' push button‚ð?ì?¬‚·‚é?B
ok_push = uicontrol('Parent', fig,...
    'Style', 'push', 'String', 'OK',...
    'FontSize', 14, 'FontWeight','bold',...
    'Units', 'pixels',...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'Position', [OkLeft OkBottom OkWidth OkHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CallBack', @okCallback);


% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚ÌGUI‚ðŠÇ—?‚·‚é?\‘¢‘Ì‚ð?ì?¬‚·‚é?B
gui = struct(...
    'para_dialog', fig,...			% dialig window‚Ìhandle
    'main_para_listbox', main_para_listbox,...	% Žå—v?ðŒ?•\Ž¦list box‚Ìhandle
    'all_para_listbox', all_para_listbox,...	% ‘S?ðŒ?•\Ž¦list box‚Ìhandle
    'exit_push', exit_push,...			% 'EXIT' push button‚Ìhandle
    'ok_push', ok_push,...			% 'OK' push button‚Ìhandle
    'exp_start', false...			% 1:OKƒ{ƒ^ƒ“/0:Exitƒ{ƒ^ƒ“
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleate_para_dialog_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = doDelete(varargin)
% function [] = doDelete(varargin)
% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚ÌCloseRequestFcnŠÖ?”
% (Window‚ð•Â‚¶‚é‚Æ‚«‚ÉŽÀ?s‚³‚ê‚é)
% 
% [input argument]
% varargin : –¢Žg—p
global gData
delete(gData.data.para_gui.para_dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function doDelete()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = okCallback(varargin)
% function [] = okCallback(varargin)
% 'OK' push button‚ÌCallBackŠÖ?”
% 
% [input argument]
% varargin : –¢Žg—p
global gData
% ŽÀŒ±ŠJŽnƒtƒ‰ƒO‚Étrue(ŽÀŒ±ŠJŽn)‚ð?Ý’è‚µ?A
% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚ð•Â‚¶‚é?B
gData.data.para_gui.exp_start = true;
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function okCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = exitCallback(varargin)
% function [] = exitCallback(varargin)
% 'EXIT' push button‚ÌCallBackŠÖ?”
% 
% [input argument]
% varargin : –¢Žg—p
global gData
% ŽÀŒ±ŠJŽnƒtƒ‰ƒO‚Éfalse(ŽÀŒ±’†Ž~)‚ð?Ý’è‚µ?A
% ŽÀŒ±?ðŒ?‚ÌŠm”F—pdialig window‚ð•Â‚¶‚é?B
gData.data.para_gui.exp_start = false;
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function exitCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
