function [str] = make_exp_result_string(para, data)
% function [str1, str2] = make_exp_result_string(para, data)
% ŽÀŒ±Œ‹‰Ê(‘ŠŠÖŒW?”‚Æ“¾“_)‚Ì•¶Žš—ñ‚ð?ì?¬‚·‚é?B
% 
% [input argument]
% para : ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
% data : ŽÀŒ±ƒf?[ƒ^?\‘¢‘Ì
% 
% [output argument]
% str : ŽÀŒ±Œ‹‰Ê‚Ì•¶Žš—ñ‚Ì•¶Žš—ñ

str = {};

% ”íŒŸŽÒ‚ª?Q‚Ä‚¢‚È‚¢‚©‚Ìƒ`ƒFƒbƒNŒ‹‰Ê
for ii=1:para.scans.sleep_check_trial_num
  str{end+1} = sprintf('sleep_check(%d) = %d \t # trial = %d',...
      ii, data.sleep_check(ii), para.scans.sleep_check_trial(ii));
end


str{end+1} = '';


% ŽŽ?sŠJŽnŒã‚Ì‘Sscan”Ô?†(all_scans) ‚Æ
% ŠeŽŽ?s‚Å‚Ì“¾“_ŒvŽZ‘Î?Û‚Ìscan?”(calc_scan_num) ‚Æ
% ŠeŽŽ?s‚Å‚Ì“¾“_ŒvŽZ‘Î?Û‚Ìscan”Ô?†(calc_scans) ‚ð‹?‚ß‚é?B
all_scans = [para.scans.pre_trial_scan_num+1:data.received_scan_num];
calc_scan_num =...
    para.scans.test_scan_num -...
    para.scans.pre_test_delay_scan_num +...
    para.scans.post_test_delay_scan_num;
% ŠeŽŽ?s‚Å‚Ì“¾“_ŒvŽZ‘Î?Û‚Ìscan”Ô?†”z—ñ‚ð‹?‚ß‚é?B
% --------------------------------------
% calc_scans(N,:) = NŽŽ?s–Ú‚Å‚Ì“¾“_ŒvŽZ‘Î?Û‚Ìscan”Ô?†
calc_scans = zeros(para.scans.trial_num, calc_scan_num);
for ii=1:para.scans.trial_num
  calc_scans(ii,:) =...
      [ para.scans.score_target_scans(ii,1):...
	para.scans.score_target_scans(ii,2) ];
end
% Scan’†‚Ì”]‚ÌˆÚ“®—Ê‚ð”»’è‚µ?A‚±‚Ìscan‚ÌŒv‘ªƒf?[ƒ^‚ð
% “¾“_‚ÌŒvŽZ‚É?Ì—p‚µ‚È‚¢scan?”‚ð‹?‚ß‚é?B
% ----------------------------------------------------
% fd_err_scan_num_all = ‘Sscan’†‚Å“¾“_‚ÌŒvŽZ‚É?Ì—p‚µ‚È‚¢scan‚Ì?”
% fd_err_scan_num_calc= “¾“_ŒvŽZ‘Î?Û‚Ìscan’†‚Å“¾“_‚ÌŒvŽZ‚É?Ì—p‚µ‚È‚¢scan‚Ì?”
fd_err_scan_num_all = length( find( data.ng_scan(all_scans) ) );
fd_err_scan_num_calc = length( find( data.ng_scan(calc_scans(:)) ) );
% “¾“_‚ÌŒvŽZ‚É?Ì—p‚µ‚È‚¢scan?”‚Ì•¶Žš—ñ‚ð?ì?¬‚·‚é?B (2016.02.01)
str{end+1} = sprintf('The number of motion contaminated scans.');
str{end+1} = sprintf('   (FD>%.3f[mm], corr_roi_template<%.3f)',...
    para.score.FD_threshold, para.score.corr_roi_template_threshold);
str{end+1} = sprintf('  >>> In total :%3d', fd_err_scan_num_all);
str{end+1} = sprintf('  >>> In task  :%3d', fd_err_scan_num_calc);


str{end+1} = '';


% ŠeŽŽ?s‚Ì 'label’l' ‚Æ '“¾“_' ‚Ì•¶Žš—ñ‚ð?ì?¬‚·‚é?B
for ii=1:para.scans.trial_num
  if data.roi_num
    tmp = '';
    for roi=1:data.roi_num
      tmp = sprintf('%sR%d=%7.4f, ', tmp, roi, data.label(ii, roi));
    end
    str{end+1} = sprintf('trial%02d : label(%s) Score=%4.0f(%6.1f)',...
	ii, tmp(1:end-2), data.score(ii), data.source_score(ii));
  else
    str{end+1} = sprintf('trial%02d : Score=%4.0f(%6.1f)',...
	ii, data.score(ii), data.source_score(ii));
  end
end

% “¾“_‚ðŒvŽZ‚µ‚½ŽŽ?s”Ô?†‚ð‹?‚ß‚é?B
score_trial = 1:para.scans.trial_num;
score_trial( isnan(data.score(:,1)) ) = [];

% 'label’l' ‚Æ '“¾“_' ‚Ì•½‹Ï’l
str{end+1} = sprintf(...
    '----------------------------------------------------------------------');
if data.roi_num
  % label’l‚ðŒvŽZ‚µ‚½ŽŽ?s”Ô?†‚ð‹?‚ß‚é?B
  label_trial = 1:para.scans.trial_num;
  label_trial( isnan(data.label(:,1)) ) = [];
  tmp = '';
  for roi=1:data.roi_num
    tmp = sprintf('%sR%d=%7.4f, ',...
	tmp, roi, mean(data.label(label_trial, roi)));
  end
  str{end+1} = sprintf('average : label(%s) Score=%4.0f(%6.1f)',...
      tmp(1:end-2),...
      round( mean(data.score(score_trial)) ),...
      round( mean(data.source_score(score_trial)) ) );
  str{end+1} = sprintf('Total number of high score streaks : %f', data.total_streaks);
else
  str{end+1} = sprintf(...
      'average : Score=%4.0f(%6.1f)',...
      round( mean(data.score(score_trial)) ),...
      round( mean(data.source_score(score_trial)) ) );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function make_exp_result_string()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
