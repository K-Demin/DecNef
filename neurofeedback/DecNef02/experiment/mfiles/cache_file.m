function [cache_data] = cache_file(save_mode)
% function [cache_data] = cache_file(save_mode)
% Cache fileを操作する。
% 
% [input argument]
% save_mode : Save(true)/Load(false)
% 
% [output argument]
% cache_data : Cache data構造体
if save_mode,	cache_data = save_cache_data();
else		cache_data = load_cache_data();
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cache_file()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cache_data] = save_cache_data()
% function [cache_data] = save_cache_data()
% Cache fileにCache dataを出力する。
% 
% [output argument]
% cache_data : Cache data構造体

global gData

% Cache fileにCache dataを出力する。
cache_fname =...
    fullfile(gData.para.files.current_dir, gData.define.default.CACHE_FNAME);
fd = fopen(cache_fname, 'w');
if fd == -1
  error( sprintf('FOPEN cannot open the file(%s)', cache_fname) );
end

% Block番号を出力する。
fprintf(fd, 'current_block = %d\n', gData.para.current_block);
% Save name( '患者(被検者)名前_検査(撮影)実施日' )をを出力する。
fprintf(fd, 'save_name = %s\n', gData.para.save_name);
% 被検者ID( '患者(被検者)名前_患者(被検者)ID' )を出力する。
fprintf(fd, 'exp_id = %s\n', gData.para.exp_id);
% 実験(撮影)実施日(YYMMDD)を出力する。
fprintf(fd, 'exp_date = %s\n', gData.para.exp_date);

% 実験プロジェクトコードを出力する。
fprintf(fd, 'decnef_project = %d\n', gData.version.decnef.project);
% 実験プロジェクトのリリース情報を出力する。
fprintf(fd, 'decnef_release = %d\n', gData.version.decnef.release);
% MATLABバージョンを出力する。
fprintf(fd, 'matlab_version = %s\n', gData.version.matlab.version);
% MATLABのリリース情報を出力する。
fprintf(fd, 'matlab_release = %s\n', gData.version.matlab.release);
% SPMバージョンを出力する。
fprintf(fd, 'spm_version = %s\n', gData.version.spm.version);
% SPMのリリース番号を出力する。
fprintf(fd, 'spm_release = %d\n', gData.version.spm.release);

% receiverプログラム数を出力する。
fprintf(fd, 'receiver_num = %d\n', gData.para.receiver_num);
% 通信経路(msocket)のTCP/IP port番号を出力する。
for ii=1:length(gData.para.msocket.port)
  fprintf(fd, 'msocket_port[%d] = %d\n', ii, gData.para.msocket.port(ii));
end
% msocket serverのhost名を出力する。
fprintf(fd, 'msocket_server_name = %s\n', gData.para.msocket.server_name);

% 以下の変数はdummy_scanプログラム用に保存する。
fprintf(fd, 'dicom_dir = %s\n', gData.para.files.dicom_dir);
fprintf(fd, 'total_scan_num = %d\n', gData.para.scans.total_scan_num);
fprintf(fd, 'TR = %f [sec]\n', gData.para.scans.TR);

fclose(fd);

% Cache data構造体を作成する。
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

% cache fileが確実に保存されるまで1秒間待つ
pause(1.0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function save_cache_data()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [cache_data] = load_cache_data()
% function [cache_data] = load_cache_data()
% Cache fileからCache dataを読み込む。
% 
% [output argument]
% cache_data : Cache data構造体

global gData

% cache fileが確実に保存されるまで1秒間待つ
pause(1.0);

cache_fname =...
    fullfile(gData.para.files.current_dir, gData.define.default.CACHE_FNAME);
fd = fopen(cache_fname, 'r');
if fd == -1
  error( sprintf('FOPEN cannot open the file(%s)', cache_fname) );
end

% Cache fileからCache dataを読み込む。
cache_data = [];
if fd ~= -1	% Cache fileが存在する
  while(true)
    str = fgets(fd);
    if str == -1, break;	% End of file
    else
      % Block番号
      tmp = sscanf(str, 'current_block = %d');
      if ~isempty(tmp),	cache_data.current_block = tmp;	end
      % Save name( '患者(被検者)名前_検査(撮影)実施日' )
      tmp = sscanf(str, 'save_name = %s');
      if ~isempty(tmp),	cache_data.save_name = tmp;	end
      % 被検者ID( '患者(被検者)名前_患者(被検者)ID' )
      tmp = sscanf(str, 'exp_id = %s');
      if ~isempty(tmp),	cache_data.exp_id = tmp;	end
      % 実験(撮影)実施日(YYMMDD)
      tmp = sscanf(str, 'exp_date = %s');
      if ~isempty(tmp),	cache_data.exp_date = tmp;	end

      % 実験プロジェクトコード
      tmp = sscanf(str, 'decnef_project = %d');
      if ~isempty(tmp),	cache_data.decnef_project = tmp;	end
      % 実験プロジェクトのリリース情報
      tmp = sscanf(str, 'decnef_release = %d');
      if ~isempty(tmp),	cache_data.decnef_release = tmp;	end
      % MATLABバージョン
      tmp = sscanf(str, 'matlab_version = %s');
      if ~isempty(tmp),	cache_data.matlab_version = tmp;	end
      % MATLABのリリース情報
      tmp = sscanf(str, 'matlab_release = %s');
      if ~isempty(tmp),	cache_data.matlab_release = tmp;	end
      % SPMバージョン
      tmp = sscanf(str, 'spm_version = %s');
      if ~isempty(tmp),	cache_data.spm_version = tmp;	end
      % SPMのリリース番号
      tmp = sscanf(str, 'spm_release = %d');
      if ~isempty(tmp),	cache_data.spm_release = tmp;	end
      
      % receiverプログラム数
      tmp = sscanf(str, 'receiver_num = %d');
      if ~isempty(tmp),	cache_data.receiver_num = tmp;	end
      % 通信経路(msocket)のTCP/IP port番号
      tmp = sscanf(str, 'msocket_port[%d] = %d');
      if length(tmp)==2,
	cache_data.msocket_port(tmp(1),1) = tmp(2);
      end
      % msocket serverのhost名
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
