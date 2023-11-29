function [this] = set_current_terminal_dir(this)
% private.current_terminal_dir�򹹿����롣
% (init_private.m��init_private()��Υ����Ȼ���)

% current_����directory�κǲ��ؤ�directory̾��������롣
tmp = find( this.public.current_dir == filesep );
if isempty(tmp)
  this.private.current_terminal_dir = this.public.current_dir;
else
  this.private.current_terminal_dir = this.public.current_dir(tmp(end)+1:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_current_terminal_dir()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
