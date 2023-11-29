%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This script will run the preprocessing in SPM in order to:
%  - get the transformation to the MNI space 
%  - get the mean image for realignment (wmean....nii must be renamed mean.nii afterward)
%  - get the mean pattern to include in the ROI.txt file
%
% Once this script completes, you have to run:
% /Neurofeedback/CreateDecoders/Code/CreateDecoders/
% -VTD-
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

structPath = 'Y:\reference\ref_SIIPS_Pilot_AM_test\Structural\Structural_t1_mprage_sag_p2_iso_20200205095754_14.nii,1';
FuncPath = 'Y:\reference\ref_SIIPS_Pilot_AM_test\Functional\';

% Use dcm2nii to convert the T1 MPRAGE

% cd to the folder with the functional files
cd(FuncPath)
listIMA = dir('*.dcm');
opts     = 'all';
root_dir = 'flat';
format   = spm_get_defaults('images.format');
mkdir('NIFTIs');
cd('.\NIFTIs\')
out_dir  = pwd;

for i =1:20
    hdr      = spm_dicom_headers([listIMA(i).folder,'\',listIMA(i).name]);
    niiFile  = spm_dicom_convert(hdr, opts, root_dir, format, out_dir);
end

% structure files for SPM
global structural
global functional
structural = {structPath};

listNII = dir('*.nii');
for i = 1:length(listNII)
    functional{1}{i,1} = [listNII(i).folder,'\',listNII(i).name,',1'];
end

% run SPM batch
nrun = 1;
jobfile = {'Y:\reference\CreateDecoders\Code\SPM_Get_MNI_Trans_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});

%
