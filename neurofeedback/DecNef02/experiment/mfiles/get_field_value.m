function [value, ret] = get_field_value(string, structure)
% function [value, ret] = get_field_value(string, structure)
% �\���̂̃����o�ϐ�������ɑΉ�����l��Ԃ��B
% 
% [input argument]
% string    : �����o�ϐ�������
% structure : �\����
% 
% [output argument]
% value : �����o�ϐ��̐ݒ�l
% ret   : �����o�ϐ������񂪐���l(true)/�s���l(false)
all_fnames = fieldnames(structure); % structure�̑Sfield��
ret = false;
value = NaN;
for ii=1:length(all_fnames)
  if strcmp(string, all_fnames{ii})
    value = getfield(structure, string);
    ret = true;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function get_field_value()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
