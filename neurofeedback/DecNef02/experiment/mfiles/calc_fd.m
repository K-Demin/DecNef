function [fd, delta_realign_val] = calc_fd(realign_val, scans, para)
% function [fd, delta_realign_val] = calc_fd(realign_val, scans, para)
% Scan���Ǿ�ΰ�ư�̤���롣
% ( create_global.m���create_para()��score��¤�ΤΥ����Ȥ򻲾� )
% 
% [input argument]
% realign_val : Template DICOM file�����Ǿ��ư����ɽ�������ѿ�
%               (spm_realign�ؿ������������Realignment value)
% scans       : Scan���Ǿ�ΰ�ư�̤����scan�ֹ�
% para        : �ѥ�᡼����¤��
% 
% [output argument]
% fd                : Scan���Ǿ�ΰ�ư�� [mm]
% delta_realign_val : Scan���Ǿ�ΰ�ư��/��ž����
%                     ( realign_val(:,1:3) = X,Y,Z�������ΰ�ư�� [mm]
%                       realign_val(:,4:6) = X,Y,Z���ޤ��β�ž�� [deg] )

% Scan���Ǿ�ΰ�ư��/��ž���٤���롣
% ( realign_val(:,1:3) = X,Y,Z�������ΰ�ư�� [mm]
%   realign_val(:,4:6) = X,Y,Z���ޤ��β�ž�� [deg] )
delta_realign_val = zeros( size( realign_val(scans,:) ) );
% ��Ԥ򳫻Ϥ�������scan(para.scans.pre_trial_scan_num)��
% �ǡ�����NaN�����ꤵ��Ƥ���ΤǷ׻��˺��Ѥ��ʤ���
tmp = find( scans > para.scans.pre_trial_scan_num+1 );
% scans(tmp-1)�˥�����������Τ�tmp=1���Բ�
tmp(tmp == 1) = [];	% <--- pre_trial_scan_num=0�ξ��ν���
% Scan���Ǿ�ΰ�ư��/��ž����
delta_realign_val(tmp,:) =...
    realign_val(scans(tmp),:) - realign_val(scans(tmp-1),:);

% X,Y,Z���ޤ��β�ž�Ѥ��ư�̤��Ѵ����롣
% ( ��ư�� = Ǿ��Ⱦ�� * ��ž���� ) [rad] -> [mm]
DELTA_REALIGN_VAL = delta_realign_val;
DELTA_REALIGN_VAL(:,4:6) =...
    para.score.radius_of_brain * DELTA_REALIGN_VAL(:,4:6);
% Scan���Ǿ�ΰ�ư�̤���롣 [mm]
fd = sum( abs(DELTA_REALIGN_VAL), 2 );

% ��Ԥ򳫻Ϥ�������scan(para.scans.pre_trial_scan_num)��
% Scan���Ǿ�ΰ�ư��(fd, delta_realign_val)��NaN�����ꤹ�롣
p = (scans <= para.scans.pre_trial_scan_num);
fd(p) = NaN;
delta_realign_val(p,:) = NaN;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <-- 'End of function calc_fd()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
