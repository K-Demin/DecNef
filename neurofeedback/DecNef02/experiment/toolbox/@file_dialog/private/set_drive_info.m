function [this] = set_drive_info(this)
% current directoryのDrive番号をcurrent_driveに設定し、
% drive_info構造体を更新する。(Windows環境のみ)


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
