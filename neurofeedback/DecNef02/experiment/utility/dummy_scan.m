save_dir = '..';
cache_fname = 'cache.txt';

cache_fname = fullfile(save_dir, cache_fname);
fd = fopen(cache_fname, 'r');
if fd ~= -1
  while(true)
    str = fgets(fd);
    if str == -1, break;	% End of file
    else
      tmp = sscanf(str, 'current_block = %d');
      if ~isempty(tmp),	current_block = tmp;	end
      tmp = sscanf(str, 'save_name = %s');
      if ~isempty(tmp),	save_name = tmp;	end
      tmp = sscanf(str, 'exp_id = %s');
      if ~isempty(tmp),	exp_id = tmp;	end
      tmp = sscanf(str, 'exp_date = %s');
      if ~isempty(tmp),	exp_date = tmp;	end
      tmp = sscanf(str, 'dicom_dir = %s');
      if ~isempty(tmp),	dicom_dir = tmp;	end
      tmp = sscanf(str, 'total_scan_num = %d');
      if ~isempty(tmp),	total_scan_num = tmp;	end
    end	% <-- End of 'if str == -1, ... else ...'
  end	% <-- End of 'while(true)'
  fclose(fd);
end	% <-- End of 'if fd ~= -1'


dummy_scan_dir = fullfile(dicom_dir, 'DUMMY');
if exist(dummy_scan_dir, 'dir') ~= 7, 	mkdir(dummy_scan_dir);
end

dicom_fnameB = sprintf('001_0000%02d', current_block); 

fprintf('dicom_dir = %s\n',dicom_dir);
fprintf('total_scan_num = %d\n', total_scan_num);
fprintf('We are earnestly making all necessary arrangements. ... ');

for scan=1:total_scan_num
  % DICOMファイル名
  dicom_fname = sprintf('%s_%06d.dcm', dicom_fnameB, scan);
  dicom_file_name = fullfile(dicom_dir, dicom_fname);
  if isunix
    unix( sprintf('mv %s %s', dicom_file_name, dummy_scan_dir) );
  else
    dos( sprintf('move %s %s', dicom_file_name, dummy_scan_dir) );
  end
end
fprintf('It is all done.\n');

scan_t = [1.8, 2.4];
dtime = scan_t(1) + (scan_t(2)-scan_t(1)).*rand(total_scan_num,1);

R = input('Waiting for DUMMY trigger... : ');

t = tic;
time = 0;
for scan=1:total_scan_num
  % DICOMファイル名
  dicom_fname = sprintf('%s_%06d.dcm', dicom_fnameB, scan);
  dicom_file_name = fullfile(dummy_scan_dir, dicom_fname);
  
  time = time+dtime(scan);
  while toc(t) < time; end;
  if isunix
    unix( sprintf('mv %s %s', dicom_file_name, dicom_dir) );
  else
    dos( sprintf('move %s %s', dicom_file_name, dicom_dir) );
  end
  fprintf('scan%3d (''%s'') : time=%8.3f dtime=%6.3f (sec)\n',...
      scan, dicom_fname, time, dtime(scan));
end

