function [key] = keyboard_check()
% function [key] = keyboard_check()
% キー入力状態をチェックする。
% 
% [output argument]
% key  : 入力状態のキー文字
%        (入力状態のキーがない場合は '' を設定する。)

global gData

key = '';

switch gData.para.feedback.io_tool
  case gData.define.feedback.io_tool.PSYCHTOOLBOX
    % PsychtoolboxによるVisual feedback処理を行なう。
    [ keyIsDown, seconds, keyCode ] = KbCheck;
    if keyIsDown
      key = KbName(keyCode);
      if 0    % いずれのキーも押されていないことをチェックしない。
	while	KbCheck;	end
      end
    end
  
  case gData.define.feedback.io_tool.MATLAB
    % MATLABによるVisual feedback処理を行なう。
    figure(gData.data.feedback.window_id);
    UserData = get(gData.data.feedback.window_id, 'UserData');
    key = UserData.key;

  case gData.define.feedback.io_tool.DO_NOT_USE

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function keyboard_check()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
