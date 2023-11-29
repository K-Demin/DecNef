function [ng_scan] = set_ng_scan(corr_temple, FD,...
    corr_temple_threshold, FD_threshold)
% function [ng_scan] = set_ng_scan(corr_temple, FD,...
% 				corr_temple_threshold, FD_threshold)
% Scan���̔]�̈ړ��ʂ𔻒肵�A����scan�̌v���f�[�^�𓾓_�̌v�Z��
% �̗p ���Ȃ�/���� ���Ǘ�����z��(ng_scan)��ݒ肷��B
% 
% [input argument]
% corr_temple : ROI template�f�[�^��ROI�f�[�^�̑��֌W�����Ǘ�����z��
% FD : Scan���̔]�̈ړ��ʂ��Ǘ�����z��
% corr_temple_threshold : ROI template��ROI�̑��֌W����臒l
% FD_threshold : Scan���̔]�̈ړ��ʂ�臒l
% 
% [output argument]
% ng_scan : scan�̌v���f�[�^�𓾓_�̌v�Z�ɍ̗p ���Ȃ�/���� ���Ǘ�����z��


% corr_err_scan = ROI template�f�[�^��ROI�f�[�^�̑��֌W����臒l�����Ȃ�TRUE
corr_err_scan = sum( corr_temple < corr_temple_threshold ,2) >= 1;
% fd_err_scans = Scan���̔]�̈ړ��ʂ�臒l�𒴂���ꍇTRUE
% ( �A���AScan���̔]�̈ړ��ʂ�臒l(FD_threshold)��NaN�̏ꍇ�A
%   scan���̔]�̈ړ��ʂ̒l�𔻒肵�Ȃ��B(fd_err_scans(:) = FALSE) )
fd_err_scans = false( size(FD) );
if ~isnan(FD_threshold)
  fd_err_scans = FD>FD_threshold;
end
% nan_scan = ROI template��ROI�̑��֌W��(corr_temple) �� 
%            Scan���̔]�̈ړ���(FD) ��NaN���ݒ肳��Ă���ꍇTRUE
% (���s���J�n����܂ł�scan��NaN���ݒ肳���B)
TMP = [corr_temple, FD];
nan_scan = sum( isnan( TMP ), 2) >= 1;
% ng_scan = scan(=�z��ԍ�)�̌v���f�[�^��
%           ���_�̌v�Z�ɍ̗p ���Ȃ�(true)/����(false)
ng_scan = corr_err_scan | fd_err_scans | nan_scan;
%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'set_ng_scan()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%
