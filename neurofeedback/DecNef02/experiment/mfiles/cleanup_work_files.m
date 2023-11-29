function [] = cleanup_work_files(define, para)
% function [] = cleanup_work_files(define, para)
% Work directory‚ÆCache file‚ð?í?œ‚·‚é?B
% 
% [input argument]
% define : define•Ï?”‚ðŠÇ—?‚·‚é?\‘¢‘Ì
% para : ŽÀŒ±ƒpƒ‰ƒ??[ƒ^?\‘¢‘Ì
fprintf('cleanup Work files .. ');
for ii=1:para.receiver_num
  %rmdir( para.files.work_dir{ii} ,'s' );
end
delete( fullfile(para.files.current_dir, define.default.CACHE_FNAME) );
fprintf('done.\n');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End of 'function cleanup_work_files()' %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
