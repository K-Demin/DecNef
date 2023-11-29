function [] = extension_popup(obj, eventdata, dialog)
% ファイルの拡張子を選択するpop-up menuのCallback関数

this = get(dialog, 'UserData');
this.private.current_file = {};

% Dialog windowのGUIのpropertyを更新する。
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function extension_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
