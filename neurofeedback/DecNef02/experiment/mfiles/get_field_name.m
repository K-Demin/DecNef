function [field_name] = get_field_name(value, structure)
% function [str] = field_str(value, structure)
% �\���̂̐ݒ�l�ɑΉ�����field����Ԃ��B
% 
% [input argument]
% value     : �p�����[�^�ϐ��ւ̐ݒ�l
% structure : �\����
% 
% [output argument]
% field_name : �\���̂̐ݒ�l�ɑΉ�����field��
all_fnames = fieldnames(structure);	% structure�̑Sfield��
field_name = '????????';
for ii=1:length(all_fnames)
  if value == getfield(structure, all_fnames{ii})
    field_name = all_fnames{ii};
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function get_field_name()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
