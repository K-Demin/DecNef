function [this] = file_dialog()
% file_dialog���饹�Υ��󥹥ȥ饯��
% 
% Copyright (C) Toshinori Yoshioka (yosioka@atr.jp)
% ATR Computational Neuroscience Laboratories (CNS)
% 2-2-2 Hikaridai, Keihanna Science city, Kyoto, 619-0288, Japan

% ���Ф��������롣
public = init_public;
private = init_private;
this = struct('public',public, 'private',private);

% ���饹����Ͽ���롣
this = class(this, 'file_dialog');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function file_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
