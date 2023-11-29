function [] = fname_listbox(obj, eventdata, dialog)
% ファイル名一覧を表示するlist boxのCallback関数

this = get(dialog, 'UserData');
v = get(obj, 'Value');
str = get(obj, 'String');

% 選択ファイル名を更新する。
this.private.current_file = {};
for ii=1:length(v)
  this.private.current_file{ii} = deblank( str(v(ii),:) );
end

% DialogのGUIのpropertyを更新する。
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function fname_listbox()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
