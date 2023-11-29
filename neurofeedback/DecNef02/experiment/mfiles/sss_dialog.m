function [sss_level, sss_comment] = sss_dialog()
% Stanford sleepiness scale(Stanford���C�ړx)
% �̎���p��dialig window��񎦂��A���C�ړx���x��
% ��I������B

global gData


% Stanford���C�ړx�̎��⎞�ɔ팟�҂ɒ񎦂���摜��\������B
if isempty(gData.para.sss.sss_image_fname)
  % ����摜file�����w�肵�Ă��Ȃ��̂ŁA����摜��񎦂��Ȃ��B
  % (create_global.m��create_para()����sss�\���̂̃R�����g�Q��)
  image_window_id = [];
else
  image_window_id = create_sss_image_window();
end

% Stanford���C�ړx�̎���p��dialig window��GUI���쐬����B
gData.data.sss_gui = cleate_sss_dialog_gui(gData.define, image_window_id);

% Stanford���C�ړx�̎���p��dialig window��\����ԂƂ��A
% dialig window��������܂ő҂B
set(gData.data.sss_gui.para_dialog, 'Resize','off', 'Visible', 'on');
uiwait(gData.data.sss_gui.para_dialog)

% Stanford���C�ړxLevel �� �R�����g������ ���l������B
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
% Figure window���J���AStanford���C�ړx�̎��⎞��
% �팟�҂ɒ񎦂���摜��\������B
% 
% [output argument]
% window_id : �摜��񎦂���Figure window��handle

