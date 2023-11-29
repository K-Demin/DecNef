function [calib_output] = pain_calib_correction_VTD(calib_data,folder_path,participant,day,stimType)

%% VTD edits: december 2020:
% So it seems that this scripts has had multiple layers of editing.
% This script will first computed corrected rating values after accounting
% for a sequence effect of time. These values are held in ratings = {};\
%
% Then, the for loop will first use the actual ratings and then the
% corrected ones.
% It will fit an exponential curve to the data, and return the predicted
% intensities for different rating values. That is what we are hoping to
% get out of here: the intensity associated to a rating of 140 (pain of
% 40).


switch stimType
    case 'Thermal'
        calib_data(:,1) = calib_data(:,1)/100;
end
        
        
fprintf(['\n=' folder_path '=']);

warning off

fprintf('\n======================================================================================');
fprintf('\n=                             Calibration results                                    =');
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
end

% Put everything on the same scale.
% Essentially, add 100 to the painful trials
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
% Column 2: Trialnumber (1 to 14)
% Column 3: temperature (absolute heat or pain temperature)
% Column 4: Armspot (1 to 4)
% Column 5: pain rating
% Column 6: pain residual.(derived from glmfit)

d_cal = [];

ID = 9999;
d_cal = ID*(ones(size(calib_data,1),1));  
d_cal = [d_cal calib_data(:,9) calib_data(:,1) calib_data(:,2) calib_data(:,10)];

% regress pain rating on temperature (0 to 200)
[b,dev,stats]= glmfit([d_cal(:,3) d_cal(:,3).^2]  ,d_cal(:,5));
d_cal = [d_cal stats.resid];

scriptdir = '/media/vtd/Pain_DecNef/Share/Neurofeedback/DecNef02/experiment/mfiles/SensoryCalibration';


%% 

[predAll,RHOsq,correction,xParMin] = RunModel(d_cal);
saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_Corrected_predicted_and_observed.png']);
close all
%snapnow;

% Remove the variance associated with predAll from the ratings (get the
% residuals)
[b,dev,stats_corr] = glmfit(predAll, ratings_0to200);
pred_y = stats_corr.resid;

% plot pred_y(residual) as a function of temperature.
figure;
scatter(calib_data(:,1),pred_y+stats_corr.beta(1)); hold on;

scatter(calib_data(:,1),calib_data(:,10)); % Plot original ratings for comparison
title('Residual of predicted rating on observed rating+ Beta','fontsize',16,'fontweight','bold');
legend('Residual','observed','location','northwest');
saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_Residual.png']);
close all
%snapnow;

%% Observed ratings with correction

% The predicted dynamics output from Marieke's script describe the temporal
% dynamics of sensation, controlling for temperature. The predicted values
% all reduce the extreme values in the uncorrected, temperature-controlled
% dynamics. Subtracting the observed from predicted values gives us a
% correction vector, that when applied to the non-temperature controlled
% dynamics, remove some of the effects sensitization and habituation in ratings.

figure %
scatter(calib_data(:,1),pred_y+stats_corr.beta(1),color_vec{4}) % pink
hold on;
scatter(calib_data(:,1),calib_data(:,10),color_vec{3}) % blue % Plot original ratings for comparison
title('Non-temperature-adjusted observed ratings minus correction','fontsize',16,'fontweight','bold');
legend('corrected','observed','location','northwest');
saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_Non_adjusted_Ratings.png']);
close all

%ratings = {ratings_0to200 ratings_0to200-correction};
% or
% According to MR:
ratings = {ratings_0to200 pred_y+stats_corr.beta(1)};

% Column 1: observed ratings
% Column 2: corrected ratings.

% Run the following analyses on both rating scales.
label = {'Observed','Corrected'};
%%

calib_output.eprime_data.obs_ratings0to200 = ratings_0to200;
calib_output.eprime_data.corr_ratings0to200 = pred_y+stats_corr.beta(1);
calib_output.eprime_data.temps = calib_data(:,1);

