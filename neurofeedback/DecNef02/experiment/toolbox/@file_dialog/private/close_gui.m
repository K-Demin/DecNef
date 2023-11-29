function [] = close_gui(obj, eventdata, dialog, action)
% 'Cancel' 'Done' push buttonのCallback関数

this = get(dialog, 'UserData');
switch lower(action)
  case 'done'
  case 'cancel',	
    this.public.current_dir = [];
    this.private.current_file = {};
end

% Dialogを非表示化する。
set(dialog, 'visible', 'off', 'UserData', this);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function close_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
