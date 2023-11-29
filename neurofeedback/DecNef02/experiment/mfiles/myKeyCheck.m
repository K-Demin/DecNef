function myKeyCheck()
% 常に押されると誤認識するキーを無効化する。
% (https://sites.google.com/site/ptbganba/)

% OSで共通のキー配置にする
KbName('UnifyKeyNames');

% いずれのキーも押されていない状態にするため1秒ほど待つ
WaitSecs(1.0);

% 無効にするキーの初期化
DisableKeysForKbCheck([]);

% 常に押されるキー情報を取得する
[ keyIsDown, secs, keyCode ] = KbCheck;

% 常に押されるキーがあったら、それを無効にする
if keyIsDown
  keys=find(keyCode);
  if 0
    fprintf('無効にしたキーがあります\n');
    % keyCodeとキーの名前を表示
    for ii=1:length(keys)
      fprintf('KbName(%d)=%s\n', keys(ii), KbName(keys(ii)));
    end
  end
  DisableKeysForKbCheck(keys);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function myKeyCheck()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
