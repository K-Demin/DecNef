function [key] = keyboard_check()
% function [key] = keyboard_check()
% �L�[���͏�Ԃ��`�F�b�N����B
% 
% [output argument]
% key  : ���͏�Ԃ̃L�[����
%        (���͏�Ԃ̃L�[���Ȃ��ꍇ�� '' ��ݒ肷��B)

global gData

key = '';

switch gData.para.feedback.io_tool
  case gData.define.feedback.io_tool.PSYCHTOOLBOX
    % Psychtoolbox�ɂ��Visual feedback�������s�Ȃ��B
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown
      key = KbName(keyCode);
      if 0    % ������̃L�[��������Ă��Ȃ����Ƃ��`�F�b�N���Ȃ��B
	while	KbCheck;	end
      end
    end
  
  case gData.define.feedback.io_tool.MATLAB
    % MATLAB�ɂ��Visual feedback�������s�Ȃ��B
    figure(gData.data.feedback.window_id);
    UserData = get(gData.data.feedback.window_id, 'UserData');
    key = UserData.key;

  case gData.define.feedback.io_tool.DO_NOT_USE

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function keyboard_check()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
