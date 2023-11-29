function [value] = yoyo_sscanf(format, str)
% function [value] = yoyo_sscanf(format, str)
% 文字列(str)が文字列条件(format)に一致するか確認する。
% [例1]
% str = 'trial_num=10', format = 'trial_num=%d'
% -> value = 10
% 
% [例2]
% str = 'ad_save_mode=ON', format = 'ad_save_mode=%s'
% -> value = 'ON'
%
% **** 注意!! ****
% 文字列条件(format)の'='の前後にスペースを挿入してはいけない。
% 
% **** 注意!! ****
% yoyo_sscanf()内で、文字列(str)内の '='  文字
% の前後のスペースを削除する。
% 
% [input argument]
% format : 文字列条件
%          sprintf()の文字列条件式と同様の形式だが、
%          '変数名=%d' の形式でなければならない(変数型により%%f->%%s)
%          [例]
%           format = 'trial_num=%d'
%           format = 'ad_save_mode=%s'
%          [注意!!]
%           文字列条件(format)の'='の前後にスペースを挿入してはいけない。
% str : Parameterファイルから読み出した文字列
% 
% [output argument]
% value : パラメータ値

value = sscanf(str, format);
% 文字列条件(format)に一致しない場合、文字列(str)内の'='文字の前後の
% スペースを削除して検索する。
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
