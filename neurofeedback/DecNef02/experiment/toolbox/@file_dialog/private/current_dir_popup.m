function [] = current_dir_popup(obj, eventdata, dialog)
% search directory�����򤹤�pop-up menu��Callback�ؿ�

this = get(dialog, 'UserData');
v = get(obj, 'Value');
  
% current����directory���ѹ����롣
hist_dir = this.public.hist_dir;
this.public.current_dir = hist_dir{v};
this.private.current_file = {};

% private.current_terminal_dir�򹹿����롣
% (current_����directory̾�κǲ��ؤ�directory̾�����ꤹ�롣)
this = set_current_terminal_dir(this);

% current_drive��current directory��Drive�ֹ���ѹ�����
% drive_info��¤�Τ򹹿����롣(Windows�Ķ��Τ�)
this = set_drive_info(this);

% Dialog��GUI��property�򹹿����롣
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function current_dir_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
