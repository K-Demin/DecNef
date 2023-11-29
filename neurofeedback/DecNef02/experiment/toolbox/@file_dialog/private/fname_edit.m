function [] = fname_edit(obj, eventdata, dialog)
% �ե�����̾�����Ϥ���edit text��Callback�ؿ�
% ���δؿ���public.save_mode = true�λ��Τ�ͭ�� 
% public.save_mode = false�λ��Ϥʤˤ⤷�ʤ���

this = get(dialog, 'UserData');


if this.public.save_mode
  fname = deblank( get(obj, 'String') );
  current_extension = get(this.private.gui_handles.extension_popup, 'Value');
  file_extension = this.public.file_extensions{current_extension};
  
  this.private.current_file = {};
  if ~isempty(fname)
    % ��ĥ�Ҥ�����å����롣
    flg = 1;
    if strcmp(file_extension, '.*') || strcmp(file_extension, '*')
      flg = 0;	% �磻��ɥ�����(��ĥ�ҤΥ����å�����)
    else
      if length(fname) > length(file_extension)
	tmp = length(fname) - length(file_extension) + 1;
	if strcmp(fname(tmp:length(fname)), file_extension)
	  flg = 0;	% ��ĥ�Ҥ�file_extension�Ȱ��פ�����
	end
      end
    end
    % ���ϥե�����̾�˳�ĥ�Ҥ��ɲä��롣
    if flg == 1,	fname = [fname, file_extension];	end
    
    this.private.current_file{1} = fname;
  end		% <-- end of 'if length(fname)'
end

% Dialog��GUI��property�򹹿����롣
set(dialog, 'UserData', this);
set_gui_property(dialog);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function fname_edit()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
