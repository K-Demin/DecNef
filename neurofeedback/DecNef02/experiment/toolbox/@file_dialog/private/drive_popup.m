function [] = drive_popup(obj, eventdata, dialog)
% Driveを選択するpop-up menuのCallback関数

this = get(dialog, 'UserData');

% current_dirveとcurrent_検索directoryを更新する。
current_drive = get(this.private.gui_handles.drive_popup, 'Value');
this.private.current_drive = current_drive;
this.public.current_dir = this.private.drive_info(current_drive).cwd;
% private.current_terminal_dirを更新する。
% (current_検索directory名の最下層のdirectory名を設定する。)
this = set_current_terminal_dir(this);

this.private.current_file = {};

% drive_info構造体を更新する。
this = set_drive_info(this);

% DialogのGUIのpropertyを更新する。
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function drive_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
