function [] = extension_popup(obj, eventdata, dialog)
% �ե�����γ�ĥ�Ҥ����򤹤�pop-up menu��Callback�ؿ�

this = get(dialog, 'UserData');
this.private.current_file = {};

% Dialog window��GUI��property�򹹿����롣
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function extension_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
