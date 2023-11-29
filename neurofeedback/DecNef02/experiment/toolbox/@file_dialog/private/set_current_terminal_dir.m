function [this] = set_current_terminal_dir(this)
% private.current_terminal_dirを更新する。
% (init_private.mのinit_private()内のコメント参照)

% current_検索directoryの最下層のdirectory名を獲得する。
tmp = find( this.public.current_dir == filesep );
if isempty(tmp)
  this.private.current_terminal_dir = this.public.current_dir;
else
  this.private.current_terminal_dir = this.public.current_dir(tmp(end)+1:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_current_terminal_dir()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
