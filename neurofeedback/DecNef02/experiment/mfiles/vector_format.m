function [str] = vector_format(pstr, dchr, len)
% function [str] = vector_format(pstr, dchr, len)
% �x�N�g���� fprintf�֐� �܂��� sprintf�֐� �ŏo�͂���ׂ�
% format��������쐬����B
% 
% [input argument]
% pstr : �o�͐��x��񎦂��镶���� (Precision string)
%        (ex : '%f', '%5d', '%10.4f')
% dchr : ��ؕ��� (delimiter character)
%        (ex : ' ', '\t', ', ')
% len  : �x�N�g���̒���(�ϐ��̐�)
% 
% [output argument]
% str : fprintf/sprintf�֐��p��format������
%        (ex : '%f %f %f', '%5d\t%5d', '%10.4f, %10.4f')
s = [pstr,dchr];	% 1����format��������쐬����B
% format��������x�N�g���̕ϐ��̐����ׂ�B
str = reshape(meshgrid(s,1:len)',1,length(s)*len);
str(end-length(dchr)+1:end) = '';	% �Ō�̋�ؕ�������菜��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function vector_format()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
