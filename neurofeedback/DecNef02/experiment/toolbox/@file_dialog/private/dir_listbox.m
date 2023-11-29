function [] = dir_listbox(obj, eventdata, dialog)
% ディレクトリ一覧を表示するlist boxのCallback関数

this = get(dialog, 'UserData');

v = get(obj, 'Value');
str = get(obj, 'String');

% current_検索directoryを更新する。
this.public.current_dir =...
    fullfile( this.public.current_dir, deblank(str(v,:)) );
% current_検索directoryを絶対パスにする。
cdir = pwd;
cd( this.public.current_dir );
this.public.current_dir = pwd;
cd( cdir );

this.private.current_file = {};

% private.current_terminal_dirを更新する。
% (current_検索directory名の最下層のdirectory名を設定する。)
this = set_current_terminal_dir(this);


% drive_info構造体を更新する。(Windows環境のみ)
this = set_drive_info(this);

% DialogのGUIのpropertyを更新する。
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function dir_listbox()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
