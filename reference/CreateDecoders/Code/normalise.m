spm('defaults','fmri');
spm_jobman('initcfg');

homedir = '/data/export/home/anarayanan/public/Bipolar/Analysis/Try7';
subjects = {
    '70182','70185','70191','70196','70201','70209','70234','70242','70315','70322',...
    '70335','70352','70362','70373','70389','70390','70391','70398','70403','70404',...
    '70405','70406','70412','70413','70415','70421','70423','70424','70430','70432',...
    '70436','70443','70444','70448','70450','70453','70454','70455','70456'
    };

for s=1:numel(subjects)
    pth = fullfile(homedir, subjects{s}, 'anatomical');
    def = spm_select('FPList',pth,'^y_.*\.nii$');
    wrt = spm_select('FPList',pth,'^(c1|c2|c3|s).*\.nii$');
    
    clear matlabbatch
    matlabbatch{1}.spm.spatial.normalise.write.subj.def = cellstr(def);
    matlabbatch{1}.spm.spatial.normalise.write.subj.resample = cellstr(wrt);
    matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = NaN(2,3);
    matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
    matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 4;
    spm_jobman('run','matlabbatch');
end

