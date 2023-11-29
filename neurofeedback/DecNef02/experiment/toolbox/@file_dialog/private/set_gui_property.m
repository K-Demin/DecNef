function [] = set_gui_property(dialog)
% Dialog windowのGUIのpropertyを更新する。


this = get(dialog,'UserData');


% histry directoryにcurrent directoryを追加する。
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


% 検索ディレクトリを選択するpop-up menuにディレクトリ名を設定する。
str = sprintf('|%s', this.public.hist_dir{:});	str(1) = [];
set(this.private.gui_handles.current_dir_popup,...
    'String', str, 'Value', current);


% 検索Drive名を選択するpopup-menuを更新する。
if length( this.private.drive_info )
  str = sprintf('|%s', this.private.drive_info(:).drive);
  str(1) = [];
  set(this.private.gui_handles.drive_text, 'Enable', 'on');
  set(this.private.gui_handles.drive_popup,...
      'Enable', 'on', 'String', str, 'Value', this.private.current_drive);
else	% Windows環境以外では無効化
  set(this.private.gui_handles.drive_text, 'Enable', 'off');
  set(this.private.gui_handles.drive_popup, 'Enable', 'off');
end


% 検索ディレクトリ内のディレクトリ名と(file_extensionの拡張子の)
% ファイル名の一覧を獲得する。
current_extension = get(this.private.gui_handles.extension_popup, 'Value');
[files, dirs] = list_files(this.public.current_dir,...
    this.public.file_extensions{current_extension});


% ディレクトリ一覧を更新する。
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


% ファイル一覧を更新する。
current_file = [];
if length(files)
  str = sprintf('%s|', files{:});	str(length(str)) = '';
  for ii=1:length(this.private.current_file)
    tmp = find( strcmp(files, this.private.current_file{ii}) );
    if length(tmp)
      current_file = [current_file, tmp];
    end
  end

  if this.public.multi_select_mode	% 複数選択可能mode
    max_val = 2;
  else	% 複数選択不可mode
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


% 選択ファイル名を表示するedit textを更新する。
if length( this.public.file_extensions{current_extension} )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file拡張子がNULL以外(拡張子あり)' の場合
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if isempty(this.private.current_file)
    filename = '';		% file未選択状態
  elseif length(this.private.current_file) == 1
    if this.public.save_mode	% SAVEモード:file名のみ表示する。
      filename = this.private.current_file{1};
    else			% LOADモード:full path表示する。
      filename =...
	  fullfile( this.public.current_dir, this.private.current_file{1} );
    end
  else				% 複数file選択状態
    filename = '';
    for ii=1:length(this.private.current_file)
      filename = sprintf('%s ''%s''', filename, this.private.current_file{ii});
    end
  end
else	% <-- End of 'length( file_extensions{current_extension} )'
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file拡張子がNULL(directory検索)' の場合  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % current_検索directoryの最下層のdirectory名を表示する。
  filename = this.private.current_terminal_dir;
end	% <-- End of 'length( file_extensions{current_extension} ) ... else'
set(this.private.gui_handles.sel_fname_edit, 'String', filename);
set_horizontal_alignment( this.private.gui_handles.sel_fname_edit );


% 'Done' push buttonを更新する。
% [注意]
% this.public.file_extensions{current_extension}が
% ''(NULL文字列)の場合、ディレクトリを検索対象と
% するので、ファイルを選択していなくても
% 'Done' push buttonを選択可能状態とする。
% (init_public.mのコメントを参照)
if length( this.public.file_extensions{current_extension} ) &...
      isempty( this.private.current_file )
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file拡張子がNULL以外(拡張子あり)' で
  % 'file選択状態でない' の場合
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'Done' push buttonは選択不可状態とする。
  set(this.private.gui_handles.done_push,...
      'FontWeight','normal', 'Enable','off');
else
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'file拡張子がNULL(directory検索)' か
  % 'file選択状態' の場合
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % 'Done' push buttonは選択可能状態とする。
  set(this.private.gui_handles.done_push,...
      'FontWeight','bold', 'Enable','on');
end

set(dialog, 'UserData', this);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_gui_property()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [files,dirs] = list_files(wdir, file_extension)
% 指定したdirectory内を検索する。
% wdir : 検索directory名
% file_extension : 検索するファイル拡張子

d = dir(wdir);
files = {};	files_num = 0;
dirs = {};	dirs_num = 0;
for ii=1:length(d)
  if d(ii).isdir	% directory名を追加する。
    dirs_num = dirs_num+1;
    dirs{dirs_num} = d(ii).name;
  else
    if strcmp(file_extension, '.*')
      append = 1;	% ワイルドカード(全ファイル検索対象とする。)
    else
      p = findstr(d(ii).name, file_extension);
      if ~isempty(p) &&...
	    ( p(length(p))==length(d(ii).name)-(length(file_extension)-1) )
	append = 1;
      else
	append = 0;
      end
    end	% <-- End of 'if strcmp(file_extension, '.*') ... else ....'
    
    if append	% file名を追加する。
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
