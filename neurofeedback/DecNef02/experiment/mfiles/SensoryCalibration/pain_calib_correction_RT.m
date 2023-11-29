function [calib_Output, models] = pain_calib_correction_RT(calib_data, folder_path, participant, day, dec_score)

%% This is an adaptation of pain_calib_correction_RT.
% The idea is to predict the ratings from the predicted brain activity.
        
fprintf(['\n=' folder_path '=']);

warning off

fprintf('\n======================================================================================');
fprintf('\n=                                                                                    =');
fprintf('\n=                                      Calibration results                           =');
fprintf('\n=                                                                                    =');
fprintf('\n=                                                                                    =');
fprintf('\n======================================================================================\n');

color_vec = {'r', 'g', 'b', 'm', 'k', 'c', 'y', 'r', 'g', 'b', 'm', 'k', 'c', 'y' };
calib_data_names = { 'temperature' 'spot' 'pain=1' 'removed~=1' 'ratings_warmth_or_int' 'unp' 'rating_RT' 'unp_RT' 'trial_num' 'int_0to200' 'int_justpain'};

% Remove trials where the participant did not answer (stored in
% calib_data(:,4)
k = 0;
removed_trials = [];
for i=1:size(calib_data,1)
    if calib_data(i,4) ~= 1
        k = k + 1;
        removed_trials(k) = i;

    end
end

% If there are trials to remove:
if ~isempty(removed_trials)
    % remove these trials altogether.
    calib_data(removed_trials,:) = [];
    dec_score(removed_trials,:) = [];
end

%everything put on same scale
% It just essentially adds 100 to the painful trials
clear ratings_0to200
for i = 1:size(calib_data, 1)
    if calib_data(i,3) == 1
        ratings_0to200(i,1) = calib_data(i,5) + 100;
    else
        ratings_0to200(i,1) = calib_data(i,5);
    end
end
calib_data = [calib_data ratings_0to200];

%% VT: d matrix and controlling for effects of sensitization-habituation

% create d matrix.
% Data matrix for use with Marieke's script
% create a matrix d_cal that contains all the info needed to regress out
% habituation and sensitization effects with Marieke's script afterwards.

% Column 1: ID number
% Column 2: Trialnumber (1 to 36)
% Column 3: temperature (absolute heat or pain temperature)
% Column 4: Armspot (1 to 4)
% Column 5: pain rating
% Column 6: pain residual.(derived from glmfit)

d_cal = [];
%ID = str2num(folder_path(end-15:end-12));
ID = 9999;
d_cal = ID*(ones(size(calib_data,1),1)); % Save participant ID
    
d_cal = [d_cal calib_data(:,9) calib_data(:,1) calib_data(:,2) calib_data(:,10)];

% regress pain rating on temperature (0 to 200)
[b,dev,stats]= glmfit([d_cal(:,3) d_cal(:,3).^2]  ,d_cal(:,5));
d_cal = [d_cal stats.resid];

scriptdir = '/media/vtd/Pain_DecNef/Share/Neurofeedback/DecNef02/experiment/mfiles/SensoryCalibration';

%cd ../..

%% ******************************

[predAll,RHOsq,correction,xParMin] = RunModel(d_cal);
close
%snapnow;

% Remove the variance associated with predAll from the ratings.
[b,dev,stats_corr] = glmfit(predAll, ratings_0to200);

pred_y = stats_corr.resid; % MR- we are supposed to take these residuals and plot them,
% but what exactly do they represent?



%% Observed ratings with correction

% The predicted dynamics output from Marieke's script describe the temporal
% dynamics of sensation, controlling for temperature. The predicted values
% all reduce the extreme values in the uncorrected, temperature-controlled
% dynamics. Subtracting the observed from predicted values gives us a
% correction vector, that when applied to the non-temperature controlled
% dynamics, remove some of the effects sensitization and habituation in ratings.

%ratings = {ratings_0to200 ratings_0to200-correction};
% or
% According to MR:
ratings = {ratings_0to200 pred_y+stats_corr.beta(1)};

% Column 1: observed ratings
% Column 2: corrected ratings.

% Run the following analyses on both rating scales.
label = {'SIIPS','NPS'};
%%

calib_output.obs_ratings0to200 = ratings_0to200;
calib_output.corr_ratings0to200 = pred_y+stats_corr.beta(1);
calib_output.temps = calib_data(:,1);
calib_output.dec_score = dec_score;

models = {};

for ppp = 1:length(label)
    %*********************

    fprintf(['\n ' label{ppp} ' decoder ...']);
    % Predict the ratings from the decoded score
    x = dec_score(:,ppp); 
    % Here we will only use the corrected ratings
    y = ratings{2};

    %close all; 
    clear scrsize; scrsize = get(0, 'ScreenSize');
    figure('Name', 'calibration 0 to 200', 'Position', [1, 1, scrsize(3)/2,scrsize(4)/2]);
    scatter(x,y); hold on;

    % fit linear function
    mdl = fitlm(x,y);

    sserr(ppp) = mdl.SSE;
    p_0to200{ppp} = table2array(mdl.Coefficients('x1','pValue'));
    
    % This is to use the predicted values to determine the min and max
    predMin = min(x);
    predMax = max(x);
    diffInt = predMax - predMin;
    IntSteps = diffInt/10;  
    
    exp_x = predMin:IntSteps:predMax;
    exp_y = predict(mdl,exp_x');
    % Plot the fit of the linear function
    plot(exp_x, exp_y, 'b','LineWidth', 3); hold on;

    %VT: display exp functions below
    text(40,180,strcat('y = 1 + X1'));
    saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_',label{ppp},'_prediction.png']);

    models{ppp} = mdl;
    close all
end

%*********************

fprintf(['\n Both decoders now ... \n']);

% Now both decoders are independent variables
x = dec_score; 
% Here we will only use the corrected ratings
y = ratings{2};

% fit linear function
mdl = fitlm(x,y);

sserr(3) = mdl.SSE;
p_0to200{3} = table2array(mdl.Coefficients('x1','pValue'));

models{3} = mdl;

% Things to take out of here:
calib_Output.models = models;
calib_Output.sserr = sserr;
calib_Output.p_0to200 = p_0to200;


