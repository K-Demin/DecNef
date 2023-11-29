function [current_dir, current_file] = visible(this)
% file_dialogクラスのGUI処理メソッド

% GUIを構築する。
this.private.gui_handles = create_gui(this);

% Dialog windowの'UserData' propertyにfile_dialog構造体をセットする。
UserData = struct('public', this.public, 'private', this.private);
% drive_info構造体を更新する。(Windows環境のみ有効)
UserData = set_drive_info(UserData);
% current_terminal_dirを更新する。
% (current_検索directory名の最下層のdirectory名を設定する。)
UserData = set_current_terminal_dir(UserData);
set(this.private.gui_handles.dialog, 'UserData', UserData, 'Visible', 'on');
% Dialog windowのGUIのproperty値を更新する。
set_gui_property(this.private.gui_handles.dialog);

% Dialog windowが非表示化されるまでwaitする。
waitfor(this.private.gui_handles.dialog, 'Visible', 'off')

% (ここですぐに処理を戻すと、環境によっては直後のGUI操作に
% 不具合をきたす場合があるので)念のため...もう少し待つ
pause(0.5);

if length( find(get(0, 'children') == this.private.gui_handles.dialog) )
  % current検索directory, current検索fileを求める。
  this = get(this.private.gui_handles.dialog, 'UserData');
  current_dir = this.public.current_dir;
  current_file = this.private.current_file;
  delete(this.private.gui_handles.dialog);
else
  current_dir = [];
  current_file = {};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function visible()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
