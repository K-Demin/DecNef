function [] = drive_popup(obj, eventdata, dialog)
% Drive�����򤹤�pop-up menu��Callback�ؿ�

this = get(dialog, 'UserData');

% current_dirve��current_����directory�򹹿����롣
current_drive = get(this.private.gui_handles.drive_popup, 'Value');
this.private.current_drive = current_drive;
this.public.current_dir = this.private.drive_info(current_drive).cwd;
% private.current_terminal_dir�򹹿����롣
% (current_����directory̾�κǲ��ؤ�directory̾�����ꤹ�롣)
this = set_current_terminal_dir(this);

this.private.current_file = {};

% drive_info��¤�Τ򹹿����롣
this = set_drive_info(this);

% Dialog��GUI��property�򹹿����롣
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function drive_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
