function myKeyCheck()
% ��ɉ������ƌ�F������L�[�𖳌�������B
% (https://sites.google.com/site/ptbganba/)

% OS�ŋ��ʂ̃L�[�z�u�ɂ���
KbName('UnifyKeyNames');

% ������̃L�[��������Ă��Ȃ���Ԃɂ��邽��1�b�قǑ҂�
WaitSecs(1.0);

% �����ɂ���L�[�̏�����
DisableKeysForKbCheck([]);

% ��ɉ������L�[�����擾����
[ keyIsDown, secs, keyCode ] = KbCheck;

% ��ɉ������L�[����������A����𖳌��ɂ���
if keyIsDown
  keys=find(keyCode);
  if 0
    fprintf('�����ɂ����L�[������܂�\n');
    % keyCode�ƃL�[�̖��O��\��
    for ii=1:length(keys)
      fprintf('KbName(%d)=%s\n', keys(ii), KbName(keys(ii)));
    end
  end
  DisableKeysForKbCheck(keys);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function myKeyCheck()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
