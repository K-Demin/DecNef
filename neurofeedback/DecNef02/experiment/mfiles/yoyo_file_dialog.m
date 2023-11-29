function [ret, dir_name, file_name] = yoyo_file_dialog(search_dir, file_extensions, title)

global  gData

ret = false;
dir_name = [];
file_name = [];

if isempty(gData.file_dialog)

  gData.file_dialog = struct(...
      'handle', [],...
      'hist_dir', []);
  gData.file_dialog.hist_dir = {};

  gData.file_dialog.handle = file_dialog();

  gData.file_dialog.handle = set(gData.file_dialog.handle,...
      'dialog_color',gData.define.gui.window_color,...
      'fgcol_panel', gData.define.gui.fgcol_panel,...
      'bgcol_panel', gData.define.gui.bgcol_panel,...
      'fgcol_text', gData.define.gui.fgcol_text,...
      'fgcol_popup', gData.define.gui.fgcol_popup,...
      'bgcol_popup', gData.define.gui.bgcol_popup,...
      'fgcol_listbox', gData.define.gui.fgcol_listbox,...
      'bgcol_listbox', gData.define.gui.bgcol_listbox,...
      'fgcol_edit', gData.define.gui.fgcol_edit,...
      'bgcol_edit', gData.define.gui.bgcol_edit,...
      'fgcol_push', gData.define.gui.fgcol_push,...
      'bgcol_push', gData.define.gui.bgcol_push);
end


% file_dialog
gData.file_dialog.handle.save_mode = false;
gData.file_dialog.handle.multi_select_mode = false;
gData.file_dialog.handle.file_extensions = file_extensions;
gData.file_dialog.handle.default_extension = 1;
gData.file_dialog.handle.title = title;

gData.file_dialog.handle.current_dir = search_dir;
gData.file_dialog.handle.hist_dir = gData.file_dialog.hist_dir;

[dir_name, file_name] = visible(gData.file_dialog.handle);
  

if ~isempty(dir_name)

  current = 0;
  hist_num = length( gData.file_dialog.hist_dir );
  hist_dir = cell(1,hist_num+1);
  for ii=1:hist_num
    hist_dir{ii+1} = gData.file_dialog.hist_dir{ii};
    if strcmp( dir_name, deblank(gData.file_dialog.hist_dir{ii}) )
      current = ii;
    end
  end
  if ~current
    hist_dir{1} = dir_name;
    gData.file_dialog.hist_dir = hist_dir;
  end
  ret = true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function yoyo_file_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
