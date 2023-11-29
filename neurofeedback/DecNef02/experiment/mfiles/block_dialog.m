function [ret] = block_dialog(participant, day)

global gData

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the gui
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.block_gui = cleate_block_dialog_gui(gData.define);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data store directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data store directory(gData.para.files.save_dir)

formatB = '001_%06d';
format = sprintf('%s_%s%s',gData.para.save_name, formatB, '_Collector.mat');

blocks = zeros(1, 1);

if exist(fullfile(gData.para.files.save_dir, participant, 'DecNef',['Day_',num2str(day)]),'dir')
    FileList = subdir(fullfile(gData.para.files.save_dir, participant, 'DecNef',['Day_',num2str(day)], '*_Collector.mat'));
    if ~isempty(FileList)
        blocks = FileList;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finished Block
% Finished block data file(finished_block_files)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
finished_blocks = length(blocks);
str = cell(length(blocks),1);
finished_block_files = cell(length(blocks),1);
if isstruct(blocks)
    for ii=1:length(blocks)
      pos = findstr(blocks(ii).name,'\');
      currFile = blocks(ii).name(pos(end)+1:end);
      str{ii} = sprintf('Block%2d : %s', ii, currFile);
      finished_block_files{ii} = currFile;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DICOM_FILE_EXTENSION = gData.define.files.DICOM_FILE_EXTENSION;	% DICOM file
templ_image_fname = gData.para.files.templ_image_fname;
templ_image_format = sprintf('%%d_%%d_%%d%s', DICOM_FILE_EXTENSION);
tmp = sscanf(templ_image_fname, templ_image_format);
if length(tmp)==3 && strcmp(sprintf('%03d_%06d_%06d%s', tmp, DICOM_FILE_EXTENSION), templ_image_fname)
  % Template image file
  default_current_block = tmp(2)+1;
else
  % default
  default_current_block = gData.define.default.CURRENT_BLOCK;
end

% Here change the default current block as a function of the number of
% files we find in the participant folder.
if isstruct(blocks)
   % This is to get the block number of the last block.
   % Increment one to define the expected new block.
   pos = findstr(blocks(end).name,'_');
   current_block = str2num(blocks(end).name(pos(end)-2:pos(end)-1))+1;
else
   current_block = default_current_block;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ÌGUI‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% (gData.data.block_gui)‚Ì
% Current Block”Ô?†(current_block)
% Finished Block”Ô?†‚ÌƒŠƒXƒg(finished_blocks)
% Finished block data file–¼‚ÌƒŠƒXƒg(finished_block_files)
% BINARYŒ`Ž®‚Ìƒf?[ƒ^ƒtƒ@ƒCƒ‹–¼?ì?¬—pformat•¶Žš—ñ(format)
% Dicom ƒtƒ@ƒCƒ‹–¼?ì?¬—pformat•¶Žš—ñ(formatB)
% receiver?”(receiver_num)
% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†(port)
% ‚ð?X?V‚·‚é?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.block_gui.current_block = current_block;
gData.data.block_gui.finished_blocks = finished_blocks;
gData.data.block_gui.finished_block_files = finished_block_files;

gData.data.block_gui.format = format;
gData.data.block_gui.formatB = formatB;
gData.data.block_gui.receiver_num = gData.para.receiver_num;
gData.data.block_gui.port = gData.para.msocket.port;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finished Block data‚ð•\Ž¦‚·‚élist box‚É
% Finished block data file–¼‚ÌƒŠƒXƒg‚Æ
% Finished Block”Ô?†‚ÌƒŠƒXƒg“à‚Ì‘I‘ðˆÊ’u‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.finished_block_listbox, 'Value', 1, 'String', str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Block‚ðŽw’è‚·‚éedit text‚ÉCurrent Block”Ô?†‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.current_block_edit, 'String',...
    sprintf('%d', gData.data.block_gui.current_block));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receiverƒvƒ?ƒOƒ‰ƒ€‚Ì?”‚ðŽw’è‚·‚éedit text‚Éreceiver?”‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.receiver_num_edit, 'String',...
    sprintf('%d', gData.data.block_gui.receiver_num));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†‚ðŽw’è‚·‚éedit text‚Éport”Ô?†”Ô?†‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.msocket_port_edit, 'String',...
    sprintf('%d', gData.data.block_gui.port));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ð•\Ž¦?ó‘Ô‚Æ‚µ?A
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ª•Â‚¶‚ç‚ê‚é‚Ü‚Å‘Ò‚Â?B
set(gData.data.block_gui.block_dialog, 'Resize','off', 'Visible', 'on');
uiwait(gData.data.block_gui.block_dialog)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OKƒ{ƒ^ƒ“(true)/Exitƒ{ƒ^ƒ“(false)‚Ì‘I‘ðŒ‹‰Ê‚ð•Ô‚·?B
ret = gData.data.block_gui.exp_start;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function block_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [gui] = cleate_block_dialog_gui(define)
% function [gui] = cleate_block_dialog_gui(define)
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ÌGUI‚ð?ì?¬‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% 
% [output argument]
% gui : ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ÌGUI‚ðŠÇ—?‚·‚é?\‘¢‘Ì

S = get(0,'ScreenSize');


Width = 350;	% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚Ì•?
Height = 330;	% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚Ì?‚‚³

BorderH = 10;	% ‰?•?
BorderV = 10;	% ‰??‚‚³


TmpWidth = Width - (2*BorderH);


%%%%%%%%%%%%%%%%%%%%%
% 'Finished block data' static text label‚Ì‘å‚«‚³‚ÆˆÊ’u
FinishedBlockTextWidth = TmpWidth;
FinishedBlockTextHeight = 25;
FinishedBlockTextLeft = BorderH;
FinishedBlockTextBottom = Height - (FinishedBlockTextHeight+BorderV);

% Finished Block data‚ð•\Ž¦‚·‚élist box‚Ì‘å‚«‚³‚ÆˆÊ’u
FinishedBlockListboxWidth = TmpWidth;
FinishedBlockListboxHeight = 170;
FinishedBlockListboxLeft = BorderH;
FinishedBlockListboxBottom =...
    FinishedBlockTextBottom - FinishedBlockListboxHeight;


%%%%%%%%%%%%%%%%%%%%%
% 'Current block number' static text label‚Ì‘å‚«‚³‚ÆˆÊ’u
CurrentBlockTextWidth = 180;
CurrentBlockTextHeight = 25;
CurrentBlockTextLeft = BorderH;
CurrentBlockTextBottom =...
    FinishedBlockListboxBottom - (CurrentBlockTextHeight+BorderV);

% Current Block”Ô?†‚ðŽw’è‚·‚éedit text‚Ì‘å‚«‚³‚ÆˆÊ’u
CurrentBlockEditWidth = 70;
CurrentBlockEditHeight = CurrentBlockTextHeight;
CurrentBlockEditLeft = CurrentBlockTextLeft + CurrentBlockTextWidth;
CurrentBlockEditBottom = CurrentBlockTextBottom;



%%%%%%%%%%%%%%%%%%%%%
% 'receiver num' static text label‚Ì‘å‚«‚³‚ÆˆÊ’u
ReceiverNumTextWidth = 100;
ReceiverNumTextHeight = 25;
ReceiverNumTextLeft = BorderH;
ReceiverNumTextBottom =...
    CurrentBlockEditBottom - (ReceiverNumTextHeight+BorderV);

% receiverƒvƒ?ƒOƒ‰ƒ€‚Ì?”‚ðŽw’è‚·‚éedit text‚Ì‘å‚«‚³‚ÆˆÊ’u
ReceiverNumEditWidth = (TmpWidth -2*BorderH)/2 - ReceiverNumTextWidth;
ReceiverNumEditHeight = ReceiverNumTextHeight;
ReceiverNumEditLeft = ReceiverNumTextLeft + ReceiverNumTextWidth;
ReceiverNumEditBottom = ReceiverNumTextBottom;


%%%%%%%%%%%%%%%%%%%%%
% 'TCP/IP port' static text label‚Ì‘å‚«‚³‚ÆˆÊ’u
MsocketPortTextWidth = ReceiverNumTextWidth;
MsocketPortTextHeight = ReceiverNumTextHeight;
MsocketPortTextLeft = ReceiverNumEditLeft + (ReceiverNumEditWidth+2*BorderH);
MsocketPortTextBottom = ReceiverNumEditBottom;

% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†‚ðŽw’è‚·‚éedit text‚Ì‘å‚«‚³‚ÆˆÊ’u
MsocketPortEditWidth = ReceiverNumEditWidth;
MsocketPortEditHeight = MsocketPortTextHeight;
MsocketPortEditLeft = MsocketPortTextLeft + MsocketPortTextWidth;
MsocketPortEditBottom = MsocketPortTextBottom;


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
fgcol_text = define.gui.fgcol_text;		% static text‚Ìforeground
bgcol_edit = define.gui.bgcol_edit;		% edit text‚Ìbackground
fgcol_edit = define.gui.fgcol_edit;		% edit text‚Ìforeground
bgcol_listbox = define.gui.bgcol_listbox;	% list box‚Ìbackground
fgcol_listbox = define.gui.fgcol_listbox;	% list box‚Ìforeground
bgcol_push = define.gui.bgcol_push;		% push button‚Ìbackground
fgcol_push = define.gui.fgcol_push;		% push button‚Ìforeground


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ð?ì?¬‚·‚é?B
fig = figure('Name','Block parameters','Tag','Block parameters',...
    'MenuBar','none', 'NumberTitle','off', 'HandleVisibility','off',...
    'WindowStyle', 'modal',...
    'Color', window_color, 'Resize','off', 'Visible', 'off',...
    'Units','Pixels','IntegerHandle','off', ...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CloseRequestFcn' ,@doDelete,...
    'Position', [S(3)/2-Width/2 S(4)/2-Height/2 Width Height]);


%%%%%%%%%%%%%%%%%%%%%
% 'Finished block data' static text label‚ð?ì?¬‚·‚é?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', '<< Finished block data >>',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Center', 'FontSize', 12,...
    'Position',...
    [FinishedBlockTextLeft, FinishedBlockTextBottom,...
      FinishedBlockTextWidth, FinishedBlockTextHeight]);
			  
% Finished Block data‚ð•\Ž¦‚·‚élist box‚ð?ì?¬‚·‚é?B
finished_block_listbox = uicontrol('Parent', fig,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'Position',...
    [FinishedBlockListboxLeft, FinishedBlockListboxBottom,...
      FinishedBlockListboxWidth, FinishedBlockListboxHeight]);


%%%%%%%%%%%%%%%%%%%%%
% 'Current block number' static text label‚ð?ì?¬‚·‚é?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'Current block number',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left', 'FontSize', 12,...
    'Position',...
    [CurrentBlockTextLeft, CurrentBlockTextBottom,...
      CurrentBlockTextWidth, CurrentBlockTextHeight]);
			  
% Current Block”Ô?†‚ðŽw’è‚·‚éedit text‚ð?ì?¬‚·‚é?B
current_block_edit = uicontrol('Parent', fig,  'Style', 'edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',10,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'Position',...
    [CurrentBlockEditLeft, CurrentBlockEditBottom,...
      CurrentBlockEditWidth, CurrentBlockEditHeight],...
    'CallBack', @current_blockCallback);


%%%%%%%%%%%%%%%%%%%%%
% 'receiver num' static text label‚ð?ì?¬‚·‚é?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'receiver num',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'left', 'FontSize', 12,...
    'Position',...
    [ReceiverNumTextLeft, ReceiverNumTextBottom,...
      ReceiverNumTextWidth, ReceiverNumTextHeight]);
			  
% receiverƒvƒ?ƒOƒ‰ƒ€‚Ì?”‚ðŽw’è‚·‚éedit text‚ð?ì?¬‚·‚é?B
receiver_num_edit = uicontrol('Parent', fig,  'Style', 'edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',10,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'Position',...
    [ReceiverNumEditLeft, ReceiverNumEditBottom,...
      ReceiverNumEditWidth, ReceiverNumEditHeight],...
    'CallBack', @receiver_numCallback);


%%%%%%%%%%%%%%%%%%%%%
% 'TCP/IP port' static text label‚ð?ì?¬‚·‚é?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'TCP/IP port',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'left', 'FontSize', 12,...
    'Position',...
    [MsocketPortTextLeft, MsocketPortTextBottom,...
      MsocketPortTextWidth, MsocketPortTextHeight]);
			  
% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†‚ðŽw’è‚·‚éedit text‚ð?ì?¬‚·‚é?B
msocket_port_edit = uicontrol('Parent', fig,  'Style', 'edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',10,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'Position',...
    [MsocketPortEditLeft, MsocketPortEditBottom,...
      MsocketPortEditWidth, MsocketPortEditHeight],...
    'CallBack', @msocket_portCallback);


%%%%%%%%%%%%%%%%%%%%%
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


% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ÌGUI‚ðŠÇ—?‚·‚é?\‘¢‘Ì‚ð?ì?¬‚·‚é?B
gui = struct(...
    'block_dialog', fig,...			% Dialig window‚Ìhandle
    'finished_block_listbox', finished_block_listbox,...
    'current_block_edit', current_block_edit,...
    'receiver_num_edit', receiver_num_edit,...
    'msocket_port_edit', msocket_port_edit,...
    'exit_push', exit_push,...			% 'EXIT' push button‚Ìhandle
    'ok_push', ok_push,...			% 'OK' push button‚Ìhandle
    'finished_blocks', [],...			% Finished block?î•ñ
    'finished_block_files', [],...		% Finished block file?î•ñ
    'current_block', 0,...			% Current Block”Ô?†
    'format', '',...				% Data file–¼?ì?¬—pformat•¶Žš—ñ
    'formatB', '',...				% Dicom file?ì?¬—pformat•¶Žš—ñ
    'receiver_num', 0,...			% receiver?”
    'port', 0,...				% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†
    'exp_start', false...			% true:OK/false:EXIT
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleate_block_dialog_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = doDelete(varargin)
% function [] = doDelete(varargin)
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ÌCloseRequestFcnŠÖ?”
% (Window‚ð•Â‚¶‚é‚Æ‚«‚ÉŽÀ?s‚³‚ê‚é)
% 
% [input argument]
% varargin : –¢Žg—p
global gData
delete(gData.data.block_gui.block_dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function doDelete()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = current_blockCallback(varargin)
% function [] = current_blockCallback(varargin)
% Current Block‚ðŽw’è‚·‚éedit text‚ÌCallBackŠÖ?”
% 
% [input argument]
% varargin : –¢Žg—p
global gData
val = str2double( get(gData.data.block_gui.current_block_edit, 'String') );
if ~isnan(val)
  if val > 0	% ?³‚Ì?”’l‚ð“ü—Í‚µ‚½?B
    % Current Block”Ô?†‚ð?X?V‚·‚é?B
    gData.data.block_gui.current_block = val;
  end
end
% Current Block‚ðŽw’è‚·‚éedit text‚ÉCurrent Block”Ô?†‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.current_block_edit, 'String',...
    sprintf('%d', gData.data.block_gui.current_block));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function current_blockCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = receiver_numCallback(varargin)
% function [] = receiver_numCallback(varargin)
% receiverƒvƒ?ƒOƒ‰ƒ€‚Ì?”‚ðŽw’è‚·‚éedit text‚ÌCallBackŠÖ?”
% 
% [input argument]
% varargin : –¢Žg—p
global gData
val = str2double( get(gData.data.block_gui.receiver_num_edit, 'String') );
if ~isnan(val)
  if val > 0	% ?³‚Ì?”’l‚ð“ü—Í‚µ‚½?B
    % receiver?”‚ð?X?V‚·‚é?B
    gData.data.block_gui.receiver_num = val;
  end
end
% receiverƒvƒ?ƒOƒ‰ƒ€‚Ì?”‚ðŽw’è‚·‚éedit text‚Éreceiver?”‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.receiver_num_edit, 'String',...
    sprintf('%d', gData.data.block_gui.receiver_num));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function receiver_numCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = msocket_portCallback(varargin)
% function [] = msocket_portCallback(varargin)
% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†‚ðŽw’è‚·‚éedit text‚ÌCallBackŠÖ?”
% 
% [input argument]
% varargin : –¢Žg—p
global gData
val = str2double( get(gData.data.block_gui.msocket_port_edit, 'String') );
if ~isnan(val)
  if val > 0	% ?³‚Ì?”’l‚ð“ü—Í‚µ‚½?B
    % port”Ô?†‚ð?X?V‚·‚é?B
    gData.data.block_gui.port = val;
  end
end
% ’Ê?MŒo˜H(msocket)‚Ìport”Ô?†‚ðŽw’è‚·‚éedit text‚Éport”Ô?†‚ð?Ý’è‚·‚é?B
set(gData.data.block_gui.msocket_port_edit, 'String',...
    sprintf('%d', gData.data.block_gui.port));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function msocket_portCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = okCallback(varargin)
% function [] = okCallback(varargin)
% 'OK' push button‚ÌCallBackŠÖ?”
% 
% [input argument]
% varargin : –¢Žg—p
global gData
% ŽÀŒ±ŠJŽnƒtƒ‰ƒO‚Étrue‚ð?Ý’è‚µ?A
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ð•Â‚¶‚é?B
gData.data.block_gui.exp_start = true;
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
% ŽÀŒ±ŠJŽnƒtƒ‰ƒO‚Éfalse‚ð?Ý’è‚µ?A
% ŽÀŒ±Block”Ô?†‘I‘ð—pdialig window‚ð•Â‚¶‚é?B
gData.data.block_gui.exp_start = false;
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function exitCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
