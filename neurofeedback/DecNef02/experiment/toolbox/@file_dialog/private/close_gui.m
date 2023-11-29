function [] = close_gui(obj, eventdata, dialog, action)
% 'Cancel' 'Done' push button$B$N(BCallback$B4X?t(B

this = get(dialog, 'UserData');
switch lower(action)
  case 'done'
  case 'cancel',	
    this.public.current_dir = [];
    this.private.current_file = {};
end

% Dialog$B$rHsI=<(2=$9$k!#(B
set(dialog, 'visible', 'off', 'UserData', this);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function close_gui()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
