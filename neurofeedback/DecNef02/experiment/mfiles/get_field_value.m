function [value, ret] = get_field_value(string, structure)
% function [value, ret] = get_field_value(string, structure)
% 構造体のメンバ変数文字列に対応する値を返す。
% 
% [input argument]
% string    : メンバ変数文字列
% structure : 構造体
% 
% [output argument]
% value : メンバ変数の設定値
% ret   : メンバ変数文字列が正常値(true)/不正値(false)
all_fnames = fieldnames(structure); % structureの全field名
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
