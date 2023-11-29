% Marieke's script
%% VT: 
% This function calls habitsens then findParamMin, using the d data matrix input.

function [params] = ModelFit_CalibrationData(d)

 fprintf('\nRun modelfit calibdata');

 % d, cols = subject, trial, temp, site, pain, pain residual
 
 
 %% load data
 %load CalData.mat % d, cols = subject, trial, temp, site, pain, pain residual

 %% %VT: where pain is from 0 to 100

% VT: for debugging
%d = calib_output.eprime_data.d;

%% VT: not happening because fitting will be done to each participant individually 

 %create new subject numbers
 sub = zeros(size(d,1),1);
 for i=1:length(sub)
     sub(i) = find(unique(d(:,1))==d(i,1));
 end
 subject = unique(d(:,1));
% %%


%% set fitting parameters and model

decay = 1; %1 for decaying all sites, 0 for decaying only the stimulated site    %MR will check whether this is correct?
offset = 0; %neutral point for temperature dependence of dynamics; set to 0 for no dependence

Lower = [-100 -100 0 0]; %parameter bounds
Upper = [100 100 1 1]; %parameter bounds
SubsetiPar = 100; % # of parameter starting points

%Fmincon options
options = optimset(@fmincon);

% VT: fmincon varies a set of parameters to reduce to a minimum the SSe errors
% produced by the terms found in the equation. More complex than a MR
% equation, with terms that can be exponential, quadratic, etc. it's a
% model. In comparison to MR, one term will influence another (sequential
% aspect). 

options = optimset(options, 'TolX', 0.00001, 'TolFun', 0.00001, 'MaxFunEvals', 900000000,'Display', 'off','Algorithm','active-set'); %turn off display

%% fit individual subjects
for s= 1:max(sub)
        
    % reset = [1;zeros(23,1)]; %mark first trial for this subject, CHANGE 23 to # trials-1!!
    %reset = [1;zeros(27,1)]; %mark first trial for this subject, CHANGE 23 to # trials-1!!
    % VT: below, changed to number of trials per run. but might need to be
    % set manually if we run this analysis on a large series of
    % concatenated runs
    reset = [1;zeros(length(d)-1,1)]; %mark first trial for this subject, CHANGE 23 to # trials-1!!
    
    
    nxPar=4; %number of parameters
    xPar=zeros(SubsetiPar,nxPar); %parameters found in each search iteration
    SSE=zeros(SubsetiPar,1); %minimum SSE from each search iteration
    Bo = zeros(SubsetiPar,1);
    
    %VT: iPar below: initial parameters, starting point in space. 
    iPar = [random('Uniform',-10,10,SubsetiPar,2) random('Uniform',0,1,SubsetiPar,2)]; %randomly draw initial values for parameters
    
    for iter = 1:SubsetiPar % VT: produces a 30 x 4 matrix with 30 sets of the 4 parameters, one row for each iteration.
        [xPar(iter,1:nxPar), SSE(iter), Bo(iter)]=fmincon(@habitsens_fit, iPar(iter,:), [], [], [], [], Lower, Upper, [], options, d(sub==s,4), d(sub==s,3), d(sub==s,6), reset, decay, offset, 0);
    end
    
    % VT: finds the set out of the 30 that minimizes SSe. 
    [xParMin, SSEMin, BICMin, Bomin] = FindParamMin(xPar,SSE, Bo, length(d(sub==s)));
    
    params(s,1:length(xParMin))=xParMin; % minimal parameters (the solution)
    params(s,1+length(xParMin):1+length(xParMin))=SSEMin; % SSe associated to minimal solution
    params(s,2+length(xParMin):2+length(xParMin))=BICMin;  % Bayesian information critera (estimate of fit weighted by free factors)
    params(s,3+length(xParMin):3+length(xParMin))=Bomin; % Intercept (?)
    
    disp(['Nonspecific mag = ' num2str(xParMin(1)) ', Site-specific mag = ' num2str(xParMin(2)) ', Nonspecific decay = ' num2str(xParMin(3)) ', Site-specific decay = ' num2str(xParMin(4))])
    
end






end
% save Output/FitParameters params
