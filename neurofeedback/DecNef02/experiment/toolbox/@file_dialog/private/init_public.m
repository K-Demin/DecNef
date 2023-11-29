function public = init_public()
% publicメンバを初期化する。

public = struct(...
    'save_mode', 0,...		% 0:Load mode, 1:Save mode
    'multi_select_mode', 1,...	% 0:Single select mode, 1:Multi select mode
    'file_extensions', [],...	% 検索対象のファイル拡張子(cell配列) (*)
    'default_extension', 1,...	% 検索対象のファイル拡張子の初期値
    'current_dir', pwd,...	% current検索directory
    'hist_dir', [],...		% 検索directoryの履歴(cell配列)
    'title', '',...		% Dialog windowのタイトル
    ...	% GUIの色を指定する。
    'dialog_color', [0.9, 0.9, 0.9],...	% dialogのbackground color
    'bgcol_panel', [0.8, 0.8, 0.8],...	% panelのbackground color
    'fgcol_panel', [0.1, 0.1, 0.4],...	% panelのforeground color
    'fgcol_text', [0.1, 0.1, 0.4],...	% static text labelのforeground color
    'bgcol_popup', [1.0, 1.0, 1.0],...	% pop-up menuのbackground color
    'fgcol_popup', [0.0, 0.0, 0.0],...	% pop-up menuのforeground color
    'bgcol_listbox', [1.0, 1.0, 1.0],...	% list boxのbackground color
    'fgcol_listbox', [0.0, 0.0, 0.0],...	% list boxのforeground color
    'bgcol_edit', [1.0, 1.0, 1.0],...	% edit textのbackground color
    'fgcol_edit', [0.0, 0.0, 0.0],...	% edit textのforeground color
    'bgcol_push', [0.8, 0.8, 0.9],...	% push buttonのbackground color
    'fgcol_push', [0.0, 0.0, 0.0]...	% push buttonのforeground color
    );
public.file_extensions = {'.*'};
public.hist_dir = {};

% (*) (2013.12.03)
% public.file_extensions(検索対象のファイル拡張子)が
% ''(NULL文字列)の場合、検索対象を(ファイルではなく)
% ディレクトリとする。

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_public()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
