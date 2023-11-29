function private = init_private()
% private���Ф��������롣

private = struct(...
    'current_file', [],...	% current����file
    'current_terminal_dir',[],...% current����directory�ν�ü��directory̾ (*)
    'drive_info', [],...	% ��³drive����(Windows�Ķ��ǤΤ�ͭ��)
    'current_drive', 1,...	% ����drive�ֹ�(Windows�Ķ��ǤΤ�ͭ��)
    'gui_handles', []);
private.current_file = {};

% drive_info���й�¤�Τ������ꤹ�롣(Windows�Ķ��Τ�)
if strcmpi(computer, 'pcwin') || strcmpi(computer, 'pcwin64')
  % ��³Drive̾�򸡺����롣(C drive����Z drives)
  cnt = 0;
  for drive = [real('C'):real('Z')]
    str = sprintf('%c:', drive);
    if ~isempty( dir(str) )
      % �����ɥ饤�֤���³����Ƥ��롣
      cnt = cnt+1;
      drive_info(cnt) = struct('drive', str, 'cwd', str);
    end
  end
  if cnt,	private.drive_info = drive_info;	end
end	% <-- End of 'if strcmp( lower(computer), 'pcwin' )'

% (*) (2013.12.04)
% private.current_terminal_dir(current����directory�ν�ü
% ��directory̾)�ϡ�public.current_dir(current����directory̾)
% �����ꤵ��Ƥ���directory̾�κǲ��ؤ�directory̾�����ꤹ�롣
% 
% [��]
% public.current_dir = '/home/sonic/yosio/tmp' �ξ�硢
% private.current_terminal_dir = 'tmp' �����ꤵ��롣

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function init_private()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
