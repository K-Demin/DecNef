function this = set(this, varargin)
% file_dialogクラスのsetメソッド
% set指定したオブジェクトにプロパティ値を設定し、file_dialogクラスを返す。

property_argin = varargin;
while length(property_argin) >= 2,
  prop = property_argin{1};
  val = property_argin{2};
  property_argin = property_argin(3:end);

  if isfield( this.public, lower(prop) )
    [val, errmsg] = feval( sprintf('set_%s', lower(prop)), prop, val );

    if ~isempty(errmsg),	error( errmsg );
    else	this.public = setfield(this.public, lower(prop), val);
    end
  else
      error('Invalid properties: ''%s''', prop);
  end
end

% default_extensionオブジェクトがfile_extensionsオブジェクトで指定している
% ファイル拡張子の数より大きい場合、default_extensionオブジェクトを修正する。
if this.public.default_extension > length(this.public.file_extensions)
  this.public.default_extension = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [save_mode, errmsg] = set_save_mode(prop, val)
% file_dialogクラスのsave_modeオブジェクトに対するsetメソッド
% 数値以外は受け付けない。

save_mode = [];
errmsg = [];
if exist('true','builtin')
  if val == true,	val = 1;
  elseif val == false,	val = 0;
  end
end
if isnumeric(val)
  if val,	save_mode = 1;
  else		save_mode = 0;
  end
else	errmsg = sprintf('''%s'':Value must be numeric.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_save_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [multi_select_mode, errmsg] = set_multi_select_mode(prop, val)
% file_dialogクラスのmulti_select_modeオブジェクトに対するsetメソッド
% 数値以外は受け付けない。

multi_select_mode = [];
errmsg = [];
if exist('true','builtin')
  if val == true,	val = 1;
  elseif val == false,	val = 0;
  end
end
if isnumeric(val)
  if val,	multi_select_mode = 1;
  else		multi_select_mode = 0;
  end
else	errmsg = sprintf('''%s'':Value must be numeric.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_multi_select_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [file_extensions, errmsg] = set_file_extensions(prop, val)
% file_dialogクラスのfile_extensionsオブジェクトに対するsetメソッド
% 文字列cell配列以外は受け付けない。

file_extensions = [];
errmsg = [];
if iscell(val)
  for ii=1:length(val)
    if ~ischar(val{ii})
      errmsg = sprintf('''%s'':Value must be string.(val{%d})',prop, ii);
    end
  end
  file_extensions = val;
else
  errmsg = sprintf('''%s'':Value must be cell array.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_save_mode()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [default_extension, errmsg] = set_default_extension(prop, val)
% file_dialogクラスのdefault_extensionオブジェクトに対するsetメソッド
% 文字列以外は受け付けない。

default_extension = [];
errmsg = [];
if isnumeric(val)
  if val > 0,	default_extension = val;
  else		errmsg = sprintf('''%s'':Value must be integer.',prop);
  end
else		errmsg = sprintf('''%s'':Value must be integer.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_default_extension()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [current_dir, errmsg] = set_current_dir(prop, val)
% file_dialogクラスのcurrent_dirオブジェクトに対するsetメソッド
% 文字列以外は受け付けない。

current_dir = '';
errmsg = [];
if ischar(val),
  [status, pathinfo] = fileattrib(val);
  if status
    % valで指定されたディレクトリ名を絶対パスにする。
    cdir = pwd;
    cd( val );
    current_dir = pwd;
    cd( cdir );
  else
    % valで指定されたディレクトリ名が存在しない。
    errmsg = sprintf('''%s'':%s (''%s'')\n', prop, pathinfo, val);
  end
else		
  errmsg = sprintf('''%s'':Value must be string.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_current_dir()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [hist_dir, errmsg] = set_hist_dir(prop, val)
% file_dialogクラスのhist_dirオブジェクトに対するsetメソッド
% 文字列cell配列以外は受け付けない。

hist_dir = [];
errmsg = [];
if iscell(val)
  for ii=1:length(val)
    if ~ischar(val{ii})
      errmsg = sprintf('''%s'':Value must be string.(val{%d})',prop, ii);
    end
  end
  hist_dir = val;
else
  errmsg = sprintf('''%s'':Value must be cell array.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_hist_dir()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [title, errmsg] = set_title(prop, val)
% file_dialogクラスのtitleオブジェクトに対するsetメソッド
% 文字列以外は受け付けない。
title = '';
errmsg = [];
if char(val)
  title = val;
else
  errmsg = sprintf('''%s'':Value must be string.',prop);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_title()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dialog_color, errmsg] = set_dialog_color(prop, val)
[dialog_color, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dialog_color()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [bgcol_panel, errmsg] = set_bgcol_panel(prop, val)
[bgcol_panel, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_bgcol_panel()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fgcol_panel, errmsg] = set_fgcol_panel(prop, val)
[fgcol_panel, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_fgcol_panel()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fgcol_text, errmsg] = set_fgcol_text(prop, val)
[fgcol_text, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_fgcol_text()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [bgcol_popup, errmsg] = set_bgcol_popup(prop, val)
[bgcol_popup, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_bgcol_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fgcol_popup, errmsg] = set_fgcol_popup(prop, val)
[fgcol_popup, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_fgcol_popup()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [bgcol_listbox, errmsg] = set_bgcol_listbox(prop, val)
[bgcol_listbox, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_bgcol_listbox()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fgcol_listbox, errmsg] = set_fgcol_listbox(prop, val)
[fgcol_listbox, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_fgcol_listbox()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [bgcol_edit, errmsg] = set_bgcol_edit(prop, val)
[bgcol_edit, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_bgcol_edit()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fgcol_edit, errmsg] = set_fgcol_edit(prop, val)
[fgcol_edit, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_fgcol_edit()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [bgcol_push, errmsg] = set_bgcol_push(prop, val)
[bgcol_push, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_bgcol_push()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fgcol_push, errmsg] = set_fgcol_push(prop, val)
[fgcol_push, errmsg] = set_gui_color(prop, val);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_fgcol_push()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [col, errmsg] = set_gui_color(prop, val)
% file_dialogクラスのcolorオブジェクトに対するsetメソッド
% 数値配列以外は受け付けない。

col = [];
errmsg = [];

if ~isnumeric(val) || ~length(val) == 3
  errmsg = sprintf('''%s'':value must be a 3 element numeric vector.',prop);
elseif min(val)<0.0 && min(val)>1.0
  errmsg = sprintf('''%s'':value out of range 0.0 <= value <= 1.0.',prop);
else
  col = val;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_gui_color()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
