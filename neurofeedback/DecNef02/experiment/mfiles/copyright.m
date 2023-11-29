function [] = copyright(version)
% function [] = copyright(version)
% ���쌠���b�Z�[�W���o�͂���B
% 
% [input argument]
% version : �o�[�W���������Ǘ�����\����

fprintf('\n');
fprintf('===============================================================\n');
fprintf(' Decoded Neurofeedback(DecNef) experiment program.\n');
fprintf('                                DecNef%02d (r%d)\n',...
    version.decnef.project, version.decnef.release);
fprintf('                                MATLAB v%s (%s)\n',...
    version.matlab.version, version.matlab.release);
fprintf('                                %s (v%d)\n\n',...
    version.spm.version, version.spm.release);
	    
if version.decnef.receiver_id == 0	% neurofeedback�v���O����
  fprintf(' USAGE : neurofeedback\n');
  fprintf('         neurofeedback(port)\n');
  fprintf('           port : TCP/IP port number\n');
elseif version.decnef.receiver_id > 0	% receiver�v���O����
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
% �����܂��͍Ĕz�z�̂��߂ɁA�v���O�����̃R�s�[�܂��͕�����
% �ʂ̃T�[�o�[�܂��͏ꏊ�ɓ]�����邱�Ƃ́A���d�ɋ֎~����Ă��܂��B
fprintf(' Transferring copy or reproduction of the program towards \n');
fprintf(' another server or location for reproduction or redistribution \n');
fprintf(' is strictly prohibited.\n');
fprintf('===============================================================\n');
fprintf('\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function copyright()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
