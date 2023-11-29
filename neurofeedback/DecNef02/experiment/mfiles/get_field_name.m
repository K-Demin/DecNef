function [field_name] = get_field_name(value, structure)
% function [str] = field_str(value, structure)
% 構造体の設定値に対応するfield名を返す。
% 
% [input argument]
% value     : パラメータ変数への設定値
% structure : 構造体
% 
% [output argument]
% field_name : 構造体の設定値に対応するfield名
all_fnames = fieldnames(structure);	% structureの全field名
field_name = '????????';
for ii=1:length(all_fnames)
  if value == getfield(structure, all_fnames{ii})
    field_name = all_fnames{ii};
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function get_field_name()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
