function NO = spm_realtime_deformations(job,NI,DefNii,outDir,Def,mat)
% Various deformation field utilities
% FORMAT out = spm_deformations(job)
% job - a job created via spm_cfg_deformations.m
% out - a struct with fields
%       .def    - file name of created deformation field
%       .warped - file names of warped images
%
% See spm_cfg_deformations.m for more information.
%__________________________________________________________________________
% Copyright (C) 2005-2015 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_deformations.m 6577 2015-10-15 15:22:11Z volkmar $


%[Def,mat] = get_comp(job.comp,DefNii);
out = struct('def',{{}},'warped',{{}},'surf',{{}},'jac',{{}});
for i=1:numel(job.out)
    fn = fieldnames(job.out{i});
    fn = fn{1};
    switch fn
    case 'savedef'
        out.def    = [out.def;    save_def(Def,mat,job.out{i}.(fn))];
    case 'pull'
        [out, NO] = pull_def(Def,mat,job.out{i}.(fn),NI,outDir);
    case 'push'
        out.warped = [out.warped; push_def(Def,mat,job.out{i}.(fn))];
    case 'surf'
        out.surf   = [out.surf;   surf_def(Def,mat,job.out{i}.(fn))];
    case 'savejac'
        out.jac    = [out.jac;    jac_def(Def,mat,job.out{i}.(fn))];
    otherwise
        error('Unknown option');
    end
end


%==========================================================================
% function [Def,mat] = get_comp(job)
%==========================================================================
function [Def,mat] = get_comp(job,DefNii)
% Return the composition of a number of deformation fields.
if isempty(job)
    error('Empty list of jobs in composition');
end
[Def,mat] = get_job(job{1},DefNii);
for i=2:numel(job)
    Def1         = Def;
    mat1         = mat;
    [Def,mat]    = get_job(job{i},DefNii);
    M            = inv(mat1);
    tmp          = zeros(size(Def),'single');
    tmp(:,:,:,1) = M(1,1)*Def(:,:,:,1)+M(1,2)*Def(:,:,:,2)+M(1,3)*Def(:,:,:,3)+M(1,4);
    tmp(:,:,:,2) = M(2,1)*Def(:,:,:,1)+M(2,2)*Def(:,:,:,2)+M(2,3)*Def(:,:,:,3)+M(2,4);
    tmp(:,:,:,3) = M(3,1)*Def(:,:,:,1)+M(3,2)*Def(:,:,:,2)+M(3,3)*Def(:,:,:,3)+M(3,4);
    Def(:,:,:,1) = single(spm_diffeo('bsplins',Def1(:,:,:,1),tmp,[1,1,1,0,0,0]));
    Def(:,:,:,2) = single(spm_diffeo('bsplins',Def1(:,:,:,2),tmp,[1,1,1,0,0,0]));
    Def(:,:,:,3) = single(spm_diffeo('bsplins',Def1(:,:,:,3),tmp,[1,1,1,0,0,0]));
    clear tmp
end



%==========================================================================
% function [Def,mat] = get_job(job)
%==========================================================================
function [Def,mat] = get_job(job,DefNii)
% Determine what is required, and pass the relevant bit of the
% job out to the appropriate function.

fn = fieldnames(job);
fn = fn{1};
switch fn
    case {'comp'}
        [Def,mat] = get_comp(job.(fn));
    case {'def'}
        [Def,mat] = get_def(job.(fn),DefNii);
    case {'dartel'}
        [Def,mat] = get_dartel(job.(fn));
    case {'sn2def'}
        [Def,mat] = get_sn2def(job.(fn));
    case {'inv'}
        [Def,mat] = get_inv(job.(fn));
    case {'id'}
        [Def,mat] = get_id(job.(fn));
    case {'idbbvox'}
        [Def,mat] = get_idbbvox(job.(fn));
    otherwise
        error('Unrecognised job type');
end

%==========================================================================
% function [Def,mat] = get_def(job)
%==========================================================================
function [Def,mat] = get_def(job,DefNii)
% Load a deformation field saved as an image
%Nii = nifti(job{1});
Def = single(DefNii.dat(:,:,:,1,:));
d   = size(Def);
if d(4)~=1 || d(5)~=3, error('Deformation field is wrong!'); end
Def = reshape(Def,[d(1:3) d(5)]);
mat = DefNii.mat;


%==========================================================================
% function [Def,mat] = get_idbbvox(job)
%==========================================================================
function [Def,mat] = get_idbbvox(job)
% Get an identity transform based on bounding box and voxel size.
% This will produce a transversal image.

[mat, dim] = spm_get_matdim('', job.vox, job.bb);
Def = identity(dim, mat);



%==========================================================================
% function out = pull_def(Def,mat,job)
%==========================================================================
function [out, NO] = pull_def(Def,mat,job, NI, outDir)

PI      = job.fnames;
intrp   = job.interp;
intrp   = [intrp*[1 1 1], 0 0 0];
out     = cell(numel(PI),1);

if numel(PI)==0, return; end

if job.mask
    oM  = zeros(4,4);
    odm = zeros(1,3);
    dim = size(Def);
    msk = true(dim);
    for m=1:numel(PI)
        %[pth,nam,ext,num] = spm_fileparts(PI{m});
        %NI = nifti(fullfile(pth,[nam ext]));
        dm = NI.dat.dim(1:3);
        j_range = 1:size(NI.dat,4);

        for j=j_range

            M0 = NI.mat;
