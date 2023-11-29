function [str] = vector_format(pstr, dchr, len)
% function [str] = vector_format(pstr, dchr, len)
% ベクトルを fprintf関数 または sprintf関数 で出力する為の
% format文字列を作成する。
% 
% [input argument]
% pstr : 出力精度を提示する文字列 (Precision string)
%        (ex : '%f', '%5d', '%10.4f')
% dchr : 句切文字 (delimiter character)
%        (ex : ' ', '\t', ', ')
% len  : ベクトルの長さ(変数の数)
% 
% [output argument]
% str : fprintf/sprintf関数用のformat文字列
%        (ex : '%f %f %f', '%5d\t%5d', '%10.4f, %10.4f')
s = [pstr,dchr];	% 1個分のformat文字列を作成する。
% format文字列をベクトルの変数の数並べる。
str = reshape(meshgrid(s,1:len)',1,length(s)*len);
str(end-length(dchr)+1:end) = '';	% 最後の句切文字を取り除く
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function vector_format()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
