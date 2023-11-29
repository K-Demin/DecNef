function [para] = set_dicom_info(define, para)
% function [para] = set_dicom_info(define, para)
% DICOMファイルの撮影情報を管理する構造体(gData.para.dicom_info)を設定する。
% -----------------------------------------------------------------------
% [以下の手順でDICOMファイルの撮影情報する構造体を設定する]
% 1. 実験前のDICOMファイルの出力先ディレクトリに、
%    既にDICOMファイルが '存在する' 場合
%    -> そのDICOMファイルのヘッダ情報を参照して、DICOMファイルの
%       撮影情報を設定する。 (*1)
% 2. 実験前のDICOMファイルの出力先ディレクトリに、
%    DICOMファイルが '存在しない' 場合
%    -> Template imageファイルがDICOM形式なら、このファイルの
%       ヘッダ情報 と DICOMファイルの出力先のディレクトリ名 
%       を参照してDICOMファイルの撮影情報を設定する。 (*2)
% 3. 上記の1. 2.では、DICOMファイルの撮影情報が設定できなかった場合
%    -> 患者(被検者)の名前とIDに不明値を、検査日に実験実施日を設定する。
% 
% (*1)
% DICOMファイルの出力先ディレクトリは、同じ患者(被検者)で同じ日に
% 撮影したDICOMファイルのみが出力されるので、このディレクトリの
% DICOMファイルは、全て同じ日に計測した同じ患者(被検者)のデータのはず。
% 
% (*2)
% Template imageファイルがDICOM形式なら、このファイルのヘッダ情報を
% 参照してDICOMファイルの撮影情報を設定する。ただし、Template image
% ファイルは、実験実施日より前に事前に計測されている可能性がるので、
% 検査日(測定日)の情報は、DICOMファイルの出力先のディレクトリ名から
% 獲得した情報を採用する。
% 
% [input argument]
% define : define変数を管理する構造体
% para : 実験パラメータ構造体
% 
% [output argument]
% para : 実験パラメータ構造体


DICOM_FILE_EXTENSION = define.files.DICOM_FILE_EXTENSION; % DICOM fileの拡張子


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOMファイルの出力先ディレクトリ(para.files.dicom_dir)の
% ファイル名リスト(list)検索して、DICOMファイルが見つかれば、
% そのDICOMファイルのヘッダ情報を参照して、DICOMファイルの
% 撮影情報を管理する構造体(para.dicom_info)を設定する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list = dir(para.files.dicom_dir);
flg = false;
for ii=1:length(list)
  if ~list(ii).isdir	% directoryではない
    [pathstr, name, ext] = fileparts( list(ii).name );
    if sum( strcmp(ext, DICOM_FILE_EXTENSION) ) &...
	  length( sscanf(name, '%03d_%06d_%06d') ) == 3
      % ファイル名の拡張子がDICOMファイルの拡張子と一致し
      % ファイル名の接頭部が '0詰3桁数字_0詰6桁数字_0詰6桁数字' の場合
      %   -> DICOMファイルのヘッダ情報を参照して、
      %      DICOMファイルの撮影情報を設定する。
      dicom_fname = fullfile(para.files.dicom_dir, list(ii).name);
      para.dicom_info = set_dicom_info_dicom_file(para, dicom_fname);
      flg = true;
      break;
    end
  end	% <-- End of 'if ~list(ii).isdir'
end	% <-- End of 'for ii=1:length(list)'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOMファイルの出力先directory(para.files.dicom_dir)に
% DICOMファイルが存在しなかった(flg = false)場合
%   -> Template imageファイルのヘッダ情報 と
%      DICOMファイルの出力先のディレクトリ名 
%      を参照してDICOMファイルの撮影情報を設定する。
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flg == false
  [pathstr, name, ext] = fileparts( para.files.templ_image_fname );
  if sum( strcmp(ext, DICOM_FILE_EXTENSION) ) 
    % Template imageファイルがDICOM形式の場合、
    %  -> (DICOM形式の)Template imageファイルのヘッダ情報から
    %     DICOMファイルの撮影情報を設定する。
    templ_image_fname =...
	fullfile(para.files.templ_image_dir, para.files.templ_image_fname);
    para.dicom_info = set_dicom_info_dicom_file(para, templ_image_fname);
  end
  % DICOMファイルの出力先のディレクトリ名を参照して
  % DICOMファイルの検査日(測定日)の情報を設定する。
  % ------------------------------------------------------
  % ( Template imageファイルは、実験実施日より前に、
  %   事前に計測されている場合もあるので、DICOM 
  %   ファイルの出力先のディレクトリ名から獲得した、
  %   検査日(測定日)の情報で上書きする。 )
  para.dicom_info = set_dicom_info_dicom_dir(para);
