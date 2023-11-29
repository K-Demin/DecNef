function [this] = file_dialog()
% file_dialogクラスのコンストラクタ
% 
% Copyright (C) Toshinori Yoshioka (yosioka@atr.jp)
% ATR Computational Neuroscience Laboratories (CNS)
% 2-2-2 Hikaridai, Keihanna Science city, Kyoto, 619-0288, Japan

% メンバを初期化する。
public = init_public;
private = init_private;
this = struct('public',public, 'private',private);

% クラスを登録する。
this = class(this, 'file_dialog');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function file_dialog()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
