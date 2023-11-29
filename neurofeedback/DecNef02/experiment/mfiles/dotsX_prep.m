function dotsX_prep(lengthInSec)
%
%
% created by RK 01/17/06
% adapted to OSX by MKMK 6/06
% modified by Cody Cushing 8/19/18 for use in phase 2 of sensory
% preconditioning decnef project. snoogins

% VTD (01-2021): Created dotsX_prep() and dotsX_stim(). Here we create all
% the frame we need and display them in dotsX_stim().
%
% arguments - minimum fields for dotInfo and screenInfo
%   most everything is in visual degrees * 10, since rex only likes integers
%
%       dot.numDotField     number of dot patches that will be shown on the screen
%		dot.coh             vertical vectors, dots coherence (0...999) for each dot patch
%		dot.speed           vertical vectors, dots speed (10th deg/sec) for each dot patch
%		dot.dir             vertical vectors, dots direction (degrees) for each dot patch
%       dot.dotSize         size of dots in visual degrees, same for all patches
%       dot.dotColor        color of dots in rgb, same for all patches
%       dot.maxDotsPerFrame determined by testing video card
%       dot.apXYD           x, y coordinates, and diameter of aperture(s) in visual degrees
%		dot.maxDotTime      optional, can set maximum duration (sec). dot	presentation can be terminated by user response
%       dot.trialtype       1 fixed duration, 2 reaction time
%       dot.keys            a set of keyboard buttons that can terminate the presentation of dots
%       dot.ppd             pixels per visual degree
%       dot.monRefresh      monitor refresh value
%       dot.dontclear       If set to 1, flip will not clear the framebuffer after Flip - this allows incremental
%                           drawing of stimuli. Needs to be zero for dots to be erased.
%		dot.rseed           random # seed, can be empty set[]
%
%       These will be set below:
%       dot.curWindow    window on which to plot dots
%       dot.center       center of the screen in pixels


% algorithm:
%	All calculations take place within a square aperture
% in which the dots are shown. The dots are constructed in 3 sets
% that are plotted in sequence.  For each set, the probability that
% a dot is replotted in motion -- as opposed to randomly replaced --
% is given by the dotInfo.coh value.  This routine generates a set of
% dots as an ndots_ by 2 matrix of locations, and sends this to DOTS for
% plotting is DrawMethod is set to MEX or to a Matlab loop in RUSH mode of
% psychtoolbox if DrawMethod is set to RUSH.  In plotting the next set of
% dots (e.g., set 2) it prepends the preceding set (e.g., set 1).
% Since DOTS writes in XOR mode, replotting the old set erases it to its
% previous value, whether that be background or fixation point, etc.
%
% created by MKMK July 2006, based on ShadlenDots by MNS, JIG and others

% structures are not altered in this function, so should not have memory
% problems from matlab creating new structures...
%

global gData

gData.dot.curWindow = gData.data.feedback.window_id;    %window on which to plot dots
gData.dot.center = [gData.data.feedback.window_center_x,gData.data.feedback.window_center_y];       %center of the screen in pixels

rseed = gData.dot.rseed;

% SEED THE RANDOM NUMBER GENERATOR ... if "[]" is given, reset
% the seed "randomly"... this is for VAR/NOVAR conditions
if ~isempty(rseed) && length(rseed) == 1
    rand('state', rseed);
elseif ~isempty(rseed) && length(rseed) == 2
    rand('state', rseed(1)*rseed(2));
else
    rseed = sum(100*clock);
    rand('state', rseed);
end

% USEFUL LOCAL VARS
% variables that are sent to rex have been multiplied by a factor of 10 to
% make sure they are integers. Now we have to convert them back so that
% they are correct for plotting.
apD = gData.dot.apXYD(:,3); % diameter of aperture
center = repmat(gData.dot.center,size(gData.dot.apXYD(:,1)));