for ppp = 1:length(ratings)
    %*********************
    fprintf('\n===================================================\n');
    fprintf(['\n          ' label{ppp} ' ratings                    ']);
    fprintf('\n===================================================\n');

    x = calib_data(:,1)'; 
    y = ratings{ppp}';

    fprintf('\n   ratings collapsed on a scale from 0 to 200');
    fprintf('\n===================================================\n');

    %close all; 
    clear scrsize; scrsize = get(0, 'ScreenSize');
    figure('Name', 'calibration 0 to 200', 'Position', [1, 1, scrsize(3)/2,scrsize(4)/2]);
    scatter(x,y); hold on;

    % fit exponential function
    expfun = inline('p(1)*exp(p(2)*x)','p','x');


    funhandle = @(p, x) expfun(p, x);               % function handle to pass in
    [p,sse,fit] = nonlin_fit(y,x,'linktype', funhandle,'start',[1 1]);


    sserr(ppp) = sse;
    p_0to200{ppp} = p;
    
    % This is to use the intensities that were actually delivered to build
    % the graphs and get the thershold.
    IntMin = min(calib_data(:,1));
    IntMax = max(calib_data(:,1));
    diffInt = IntMax - IntMin;
    IntSteps = diffInt/10;  
    
    exp_x = IntMin:IntSteps:IntMax;
    exp_y = p(1)*exp(p(2)*exp_x);
    % Plot the fit of the exponential function
    plot(exp_x, exp_y, 'b','LineWidth', 3); hold on;

    %VT: display exp functions below
    text(40,180,strcat('y =',num2str(p(1)), '*exp(', num2str(p(2)), '*x)'));

    clear exp_x exp_y
    
    switch stimType
        case 'Thermal'
             steps = (IntMax+0.5)/1000;
             exp_x = 0:steps:IntMax+0.5;
             exp_y = p(1)*exp(p(2)*exp_x);
        case 'Electrical'
             steps = (IntMax*2)/200;
             exp_x = 0:steps:IntMax*2;
             exp_y = p(1)*exp(p(2)*exp_x);
    end

    %detect pain threshold
    k = 0;  thresholds = [10:10:200]; clear deciles; %ADD THIS BACK IN FOR REAL THING
    deciles = [];
    %for i = 1:length(exp_x)
    for i = 2:length(exp_x)
        for j = 1:length(thresholds)

            if exp_y(i) > thresholds(j) && exp_y(i-1) < thresholds(j)
                k = k + 1;
                deciles(k, 1) = thresholds(j); deciles(k, 2) = exp_x(i);
                break
            end
        end
    end
    deciles0to20{ppp} = deciles;

    threshold{ppp} = deciles(find(deciles(:,1) == 140),2);

    plot([deciles(find(deciles(:,1) == 140),2) deciles(find(deciles(:,1) == 140),2)+0.000000000001], [0 200], 'r'); hold on;
    plot([IntMin IntMax], [140 140.00000000000001], 'r'); hold on;
    title(['Ratings as a function of temperature-' label{ppp}],'fontsize',16,'fontweight','bold');

    drawnow;
    saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_Rating_curve_fit_',label{ppp},'.png']);
    close all

    fprintf(['\n  ' label{ppp} ' ratings: ']);

    fprintf('\n temperatures corresponding');
    fprintf('\n to ratings from 10 to 200 ');
    fprintf('\n ==========================');
    fprintf('\n    rating     temperature ');


    for i = 1:size(deciles, 1)
        if deciles(i,1) < 100
            fprintf(['\n      ' num2str(deciles(i,1)) '           ' num2str(deciles(i,2)) '']);
        else
            fprintf(['\n      ' num2str(deciles(i,1)) '          ' num2str(deciles(i,2)) '']);
        end
    end
    fprintf('\n ==========================\n');
    
    % VTD edit: 
    % Temperature corresponding to a rating of 140. To be used in the
    % following experiment.
    if strcmp(label{ppp},'Corrected')
        % If we are dealing with the thermal stimulator, multiply this
        % value by 100 (we divided by 100 above).
        switch stimType
            case 'Thermal'
                ExpTemp = deciles(find(deciles(:,1) == 140),2)*100;
            case 'Electrical'
                ExpTemp = deciles(find(deciles(:,1) == 140),2);
        end
        
    end


    %% Calculate fit of the curve

    % Use mean-squared error. loop through x.
    % for each point, y(i) - x* exponential function. add to a sum value.
    % Outside the loop, divide by number of points for the MSE.

    % the function is the following:
    % exp_x = 0:0.1:60;
    %  exp_y = p(1)*exp(p(2)*exp_x);

    % but we need to check if there<s an intercept to add - no intercept.

    % alternatively we have this:
    exp_y_tofit = p(1)*exp(p(2)*x);

    SSE = 0;

    % scatter(x,exp_y_tofit,'m');
    % hold on;
    % scatter(x,y,'c');

    for i = 1:length(y)
        Esq = (exp_y_tofit(i) - y(i))^2;
        SSE = SSE + Esq;
    end
    MSE = SSE/length(y);

    calib_output.eprime_data.fit.(label{ppp}) = MSE;

    %% ********************************
    %%
    %now just pain
    clear ratings_justpain
    for i = 1:size(calib_data, 1)
        if calib_data(i,3) == 0
            % if y(i) > 99 % if the rating is above pain threshold,
            ratings_justpain(i,1) = 0; % set the heat value to 0 in the first column
        else
            %ratings_justpain(i,1) = calib_data(i,5);
            ratings_justpain(i,1) = y(i)-100;

        end
    end

    ratings_justpain(:, 2) = calib_data(:,6); % unpleasantness
    calib_data = [calib_data ratings_justpain];

    % in Ratings_justpain, the second column is always uncorrected
    % unpleasantness. The first column will variably be observed or corrected
    % pain intensity.

    fprintf(['\n   ' label{ppp} ' ratings: ']);
    fprintf('\n  intensity and unpleasantness separate - just pain');
    fprintf('\n===================================================\n');


    %close all;
    figure('Name', ['intensity and unpleasantness-',label{ppp}], 'Position', [1, 1, scrsize(3)/2,scrsize(4)/2]);

    colors = {'b', 'r'};
    clear deciles; deciles(:, 1) = [10:10:100]';


    for ii = 1:size(ratings_justpain, 2)

        %x = calib_data(:,1)'; % this has already previously been set
        y = ratings_justpain(:, ii)';
        scatter(x,y, colors{ii}); hold on;
        title(['Ratings - just pain -' label{ppp}],'fontsize',16,'fontweight','bold');


        % fit exponential function
        clear p;
        expfun = inline('p(1)*exp(p(2)*x)','p','x');
        funhandle = @(p, x) expfun(p, x);               % function handle to pass in
        [p,sse,fit] = nonlin_fit(y,x,'linktype', funhandle,'start',[1 1]);

        p_int_unp{ppp}(ii,:) = p;

        clear exp_x exp_y

        exp_x = IntMin:IntSteps:IntMax;
        exp_y = p(1)*exp(p(2)*exp_x);
        plot(exp_x, exp_y, colors{ii},'LineWidth', 3); hold on;

        clear exp_x exp_y
        steps = (IntMax*2)/200;
        exp_x = 0:steps:IntMax*2;
        exp_y = p(1)*exp(p(2)*exp_x);

        %detect pain threshold
        k = 0;  thresholds = [10:10:100];
        deciles = [];
        deciles_column = [];
        for i = 2:length(exp_x) %CHANGE BACK TO 1???
            for j = 1:length(thresholds)
                if exp_y(i) > thresholds(j) && exp_y(i-1) < thresholds(j)
                    k = k + 1;
                    deciles_column(k,1) = exp_x(i) ;
                    deciles(k, 1) = thresholds(j); deciles(k, 2) = exp_x(i);
                    break
                end
            end
        end
        deciles = [deciles deciles_column];

    end

    legend('intensity', 'intensity', 'unpleasantness', 'unpleasantness', 'Northwest');

    drawnow;
    saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_Ratings_just_pain_',label{ppp},'.png']);
    close all

    %snapnow;
    %close all;

    fprintf(['\n  ' label{ppp} ' ratings: ']);
    fprintf('\n temperatures corresponding');
    fprintf('\n to ratings from 0 to 100 ');
    fprintf('\n ==========================');
    fprintf('\n  rating     int     unp ');
    for i = 1:size(deciles, 1)
        if deciles(i,1) < 100
            fprintf(['\n    ' num2str(deciles(i,1)) '       ' num2str(deciles(i,2)) '    ' num2str(deciles(i,3)) '']);
        else
            fprintf(['\n   ' num2str(deciles(i,1)) '       ' num2str(deciles(i,2)) '    ' num2str(deciles(i,3)) '']);
        end
    end
    fprintf('\n ==========================\n');

    deciles_{ppp} = deciles;



    %% Now check order effects
    clear temp_per_temp
    fprintf(['\n' label{ppp} ' ratings: ']);

    fprintf('\n                 order and site effects                 ');
    fprintf('\n======================================================\n');

    %sort per order

    num_repeat = 1; num_temp = 1;
    sorted_temps = sortrows(calib_data,1); temp_per_temp{1,num_temp}(num_repeat,:) = sorted_temps(1,:);

    for i = 2:size(sorted_temps,1)
        if sorted_temps(i,1) == sorted_temps(i-1,1)
            num_repeat = num_repeat + 1;
            temp_per_temp{1,num_temp}(num_repeat,:) = sorted_temps(i,:);
        else
            num_repeat = 1; num_temp = num_temp + 1;
            temp_per_temp{1,num_temp}(num_repeat,:) = sorted_temps(i,:);
        end
    end
    color_vec = {'r', 'g', 'b', 'm', 'k', 'c', 'y', 'r', 'g', 'b', 'm', 'k', 'c', 'y' };
    legend_names = [];


    fprintf('\n         order effects for each temperature           ');
    fprintf('\n======================================================\n');

    figure('Name', 'order effects per temperature', 'Position', [1, 1, scrsize(3)/2,scrsize(4)/2]);
    for i = 1:length(temp_per_temp)
        y = sortrows(temp_per_temp{1,i}, 9);
        temp_per_temp{1,i}(:, end + 1) = [1:1:size(temp_per_temp{1,i}, 1)]';
        legend_names{1,i} =  num2str(temp_per_temp{1,i}(1,1));
        plot([1:1:size(temp_per_temp{1,i}, 1)], y(:,10)', color_vec{i});hold on ;
    end
    legend(legend_names);

    drawnow;
    saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_Order_Effect_per_temperature_',label{ppp},'.png']);
    close all

    if ppp == 1 % observed ratings


        % test stat signif

        %[b,dev,stats_temp_effects] = glmfit(calib_data(:,1), calib_data(:,10));
        [b,dev,stats_temp_effects_obs] = glmfit(calib_data(:,1), ratings{ppp});

        %[b,dev,stats_ordereffects_tempcov] = glmfit(calib_data(:,9), stats_temp_effects.resid);
        [b,dev,stats_ordereffects_tempcov_obs] = glmfit(calib_data(:,9), stats_temp_effects_obs.resid);

        dummy = [];

        % create dummy for spot
        k = 0; kk = 0; kkk = 0; kkkk = 0;
        for i = 1:length(calib_data)

            if calib_data(i,2) == 1
                dummy(i,:) = [1 0 0];
                k = k + 1; anova_mat_obs(k, 1) = stats_ordereffects_tempcov_obs.resid(i);
            elseif calib_data(i,2) == 2
                dummy(i,:) = [0 1 0];

                kk = kk + 1; anova_mat_obs(kk, 2) = stats_ordereffects_tempcov_obs.resid(i);
            elseif calib_data(i,2) == 3
                dummy(i,:) = [0 0 1];

                kkk = kkk + 1; anova_mat_obs(kkk, 3) = stats_ordereffects_tempcov_obs.resid(i);
            elseif calib_data(i,2) == 4
                % added below VT
                dummy(i,:) = [0 0 0];

                kkkk = kkkk + 1; anova_mat_obs(kkkk, 4) = stats_ordereffects_tempcov_obs.resid(i);
            end
        end


        [b,dev,stats_siteeffects_tempcov_obs] = glmfit(dummy,stats_temp_effects_obs.resid);
        [b,dev,stats_ordereffects_tempcov_sitecov_obs] = glmfit(calib_data(:,9),stats_siteeffects_tempcov_obs.resid);

        fprintf(['\n   for ' label{ppp} ' ratings']);

        fprintf('\n   results of regression models (note: this requires stats toolbox)');
        fprintf('\n====================================================================');
        fprintf('\n           model                       b           t           p    \n');
        fprintf(['\n    temperature effects             '  num2str(stats_temp_effects_obs.beta(2)) '    ' num2str(stats_temp_effects_obs.t(2)) '    ' num2str(stats_temp_effects_obs.p(2))    '']);
        fprintf(['\n  order, controlling temp           '  num2str(stats_ordereffects_tempcov_obs.beta(2)) '    ' num2str(stats_ordereffects_tempcov_obs.t(2)) '    ' num2str(stats_ordereffects_tempcov_obs.p(2))    '']);
        fprintf(['\n order, controlling temp & site     '  num2str(stats_ordereffects_tempcov_sitecov_obs.beta(2)) '    ' num2str(stats_ordereffects_tempcov_sitecov_obs.t(2)) '    ' num2str(stats_ordereffects_tempcov_sitecov_obs.p(2))    '']);
        fprintf('\n====================================================================\n');

        fprintf('\n             site effects - results of ANOVA          ');
        fprintf('\n======================================================\n');

        [p,anova_table_obs,anova_stats_obs] = anova1(anova_mat_obs);

        drawnow;
        saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_Intensity_ANOVA_Table_',label{ppp},'.png']);
        close all

        %snapnow;
        %close all;

        %*********************

        %% prev temp or ratings effects

        [b,dev,stats_prev_temp_obs] = glmfit(calib_data(1:end-1,1), calib_data(2:end,10));
        [b,dev,stats_prev_rating_obs] = glmfit(calib_data(1:end-1,10), calib_data(2:end,10));
        [b,dev,stats_prev_temp_ratingcov_obs] = glmfit(calib_data(1:end-1,1), stats_prev_rating_obs.resid);
        [b,dev,stats_prev_rating_tempcov_obs] = glmfit(calib_data(1:end-1,10), stats_prev_temp_obs.resid);


        fprintf('\n               previous stim and previous rating efects             ');
        fprintf('\n====================================================================');
        fprintf('\n           model                       b           t           p    \n');
        fprintf(['\n  previous temperature effects      '  num2str(stats_prev_temp_obs.beta(2)) '    ' num2str(stats_prev_temp_obs.t(2)) '    ' num2str(stats_prev_temp_obs.p(2))    '']);
        fprintf(['\n    previous ratings effects        '  num2str(stats_prev_rating_obs.beta(2)) '    ' num2str(stats_prev_rating_obs.t(2)) '    ' num2str(stats_prev_rating_obs.p(2))    '']);
        fprintf(['\n    previous temp, rating cov       '  num2str(stats_prev_temp_ratingcov_obs.beta(2)) '    ' num2str(stats_prev_temp_ratingcov_obs.t(2)) '    ' num2str(stats_prev_temp_ratingcov_obs.p(2))    '']);
        fprintf(['\n    previous rating, temp cov       '  num2str(stats_prev_rating_tempcov_obs.beta(2)) '    ' num2str(stats_prev_rating_tempcov_obs.t(2)) '    ' num2str(stats_prev_rating_tempcov_obs.p(2))    '']);
        fprintf('\n====================================================================\n');


    else % working with corrected ratings, ppp = 2

        % same thing as above, but with new variable names.
        % test stat signif

        %[b,dev,stats_temp_effects] = glmfit(calib_data(:,1), calib_data(:,10));
        [b,dev,stats_temp_effects_corr] = glmfit(calib_data(:,1), ratings{ppp});

        %[b,dev,stats_ordereffects_tempcov] = glmfit(calib_data(:,9), stats_temp_effects.resid);
        [b,dev,stats_ordereffects_tempcov_corr] = glmfit(calib_data(:,9), stats_temp_effects_corr.resid);

        clear dummy;
        % create dummy for spot
        k = 0; kk = 0; kkk = 0; kkkk = 0;
        for i = 1:length(calib_data(i,2))
            if calib_data(i,2) == 1
                dummy(i,:) = [1 0 0];
                k = k + 1; anova_mat_corr(k, 1) = stats_ordereffects_tempcov_corr.resid(i);
            elseif calib_data(i,2) == 2
                dummy(i,:) = [0 1 0];
                kk = kk + 1; anova_mat_corr(kk, 2) = stats_ordereffects_tempcov_corr.resid(i);
            elseif calib_data(i,2) == 3
                dummy(i,:) = [0 0 1];
                kkk = kkk + 1; anova_mat_corr(kkk, 3) = stats_ordereffects_tempcov_corr.resid(i);
            elseif calib_data(i,2) == 4
                % VT: added below
                dummy(i,:) = [0 0 0];


                kkkk = kkkk + 1; anova_mat_corr(kkkk, 4) = stats_ordereffects_tempcov_corr.resid(i);
            end
        end

    end
end

calib_output.eprime_data.ratings_justpainunpleas = ratings_justpain;

% VTD edit: 
% Temperature corresponding to a rating of 140. To be used in the
% following experiment.

calib_output.eprime_data.ExpTempOne = ExpTemp;
calib_output.eprime_data.d = d_cal;

switch stimType
    case 'Thermal'
        calib_data(:,1) = calib_data(:,1)*100;
        deciles0to20{1}(:,2) = deciles0to20{1}(:,2)*100;
        deciles0to20{2}(:,2) = deciles0to20{2}(:,2)*100;
        
        calib_output.eprime_data.data = calib_data(:,1:11);
        calib_output.eprime_data.temperature_x_rating0to200_match_obs = deciles0to20{1};
        calib_output.eprime_data.temperature_x_rating0to200_match_corr = deciles0to20{2};
    case 'Electrical'
        calib_output.eprime_data.data = calib_data(:,1:11);
        calib_output.eprime_data.temperature_x_rating0to200_match_obs = deciles0to20{1};
        calib_output.eprime_data.temperature_x_rating0to200_match_corr = deciles0to20{2};
end
      
calib_output.eprime_data.names = calib_data_names;

calib_output.eprime_data.temperature_x_intunp_justpain_match_obs = deciles_{1};
calib_output.eprime_data.temperature_x_intunp_justpain_match_corr = deciles_{2};

calib_output.eprime_data.expfun_params_ratings0to200_obs= p_0to200{1};
calib_output.eprime_data.expfun_params_ratings0to200_corr= p_0to200{2};

calib_output.eprime_data.expfun_params_int_obs = p_int_unp{1}(1,:);
calib_output.eprime_data.expfun_params_unp_obs = p_int_unp{1}(2,:);

calib_output.eprime_data.expfun_params_int_corr = p_int_unp{2}(1,:);
calib_output.eprime_data.expfun_params_unp_corr = p_int_unp{2}(2,:);

calib_output.eprime_data.expfun = 'p(1)*exp(p(2)*x)';

calib_output.eprime_data.corr_ratings = ratings{2};
calib_output.eprime_data.correction = correction;
calib_output.eprime_data.corrparams = xParMin;
calib_output.eprime_data.corrparams_description = {'nonspecific magnification','site-specific magnification','nonspecific decay','site-specific decay'};


calib_output.eprime_data.sum_squared_errors = sserr;
calib_output.eprime_data.sum_squared_errors_description = {'exp curve fit for raw data','exp curve fit for corrected data'};

calib_output.eprime_data.threshold_obs = threshold{1};
calib_output.eprime_data.threshold_corr = threshold{2};


calib_output.eprime_data.order_and_site_effects_obs.temp_effects_b_t_p = [stats_temp_effects_obs.beta stats_temp_effects_obs.t stats_temp_effects_obs.p];
calib_output.eprime_data.order_and_site_effects_obs.order_effects_tempcov_b_t_p = [stats_ordereffects_tempcov_obs.beta stats_ordereffects_tempcov_obs.t stats_ordereffects_tempcov_obs.p];
calib_output.eprime_data.order_and_site_effects_obs.order_effects_tempcov_sitecov_b_t_p = [stats_ordereffects_tempcov_sitecov_obs.beta stats_ordereffects_tempcov_sitecov_obs.t stats_ordereffects_tempcov_sitecov_obs.p];
calib_output.eprime_data.order_and_site_effects_obs.site_effects_covtemp_anova.data = anova_mat_obs;
calib_output.eprime_data.order_and_site_effects_obs.site_effects_covtemp_anova.stats = anova_stats_obs;
calib_output.eprime_data.order_and_site_effects_obs.site_effects_covtemp_anova.table = anova_table_obs;
calib_output.eprime_data.order_and_site_effects_obs.prevtemp_effects_b_t_p = [stats_prev_temp_obs.beta stats_prev_temp_obs.t stats_prev_temp_obs.p];
calib_output.eprime_data.order_and_site_effects_obs.prevtemp_effects_covrating_b_t_p = [stats_prev_temp_ratingcov_obs.beta stats_prev_temp_ratingcov_obs.t stats_prev_temp_ratingcov_obs.p];
calib_output.eprime_data.order_and_site_effects_obs.prevrating_effects_b_t_p = [stats_prev_rating_obs.beta stats_prev_rating_obs.t stats_prev_rating_obs.p];
calib_output.eprime_data.order_and_site_effects_obs.prevrating_effects_covtemp_b_t_p = [stats_prev_rating_tempcov_obs.beta stats_prev_rating_tempcov_obs.t stats_prev_rating_tempcov_obs.p];


calib_output.eprime_data.order_and_site_effects_corr.temp_effects_b_t_p = [stats_temp_effects_corr.beta stats_temp_effects_corr.t stats_temp_effects_corr.p];
calib_output.eprime_data.order_and_site_effects_corr.order_effects_tempcov_b_t_p = [stats_ordereffects_tempcov_corr.beta stats_ordereffects_tempcov_corr.t stats_ordereffects_tempcov_corr.p];

end


