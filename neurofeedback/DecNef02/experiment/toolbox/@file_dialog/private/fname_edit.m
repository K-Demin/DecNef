function [] = fname_edit(obj, eventdata, dialog)
% ファイル名を入力するedit textのCallback関数
% この関数はpublic.save_mode = trueの時のみ有効 
% public.save_mode = falseの時はなにもしない。

this = get(dialog, 'UserData');


if this.public.save_mode
  fname = deblank( get(obj, 'String') );
  current_extension = get(this.private.gui_handles.extension_popup, 'Value');
  file_extension = this.public.file_extensions{current_extension};
  
  this.private.current_file = {};
  if ~isempty(fname)
    % 拡張子をチェックする。
    flg = 1;
    if strcmp(file_extension, '.*') || strcmp(file_extension, '*')
      flg = 0;	% ワイルドカード(拡張子のチェック不要)
    else
      if length(fname) > length(file_extension)
	tmp = length(fname) - length(file_extension) + 1;
	if strcmp(fname(tmp:length(fname)), file_extension)
	  flg = 0;	% 拡張子がfile_extensionと一致した。
	end
      end
    end
    % 入力ファイル名に拡張子を追加する。
    if flg == 1,	fname = [fname, file_extension];	end
    
    this.private.current_file{1} = fname;
  end		% <-- end of 'if length(fname)'
end

% DialogのGUIのpropertyを更新する。
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function fname_edit()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
