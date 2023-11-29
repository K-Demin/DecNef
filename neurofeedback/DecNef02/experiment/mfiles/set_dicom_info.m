function [para] = set_dicom_info(define, para)
% function [para] = set_dicom_info(define, para)
% DICOM�t�@�C���̎B�e�����Ǘ�����\����(gData.para.dicom_info)��ݒ肷��B
% -----------------------------------------------------------------------
% [�ȉ��̎菇��DICOM�t�@�C���̎B�e��񂷂�\���̂�ݒ肷��]
% 1. �����O��DICOM�t�@�C���̏o�͐�f�B���N�g���ɁA
%    ����DICOM�t�@�C���� '���݂���' �ꍇ
%    -> ����DICOM�t�@�C���̃w�b�_�����Q�Ƃ��āADICOM�t�@�C����
%       �B�e����ݒ肷��B (*1)
% 2. �����O��DICOM�t�@�C���̏o�͐�f�B���N�g���ɁA
%    DICOM�t�@�C���� '���݂��Ȃ�' �ꍇ
%    -> Template image�t�@�C����DICOM�`���Ȃ�A���̃t�@�C����
%       �w�b�_��� �� DICOM�t�@�C���̏o�͐�̃f�B���N�g���� 
%       ���Q�Ƃ���DICOM�t�@�C���̎B�e����ݒ肷��B (*2)
% 3. ��L��1. 2.�ł́ADICOM�t�@�C���̎B�e��񂪐ݒ�ł��Ȃ������ꍇ
%    -> ����(�팟��)�̖��O��ID�ɕs���l���A�������Ɏ������{����ݒ肷��B
% 
% (*1)
% DICOM�t�@�C���̏o�͐�f�B���N�g���́A��������(�팟��)�œ�������
% �B�e����DICOM�t�@�C���݂̂��o�͂����̂ŁA���̃f�B���N�g����
% DICOM�t�@�C���́A�S�ē������Ɍv��������������(�팟��)�̃f�[�^�̂͂��B
% 
% (*2)
% Template image�t�@�C����DICOM�`���Ȃ�A���̃t�@�C���̃w�b�_����
% �Q�Ƃ���DICOM�t�@�C���̎B�e����ݒ肷��B�������ATemplate image
% �t�@�C���́A�������{�����O�Ɏ��O�Ɍv������Ă���\������̂ŁA
% ������(�����)�̏��́ADICOM�t�@�C���̏o�͐�̃f�B���N�g��������
% �l�����������̗p����B
% 
% [input argument]
% define : define�ϐ����Ǘ�����\����
% para : �����p�����[�^�\����
% 
% [output argument]
% para : �����p�����[�^�\����


DICOM_FILE_EXTENSION = define.files.DICOM_FILE_EXTENSION; % DICOM file�̊g���q


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOM�t�@�C���̏o�͐�f�B���N�g��(para.files.dicom_dir)��
% �t�@�C�������X�g(list)�������āADICOM�t�@�C����������΁A
% ����DICOM�t�@�C���̃w�b�_�����Q�Ƃ��āADICOM�t�@�C����
% �B�e�����Ǘ�����\����(para.dicom_info)��ݒ肷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
list = dir(para.files.dicom_dir);
flg = false;
for ii=1:length(list)
  if ~list(ii).isdir	% directory�ł͂Ȃ�
    [pathstr, name, ext] = fileparts( list(ii).name );
    if sum( strcmp(ext, DICOM_FILE_EXTENSION) ) &...
	  length( sscanf(name, '%03d_%06d_%06d') ) == 3
      % �t�@�C�����̊g���q��DICOM�t�@�C���̊g���q�ƈ�v��
      % �t�@�C�����̐ړ����� '0�l3������_0�l6������_0�l6������' �̏ꍇ
      %   -> DICOM�t�@�C���̃w�b�_�����Q�Ƃ��āA
      %      DICOM�t�@�C���̎B�e����ݒ肷��B
      dicom_fname = fullfile(para.files.dicom_dir, list(ii).name);
      para.dicom_info = set_dicom_info_dicom_file(para, dicom_fname);
      flg = true;
      break;
    end
  end	% <-- End of 'if ~list(ii).isdir'
end	% <-- End of 'for ii=1:length(list)'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DICOM�t�@�C���̏o�͐�directory(para.files.dicom_dir)��
% DICOM�t�@�C�������݂��Ȃ�����(flg = false)�ꍇ
%   -> Template image�t�@�C���̃w�b�_��� ��
%      DICOM�t�@�C���̏o�͐�̃f�B���N�g���� 
%      ���Q�Ƃ���DICOM�t�@�C���̎B�e����ݒ肷��B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flg == false
  [pathstr, name, ext] = fileparts( para.files.templ_image_fname );
  if sum( strcmp(ext, DICOM_FILE_EXTENSION) ) 
    % Template image�t�@�C����DICOM�`���̏ꍇ�A
    %  -> (DICOM�`����)Template image�t�@�C���̃w�b�_��񂩂�
    %     DICOM�t�@�C���̎B�e����ݒ肷��B
    templ_image_fname =...
	fullfile(para.files.templ_image_dir, para.files.templ_image_fname);
    para.dicom_info = set_dicom_info_dicom_file(para, templ_image_fname);
  end
  % DICOM�t�@�C���̏o�͐�̃f�B���N�g�������Q�Ƃ���
  % DICOM�t�@�C���̌�����(�����)�̏���ݒ肷��B
  % ------------------------------------------------------
  % ( Template image�t�@�C���́A�������{�����O�ɁA
  %   ���O�Ɍv������Ă���ꍇ������̂ŁADICOM 
  %   �t�@�C���̏o�͐�̃f�B���N�g��������l�������A
  %   ������(�����)�̏��ŏ㏑������B )
  para.dicom_info = set_dicom_info_dicom_dir(para);
end


% ����(�팟��)�̖��O�����ݒ�Ȃ�A�s���l('Unknown')��ݒ肷��B
if isempty(para.dicom_info.patient_name)
  para.dicom_info.patient_name = 'Unknown';
end
% ����(�팟��)ID�����ݒ�Ȃ�A�s���l('NaN')��ݒ肷��B
if isempty(para.dicom_info.patient_id)
  para.dicom_info.patient_id = 'NaN';
end
% �����������ݒ�Ȃ�A�������{��(YYMMDD)��ݒ肷��B
if isempty(para.dicom_info.study_date)
  para.dicom_info.study_date = datestr(now, 'yymmdd');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dicom_info()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dicom_info] = set_dicom_info_dicom_file(para, dicom_fname)
% function [dicom_info] = set_dicom_info_dicom_file(para, dicom_fname)
% DICOM�t�@�C���̃w�b�_�����Q�Ƃ��ADICOM�t�@�C���̎B�e����ݒ肷��B
% 
% [input argument]
% para : �����p�����[�^�\����
% dicom_fname : DICOM�t�@�C����
% 
% [output argument]
% dicom_info : DICOM�t�@�C���̎B�e�����Ǘ�����\����

% DICOM�t�@�C���̃w�b�_�����l������B
hdr = spm_dicom_headers(dicom_fname);

% ����(�팟��)�̖��O�̕���������o���B
% --------------------------------------------------
% ( SPM8 �� SPM12 �Ńw�b�_���\���̂̕ϐ������قȂ�B )
% SPM8  : hdr{1}.PatientsName
% SPM12 : hdr{1}.PatientName
if isfield(hdr{1}, 'PatientsName'),	patient_name = hdr{1}.PatientsName;
elseif isfield(hdr{1}, 'PatientName'),	patient_name = hdr{1}.PatientName;
end

% DICOM�t�@�C���̎B�e�����Ǘ�����\���̂�ݒ肷��B
dicom_info = para.dicom_info;
dicom_info.patient_name = strtrim( patient_name );	% ����(�팟��)�̖��O
dicom_info.patient_id = strtrim( hdr{1}.PatientID );	% ����(�팟��)ID
dicom_info.study_date = datestr(hdr{1}.StudyDate, 'yymmdd'); % ������ (YYMMDD)
dicom_info.institution_name = strtrim( hdr{1}.InstitutionName ); % �{�ݖ�
dicom_info = atr_local(dicom_info);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dicom_info_dicom_file()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dicom_info] = set_dicom_info_dicom_dir(para)
% function [dicom_info] = set_dicom_info_dicom_dir(para)
% DICOM�t�@�C���̏o�͐�̃f�B���N�g�������Q�Ƃ���
% DICOM�t�@�C���̌�����(�����)�̏���ݒ肷��B
% --------------------------------------------------------
% 1. DICOM�t�@�C���̏o�͐�̃f�B���N�g��������
%    �������{��, ����(�팟��)�̖��O, ����(�팟��)ID
%    ���l������B
% 2. DICOM�t�@�C���̏o�͐�̃f�B���N�g��������l������
%    ����(�팟��)�̖��O�A����(�팟��)ID ��
%    DICOM�t�@�C���̎B�e�����Ǘ�����\����(para.dicom_info)
%    �� ����(�팟��)�̖��O�A����(�팟��)ID ����v����ꍇ�A
%    DICOM�t�@�C���̏o�͐�̃f�B���N�g��������l������
%    �������{�� �ŁADICOM�t�@�C���̎B�e�����Ǘ�����\����
%    �� �������{�� ���X�V����B
% 
% [input argument]
% para : �����p�����[�^�\����
% 
% [output argument]
% dicom_info : DICOM�t�@�C���̎B�e�����Ǘ�����\����

% DICOM�t�@�C���̎B�e�����Ǘ�����\���̂��l������B
dicom_info = para.dicom_info;


% DICOM�t�@�C���̏o�͐�̃f�B���N�g����(Full path)����A
% �ŏI�K�w�̃f�B���N�g�����̕���������o���B
% --------------------------------------------------------
% DICOM�t�@�C���̏o�͐�̃f�B���N�g������ 
% 'C:\Users\DATA\realtime\20160308.Tanaka.AT' 
% �̏ꍇ�A '20160308.Tanaka.AT' �����o���B
dicom_dir = para.files.dicom_dir;
p = findstr(para.files.dicom_dir, filesep);
if length(p),	dicom_dir = para.files.dicom_dir(p(end)+1:end);
end


p = findstr(dicom_dir, '.');	% �t�B�[���h�Ԃ̐ڑ�����('.')����������B

if length(p) == 2 & min(p) > 1 & max(p) < length(dicom_dir)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % DICOM�t�@�C���̏o�͐�̃f�B���N�g�����̕�����(dicom_dir)��
  % �t�B�[���h�Ԃ̐ڑ�����('.')��2�J���܂܂�Ă���A�t�B�[���h��
  % �̐ڑ������̐ݒu�ꏊ���A�f�B���N�g�����̕�����̐擪�ʒu��
  % �ŏI�ʒu�ł͂Ȃ��B(3�̃t�B�[���h������ɕ��މ\)
  % ----------------------------------------------------------------
  % ��1�t�B�[���h������ : �������{��
  % ��2�t�B�[���h������ : ����(�팟��)�̖��O
  % ��3�t�B�[���h������ : ����(�팟��)ID
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  study_date = dicom_dir(1:p(1)-1);		% �������{�� (��1������)
  patient_name = dicom_dir(p(1)+1:p(2)-1);	% ����(�팟��)���O (��2������)
  patient_id = dicom_dir(p(2)+1:end);		% ����(�팟��)ID (��3������)
  
  len = length(study_date);
  if length( find(study_date>='0' & study_date<='9') ) == len &...
	(len == 6 | len == 8)
    % �������{���̕�����(study_date)���S�Đ��l���� ��
    % �������{���̕�����̕�������6������8�����̏ꍇ
    %   -> �������{��(YYMMDD)���l������B
    if len == 8
      study_date = study_date(3:end);	% 8����(YYYYMMDD) -> 6����(YYMMDD)
    end
    dir_info = para.dicom_info;
    dir_info.patient_name = patient_name;	% ����(�팟��)�̖��O
    dir_info.patient_id = patient_id;		% ����(�팟��)ID
    dir_info.study_date = study_date;		% ������ (YYMMDD)
    dir_info = atr_local(dir_info);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % DICOM�t�@�C���̎B�e�����Ǘ�����\����(dicom_info) ���X�V����B
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(dicom_info.patient_name) &...
	  isempty(dicom_info.patient_id) &...
	  isempty(dicom_info.study_date)
      % DICOM�t�@�C���̎B�e�����Ǘ�����\����(dicom_info) ��
      % ����(�팟��)�̖��O �� ����(�팟��)ID �� �������{�� ��
      % �ݒ肳��Ă��Ȃ��ꍇ�A
      % DICOM�t�@�C���̎B�e�����Ǘ�����\����(dir_info) ��
      % DICOM�t�@�C���̎B�e�����Ǘ�����\����(dicom_info) ��
      % �X�V����B
      dicom_info = dir_info;
    elseif strcmp(dicom_info.patient_name, dir_info.patient_name) &...
	  strcmp(dicom_info.patient_id, dir_info.patient_id)
      % DICOM�t�@�C���̎B�e�����Ǘ�����\����(dicom_info) ��
      % DICOM�t�@�C���̏o�͐�̃f�B���N�g��������ݒ肵��
      % �B�e�����Ǘ�����\����(dir_info) ��
      % ����(�팟��)�̖��O �� ����(�팟��)ID ����v����ꍇ
      % DICOM�t�@�C���̏o�͐�̃f�B���N�g��������l������
      % �������{��(dir_info.study_date)�ŁADICOM�t�@�C����
      % �B�e�����Ǘ�����\���̂̌������{��(dicom_info.study_date)
      % ���X�V����B
      dicom_info.study_date = dir_info.study_date;	% ������ (YYMMDD)
    end
  end	% <-- End of 'if length( find(study_date>='0' & study_date<='9') )...'
end	% <-- End of 'if length(p) == 2 & min(p) > 1 & ...'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function set_dicom_info_dicom_dir() ' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [dicom_info] = atr_local(dicom_info)
% function [dicom_info] = atr_local(dicom_info)
% DICOM�t�@�C���̎B�e�����Ǘ�����\����(dicom_info)��
% ����(�팟��)�̖��O(dicom_info.patient_name) ��
% ����(�팟��)ID(dicom_info.patient_id) ��
% ����(�B�e)���{���̏�񂪊܂܂�Ă���ꍇ�A
% �������菜���B
% 
% (*)
% ATR��fMRI���u�Ōv������DICOM�t�@�C���̏ꍇ�A
% ����(�팟��)�̖��O �� ����(�팟��)ID ��
% ����(�B�e)���{���̏�񂪊܂܂�Ă���̂ŁA
% �������菜���B
% dicom_info.patient_name     = '160308_Tanaka' -> 'Tanaka''
% dicom_info.patient_id       = 'AT160308'      -> 'AT'
% dicom_info.study_date       = '160308'
% dicom_info.institution_name = 'ATR-BAIC'
% 
% [input argument]
% dicom_info : DICOM�t�@�C���̎B�e�����Ǘ�����\����
% 
% [output argument]
% dicom_info : DICOM�t�@�C���̎B�e�����Ǘ�����\����

study_date = dicom_info.study_date;	% ����(�B�e)���{�� (������:YYMMDD)

% ����(�팟��)�̖��O(dicom_info.patient_name)�ɁA
% ����(�B�e)���{���̕�����('YYMMDD_')���܂܂�Ă���ꍇ�A
% �������菜���B
p = findstr(dicom_info.patient_name, sprintf('%s_', study_date));
for ii=length(p):-1:1
  dicom_info.patient_name(p(ii):p(ii)+length(study_date)) = '';
end
% ����(�팟��)ID(dicom_info.patient_id)�ɁA
% ����(�B�e)���{���̕�����('YYMMDD')���܂܂�Ă���ꍇ�A
% �������菜���B
p = findstr(dicom_info.patient_id, study_date);
for ii=length(p):-1:1
  dicom_info.patient_id(p(ii):p(ii)+length(study_date)-1) = '';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function atr_local()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
