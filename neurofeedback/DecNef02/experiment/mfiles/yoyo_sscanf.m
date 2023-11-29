function [value] = yoyo_sscanf(format, str)
% function [value] = yoyo_sscanf(format, str)
% ������(str)�����������(format)�Ɉ�v���邩�m�F����B
% [��1]
% str = 'trial_num=10', format = 'trial_num=%d'
% -> value = 10
% 
% [��2]
% str = 'ad_save_mode=ON', format = 'ad_save_mode=%s'
% -> value = 'ON'
%
% **** ����!! ****
% ���������(format)��'='�̑O��ɃX�y�[�X��}�����Ă͂����Ȃ��B
% 
% **** ����!! ****
% yoyo_sscanf()���ŁA������(str)���� '='  ����
% �̑O��̃X�y�[�X���폜����B
% 
% [input argument]
% format : ���������
%          sprintf()�̕�����������Ɠ��l�̌`�������A
%          '�ϐ���=%d' �̌`���łȂ���΂Ȃ�Ȃ�(�ϐ��^�ɂ��%%f->%%s)
%          [��]
%           format = 'trial_num=%d'
%           format = 'ad_save_mode=%s'
%          [����!!]
%           ���������(format)��'='�̑O��ɃX�y�[�X��}�����Ă͂����Ȃ��B
% str : Parameter�t�@�C������ǂݏo����������
% 
% [output argument]
% value : �p�����[�^�l

value = sscanf(str, format);
% ���������(format)�Ɉ�v���Ȃ��ꍇ�A������(str)����'='�����̑O���
% �X�y�[�X���폜���Č�������B
% str = 'trial_num = 0.010' -> 'trial_num =0.010' -> 'trial_num=0.010'
if length(value) == 0 & findstr(str,' =')
  str( findstr(str,' =') ) = [];
  value = yoyo_sscanf(format, str);
end
if length(value) == 0 & findstr(str,'= ')
  str( findstr(str,'= ')+1 ) = [];
  value = yoyo_sscanf(format, str);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function yoyo_sscanf()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
