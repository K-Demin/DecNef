function [this] = set_drive_info(this)
% current directory��Drive�ֹ��current_drive�����ꤷ��
% drive_info��¤�Τ򹹿����롣(Windows�Ķ��Τ�)


if ~isempty( this.private.drive_info )
  current_drive = 1;
  for ii=1:length( this.private.drive_info )
    if strncmp( upper(this.public.current_dir),...
	  this.private.drive_info(ii).drive,...
	  length(this.private.drive_info(ii).drive) )
      current_drive = ii;
      this.private.drive_info(ii).cwd = this.public.current_dir;
      break;
    end
  end
  this.private.current_drive = current_drive;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_drive_info()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