% change the xy coordinates to pixels (y is inverted - pos on bottom, neg.
% on top
center = [center(:,1) + gData.dot.apXYD(:,1)/10*gData.dot.ppd center(:,2) - gData.dot.apXYD(:,2)/10*gData.dot.ppd]; % where you want the center of the aperture
d_ppd 	= floor(apD/10 * gData.dot.ppd);	% size of aperture in pixels
ndots 	= min(gData.dot.maxDotsPerFrame, ceil(16.7 * apD .* apD * 0.01 / gData.dot.monRefresh));
% Save the centerfor the display later.
gData.dot.centerDisp = center;

% dxdy is an N x 2 matrix that gives jumpsize in units on 0..1
%    	 deg/sec     * Ap-unit/deg  * sec/jump   =   unit/jump
dxdy 	= repmat((gData.dot.speed/10) * (10/apD) * (3/gData.dot.monRefresh) ...
    * [cos(pi*gData.dot.dir/180.0) -sin(pi*gData.dot.dir/180.0)], ndots,1);
% ARRAYS, INDICES for loop
ss		= rand(ndots*3, 2); % array of dot positions raw
xs 		= zeros(ndots*3, 2); % array of dot positions within aperture
% divide dots into three sets...
Ls      = cumsum(ones(ndots,3))+repmat([0 ndots ndots*2], ndots, 1);
loopi   = 1; 	% loops through the three sets of dots

%disp('after one loop')
% loop length is determined by the field "dotInfo.maxDotTime"
% if none given, loop until "continue_show=0" is set by other means (eg
% user response), otherwise loop until dotInfo.maxDotTime
% always one video frame per loop

if ~isfield(gData.dot,'maxDotTime') || (isempty(gData.dot.maxDotTime) && ndots>0)
    continue_show = -1;
elseif ndots > 0
    continue_show = round(lengthInSec*gData.dot.monRefresh);
else
    continue_show = 0;
end

% THE MAIN LOOP
%priorityLevel = MaxPriority(curWindow,'KbCheck');
%Priority(priorityLevel);
dontclear = gData.dot.dontclear;
frames = 0;
index = 0;
rtTimer=GetSecs;

% Reset the counter while setting the new stim.
gData.dot.cpt = 1;

% This is to store the generated dot motion.
gData.dot.dot_show = {};
cpt = 1;
while continue_show

    % get ss & xs from the big matrices
    % xs and ss are matrices that have stuff for dots from the last 2 positions + current
    % Ls picks out the previous set (1:5, 6:10, or 11:15)
    Lthis  = Ls(:,loopi);  % Lthis picks out the loop from 3 times ago, which is what is then
    % moved in the current loop
    this_x = xs(Lthis,:);  % this_x is just the matrix in pixel coordinates instead of degrees
    this_s = ss(Lthis,:); % this is a matrix of random #s - starting positions
    % 1 group of dots are shown in the first frame, a second group are
    % shown in the second frame, a third group shown in the third
    % frame, then in the next frame, some percentage of the dots from
    % the first frame are replotted according to the speed/direction
    % and coherence, the next frame the same is done for the second
    % group, etc.

    % compute new locations
    this_s = this_s + dxdy;	% offset the selected dots

    % wrap around - check to see if any positions are greater than one or less than zero
    % which is out of the aperture, and then replace with a dot along one
    % of the edges opposite from direction of motion.
    L = sum((this_s > 1 | this_s < 0)')' ~= 0;
    if sum(L) > 0
        xdir = sin(pi*gData.dot.dir/180.0);
        ydir = cos(pi*gData.dot.dir/180.0);
        % flip a weighted coin to see which edge to put the replaced dots
        if rand < abs(xdir)/(abs(xdir) + abs(ydir))
            this_s(L,:) = [rand(sum(L),1) (xdir > 0)*ones(sum(L),1)];
        else
            this_s(L,:) = [(ydir < 0)*ones(sum(L),1) rand(sum(L),1)];
        end
    end
    this_x = floor(d_ppd * this_s);	% pix/ApUnit

    % this assumes that zero is at the top left, but we want it to be
    % in the center, so shift the dots up and left, which just means
    % adding half of the aperture size to both the x and y direction.
    %shift = repamt(d_ppd/2,
    gData.dot.dot_show{cpt} = (this_x - d_ppd/2)';

    % update the arrays so xor works next time...
    xs(Lthis, :) = this_x;
    ss(Lthis, :) = this_s;

    continue_show = continue_show - 1;
    % increment
    cpt = cpt + 1;
end

