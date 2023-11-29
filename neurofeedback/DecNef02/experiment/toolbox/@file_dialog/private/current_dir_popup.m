function [] = current_dir_popup(obj, eventdata, dialog)
% search directoryを選択するpop-up menuのCallback関数

this = get(dialog, 'UserData');
v = get(obj, 'Value');
  
% current検索directoryを変更する。
hist_dir = this.public.hist_dir;
this.public.current_dir = hist_dir{v};
this.private.current_file = {};

% private.current_terminal_dirを更新する。
% (current_検索directory名の最下層のdirectory名を設定する。)
this = set_current_terminal_dir(this);

% current_driveをcurrent directoryのDrive番号に変更し、
% drive_info構造体を更新する。(Windows環境のみ)
this = set_drive_info(this);

% DialogのGUIのpropertyを更新する。
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function current_dir_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