global gData


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford���C�ړx�̎��⎞�ɔ팟�҂ɒ񎦂���
% �摜�f�[�^��ǂݍ��ށB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sss_image_fname = fullfile(...
    gData.para.files.para_dir,...
    gData.para.sss.sss_image_dir,...
    gData.para.sss.sss_image_fname);
try
  sss_image = imread(sss_image_fname);
catch
  % �摜�f�[�^�̓ǂݍ��݂Ɏ��s�����̂ŉ摜�͒񎦂��Ȃ��B
  fprintf('\n');
  fprintf('ERROR : Can''t open file ''%s'' for reading.\n', sss_image_fname);
  fprintf('ERROR : para_file_dir   = ''%s''\n', gData.para.files.para_dir);
  fprintf('ERROR : sss_image_dir   = ''%s''\n', gData.para.sss.sss_image_dir);
  fprintf('ERROR : sss_image_fname = ''%s''\n',gData.para.sss.sss_image_fname);
  window_id = [];
  return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stanford���C�ړx�̎��⎞�ɔ팟�҂ɒ񎦂���摜
% �񎦗p��Figure window�𐶐�����B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows���Ŏ��s����Ă���ꍇ�A�摜�񎦗p��
  % Figure window�́A�t���X�N���[�����[�h�ŕ\������B
  % (���o�񎦂���screen����Figure window���J������A
  %  �t���X�N���[�����[�h�ɐ؂�ւ���B)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  MonitorPositions = get(0,'MonitorPositions');
  screen = gData.para.feedback.screen;  % ���o�񎦂���screen�ԍ�
  width = MonitorPositions(screen,3) - MonitorPositions(screen,1) + 1;
  height = MonitorPositions(screen,4) - MonitorPositions(screen,2) + 1;
  bottom = MonitorPositions(1,4) - MonitorPositions(screen,4);
  left = MonitorPositions(screen,3) - width;
  
  pos = [left+50, bottom+50, 10, 10];
  window_id = figure('menubar','non','NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'Position', pos);
  if 0	% maximize()�֐���Figure window���t���X�N���[�����[�h�ɐ؂�ւ���B
    maximize(window_id);
  else	% 'Position' property�Ƀt���X�N���[���T�C�Y��ݒ肷��B
    set(window_id, 'Position', [left, bottom, width, height]);
  end
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows�ȊO��OS�Ŏ��s����Ă���ꍇ�A�摜�񎦗p��
  % Figure window�́A�X�N���[���̒����t�߂ɌŒ�T�C�Y
  % (1280x1024)�ŕ\������B
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  S = get(0,'ScreenSize');
  width = 1280;
  height= 1024;
  window_id = figure('NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'Position',[S(3)/2-width/2, S(4)/2-height/2, width, height]);
end	% <-- End of 'if ispc ... else'


% (��\����Ԃ�)Axes�I�u�W�F�N�g���쐬����B
[h, w, x] = size(sss_image);
set(gca,...
    'DataAspectRatio', [1,1,1], 'DrawMode', 'fast',...
    'FontUnits', 'pixels', 'FontWeight', 'normal',...
    'Units', 'normalized',...
    'OuterPosition', [0,0,1,1], 'Position',[0,0,1,1],...
    'XLim', [0,w], 'YLim', [0,h], 'Visible', 'off');

% Figure window�ɁAStanford���C�ړx�̎��⎞�ɔ팟�҂�
% ������摜��񎦂���B
image(sss_image);
set(gca, 'XTick', [], 'YTick', []);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'create_sss_image_window()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [gui] = cleate_sss_dialog_gui(define, image_fig)
% function [] = cleate_sss_dialog_gui(define, image_fig)
% Stanford���C�ړx�̎���p��dialig window��GUI���쐬����B
% 
% [input argument]
% image_fig : �摜��񎦂���Figure window��handle
% define    : define�ϐ����Ǘ�����\����
% 
% [output argument]
% gui : Stanford���C�ړx�̎���p��dialig window��GUI���Ǘ�����\����


S = get(0,'ScreenSize');


Width = 320;	% dialig window�̕�
Height = 170;	% dialig window�̍���

BorderH = 10;	% ����
BorderV = 10;	% ������


% 'Stanford sleepiness scale Level' static text label�̑傫���ƈʒu
LevelTextWidth = 240;
LevelTextHeight = 25;
LevelTextLeft = BorderH;
LevelTextBottom = Height - (LevelTextHeight+BorderV);

% Stanford���C�ړxLevel��I������pop-up menu�̑傫���ƈʒu
LevelPopupWidth = Width - 2*BorderH - LevelTextWidth;
LevelPopupHeight = LevelTextHeight;
LevelPopupLeft = LevelTextLeft + LevelTextWidth;
LevelPopupBottom = LevelTextBottom;


% 'Comment' static text label�̑傫���ƈʒu
CommentTextWidth = 100;
CommentTextHeight = 25;
CommentTextLeft = BorderH;
CommentTextBottom = LevelPopupBottom - (CommentTextHeight+BorderV);

% �R�����g����͂���edit text�̑傫���ƈʒu
CommentEditWidth = Width - 2*BorderH;
CommentEditHeight = 30;
CommentEditLeft = BorderH;
CommentEditBottom = CommentTextBottom - CommentEditHeight;


% 'OK' push button�̑傫���ƈʒu
OkWidth = 200;
OkHeight = 30;
OkLeft = (Width - OkWidth)/2;
OkBottom = BorderV;


% GUI�̐F
window_color = define.gui.window_color;		% window��color
fgcol_text = define.gui.fgcol_text;		% static text��foreground
bgcol_popup = define.gui.bgcol_popup;		% pop-up menu��background
fgcol_popup = define.gui.fgcol_popup;		% pop-up menu��foreground
bgcol_edit = define.gui.bgcol_edit;		% edit text��background
fgcol_edit = define.gui.fgcol_edit;		% edit text��foreground
bgcol_push = define.gui.bgcol_push;		% push button��background
fgcol_push = define.gui.fgcol_push;		% push button��foreground


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dialig window���쐬����B
fig = figure('Name','Stanford sleepiness scale','Tag','Parameters',...
    'MenuBar','none', 'NumberTitle','off', 'HandleVisibility','off',...
    'WindowStyle', 'modal',...
    'Color', window_color, 'Resize','off', 'Visible', 'off',...
    'Units','Pixels','IntegerHandle','off', ...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CloseRequestFcn' ,@doDelete,...
    'Position', [S(3)/2-Width/2 S(4)/2-Height/2 Width Height]);


%%%%%%%%%%%%%%%%%%%%%
% 'Stanford sleepiness scale Level' static text label���쐬����B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'Stanford sleepiness scale Level',...
    'FontSize', 12, 'FontWeight','normal',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left',...
    'Position',...
    [LevelTextLeft, LevelTextBottom, LevelTextWidth, LevelTextHeight]);

% Stanford���C�ړxLevel��I������pop-up menu���쐬����B
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
% 'Comment' static text label���쐬����B
uicontrol('Parent', fig,  'Style', 'text',...
    'String', 'Comment', 'FontSize', 12, 'FontWeight','normal',...
    'BackgroundColor', window_color, 'ForegroundColor', fgcol_text,...
    'HorizontalAlignment', 'Left',...
    'Position',...
    [CommentTextLeft, CommentTextBottom, CommentTextWidth, CommentTextHeight]);

% �R�����g����͂���edit text���쐬����B
comment_edit = uicontrol('Parent', fig, 'Style','edit',...
    'BackgroundColor', bgcol_edit, 'ForegroundColor', fgcol_edit,...
    'Units', 'pixels', 'FontSize',9,...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'HorizontalAlignment', 'Left',...
    'Position',...
    [CommentEditLeft CommentEditBottom CommentEditWidth CommentEditHeight]);


% 'OK' push button���쐬����B
ok_push = uicontrol('Parent', fig,...
    'Style', 'push', 'String', 'OK',...
    'FontSize', 14, 'FontWeight','bold',...
    'Units', 'pixels',...
    'BackgroundColor', bgcol_push, 'ForegroundColor', fgcol_push,...
    'Position', [OkLeft OkBottom OkWidth OkHeight],...
    'BusyAction', 'cancel', 'Interruptible', 'off',...
    'CallBack', @okCallback);


% Stanford���C�ړx�̎���p��dialig window��GUI���Ǘ�����\���̂��쐬����B
gui = struct(...
    'image_fig', image_fig,...		% �摜��񎦂���Figure window��handle
    'para_dialog', fig,...		% SSS����p��dialig window��handle
    'level_popup', level_popup,...	% SSS Level�I������pop-up menu��handle
    'comment_edit', comment_edit,...	% �R�����g����͂���edit text��handle
    'ok_push', ok_push,...		% 'OK' push button��handle
    'sss_level', NaN,...		% Stanford���C�ړxLevel
    'sss_comment', ''...		% Stanford���C�ړx�R�����g������
    );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleate_sss_dialog_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = doDelete(varargin)
% function [] = doDelete(varargin)
% Stanford���C�ړx�̎���p��dialig window��CloseRequestFcn�֐�
% (Window�����Ƃ��Ɏ��s�����)
% 
% [input argument]
% varargin : ���g�p
global gData
delete(gData.data.sss_gui.para_dialog);
if ~isempty(gData.data.sss_gui.image_fig)
  % �摜��񎦂���Figure window�����B
  close(gData.data.sss_gui.image_fig)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function doDelete()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = okCallback(varargin)
% function [] = okCallback(varargin)
% 'OK' push button��CallBack�֐�
% 
% [input argument]
% varargin : ���g�p
global gData
% Stanford���C�ړxLevel �� �R�����g������ ���l�����A
% Stanford���C�ړx�̎���p��dialig window�����B
sss_level = get(gData.data.sss_gui.level_popup, 'value');
if sss_level <= gData.define.default.SSS_MAX_LEVEL
  gData.data.sss_gui.sss_level = sss_level;
else
  gData.data.sss_gui.sss_level = NaN;	% Stanford���C�ړxLevel�����I�����
end
gData.data.sss_gui.sss_comment =...
    get(gData.data.sss_gui.comment_edit, 'String');
doDelete();
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function okCallback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
