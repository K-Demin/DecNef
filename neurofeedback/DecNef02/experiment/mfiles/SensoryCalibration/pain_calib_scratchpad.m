    % This script calls a pain calibration function "pain_calib.m" through an
% intermediate script "publish_pain_calib.m" and creates an output .html
% file under a new folder called "calibration_html_output". All these
% scripts must be placed in a "sctipts" folder in your basedir.
%
% see help in "pain_calib.m"
%
% Mathieu Roy, July 22th 2014

clear all; clc; close all;
if ispc % checks whether this file is on a pc or not.    
    % if we are on a pc, set the base directory to the one one Mathieu's
    % laptop I was using.
   % basedir =  'C:\Users\labo-prainville\Desktop\PCDC\PCDC_data/';
   
   %basedir = 'C:\Users\labo-prainville\Desktop\Exercice\Exercice_data\';
   basedir = pwd; %Tav
else
    % If we are on a mac, use below: 
    %basedir = '/Users/VTabry/Dropbox/Vanessa_Mathieu/Pain_exec_data/';
    basedir = pwd
end

% VT: added Dec 22
%addpath(genpath('C:\Users\labo-prainville\Desktop\PCDC\PCDC_data\scripts'));
%addpath(genpath('C:\Users\labo-prainville\Desktop\Exercice\Exercice_data\scripts'));
addpath(genpath(pwd))

%% Multiple subjects

%   subjects_to_run = {'0001', '0002', '0003','0004' ,'0005','0006','0007',...
%  '0008', '0009','0010','0011','0012','0013','0014','0015','0016','0017',...
%  '0018','0019','0020','0021','0022','0023','0024','0025','0026','0027',...
%  '0028','0029','0030','0031','0032','0033','0034','0035','0036','0037',...
%  '0038','0039','0040','0041','0042','0043','0044','0045','0047','0048',...
%  '0049', '0050','0051','0052','0053','0054','0055','0057','0058','0059','0060',...
%  '0061','0062','0064','0065','0066','0067','0068','0069','0070','0071','0072',...
%  '0073','0074','0075','0076','0077','0078','0079','0081','0082','0083',...
%  '0084','0085','0086','0088','0090','0091','0094','0095','0096'};

%% Subjects********************************************************

   subjects_to_run = {'0072'};

%% *******************************************************************   
   
 F_to_run = ones(size(subjects_to_run)); % F = 1 to analyse eprime data only, F = 2 for medoc only, F = 3 for both 
 remove_last_temp_to_run = 2.*ones(size(subjects_to_run)); %2 = remove last temp that figures in MEDOC_results 


for i=1:length(subjects_to_run) % Run a loop where each participant is analyzed separately and a html file is created and stored in their respective files. 

    
    F = F_to_run(i);
    remove_last_temp = remove_last_temp_to_run(i);
    
%%pour le html
    %subdir = [basedir 'subject_' subjects_to_run{i} '/calibration']; 
    subdir = [basedir '/subject_' subjects_to_run{i} '/calibration'];
    
    scriptname = 'publish_pain_calib.m';
    scriptdir = fullfile(basedir, '/scripts'); %les fichiers scripts (publish et plugin) doivent ?tre dans le fichiers "scripts"
    addpath(scriptdir);
         
   outputdir = [subdir  '/calibration_html_output']; %creer un folder html dans lequel tout est mis 
    mkdir(outputdir);

       
    p = struct('useNewFigure', false, 'maxHeight', 1500, 'maxWidth', 1200, ...
        'outputDir', outputdir, 'showCode', false); % struct with the output file parameters, to be passed to 'publish' later.
%%  
    display(subdir);
    publish(scriptname, p); % run publish_pain_calib with the p struct containing customized output options. 
    
    
end


display('done');
