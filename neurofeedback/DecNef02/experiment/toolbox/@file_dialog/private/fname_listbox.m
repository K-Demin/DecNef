function [] = fname_listbox(obj, eventdata, dialog)
% �ե�����̾������ɽ������list box��Callback�ؿ�

this = get(dialog, 'UserData');
v = get(obj, 'Value');
str = get(obj, 'String');

% ����ե�����̾�򹹿����롣
this.private.current_file = {};
for ii=1:length(v)
  this.private.current_file{ii} = deblank( str(v(ii),:) );
end

% Dialog��GUI��property�򹹿����롣
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function fname_listbox()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
