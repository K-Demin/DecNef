function [] = copyright(version)
% function [] = copyright(version)
% 著作権メッセージを出力する。
% 
% [input argument]
% version : バージョン情報を管理する構造体

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' Decoded Neurofeedback(DecNef) experiment program.\n');
fprintf('                                DecNef%02d (r%d)\n',...
    version.decnef.project, version.decnef.release);
fprintf('                                MATLAB v%s (%s)\n',...
    version.matlab.version, version.matlab.release);
fprintf('                                %s (v%d)\n\n',...
    version.spm.version, version.spm.release);
	    
if version.decnef.receiver_id == 0	% neurofeedbackプログラム
  fprintf(' USAGE : neurofeedback\n');
  fprintf('         neurofeedback(port)\n');
  fprintf('           port : TCP/IP port number\n');
elseif version.decnef.receiver_id > 0	% receiverプログラム
  fprintf(' USAGE : receiver\n');
end

fprintf('\n');
fprintf(' Copyright 2013 All Rights Reserved.\n');
fprintf(' ATR Brain Information Communication Research Lab Group.\n');
fprintf('-----------------------------------------------------------\n');
fprintf(' Toshinori YOSHIOKA.\n');
fprintf(' 2-2-2 Hikaridai, Seika-cho, Sorakugun, Kyoto,\n');
fprintf(' 619-0288, Japan (Keihanna Science city)\n');
fprintf('-----------------------------------------------------------\n');
% 複製または再配布のために、プログラムのコピーまたは複製を
% 別のサーバーまたは場所に転送することは、厳重に禁止されています。
fprintf(' Transferring copy or reproduction of the program towards \n');
fprintf(' another server or location for reproduction or redistribution \n');
fprintf(' is strictly prohibited.\n');
fprintf('===============================================================\n');
fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function copyright()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
