function [cache_data] = cache_file(save_mode)
% function [cache_data] = cache_file(save_mode)
% Cache file�𑀍삷��B
% 
% [input argument]
% save_mode : Save(true)/Load(false)
% 
% [output argument]
% cache_data : Cache data�\����
if save_mode,	cache_data = save_cache_data();
else		cache_data = load_cache_data();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cache_file()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cache_data] = save_cache_data()
% function [cache_data] = save_cache_data()
% Cache file��Cache data���o�͂���B
% 
% [output argument]
% cache_data : Cache data�\����

global gData

% Cache file��Cache data���o�͂���B
cache_fname =...
    fullfile(gData.para.files.current_dir, gData.define.default.CACHE_FNAME);
fd = fopen(cache_fname, 'w');
if fd == -1
  error( sprintf('FOPEN cannot open the file(%s)', cache_fname) );
end

% Block�ԍ����o�͂���B
fprintf(fd, 'current_block = %d\n', gData.para.current_block);
% Save name( '����(�팟��)���O_����(�B�e)���{��' )�����o�͂���B
fprintf(fd, 'save_name = %s\n', gData.para.save_name);
% �팟��ID( '����(�팟��)���O_����(�팟��)ID' )���o�͂���B
fprintf(fd, 'exp_id = %s\n', gData.para.exp_id);
% ����(�B�e)���{��(YYMMDD)���o�͂���B
fprintf(fd, 'exp_date = %s\n', gData.para.exp_date);

% �����v���W�F�N�g�R�[�h���o�͂���B
fprintf(fd, 'decnef_project = %d\n', gData.version.decnef.project);
% �����v���W�F�N�g�̃����[�X�����o�͂���B
fprintf(fd, 'decnef_release = %d\n', gData.version.decnef.release);
% MATLAB�o�[�W�������o�͂���B
fprintf(fd, 'matlab_version = %s\n', gData.version.matlab.version);
% MATLAB�̃����[�X�����o�͂���B
fprintf(fd, 'matlab_release = %s\n', gData.version.matlab.release);
% SPM�o�[�W�������o�͂���B
fprintf(fd, 'spm_version = %s\n', gData.version.spm.version);
% SPM�̃����[�X�ԍ����o�͂���B
fprintf(fd, 'spm_release = %d\n', gData.version.spm.release);

% receiver�v���O���������o�͂���B
fprintf(fd, 'receiver_num = %d\n', gData.para.receiver_num);
% �ʐM�o�H(msocket)��TCP/IP port�ԍ����o�͂���B
for ii=1:length(gData.para.msocket.port)
  fprintf(fd, 'msocket_port[%d] = %d\n', ii, gData.para.msocket.port(ii));
end
% msocket server��host�����o�͂���B
fprintf(fd, 'msocket_server_name = %s\n', gData.para.msocket.server_name);

% �ȉ��̕ϐ���dummy_scan�v���O�����p�ɕۑ�����B
fprintf(fd, 'dicom_dir = %s\n', gData.para.files.dicom_dir);
fprintf(fd, 'total_scan_num = %d\n', gData.para.scans.total_scan_num);
fprintf(fd, 'TR = %f [sec]\n', gData.para.scans.TR);

fclose(fd);

% Cache data�\���̂��쐬����B
cache_data = struct(...
    'current_block', gData.para.current_block,...
    'save_name', gData.para.save_name,...
    'exp_id', gData.para.exp_id,...
    'exp_date', gData.para.exp_date,...
    'decnef_project', gData.version.decnef.project,...
    'decnef_release', gData.version.decnef.release,...
    'matlab_version', gData.version.matlab.version,...
    'matlab_release', gData.version.matlab.release,...
    'spm_version', gData.version.spm.version,...
    'spm_release', gData.version.spm.release,...
    'receiver_num', gData.para.receiver_num,...
    'msocket_port', gData.para.msocket.port,...
    'msocket_server_name', gData.para.msocket.server_name,...
    'dicom_dir', gData.para.files.dicom_dir,...
    'total_scan_num', gData.para.scans.total_scan_num...
    );

% cache file���m���ɕۑ������܂�1�b�ԑ҂�
pause(1.0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_cache_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [cache_data] = load_cache_data()
% function [cache_data] = load_cache_data()
% Cache file����Cache data��ǂݍ��ށB
% 
% [output argument]
% cache_data : Cache data�\����

global gData

% cache file���m���ɕۑ������܂�1�b�ԑ҂�
pause(1.0);

cache_fname =...
    fullfile(gData.para.files.current_dir, gData.define.default.CACHE_FNAME);
fd = fopen(cache_fname, 'r');
if fd == -1
  error( sprintf('FOPEN cannot open the file(%s)', cache_fname) );
end

% Cache file����Cache data��ǂݍ��ށB
cache_data = [];
if fd ~= -1	% Cache file�����݂���
  while(true)
    str = fgets(fd);
    if str == -1, break;	% End of file
    else
      % Block�ԍ�
      tmp = sscanf(str, 'current_block = %d');
      if ~isempty(tmp),	cache_data.current_block = tmp;	end
      % Save name( '����(�팟��)���O_����(�B�e)���{��' )
      tmp = sscanf(str, 'save_name = %s');
      if ~isempty(tmp),	cache_data.save_name = tmp;	end
      % �팟��ID( '����(�팟��)���O_����(�팟��)ID' )
      tmp = sscanf(str, 'exp_id = %s');
      if ~isempty(tmp),	cache_data.exp_id = tmp;	end
      % ����(�B�e)���{��(YYMMDD)
      tmp = sscanf(str, 'exp_date = %s');
      if ~isempty(tmp),	cache_data.exp_date = tmp;	end

      % �����v���W�F�N�g�R�[�h
      tmp = sscanf(str, 'decnef_project = %d');
      if ~isempty(tmp),	cache_data.decnef_project = tmp;	end
      % �����v���W�F�N�g�̃����[�X���
      tmp = sscanf(str, 'decnef_release = %d');
      if ~isempty(tmp),	cache_data.decnef_release = tmp;	end
      % MATLAB�o�[�W����
      tmp = sscanf(str, 'matlab_version = %s');
      if ~isempty(tmp),	cache_data.matlab_version = tmp;	end
      % MATLAB�̃����[�X���
      tmp = sscanf(str, 'matlab_release = %s');
      if ~isempty(tmp),	cache_data.matlab_release = tmp;	end
      % SPM�o�[�W����
      tmp = sscanf(str, 'spm_version = %s');
      if ~isempty(tmp),	cache_data.spm_version = tmp;	end
      % SPM�̃����[�X�ԍ�
      tmp = sscanf(str, 'spm_release = %d');
      if ~isempty(tmp),	cache_data.spm_release = tmp;	end
      
      % receiver�v���O������
      tmp = sscanf(str, 'receiver_num = %d');
      if ~isempty(tmp),	cache_data.receiver_num = tmp;	end
      % �ʐM�o�H(msocket)��TCP/IP port�ԍ�
      tmp = sscanf(str, 'msocket_port[%d] = %d');
      if length(tmp)==2,
	cache_data.msocket_port(tmp(1),1) = tmp(2);
      end
      % msocket server��host��
      tmp = sscanf(str, 'msocket_server_name = %s');
      if ~isempty(tmp),	cache_data.msocket_server_name = tmp;	end
      
      tmp = sscanf(str, 'dicom_dir = %s');
      if ~isempty(tmp),	cache_data.dicom_dir = tmp;	end
      tmp = sscanf(str, 'total_scan_num = %d');
      if ~isempty(tmp),	cache_data.total_scan_num = tmp;	end
      tmp = sscanf(str, 'TR = %f');
      if ~isempty(tmp),	cache_data.TR = tmp;	end
    end	% <-- End of 'if str == -1, ... else ...'
  end	% <-- End of 'while(true)'
  fclose(fd);
end	% <-- End of 'if fd ~= -1'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function load_cache_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