end


% 患者(被検者)の名前が未設定なら、不明値('Unknown')を設定する。
if isempty(para.dicom_info.patient_name)
  para.dicom_info.patient_name = 'Unknown';
end
% 患者(被検者)IDが未設定なら、不明値('NaN')を設定する。
if isempty(para.dicom_info.patient_id)
  para.dicom_info.patient_id = 'NaN';
end
% 検査日が未設定なら、実験実施日(YYMMDD)を設定する。
if isempty(para.dicom_info.study_date)
  para.dicom_info.study_date = datestr(now, 'yymmdd');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dicom_info()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dicom_info] = set_dicom_info_dicom_file(para, dicom_fname)
% function [dicom_info] = set_dicom_info_dicom_file(para, dicom_fname)
% DICOMファイルのヘッダ情報を参照し、DICOMファイルの撮影情報を設定する。
% 
% [input argument]
% para : 実験パラメータ構造体
% dicom_fname : DICOMファイル名
% 
% [output argument]
% dicom_info : DICOMファイルの撮影情報を管理する構造体

% DICOMファイルのヘッダ情報を獲得する。
hdr = spm_dicom_headers(dicom_fname);

% 患者(被検者)の名前の文字列を取り出す。
% --------------------------------------------------
% ( SPM8 と SPM12 でヘッダ情報構造体の変数名が異なる。 )
% SPM8  : hdr{1}.PatientsName
% SPM12 : hdr{1}.PatientName
if isfield(hdr{1}, 'PatientsName'),	patient_name = hdr{1}.PatientsName;
elseif isfield(hdr{1}, 'PatientName'),	patient_name = hdr{1}.PatientName;
end

% DICOMファイルの撮影情報を管理する構造体を設定する。
dicom_info = para.dicom_info;
dicom_info.patient_name = strtrim( patient_name );	% 患者(被検者)の名前
dicom_info.patient_id = strtrim( hdr{1}.PatientID );	% 患者(被検者)ID
dicom_info.study_date = datestr(hdr{1}.StudyDate, 'yymmdd'); % 検査日 (YYMMDD)
dicom_info.institution_name = strtrim( hdr{1}.InstitutionName ); % 施設名
dicom_info = atr_local(dicom_info);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dicom_info_dicom_file()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dicom_info] = set_dicom_info_dicom_dir(para)
% function [dicom_info] = set_dicom_info_dicom_dir(para)
% DICOMファイルの出力先のディレクトリ名を参照して
% DICOMファイルの検査日(測定日)の情報を設定する。
% --------------------------------------------------------
% 1. DICOMファイルの出力先のディレクトリ名から
%    検査実施日, 患者(被検者)の名前, 患者(被検者)ID
%    を獲得する。
% 2. DICOMファイルの出力先のディレクトリ名から獲得した
%    患者(被検者)の名前、患者(被検者)ID と
%    DICOMファイルの撮影情報を管理する構造体(para.dicom_info)
%    の 患者(被検者)の名前、患者(被検者)ID が一致する場合、
%    DICOMファイルの出力先のディレクトリ名から獲得した
%    検査実施日 で、DICOMファイルの撮影情報を管理する構造体
%    の 検査実施日 を更新する。
% 
% [input argument]
% para : 実験パラメータ構造体
% 
% [output argument]
% dicom_info : DICOMファイルの撮影情報を管理する構造体

% DICOMファイルの撮影情報を管理する構造体を獲得する。
dicom_info = para.dicom_info;


% DICOMファイルの出力先のディレクトリ名(Full path)から、
% 最終階層のディレクトリ名の文字列を取り出す。
% --------------------------------------------------------
% DICOMファイルの出力先のディレクトリ名が 
% 'C:\Users\DATA\realtime\20160308.Tanaka.AT' 
% の場合、 '20160308.Tanaka.AT' を取り出す。
dicom_dir = para.files.dicom_dir;
p = findstr(para.files.dicom_dir, filesep);
if length(p),	dicom_dir = para.files.dicom_dir(p(end)+1:end);
end


p = findstr(dicom_dir, '.');	% フィールド間の接続文字('.')を検索する。

