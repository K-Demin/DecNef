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
% ����Block��?��I��pdialig window��GUI���Ǘ?����?\����
% (gData.data.block_gui)��
% Current Block��?�(current_block)
% Finished Block��?��̃��X�g(finished_blocks)
% Finished block data file���̃��X�g(finished_block_files)
% BINARY�`���̃f?[�^�t�@�C����?�?��pformat������(format)
% Dicom �t�@�C����?�?��pformat������(formatB)
% receiver?�(receiver_num)
% ��?M�o�H(msocket)��port��?�(port)
% ��?X?V����?B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.block_gui.current_block = current_block;
gData.data.block_gui.finished_blocks = finished_blocks;
gData.data.block_gui.finished_block_files = finished_block_files;

gData.data.block_gui.format = format;
gData.data.block_gui.formatB = formatB;
gData.data.block_gui.receiver_num = gData.para.receiver_num;
gData.data.block_gui.port = gData.para.msocket.port;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finished Block data��\������list box��
% Finished block data file���̃��X�g��
% Finished Block��?��̃��X�g���̑I���ʒu��?ݒ肷��?B
set(gData.data.block_gui.finished_block_listbox, 'Value', 1, 'String', str);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Block���w�肷��edit text��Current Block��?���?ݒ肷��?B
set(gData.data.block_gui.current_block_edit, 'String',...
    sprintf('%d', gData.data.block_gui.current_block));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% receiver�v�?�O������?����w�肷��edit text��receiver?���?ݒ肷��?B
set(gData.data.block_gui.receiver_num_edit, 'String',...
    sprintf('%d', gData.data.block_gui.receiver_num));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��?M�o�H(msocket)��port��?����w�肷��edit text��port��?���?���?ݒ肷��?B
set(gData.data.block_gui.msocket_port_edit, 'String',...
    sprintf('%d', gData.data.block_gui.port));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����Block��?��I��pdialig window��\��?�ԂƂ�?A
% ����Block��?��I��pdialig window��������܂ő҂�?B
set(gData.data.block_gui.block_dialog, 'Resize','off', 'Visible', 'on');
uiwait(gData.data.block_gui.block_dialog)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OK�{�^��(true)/Exit�{�^��(false)�̑I�����ʂ�Ԃ�?B
ret = gData.data.block_gui.exp_start;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function block_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [gui] = cleate_block_dialog_gui(define)
% function [gui] = cleate_block_dialog_gui(define)
% ����Block��?��I��pdialig window��GUI��?�?�����?B
% 
% [input argument]
% define : define��?����Ǘ?����?\����
% 
% [output argument]
% gui : ����Block��?��I��pdialig window��GUI���Ǘ?����?\����

S = get(0,'ScreenSize');


Width = 350;	% ����Block��?��I��pdialig window�̕?
Height = 330;	% ����Block��?��I��pdialig window��?���

BorderH = 10;	% �?�?
BorderV = 10;	% �??���


TmpWidth = Width - (2*BorderH);


%%%%%%%%%%%%%%%%%%%%%
% 'Finished block data' static text label�̑傫���ƈʒu
FinishedBlockTextWidth = TmpWidth;
FinishedBlockTextHeight = 25;
FinishedBlockTextLeft = BorderH;
FinishedBlockTextBottom = Height - (FinishedBlockTextHeight+BorderV);

% Finished Block data��\������list box�̑傫���ƈʒu
FinishedBlockListboxWidth = TmpWidth;
FinishedBlockListboxHeight = 170;
FinishedBlockListboxLeft = BorderH;
FinishedBlockListboxBottom =...
    FinishedBlockTextBottom - FinishedBlockListboxHeight;


%%%%%%%%%%%%%%%%%%%%%
% 'Current block number' static text label�̑傫���ƈʒu
CurrentBlockTextWidth = 180;
CurrentBlockTextHeight = 25;
CurrentBlockTextLeft = BorderH;
CurrentBlockTextBottom =...
    FinishedBlockListboxBottom - (CurrentBlockTextHeight+BorderV);

% Current Block��?����w�肷��edit text�̑傫���ƈʒu
CurrentBlockEditWidth = 70;
CurrentBlockEditHeight = CurrentBlockTextHeight;
CurrentBlockEditLeft = CurrentBlockTextLeft + CurrentBlockTextWidth;
CurrentBlockEditBottom = CurrentBlockTextBottom;



%%%%%%%%%%%%%%%%%%%%%
% 'receiver num' static text label�̑傫���ƈʒu
ReceiverNumTextWidth = 100;
ReceiverNumTextHeight = 25;
ReceiverNumTextLeft = BorderH;
ReceiverNumTextBottom =...
    CurrentBlockEditBottom - (ReceiverNumTextHeight+BorderV);

% receiver�v�?�O������?����w�肷��edit text�̑傫���ƈʒu
ReceiverNumEditWidth = (TmpWidth -2*BorderH)/2 - ReceiverNumTextWidth;
ReceiverNumEditHeight = ReceiverNumTextHeight;
ReceiverNumEditLeft = ReceiverNumTextLeft + ReceiverNumTextWidth;
ReceiverNumEditBottom = ReceiverNumTextBottom;


%%%%%%%%%%%%%%%%%%%%%
% 'TCP/IP port' static text label�̑傫���ƈʒu
MsocketPortTextWidth = ReceiverNumTextWidth;
MsocketPortTextHeight = ReceiverNumTextHeight;
MsocketPortTextLeft = ReceiverNumEditLeft + (ReceiverNumEditWidth+2*BorderH);
MsocketPortTextBottom = ReceiverNumEditBottom;

% ��?M�o�H(msocket)��port��?����w�肷��edit text�̑傫���ƈʒu
MsocketPortEditWidth = ReceiverNumEditWidth;
MsocketPortEditHeight = MsocketPortTextHeight;
MsocketPortEditLeft = MsocketPortTextLeft + MsocketPortTextWidth;
MsocketPortEditBottom = MsocketPortTextBottom;


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
fgcol_text = define.gui.fgcol_text;		% static text��foreground
bgcol_edit = define.gui.bgcol_edit;		% edit text��background
fgcol_edit = define.gui.fgcol_edit;		% edit text��foreground
bgcol_listbox = define.gui.bgcol_listbox;	% list box��background
fgcol_listbox = define.gui.fgcol_listbox;	% list box��foreground
bgcol_push = define.gui.bgcol_push;		% push button��background
fgcol_push = define.gui.fgcol_push;		% push button��foreground


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ����Block��?��I��pdialig window��?�?�����?B
fig = figure('Name','Block parameters','Tag','Block parameters',...
    'MenuBar','none', 'NumberTitle','off', 'HandleVisibility','off',...
    'WindowStyle', 'modal',...
    'Color', window_color, 'Resize','off', 'Visible', 'off',...
    'Units','Pixels','IntegerHandle','off', ...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CloseRequestFcn' ,@doDelete,...
    'Position', [S(3)/2-Width/2 S(4)/2-Height/2 Width Height]);


%%%%%%%%%%%%%%%%%%%%%
% 'Finished block data' static text label��?�?�����?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', '<< Finished block data >>',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Center', 'FontSize', 12,...
    'Position',...
    [FinishedBlockTextLeft, FinishedBlockTextBottom,...
      FinishedBlockTextWidth, FinishedBlockTextHeight]);
			  
% Finished Block data��\������list box��?�?�����?B
finished_block_listbox = uicontrol('Parent', fig,  'Style', 'listbox',...
    'String', '',...
    'BackgroundColor', bgcol_listbox, 'ForegroundColor', fgcol_listbox,...
    'HorizontalAlignment', 'Left', 'FontSize', 10,...
    'Position',...
    [FinishedBlockListboxLeft, FinishedBlockListboxBottom,...
      FinishedBlockListboxWidth, FinishedBlockListboxHeight]);


%%%%%%%%%%%%%%%%%%%%%
% 'Current block number' static text label��?�?�����?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'Current block number',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left', 'FontSize', 12,...
    'Position',...
    [CurrentBlockTextLeft, CurrentBlockTextBottom,...
      CurrentBlockTextWidth, CurrentBlockTextHeight]);
			  
% Current Block��?����w�肷��edit text��?�?�����?B
current_block_edit = uicontrol('Parent', fig,  'Style', 'edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',10,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'Position',...
    [CurrentBlockEditLeft, CurrentBlockEditBottom,...
      CurrentBlockEditWidth, CurrentBlockEditHeight],...
    'CallBack', @current_blockCallback);


%%%%%%%%%%%%%%%%%%%%%
% 'receiver num' static text label��?�?�����?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'receiver num',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'left', 'FontSize', 12,...
    'Position',...
    [ReceiverNumTextLeft, ReceiverNumTextBottom,...
      ReceiverNumTextWidth, ReceiverNumTextHeight]);
			  
% receiver�v�?�O������?����w�肷��edit text��?�?�����?B
receiver_num_edit = uicontrol('Parent', fig,  'Style', 'edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',10,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'Position',...
    [ReceiverNumEditLeft, ReceiverNumEditBottom,...
      ReceiverNumEditWidth, ReceiverNumEditHeight],...
    'CallBack', @receiver_numCallback);


%%%%%%%%%%%%%%%%%%%%%
% 'TCP/IP port' static text label��?�?�����?B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'TCP/IP port',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'left', 'FontSize', 12,...
    'Position',...
    [MsocketPortTextLeft, MsocketPortTextBottom,...
      MsocketPortTextWidth, MsocketPortTextHeight]);
			  
% ��?M�o�H(msocket)��port��?����w�肷��edit text��?�?�����?B
msocket_port_edit = uicontrol('Parent', fig,  'Style', 'edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',10,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'Position',...
    [MsocketPortEditLeft, MsocketPortEditBottom,...
      MsocketPortEditWidth, MsocketPortEditHeight],...
    'CallBack', @msocket_portCallback);


%%%%%%%%%%%%%%%%%%%%%
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


% ����Block��?��I��pdialig window��GUI���Ǘ?����?\���̂�?�?�����?B
gui = struct(...
    'block_dialog', fig,...			% Dialig window��handle
    'finished_block_listbox', finished_block_listbox,...
    'current_block_edit', current_block_edit,...
    'receiver_num_edit', receiver_num_edit,...
    'msocket_port_edit', msocket_port_edit,...
    'exit_push', exit_push,...			% 'EXIT' push button��handle
    'ok_push', ok_push,...			% 'OK' push button��handle
    'finished_blocks', [],...			% Finished block?��
    'finished_block_files', [],...		% Finished block file?��
    'current_block', 0,...			% Current Block��?�
    'format', '',...				% Data file��?�?��pformat������
    'formatB', '',...				% Dicom file?�?��pformat������
    'receiver_num', 0,...			% receiver?�
    'port', 0,...				% ��?M�o�H(msocket)��port��?�
    'exp_start', false...			% true:OK/false:EXIT
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleate_block_dialog_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = doDelete(varargin)
% function [] = doDelete(varargin)
% ����Block��?��I��pdialig window��CloseRequestFcn��?�
% (Window�����Ƃ��Ɏ�?s�����)
% 
% [input argument]
% varargin : ���g�p
global gData
delete(gData.data.block_gui.block_dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function doDelete()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = current_blockCallback(varargin)
% function [] = current_blockCallback(varargin)
% Current Block���w�肷��edit text��CallBack��?�
% 
% [input argument]
% varargin : ���g�p
global gData
val = str2double( get(gData.data.block_gui.current_block_edit, 'String') );
if ~isnan(val)
  if val > 0	% ?���?��l����͂���?B
    % Current Block��?���?X?V����?B
    gData.data.block_gui.current_block = val;
  end
end
% Current Block���w�肷��edit text��Current Block��?���?ݒ肷��?B
set(gData.data.block_gui.current_block_edit, 'String',...
    sprintf('%d', gData.data.block_gui.current_block));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function current_blockCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = receiver_numCallback(varargin)
% function [] = receiver_numCallback(varargin)
% receiver�v�?�O������?����w�肷��edit text��CallBack��?�
% 
% [input argument]
% varargin : ���g�p
global gData
val = str2double( get(gData.data.block_gui.receiver_num_edit, 'String') );
if ~isnan(val)
  if val > 0	% ?���?��l����͂���?B
    % receiver?���?X?V����?B
    gData.data.block_gui.receiver_num = val;
  end
end
% receiver�v�?�O������?����w�肷��edit text��receiver?���?ݒ肷��?B
set(gData.data.block_gui.receiver_num_edit, 'String',...
    sprintf('%d', gData.data.block_gui.receiver_num));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function receiver_numCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = msocket_portCallback(varargin)
% function [] = msocket_portCallback(varargin)
% ��?M�o�H(msocket)��port��?����w�肷��edit text��CallBack��?�
% 
% [input argument]
% varargin : ���g�p
global gData
val = str2double( get(gData.data.block_gui.msocket_port_edit, 'String') );
if ~isnan(val)
  if val > 0	% ?���?��l����͂���?B
    % port��?���?X?V����?B
    gData.data.block_gui.port = val;
  end
end
% ��?M�o�H(msocket)��port��?����w�肷��edit text��port��?���?ݒ肷��?B
set(gData.data.block_gui.msocket_port_edit, 'String',...
    sprintf('%d', gData.data.block_gui.port));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function msocket_portCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = okCallback(varargin)
% function [] = okCallback(varargin)
% 'OK' push button��CallBack��?�
% 
% [input argument]
% varargin : ���g�p
global gData
% �����J�n�t���O��true��?ݒ肵?A
% ����Block��?��I��pdialig window�����?B
gData.data.block_gui.exp_start = true;
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
% �����J�n�t���O��false��?ݒ肵?A
% ����Block��?��I��pdialig window�����?B
gData.data.block_gui.exp_start = false;
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function exitCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
