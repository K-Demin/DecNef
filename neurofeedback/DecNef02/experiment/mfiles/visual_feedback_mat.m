function [] = visual_feedback_mat(status)
% function [] = visual_feedback_mat(status)
% MATLAB�ɂ��Visual feedback�������s�Ȃ��B
% status�̐ݒ�l�ɏ]��Visual feedback���������s����B
% 
% [input argument]
% status : Visual feedback��������

global gData

% ��U�AVisual feedback�̒񎦗p��Figure Window��
% �S�ẴI�u�W�F�N�g���\��������B
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
  case gData.define.feedback.INITIALIZE		% ����������
    init_feedback();
  case gData.define.feedback.GAZE		% �����_�̕`�揈��
    gaze_feedback();
  case gData.define.feedback.PREP_REST1		% �O�����p��REST���� ����1
    prep_rest1_feedback();
  case gData.define.feedback.PREP_REST2		% �O�����p��REST���� ����2
    prep_rest2_feedback();
  case gData.define.feedback.REST		% REST����
    rest_feedback();
  case gData.define.feedback.TEST		% TEST����
    test_feedback();
  case gData.define.feedback.PREP_SCORE		% ���_�񎦂܂ł̏���
    prep_score_feedback();
  case gData.define.feedback.SCORE		% ���_��
    score_feedback();
  case gData.define.feedback.NG_SCORE		% ���_�̌v�Z�����s���̒�
    ng_score_feedback();
  case gData.define.feedback.SLEEP_CHECK	% �Q�Ă��Ȃ����`�F�b�N����
    sleep_check_feedback();
  case gData.define.feedback.FINISHED_BLOCK	% �u���b�N�I������(���ϓ_��)
    finished_block_feedback();
  case gData.define.feedback.FINISH		% �I������
    finish_feedback();
  otherwise,
end	% <-- End of 'switch status'