if length(p) == 2 & min(p) > 1 & max(p) < length(dicom_dir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DICOMファイルの出力先のディレクトリ名の文字列(dicom_dir)に
  % フィールド間の接続文字('.')が2カ所含まれており、フィールド間
  % の接続文字の設置場所が、ディレクトリ名の文字列の先頭位置と
  % 最終位置ではない。(3つのフィールド文字列に分類可能)
  % ----------------------------------------------------------------
  % 第1フィールド文字列 : 検査実施日
  % 第2フィールド文字列 : 患者(被検者)の名前
  % 第3フィールド文字列 : 患者(被検者)ID
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  study_date = dicom_dir(1:p(1)-1);		% 検査実施日 (第1文字列)
  patient_name = dicom_dir(p(1)+1:p(2)-1);	% 患者(被検者)名前 (第2文字列)
  patient_id = dicom_dir(p(2)+1:end);		% 患者(被検者)ID (第3文字列)
  
  len = length(study_date);
  if length( find(study_date>='0' & study_date<='9') ) == len &...
	(len == 6 | len == 8)
    % 検査実施日の文字列(study_date)が全て数値文字 で
    % 検査実施日の文字列の文字数が6文字か8文字の場合
    %   -> 検査実施日(YYMMDD)を獲得する。
    if len == 8
      study_date = study_date(3:end);	% 8文字(YYYYMMDD) -> 6文字(YYMMDD)
    end
    dir_info = para.dicom_info;
    dir_info.patient_name = patient_name;	% 患者(被検者)の名前
    dir_info.patient_id = patient_id;		% 患者(被検者)ID
    dir_info.study_date = study_date;		% 検査日 (YYMMDD)
    dir_info = atr_local(dir_info);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DICOMファイルの撮影情報を管理する構造体(dicom_info) を更新する。
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(dicom_info.patient_name) &...
	  isempty(dicom_info.patient_id) &...
	  isempty(dicom_info.study_date)
      % DICOMファイルの撮影情報を管理する構造体(dicom_info) の
      % 患者(被検者)の名前 と 患者(被検者)ID と 検査実施日 が
      % 設定されていない場合、
      % DICOMファイルの撮影情報を管理する構造体(dir_info) で
      % DICOMファイルの撮影情報を管理する構造体(dicom_info) を
      % 更新する。
      dicom_info = dir_info;
    elseif strcmp(dicom_info.patient_name, dir_info.patient_name) &...
	  strcmp(dicom_info.patient_id, dir_info.patient_id)
      % DICOMファイルの撮影情報を管理する構造体(dicom_info) と
      % DICOMファイルの出力先のディレクトリ名から設定した
      % 撮影情報を管理する構造体(dir_info) の
      % 患者(被検者)の名前 と 患者(被検者)ID が一致する場合
      % DICOMファイルの出力先のディレクトリ名から獲得した
      % 検査実施日(dir_info.study_date)で、DICOMファイルの
      % 撮影情報を管理する構造体の検査実施日(dicom_info.study_date)
      % を更新する。
      dicom_info.study_date = dir_info.study_date;	% 検査日 (YYMMDD)
    end
  end	% <-- End of 'if length( find(study_date>='0' & study_date<='9') )...'
end	% <-- End of 'if length(p) == 2 & min(p) > 1 & ...'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dicom_info_dicom_dir() ' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dicom_info] = atr_local(dicom_info)
% function [dicom_info] = atr_local(dicom_info)
% DICOMファイルの撮影情報を管理する構造体(dicom_info)の
% 患者(被検者)の名前(dicom_info.patient_name) と
% 患者(被検者)ID(dicom_info.patient_id) に
% 検査(撮影)実施日の情報が含まれている場合、
% それを取り除く。
% 
% (*)
% ATRのfMRI装置で計測したDICOMファイルの場合、
% 患者(被検者)の名前 と 患者(被検者)ID に
% 検査(撮影)実施日の情報が含まれているので、
% それを取り除く。
% dicom_info.patient_name     = '160308_Tanaka' -> 'Tanaka''
% dicom_info.patient_id       = 'AT160308'      -> 'AT'
% dicom_info.study_date       = '160308'
% dicom_info.institution_name = 'ATR-BAIC'
% 
% [input argument]
% dicom_info : DICOMファイルの撮影情報を管理する構造体
% 
% [output argument]
% dicom_info : DICOMファイルの撮影情報を管理する構造体

study_date = dicom_info.study_date;	% 検査(撮影)実施日 (文字列:YYMMDD)

% 患者(被検者)の名前(dicom_info.patient_name)に、
% 検査(撮影)実施日の文字列('YYMMDD_')が含まれている場合、
% それを取り除く。
p = findstr(dicom_info.patient_name, sprintf('%s_', study_date));
for ii=length(p):-1:1
  dicom_info.patient_name(p(ii):p(ii)+length(study_date)) = '';
end
% 患者(被検者)ID(dicom_info.patient_id)に、
% 検査(撮影)実施日の文字列('YYMMDD')が含まれている場合、
% それを取り除く。
p = findstr(dicom_info.patient_id, study_date);
for ii=length(p):-1:1
  dicom_info.patient_id(p(ii):p(ii)+length(study_date)-1) = '';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function atr_local()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
