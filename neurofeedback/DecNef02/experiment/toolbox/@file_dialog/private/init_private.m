function private = init_private()
% privateメンバを初期化する。

private = struct(...
    'current_file', [],...	% current検索file
    'current_terminal_dir',[],...% current検索directoryの終端のdirectory名 (*)
    'drive_info', [],...	% 接続drive情報(Windows環境でのみ有効)
    'current_drive', 1,...	% 検索drive番号(Windows環境でのみ有効)
    'gui_handles', []);
private.current_file = {};

% drive_infoメンバ構造体を初期設定する。(Windows環境のみ)
if strcmpi(computer, 'pcwin') || strcmpi(computer, 'pcwin64')
  % 接続Drive名を検索する。(C driveからZ drives)
  cnt = 0;
  for drive = [real('C'):real('Z')]
    str = sprintf('%c:', drive);
    if ~isempty( dir(str) )
      % 検索ドライブが接続されている。
      cnt = cnt+1;
      drive_info(cnt) = struct('drive', str, 'cwd', str);
    end
  end
  if cnt,	private.drive_info = drive_info;	end
end	% <-- End of 'if strcmp( lower(computer), 'pcwin' )'

% (*) (2013.12.04)
% private.current_terminal_dir(current検索directoryの終端
% のdirectory名)は、public.current_dir(current検索directory名)
% に設定されているdirectory名の最下層のdirectory名を設定する。
% 
% [例]
% public.current_dir = '/home/sonic/yosio/tmp' の場合、
% private.current_terminal_dir = 'tmp' が設定される。

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_private()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
