%% runs dynamic model on sequences of heat stimuli from example data set
% Does not do any fitting, uses the median parameters estimates from study IE 
% Regress out the effects of temperature from the pain ratings before running the model!
% output predAll has predicted dynamics per subject 

% VT: takes as input the d matrix produced in calib_data or
% behavioral_3conds and controls for the effects of size-specific and site
% non-specific sensitization and habituation, returning RHO (correlation
% between predicted and observed values, giving % of variance explained
% when squared) and all the predicted intensity ratings according to the model. 

function [predAll2,RHOsq,correction,xParMin] = RunModel(d)

%% load data---------------------------------------------

%load ExampleData.mat % example data with 64 trials/38 subjects 
% columns: [1] Subject, [2] temp, [3] site, [4] pain residuals (temp regressed out)
% in this data set there is a break (10x more decay) after every 16 trials 

% VT: create data matrix by removing cols 2 and 5.
data = [d(:,1) d(:,3) d(:,4) d(:,6)];

%d_cal columns = 1)ID  
%                2)trialnum 
%                3)temperature
%                4)armspot
%                5)int_0to200
%                6)stats.resid


%create new subject numbers
%TV: is this necessary/can be removed?
sub = zeros(size(data,1),1);
for i=1:length(sub)
    sub(i) = find(unique(data(:,1))==data(i,1));
end

%% set parameters, use median estimates from IE 
%TV: what is IE?

% VT: input these values as output from ModelFit_calibrationData
[params] = ModelFit_CalibrationData(d);
xParMin = params(1:4);

%  xParMin(1) = 0.0501; % signed magnitude of site-nonspecific adaptation
%  xParMin(2) = -2.026; % signed magnitude of site-specific adaptation  
%  xParMin(3) = 0.815;  % site-nonspecific decay rate (inverse)
%  xParMin(4) = 0.324;  % site-specific decay rate (inverse)
 
%  xParMin(1) = 0.05; % signed magnitude of site-nonspecific adaptation
%  xParMin(2) = 0; % signed magnitude of site-specific adaptation  
%  xParMin(3) = 0.81;  % site-nonspecific decay rate (inverse)
%  xParMin(4) = 0;  % site-specific decay rate (inverse) MR:I think 1 means no decay

% Intercept (Bomin?)

%% run model using fixed pars

NumTrials = size(data,1); % calib - 28; behav - 36
% decay = 0; %1 for decaying all sites, 0 for decaying only the stimulated site, does not matter here
offset = 0; % baseline temp for temperature dependence of dynamics

for s=1:max(sub) % for each subject (only one at a time here)
    
    % mark first trial 
    reset = [1;zeros(NumTrials-1,1)]; 
     
    % Mark new run (needed for additional decay between runs)
    NewRun = zeros(NumTrials,1);
    %NewRun(16:16:48)=1; % here assume runs of 16 trials, ADAPT!
    NewRun(end) = 1;
    
    target = zeros(NumTrials,1);
    pred = zeros(NumTrials,1);
    
    [target, pred, Cs, Phcom] = habitsens(xParMin,data(sub==s,3),data(sub==s,2),data(sub==s,4),reset,NewRun, offset);
    
    targetAll(:,s) = target; % observed data per subject
    predAll(:,s) = pred; % predictions per subject % the sum of CsAll and PhAll. 
    CsAll(:,s) = Cs'; % Site-nonspecific sensitization per subject VT: separate predictions.
    PhAll(:,s) = Phcom'; % Site-specific habituation per subject

end

%% plot mean predicted pain dynamics

predAll2 = mean(predAll,2); % Average across subjects (1 col per subject, to be done possibly later with lots of subjects)

figure(61)
plot(predAll2,'ko-','MarkerEdgeColor','k','MarkerFaceColor','r')
xlabel('Trial Number')
ylabel('Effects of repeated stimulation')
title('Corrected predicted and observed ratings (both controlling for temperature)', 'fontsize', 18);
hold on;
plot(targetAll,'bo-','MarkerEdgeColor','r','MarkerFaceColor','b');


[RHOsq,PVAL] = corr(predAll2,targetAll);


%VT: calculate the difference between corrected predicted and observed
%ratings and return this value. This will be a correction to apply to the
%uncorrected observed ratings in the pain_calib script.

correction = targetAll - predAll2; % we will subtract this from the original observed data.

% VT: square RHO to obtain the %of variance explained by the
% habituation/sensitization model. 

% On enleve predall2 des ratings (0 a 200).
% on fait glmfit(predall2,ratings(0 a 200)), on prend les residuels, qui
% representent la deviation des ratings predits des ratings bruts. 

% on peut faire plein d'affaires.
% we plot the residuals (contain the data of the effects of the task
% (temperature in calib; task condition in behav)) as a function of
% temperature to find the exp fcts we need to setting the temperatures for
% behav session. 

end

