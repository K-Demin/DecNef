function log_collector()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The role of this function is to keep track of what was executed for each
% participant during the experiment. so, here we will keep a log of the
% parameters that were fed to the collector() and collector_RS() functions.
% Konstantin "Kostya" Demin UPD:
% Now log_collector also sets project_folder as a global variable 
% to improve transportability of the script
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This generated the order of the 20 first participant.
% this do not need to be rerun. The name of the participant can be simply
% added to the list below and the group information will be fetched from
% the "participant_order.mat" file directly (double blind).

% generateOrder(20)

list = {'AB_Pilot'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is a participant template that can be used:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
participant = 'AB_Pilot';

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

% RestingState
collector_RS(participant, day, 1, 1)

% RT Intensity
collector_Int_RT(participant, day, 'Calibrate_Intensity', 1, 1)
collector_Int_RT(participant, day, 'Intensity', 1, 1)

%%%%%%%%%%
% Day 2
%%%%%%%%%%
day = 2;

% Neurofeedback
collector(participant, day, 1, condition)
