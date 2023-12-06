function log_display()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The role of this function is to keep track of what was executed for each
% participant during the experiment. so, here we will keep a log of the
% parameters that were fed to the display_exp() function.
% Konstantin "Kostya" Demin UPD:
% Now log_display also sets project_folder as a global variable 
% to improve transportability of the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This generated the order of the 20 first participant.
% this do not need to be rerun. The name of the participant can be simply
% added to the list below and the group information will be fetched from
% the "participant_order.mat" file directly (double blind).

% generateOrder(20)

list = {'AB_Pilot'};

% % % This is a participant template that can be used:
% name = '02_ZZZ';
% 
% % Find the index of the participant's name in the list.
% index = find(strcmp(list, name));
% 
% % Load the participant order.
% participant_order = load('Y:\Neurofeedback\DecNef02\experiment\participant_order.mat');
% 
% % Get the condition associated with that participant.
% condition = participant_order(index);

%%this is a value range for the electrical stim
%noPainInt = 0.15;
%painMin = 0.30;
%painMax = 0.66;

%%This isi for the thermal stimulator
% noPainInt = 430;
% painMin = 450;
% painMax = 490;

% Parameters are:
% display_exp(participant, task, day, painStim, stimType, noPainInt, painMin, painMax, condition)
% see the header of the display_exp() function for details.
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Common parameters for participant:
% sub01_zzz
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a participant template that can be used:
participant = 'AB_Pilot';

painStim = 1; % stimulations will be delivered.
stimType = 'Thermal'; % Technically the code can also manage 'Electrical' but this is not to be used for this experiment.
noPainInt = 42.0;
painMin = 45.0;
painMax = 48.0;

% Find the index of the participant's name in the list.
index = find(strcmp(list, participant));

% Load the root_folder in the workspace
global project_folder; 
scriptPath = mfilename('fullpath');
[pathToScript, ~, ~] = fileparts(scriptPath);
project_folder = fileparts(fileparts(fileparts(pathToScript)));


% Load the participant order.
load(fullfile(project_folder, 'neurofeedback', 'DecNef02', 'experiment', 'participant_order.mat'));

% Get the condition associated with that participant.
condition = participant_order(index);

%%%%%%%%%%
% Day 1
%%%%%%%%%%
day = 1;

% RestingState (10 min)
display_exp(participant, 'Resting_State', day, painStim, stimType, noPainInt, painMin, painMax, condition)

% Calibrate_Intensity_RT (8-9 min)
display_exp(participant, 'Calibrate_Intensity_RT', day, painStim, stimType, noPainInt, painMin, painMax, condition)

% Calibrate 2 IFC (6-7 min)
display_exp(participant, 'Calibrate_TwoIFC', day, painStim, stimType, noPainInt, painMin, painMax, condition)

% Two IFC (20 min)
display_exp(participant, 'TwoIFC', day, painStim, stimType, noPainInt, painMin, painMax, condition)

% Intensity_RT (12.5 min)
display_exp(participant, 'Intensity_RT', day, painStim, stimType, noPainInt, painMin, painMax, condition)


%%%%%%%%%%
% Day 2
%%%%%%%%%%
day = 2;

% RestingState (10 min)
display_exp(participant, 'Resting_State', day, painStim, stimType, noPainInt, painMin, painMax, condition)

% Neurofeedback
display_exp(participant, 'Neurofeedback', day, painStim, stimType, noPainInt, painMin, painMax, condition)


