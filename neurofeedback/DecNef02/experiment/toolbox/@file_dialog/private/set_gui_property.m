function [] = set_gui_property(dialog)
% Dialog window��GUI��property�򹹿����롣


this = get(dialog,'UserData');


% histry directory��current directory���ɲä��롣
current = 0;
hist_num = length( this.public.hist_dir );
hist_dir = cell(1,hist_num+1);
for ii=1:hist_num
  hist_dir{ii+1} = this.public.hist_dir{ii};
  if strcmp( this.public.current_dir, deblank(this.public.hist_dir{ii}) )
    current = ii;
  end
end
if ~current
  current = 1;
  hist_dir{1} = this.public.current_dir;
  this.public.hist_dir = hist_dir;
end


% �����ǥ��쥯�ȥ�����򤹤�pop-up menu�˥ǥ��쥯�ȥ�̾�����ꤹ�롣
str = sprintf('|%s', this.public.hist_dir{:});	str(1) = [];
set(this.private.gui_handles.current_dir_popup,...
    'String', str, 'Value', current);


% ����Drive̾�����򤹤�popup-menu�򹹿����롣
if length( this.private.drive_info )
  str = sprintf('|%s', this.private.drive_info(:).drive);
  str(1) = [];
  set(this.private.gui_handles.drive_text, 'Enable', 'on');
  set(this.private.gui_handles.drive_popup,...
      'Enable', 'on', 'String', str, 'Value', this.private.current_drive);
else	% Windows�Ķ��ʳ��Ǥ�̵����
  set(this.private.gui_handles.drive_text, 'Enable', 'off');
  set(this.private.gui_handles.drive_popup, 'Enable', 'off');
end


% �����ǥ��쥯�ȥ���Υǥ��쥯�ȥ�̾��(file_extension�γ�ĥ�Ҥ�)
% �ե�����̾�ΰ�����������롣
current_extension = get(this.private.gui_handles.extension_popup, 'Value');
[files, dirs] = list_files(this.public.current_dir,...
    this.public.file_extensions{current_extension});


% �ǥ��쥯�ȥ�����򹹿����롣
if length(dirs)
  str = sprintf('|%s', dirs{:});	str(1) = [];
  active_dir = find( strcmp(dirs, '.') );
  if isempty( active_dir )
    str = sprintf('.|%s', str);
    active_dir = 1;
  end
  set(this.private.gui_handles.dir_listbox, 'String', str,...
      'Min',0, 'Max',1, 'Value',active_dir, 'Enable','on');
else
  set(this.private.gui_handles.dir_listbox, 'String', '',...
      'Min',0, 'Max', 0, 'Value',[], 'Enable', 'off');
end


% �ե���������򹹿����롣
current_file = [];
if length(files)
  str = sprintf('%s|', files{:});	str(length(str)) = '';
  for ii=1:length(this.private.current_file)
    tmp = find( strcmp(files, this.private.current_file{ii}) );
    if length(tmp)
      current_file = [current_file, tmp];
    end
  end

  if this.public.multi_select_mode	% ʣ�������ǽmode
    max_val = 2;
  else	% ʣ�������Բ�mode
    if isempty(current_file),	max_val = 2;
    else			max_val = 1;
    end
  end
  set(this.private.gui_handles.fname_listbox, 'String', str,...
      'Min', 0, 'Max', max_val, 'Value', current_file, 'Enable', 'on');
else
  set(this.private.gui_handles.fname_listbox, 'String', '',...
      'Min', 0, 'Max', 0, 'Value', current_file, 'Enable', 'off');
end


% ����ե�����̾��ɽ������edit text�򹹿����롣
if length( this.public.file_extensions{current_extension} )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file��ĥ�Ҥ�NULL�ʳ�(��ĥ�Ҥ���)' �ξ��
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isempty(this.private.current_file)
    filename = '';		% file̤�������
  elseif length(this.private.current_file) == 1
    if this.public.save_mode	% SAVE�⡼��:file̾�Τ�ɽ�����롣
      filename = this.private.current_file{1};
    else			% LOAD�⡼��:full pathɽ�����롣
      filename =...
	  fullfile( this.public.current_dir, this.private.current_file{1} );
    end
  else				% ʣ��file�������
    filename = '';
    for ii=1:length(this.private.current_file)
      filename = sprintf('%s ''%s''', filename, this.private.current_file{ii});
    end
  end
else	% <-- End of 'length( file_extensions{current_extension} )'
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file��ĥ�Ҥ�NULL(directory����)' �ξ��  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % current_����directory�κǲ��ؤ�directory̾��ɽ�����롣
  filename = this.private.current_terminal_dir;
end	% <-- End of 'length( file_extensions{current_extension} ) ... else'
set(this.private.gui_handles.sel_fname_edit, 'String', filename);
set_horizontal_alignment( this.private.gui_handles.sel_fname_edit );


% 'Done' push button�򹹿����롣
% [���]
% this.public.file_extensions{current_extension}��
% ''(NULLʸ����)�ξ�硢�ǥ��쥯�ȥ�򸡺��оݤ�
% ����Τǡ��ե���������򤷤Ƥ��ʤ��Ƥ�
% 'Done' push button�������ǽ���֤Ȥ��롣
% (init_public.m�Υ����Ȥ򻲾�)
if length( this.public.file_extensions{current_extension} ) &...
      isempty( this.private.current_file )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file��ĥ�Ҥ�NULL�ʳ�(��ĥ�Ҥ���)' ��
  % 'file������֤Ǥʤ�' �ξ��
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'Done' push button�������Բľ��֤Ȥ��롣
  set(this.private.gui_handles.done_push,...
      'FontWeight','normal', 'Enable','off');
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file��ĥ�Ҥ�NULL(directory����)' ��
  % 'file�������' �ξ��
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'Done' push button�������ǽ���֤Ȥ��롣
  set(this.private.gui_handles.done_push,...
      'FontWeight','bold', 'Enable','on');
end

set(dialog, 'UserData', this);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_gui_property()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [files,dirs] = list_files(wdir, file_extension)
% ���ꤷ��directory��򸡺����롣
% wdir : ����directory̾
% file_extension : ��������ե������ĥ��

d = dir(wdir);
files = {};	files_num = 0;
dirs = {};	dirs_num = 0;
for ii=1:length(d)
  if d(ii).isdir	% directory̾���ɲä��롣
    dirs_num = dirs_num+1;
    dirs{dirs_num} = d(ii).name;
  else
    if strcmp(file_extension, '.*')
      append = 1;	% �磻��ɥ�����(���ե����븡���оݤȤ��롣)
    else
      p = findstr(d(ii).name, file_extension);
      if ~isempty(p) &&...
	    ( p(length(p))==length(d(ii).name)-(length(file_extension)-1) )
	append = 1;
      else
	append = 0;
      end
    end	% <-- End of 'if strcmp(file_extension, '.*') ... else ....'
    
    if append	% file̾���ɲä��롣
      files_num = files_num+1;
      files{files_num} = d(ii).name;
    end

  end	% <-- End of 'if d(ii).isdir ... else ...'
end	% <-- End of 'for ii=1:length(d)'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function list_files()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function set_horizontal_alignment(handle)

if isunix
  p = get(handle, 'Position');
  ext = get(handle,'Extent');
  if p(3) < ext(3),	set(handle,'HorizontalAlignment','right');
  else			set(handle,'HorizontalAlignment','left');
  end
else
  set(handle,'HorizontalAlignment','left');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_horizontal_alignment()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
