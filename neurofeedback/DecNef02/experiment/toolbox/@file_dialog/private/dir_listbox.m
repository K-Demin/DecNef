function [] = dir_listbox(obj, eventdata, dialog)
% �ǥ��쥯�ȥ������ɽ������list box��Callback�ؿ�

this = get(dialog, 'UserData');

v = get(obj, 'Value');
str = get(obj, 'String');

% current_����directory�򹹿����롣
this.public.current_dir =...
    fullfile( this.public.current_dir, deblank(str(v,:)) );
% current_����directory�����Хѥ��ˤ��롣
cdir = pwd;
cd( this.public.current_dir );
this.public.current_dir = pwd;
cd( cdir );

this.private.current_file = {};

% private.current_terminal_dir�򹹿����롣
% (current_����directory̾�κǲ��ؤ�directory̾�����ꤹ�롣)
this = set_current_terminal_dir(this);


% drive_info��¤�Τ򹹿����롣(Windows�Ķ��Τ�)
this = set_drive_info(this);

% Dialog��GUI��property�򹹿����롣
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function dir_listbox()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