%             if ~isempty(NI.extras) && isstruct(NI.extras) && isfield(NI.extras,'mat')
%                 M1 = NI.extras.mat;
%                 if size(M1,3) >= j && sum(sum(M1(:,:,j).^2)) ~=0
%                     M0 = M1(:,:,j);
%                 end
%             end
            M   = inv(M0);
            if ~all(M(:)==oM(:)) || ~all(dm==odm)
                tmp = affine(Def,M);
                msk = tmp(:,:,:,1)>=1 & tmp(:,:,:,1)<=size(NI.dat,1) ...
                    & tmp(:,:,:,2)>=1 & tmp(:,:,:,2)<=size(NI.dat,2) ...
                    & tmp(:,:,:,3)>=1 & tmp(:,:,:,3)<=size(NI.dat,3);
            end
            oM  = M;
            odm = dm;
        end
    end
end

oM = zeros(4,4);
spm_progress_bar('Init',numel(PI),'Resampling','volumes completed');
for m=1:numel(PI)

    % Generate headers etc for output images
    %----------------------------------------------------------------------
    %[pth,nam,ext,num] = spm_fileparts(PI{m});
    %NI = nifti(fullfile(pth,[nam ext]));
    j_range = 1:size(NI.dat,4);
    k_range = 1:size(NI.dat,5);
    l_range = 1:size(NI.dat,6);

    NO = NI;
    wd = outDir;

    if sum(job.fwhm.^2)==0
        newprefix  = spm_get_defaults('normalise.write.prefix');
        NO.descrip = sprintf('Warped');
    else
        newprefix  = [spm_get_defaults('smooth.prefix') spm_get_defaults('normalise.write.prefix')];
        NO.descrip = sprintf('Smoothed (%gx%gx%g subopt) warped',job.fwhm);
    end
    pos = findstr(NI.dat.fname, '\');
    NO.dat.fname = [NI.dat.fname(1:pos(end)),'w',NI.dat.fname(pos(end)+1:end)];

    dim            = size(Def);
    dim            = dim(1:3);
    NO.dat.dim     = [dim NI.dat.dim(4:end)];
    NO.dat.offset  = 0; % For situations where input .nii images have an extension.
    NO.mat         = mat;
    NO.mat0        = mat;
    NO.mat_intent  = 'Aligned';
    NO.mat0_intent = 'Aligned';
    out{m}     = NO.dat.fname;
    NO.extras      = [];
    
    % This can be used to write out the w....nii image to the HD.
    create(NO);

    % Smoothing settings
    vx  = sqrt(sum(mat(1:3,1:3).^2));
    krn = max(job.fwhm./vx,0.25);

    % Loop over volumes within the file
    %----------------------------------------------------------------------
    %fprintf('%s',nam);
    for j=j_range

        M0 = NI.mat;
        if ~isempty(NI.extras) && isstruct(NI.extras) && isfield(NI.extras,'mat')
            M1 = NI.extras.mat;
            if size(M1,3) >= j && sum(sum(M1(:,:,j).^2)) ~=0
                M0 = M1(:,:,j);
            end
        end
        M  = inv(M0);
        if ~all(M(:)==oM(:))
            % Generate new deformation (if needed)
            Y     = affine(Def,M);
        end
        oM = M;
        % Write the warped data for this time point
        %------------------------------------------------------------------
        for k=k_range
            for l=l_range
                C   = spm_diffeo('bsplinc',single(NI.dat(:,:,:,j,k,l)),intrp);
                dat = spm_diffeo('bsplins',C,Y,intrp);
                if job.mask
                    dat(~msk) = NaN;
                end
                if sum(job.fwhm.^2)~=0
                    spm_smooth(dat,dat,krn); % Side effects
                end
                NO.dat(:,:,:,j,k,l) = dat;
                %fprintf('\t%d,%d,%d', j,k,l);
            end
        end
    end
    %fprintf('\n');
    %spm_progress_bar('Set',m);
end
%spm_progress_bar('Clear');



%==========================================================================
% function Def = affine(y,M)
%==========================================================================
function Def = affine(y,M)
Def          = zeros(size(y),'single');
Def(:,:,:,1) = y(:,:,:,1)*M(1,1) + y(:,:,:,2)*M(1,2) + y(:,:,:,3)*M(1,3) + M(1,4);
Def(:,:,:,2) = y(:,:,:,1)*M(2,1) + y(:,:,:,2)*M(2,2) + y(:,:,:,3)*M(2,3) + M(2,4);
Def(:,:,:,3) = y(:,:,:,1)*M(3,1) + y(:,:,:,2)*M(3,2) + y(:,:,:,3)*M(3,3) + M(3,4);


%==========================================================================
% function Def = identity(d,M)
%==========================================================================
function Def = identity(d,M)
[y1,y2]   = ndgrid(single(1:d(1)),single(1:d(2)));
Def       = zeros([d 3],'single');
for y3=1:d(3)
    Def(:,:,y3,1) = y1*M(1,1) + y2*M(1,2) + (y3*M(1,3) + M(1,4));
    Def(:,:,y3,2) = y1*M(2,1) + y2*M(2,2) + (y3*M(2,3) + M(2,4));
    Def(:,:,y3,3) = y1*M(3,1) + y2*M(3,2) + (y3*M(3,3) + M(3,4));
end