% Visual feedback�̒񎦗p��Figure Window�̕`����X�V����B
drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function visual_feedback_mat()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = init_feedback()
% function [] = init_feedback()
% Visual feedback�̏���������

global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Visual feedback�̒񎦗p��Figure window�𐶐�����B
% (Figure window��Renderer�v���p�e�B��OpenGL�ɐݒ肷��)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ispc
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows���Ŏ��s����Ă���ꍇ�AVisual feedback
  % �񎦗p��Figure window�́A�t���X�N���[�����[�h��
  % �\������B
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
  gData.data.feedback.window_id =...
      figure('menubar','non','NumberTitle','off',...
      'Units','pixels', 'Visible', 'on', 'Renderer', 'OpenGL',...
      'WindowStyle', 'modal',...
      'Position', pos, 'Color', define.color.BG/255);
  if 0
    % maximize()�֐���Figure window���t���X�N���[�����[�h�ɐ؂�ւ���B
    maximize(gData.data.feedback.window_id);
  else
    % 'Position' property�Ƀt���X�N���[���T�C�Y��ݒ肷��B
    fprintf('set figure position(L:%d,B:%d,W:%d,H:%d)\n',...
	left, bottom, width, height);
    set(gData.data.feedback.window_id,...
	'Position', [left, bottom, width, height]);
  end
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Windows�ȊO��OS�Ŏ��s����Ă���ꍇ�AVisual feedback
  % �񎦗p��Figure window�́A�X�N���[���̒����t�߂�
  % �Œ�T�C�Y(1280x1024)�ŕ\������B
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
% Figure window�Ƀt�H�[�J�X�������Ԃł�
% �L�[�����������ɌĂяo�����R�[���o�b�N�֐� ��
% �L�[�𗣂������ɌĂяo�����R�[���o�b�N�֐� ��
% Figure window��̃}�E�X�̃|�C���^�[(����) ��
% �ݒ肷��B
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
  % �Â��o�[�W������MATLAB�ł́A 'WindowKeyPressFcn' property��
  % 'WindowKeyReleaseFcn' property���T�|�[�g����Ă��Ȃ��B
  set(gData.data.feedback.window_id, 'UserData', UserData,...
      'KeyPressFcn', @keypressfcn, 'KeyReleaseFcn', @keyreleasefcn,...
      'Pointer','custom','PointerShapeCData', nan(16,16) );
end

if 0
  % ������drawnow��call���Ȃ��ƁA ���̌�̍s�ōs�Ȃ�
  % set�֐��Ŏ擾���� 'Position' property�̒l���s����
  % �ꍇ������B (Window�̑傫�������f����Ă��Ȃ�)
  drawnow;	% ���܂��Ȃ�...
  
  % Visual feedback Window�̑傫�����l������B
  pos = get(gData.data.feedback.window_id, 'Position');
  gData.data.feedback.window_width = pos(3);
  gData.data.feedback.window_height= pos(4);
else
  gData.data.feedback.window_width = width;
  gData.data.feedback.window_height= height;
end

% (��\����Ԃ�)Axes�I�u�W�F�N�g���쐬����B
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
try	% �t�H���g�����w�肷��B
  set(gca, 'FontName', define.FONT_NAME);
end


% ���ofeedback��񎦗p��Window�̒��_�̍��W��ݒ肷��B
gData.data.feedback.window_center_x =...
    round(gData.data.feedback.window_width/2);
gData.data.feedback.window_center_y =...
    round(gData.data.feedback.window_height/2);


% �R�����g������̃A���_�[�X�R�A('_')���X�y�[�X(' ')��
% �u����������������쐬���A���̕���������s������('\n')
% �ŕ�������cell�������ݒ肷��B
% (create_global.m����create_para()��create_data()��
%  �R�����g�Q��)
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

% �����_(�~�� �g)��patch�I�u�W�F�N�g���쐬����B
% ( �����_(�~�� �g)��Z���W��0.0��ݒ肷�� )
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

% �����_(�~�� �h)��patch�I�u�W�F�N�g���쐬����B
% (�����_��Z���W��0.01��ݒ肷��)
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

% �����_�̋�`(�Q�Ă��Ȃ����`�F�b�N�p)��patch�I�u�W�F�N�g���쐬����B
% (�����_��Z���W��0.02��ݒ肷��)
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

% ���_�̏���l���擾���̉~(�g)��patch�I�u�W�F�N�g���쐬����B
% (�����_��Z���W(0.0����0.02)�����ɐݒ肷��B)
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

% ���_�̏���l��50%���擾���̉~(�g)��patch�I�u�W�F�N�g���쐬����B
% (�����_��Z���W(0.0����0.02)�����ɐݒ肷��B)
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

% ���_�̉~(�h)��patch�I�u�W�F�N�g���쐬����B
% (�����_��Z���W(0.0����0.02)�����ɐݒ肷��B)
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

% �R�����g��������쐬����B
% (�����_��Z���W(0.0����0.02)����O�ɐݒ肷��B)
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
try	% �t�H���g�����w�肷��B
  set(gData.data.feedback.comment_text, 'FontName', define.FONT_NAME);
end

% �u���b�N�I�����̃R�����g��������쐬����B
% (�����_��Z���W(0.0����0.02)����O�ɐݒ肷��B)
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
try	% �t�H���g�����w�肷��B
  set(gData.data.feedback.finished_comment_text, 'FontName', define.FONT_NAME);
end

% ���_��������쐬����B
% (�����_��Z���W(0.0����0.2)����O�ɐݒ肷��B)
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
try	% �t�H���g�����w�肷��B
  set(gData.data.feedback.score_text, 'FontName', define.FONT_NAME);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dst] = comment_string(src)
% function [dst] = comment_string(src)
% �R�����g������̃A���_�[�X�R�A('_')���X�y�[�X(' ')
% �ɒu����������������쐬���A���̕���������s������
% ('\n')�ŕ�������cell��������쐬����B
% (create_global.m����create_para()��create_data()��
% �R�����g�Q��)
% 
% [input argument]
% src : �ϊ��O�̃R�����g������
% 
% [input argument]
% dst : �ϊ���̃R�����g������(cell������)

% �A���_�[�X�R�A('_')���X�y�[�X(' ')�ɒu��������B
str = src;
str( findstr(str, '_') ) = ' ';

% ���s������('\n')�ŕ�������cell��������쐬����B
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
% �����_�̕`�揈��
global gData
% �����_(�~�ʂ̒��ɓh�����~)��\����Ԃɂ���B
set(gData.data.feedback.gaze_frame, 'Visible', 'on');
set(gData.data.feedback.gaze_fill, 'Visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function gaze_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = prep_rest1_feedback()
% function [] = prep_rest1_feedback()
% 1���s�ڂ̑O�����p��REST��������1�̕`�揈��
global gData
% 1���s�ڂ̑O�����p��REST��������1�̃R�����g�������\������B
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.prep_rest1_comment, 'Visible', 'on');

gaze_feedback();	% �����_��`�悷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function prep_rest1_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = prep_rest2_feedback()
% function [] = prep_rest2_feedback()
% 1���s�ڂ̑O�����p��REST��������2�̕`�揈��
global gData
% 1���s�ڂ̑O�����p��REST��������2�̃R�����g�������\������B
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.prep_rest2_comment, 'Visible', 'on');

gaze_feedback();	% �����_��`�悷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function prep_rest2_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = rest_feedback()
% function [] = rest_feedback()
% REST�����̕`�揈��
global gData
% REST�����̃R�����g�������\������B
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.rest_comment, 'Visible', 'on');

gaze_feedback();	% �����_��`�悷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function rest_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = test_feedback()
% function [] = test_feedback()
% TEST�����̕`�揈��
global gData
% TEST�����̃R�����g�������\������B
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.test_comment, 'Visible', 'on');

gaze_feedback();	% �����_��`�悷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function test_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = prep_score_feedback()
% function [] = prep_score_feedback()
% TEST�������I��������A���_�񎦂܂ł̏����̕`�揈��
global gData
% ���_�񎦂܂ł̏����̃R�����g�������\������B
set(gData.data.feedback.comment_text,...
    'String', gData.data.feedback.prep_score_comment, 'Visible', 'on');

sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &...
      gData.data.sleep_check(sleep_check_count) == false
  % '�팟�҂��Q�Ă��Ȃ����̃`�F�b�N�����̎��s' ��
  % '�`�F�b�N�p�̃L�[�����������͏��'
  % -> �팟�҂��Q�Ă��Ȃ����`�F�b�N�p�̕`�揈��
  sleep_check_feedback();
else
  % �����_�̕`�揈��
  gaze_feedback();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function prep_score_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = score_feedback()
% function [] = score_feedback()
% ���_��񎦂���B
global gData
switch gData.para.feedback.feedback_type
  case gData.define.feedback.feedback_type.TEXT_MODE
    % ���ofeedback�̒񎦃^�C�v �� �e�L�X�g���� �̏ꍇ
    score_text_mode();
  case gData.define.feedback.feedback_type.CIRCLE_MODE
    % ���ofeedback�̒񎦃^�C�v �� �~�ʕ��� �̏ꍇ
    score_circle_mode();
  otherwise
end

sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &...
      gData.data.sleep_check(sleep_check_count) == false
  % '�팟�҂��Q�Ă��Ȃ����̃`�F�b�N�����̎��s' ��
  % '�`�F�b�N�p�̃L�[�����������͏��'
  % -> �팟�҂��Q�Ă��Ȃ����`�F�b�N�p�̕`�揈��
  sleep_check_feedback();
else
  % �����_�̕`�揈��
  gaze_feedback();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function score_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = score_text_mode()
% function [] = score_text_mode()
% ���_���e�L�X�g�ŕ\������
global gData

score = gData.data.score(gData.data.current_trial);
if ~isnan(score)
  % ���_(score)��NaN�̏ꍇ�A���_�����v�Z�̂��ߕ\�����Ȃ��B
    
  % ���_�񎦏����̃R�����g�������\������B
  set(gData.data.feedback.comment_text,...
      'String', gData.data.feedback.score_comment, 'Visible', 'on');
	        
  % ���݂̎��s�̓��_��\������B
  set(gData.data.feedback.score_text,...
      'String', sprintf('%d', score), 'Visible', 'on');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function score_text_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = score_circle_mode()
% function [] = score_circle_mode()
% ���_���~�̑傫���ŕ\������
global gData

score = gData.data.score(gData.data.current_trial);
if ~isnan(score)
  % ���_(score)��NaN�̏ꍇ�A���_�����v�Z�̂��ߕ\�����Ȃ��B

  X_AXIS = 1;
  Y_AXIS = 2;
  define = gData.define.feedback;
    
  % ���_�̏���l���擾���̉~(�g)��\����Ԃɂ���B
  set(gData.data.feedback.max_score, 'Visible', 'on');
  % ���_�̏���l��50%���擾���̉~(�g)��\����Ԃɂ���B
  set(gData.data.feedback.half_score, 'Visible', 'on');
  
  % ���_�̉~(�h)��`�悷��B
  if sum( isnan(gData.para.score.score_limit) )
    % score_limit��NaN���܂�(�����Ə����臒l�͖����l)
    % �E ���_��0�_�ȏ�Ȃ�
    %     -> �~�ʂ̐F : SCORE_CIRCLE_PLUS
    %     -> �ŏ��~�� : +0�_
    %     -> �ő�~�� : +100�_
    %  �E ���_��0�_�����Ȃ�
    %     -> �~�ʂ̐F : SCORE_CIRCLE_MINUS
    %     -> �ŏ��~�� : -0�_
    %     -> �ő�~�� : -100�_
    tmp = abs(score)/100.0;
    R = round( tmp * gData.para.feedback.max_score_r );
    if score >= 0,	color = define.color.SCORE_CIRCLE_PLUS/255;
    else		color = define.color.SCORE_CIRCLE_MINUS/255;
    end
  else
    % score_limit��NaN�͊܂܂Ȃ�
    %     -> �~�ʂ̐F : SCORE_CIRCLE
    %     -> �ŏ��~�� : ������臒l�̓��_
    %     -> �ő�~�� : �����臒l�̓��_
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
% ���_�̌v�Z�����s���̒�
global gData
% ���_�̌v�Z�����s���̃R�����g�������\������B
set(gData.data.feedback.score_text,...
    'String', gData.data.feedback.ng_score_comment, 'Visible', 'on');

sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &...
      gData.data.sleep_check(sleep_check_count) == false
  % '�팟�҂��Q�Ă��Ȃ����̃`�F�b�N�����̎��s' ��
  % '�`�F�b�N�p�̃L�[�����������͏��'
  % -> �팟�҂��Q�Ă��Ȃ����`�F�b�N�p�̕`�揈��
  sleep_check_feedback();
else
  % �����_�̕`�揈��
  gaze_feedback();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function ng_score_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = sleep_check_feedback()
% function [] = sleep_check_feedback()
% �팟�҂��Q�Ă��Ȃ����̃`�F�b�N�����̕`�揈��
global gData
% �����_�̋�`(�Q�Ă��Ȃ����`�F�b�N�p)��\����Ԃɂ���B
set(gData.data.feedback.sleep_fill, 'Visible', 'on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function sleep_check_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = finished_block_feedback()
% function [] = finished_block_feedback()
% �u���b�N�I������(�u���b�N�̕��ϓ��_��)�̕`�揈��
global gData
% �u���b�N�̕��ϓ��_��\������B
switch gData.para.feedback.feedback_type
  case gData.define.feedback.feedback_type.TEXT_MODE
    % ���ofeedback�̒񎦃^�C�v �� �e�L�X�g���� �̏ꍇ
    ave_score_text_mode();
  case gData.define.feedback.feedback_type.CIRCLE_MODE
    % ���ofeedback�̒񎦃^�C�v �� �~�ʕ��� �̏ꍇ
    ave_score_circle_mode();
  otherwise
end

% �u���b�N�I���̃R�����g�������\������B
set(gData.data.feedback.finished_comment_text,...
    'String', gData.data.feedback.finished_block_comment, 'Visible', 'on');

gaze_feedback();	% �����_��`�悷��B  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function finished_block_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = ave_score_text_mode()
% function [] = ave_score_text_mode()
% �u���b�N�̕��ϓ��_���e�L�X�g�ŕ\������B
global gData

% �u���b�N�̕��ϓ��_��\������B
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
% �u���b�N�̕��ϓ��_���~�̑傫���ŕ\������
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;
    
% ���_�̏���l���擾���̉~(�g)��\����Ԃɂ���B
set(gData.data.feedback.max_score, 'Visible', 'on');
% ���_�̏���l��50%���擾���̉~(�g)��\����Ԃɂ���B
set(gData.data.feedback.half_score, 'Visible', 'on');

tmp = 1:gData.para.scans.trial_num;
tmp( isnan(gData.data.score) ) = [];
score = round( mean( gData.data.score(tmp) ) );
% �u���b�N�̕��ϓ��_�̉~(�h)��`�悷��B
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
% Visual feedback�̏I������
global gData
% Visual feedback�̒񎦗p��Figure window�����B
close(gData.data.feedback.window_id);
% Visual feedback�̒񎦗p��Window ID�������l(�����l)�ɖ߂��B
gData.data.feedback.window_id = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function finish_feedback()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = keypressfcn(src,event)
% function [] = keypressfcn(src,event)
% Visual feedback�񎦗p��Figure window��
% �L�[�����������ɌĂяo�����R�[���o�b�N�֐�
% (���͕�����ێ�����B)
UserData = get(src, 'UserData');
UserData.key = event.Key;
set(src, 'UserData', UserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function keypressfcn()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [] = keyreleasefcn(src,event)
% function [] = keypressfcn(src,event)
% Visual feedback�񎦗p��Figure window��
% �L�[�𗣂������ɌĂяo�����R�[���o�b�N�֐�
% (���͕���������������B)
UserData = get(src, 'UserData');
UserData.key = '';
set(src, 'UserData', UserData);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function keyreleasefcn()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
