function [Def, mat] = spm_get_trans(job,DefNii,outDir)
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


[Def,mat] = get_comp(job.comp,DefNii);


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
