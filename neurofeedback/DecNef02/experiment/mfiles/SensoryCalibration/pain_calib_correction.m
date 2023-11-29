%function [calib_output] = pain_calib(folder_path)
function [calib_output] = pain_calib_correction(folder_path, F, remove_last_temp)

%
% % VT temporary ***********
% % clc; clear;
% % if ispc
% %    folder_path = 'C:\Users\labo-prainville\Desktop\PCDC\PCDC_data/subject_0001/calibration';
% %
% %    basedir = '../subject_0001/calibration';
% % else
% % folder_path = '/Users/VTabry/Dropbox/Vanessa_Mathieu/Pain_exec_data/subject_0007/calibration';
% % end
% % remove_last_temp = 2;
% % F = 1;
% % % **********************

%scriptsdir = [pwd '\trunk\SCN_Core_Support\Statistics_tools'];
%

%
%This function reads MEDOC and eprime outputs of a calibration procedure
%and returns several diagnostic checks and calibration outputs in a html
%document and a .mat structure.
%
%Before running the function You have to convert .xlsx file to .txt files because
%xslread.m only works in basic mode for non-windows systems. Use "save as
%MS-DOS .txt file" (Be careful, the format really matters) in xcell to save "Data" and
%"Results" sheets in "MEDOC_data.txt" and "MEDOC_results.txt" files.
%Then place in a "calibration" subfolder. Note that number of text file columns
%to read for textscan should probably be shortened if there is a lesser number of stims
%(for high number of stims, MEDOC software splits data in 2 xcell columns.
%
%Calibration eprime data, which is directly saved in a .txt should also be
%put in the same folder. The name of the .txt should start with "sens".
%
%baseline is assumed to be temperature at the beginning of the file; onsets
%and offsets are identified as temperatures that depart from baseline by
%0.2C --- this could be modifified to be more flexible.
%
%
%You will also need the stats toolbox for using glmfit.m and anova.m
%functions
%
% 'F' is a value indicating whether to analyse both or only one of the
% MEDOC or sens files.
% 1 : eprime only
% 2 : MEDOC only
% 3 : eprime and MEDOC
%
%
% 'remove_last_temp' indicates whether or not to analyze the last temperature as set in the
% 'results' sheet of the MEDOC output. Sometimes it is set at "32C" (i.e. identical to baseline).
% to prevent the temperature from dropping suddenly when the calibration terminates, and therefore
% this trial shouldn't be considered.
% 1: keep last trial
% 2: remove last trial
%
% Note: BTW, if ever there is only one trial per target temperature this will cause problem calculating
% standard deviations and cause bugs in the script.
%
% Note: If you have target temperatures that have decimal, MEDOC saves that
% temperature in xcell with a comma as separator. Change commas for dots
% before converting to .txt files.
%

% % This is for debugging
%    clear all
%    folder_path = '/Users/p0633079/Dropbox/Vanessa_Mathieu/Pain_exec_data/subject_8888/calibration';

%TAV TEMP!!!!:
%folder_path = 'C:\Users\Todd\Desktop\Matlab threshold curve fitting'; %TEMP
%remove_last_temp = 2; %TEMP
%F = 2; %TEMP

fprintf(['\n=' folder_path '=']);

warning off


if F == 2 || F == 3
    
    %VT: Ouvrir données médoc (open Medoc data)
    FID = fopen([folder_path '/MEDOC_data.txt']); %nom et emplacement du fichier texte (Name and location of the text file)
    raw_data = textscan(FID, '%s %s %*s %*s %*s      %*s %*s %s %s %*s      %*s %*s %*s %*s %*s     %*s %*s %*s %*s %*s    %*s %*s %*s %*s %*s   %*s %*s %*s %*s %*s      %*s %*s %*s %*s %*s   %*s '); % le nombre de s doit correspondre au nombre de colonnes
    fclose('all');
    
    FID = fopen([folder_path '/MEDOC_results.txt']); %nom et emplacement du fichier texte
    raw_results = textscan(FID, '%s %s %*s %*s %*s %*s'); % le nombre de s doit correspondre au nombre de colonnes
    fclose('all');
    
    if remove_last_temp == 2 %remove last temp
        for i = 1:length(raw_results{1,1})-1
            cleaned_raw_results{1,1}{i,1} = raw_results{1,1}{i,1};
            cleaned_raw_results{1,2}{i,1} = raw_results{1,2}{i,1};
        end
        clear raw_results; raw_results = cleaned_raw_results;
    end
    %%
    clear data data1 data2;
    
    fprintf('\n======================================================================================')
    fprintf('\n=                                                                                    =')
    fprintf('\n=                                      MEDOC checks                                  =')
    fprintf('\n=                                                                                    =')
    fprintf('\n=                                                                                    =')
    fprintf('\n======================================================================================\n')
    
    %VT: allocate the raw data to data structures. Accomodates variable column
    %lengths.
    
    for i = 1:2 % do first set of columns.
        k = 0;
        for j = 3:length(raw_data{1,i})
            a = str2double(raw_data{1,i}{j,1});
            if ~isnan(a)
                k = k + 1; 
                data1(k,i) = a; 
                clear a;
            end
        end
    end
    
    % fprintf('Size of "data1":');
    % size(data1)
    
    for i = 3:4 % Now do second set of columns
        k=0;
        for j = 5:length(raw_data{1,i}) % here we are missing 3 samples when transitionning between columns
            a = str2double(raw_data{1,i}{j,1});
            if ~isnan(a)
                if  (str2double(raw_data{1,i}{j-1,1})/str2double(raw_data{1,i}{j-1,1})) > 0.25
                    k = k + 1; 
                    data2(k,i-2) = a; 
                    clear a;
                end
            end
        end
    end
    
    % if exist('data2')
    % fprintf('Size of "data2":');
    % size(data2)
    % end
    
    %%
    % collapse together, resamples and smooth
    if exist('data2') % if there is two columns of data in xcell
        data = [data1; data2];
    else
        data = data1;
    end
    
    % fprintf('Size of "data":');
    % size(data)
    
    xo = data(:,1)';
    yo = data(:,2)';
    xi = 1:100:data(length(data),1); % Create a time vector that samples temperature every 100ms
    yi = interp1(xo,yo,xi); % VT: The interp1 command interpolates between data points.
    % It finds values at intermediate points (in this case, of 100ms interval) of a one-dimensional function f(x) that underlies the data.
    resamp_data = [xi' yi'];
    
    smooth_data = resamp_data;
    smooth_data(:,2) = smooth(smooth_data(:,2), 50, 'moving'); % VT: applies a low-pass filter to the data (averages over a number of data points)
    
    close all; scrsize = get(0, 'ScreenSize'); figure('Name', 'Whole Session', 'Position', [1, 1, scrsize(3),scrsize(4)/2]);
    plot(data(:,1)', data(:,2)', 'r'); hold on; % plot the raw data line in red
    plot(resamp_data(:,1)',resamp_data(:,2)', 'b'); % plot the resampled data line in blue
    plot(smooth_data(:,1)',smooth_data(:,2)', 'k'); % plot the smoothed data line in black.
    legend('raw', 'resamp', 'smoothed');
    
    clear data; data = smooth_data;
    % fprintf('Size of "smooth_data":');
    % size(smooth_data)
    
    %%
    % find onsets
    clear onsets offsets cleaned_onsets cleaned_offsets
    baseline = str2double(raw_data{1,2}{4,1});
    
    % Onset is determined as any point where the temperature increase is larger
    % than 0.2 deg as compared to the previous time point. This can be varied.
    
    k = 0; kk = 0;
    for i = 4:length(data)
        if data(i,2) > baseline + 0.2 % If the datapoint is 0.2 points above baseline
            if data(i-1,2) < baseline + 0.2 % if the previous point is below this threshold
                if mean(data(i-10:i,2)) < baseline + 0.2 % if the average of the previous 10 points is below the threshold
                    k = k + 1;
                    onsets(k,1:2) = data(i-2,:);
                    onsets(k,3) = i;
                end
            end
            
        elseif data(i,2) < baseline + 0.2 % offset detection, by the opposite tests.
            if data(i-1,2) > baseline + 0.2
                if mean(data(i-10:i,2)) > baseline + 0.2
                    kk = kk + 1; offsets(kk,1:2) = data(i-2,:); offsets(kk,3) = i;
                end
            end
        end
    end
    
    %discard extra onsets offsets
    k = 1; cleaned_onsets(k,:) = onsets(1,:);
    for i = 2:length(onsets)
        if (onsets(i,1) - onsets(i-1,1)) > 1000
            k = k + 1;
            cleaned_onsets(k,:) = onsets(i,:);
        end
    end
    k = 1; cleaned_offsets(k,:) = offsets(1,:);
    for i = 2:length(offsets)
        if (offsets(i,1) - offsets(i-1,1)) > 1000
            k = k + 1;
            cleaned_offsets(k,:) = offsets(i,:);
        end
    end
    clear offsets; offsets = cleaned_offsets; clear cleaned_offsets;
    clear onsets; onsets = cleaned_onsets; clear cleaned_onsets;
    
    
    %discard small bumps in temperature
    k = 0;
    for i = 1:length(onsets)
        if offsets(i,1) - onsets(i,1) > 2000
            k = k + 1;
            cleaned_onsets(k,:) = onsets(i,:);
            cleaned_offsets(k,:) = offsets(i,:);
        end
    end
    clear offsets; offsets = cleaned_offsets; clear cleaned_offsets;
    clear onsets; onsets = cleaned_onsets; clear cleaned_onsets;
    
    
    
    
    
    
    % add onsets to figure
    plot(onsets(:,1), onsets(:,2),'*g'); hold on;
    plot(offsets(:,1), offsets(:,2),'*r');
    
    fprintf('\n                                                raw, resampled and smoothed data ---- lines must overlap!');
    fprintf('\n=========================================================================================================================================================');
    
    
    drawnow;
    snapnow;
    %close all;
    
    %%
    %now plot every response.
    close all;
    figure('Name', 'trial by trial', 'Position', [1, 1, scrsize(3),scrsize(4)]);
    
    fprintf('Number of onsets: %i',length(onsets));
    
    for i = 1:length(onsets)
        grid_size = ceil(sqrt(length(onsets)));
        subplot(grid_size, grid_size, i);
        stim_length_seconds(i) = offsets(i,1) - onsets(i,1);
        stim_length_samples(i) = offsets(i,3) - onsets(i,3);
        
        %data(onsets(i,3)-20,2)
        %data(onsets(i,3)+250,2)
        
        plot([-1000:100:25000], data(onsets(i,3)-10:onsets(i,3)+250,2)); hold on;
        plot([-1000 25000], [32 32.00001], 'k'); hold on;
        plot(0, onsets(i,2),'*g'); hold on;
        plot(stim_length_samples(i)*100, offsets(i,2),'*r');
        title(['stim #' num2str(i)]);hold on;
        axis([-1000,25000, 30, 50]);
    end
    
    fprintf('\n                                                                      trial-by-trial');
    fprintf('\n=========================================================================================================================================================\n');
    
    drawnow;
    snapnow;
    close all;
    
    %%
    %now plot averaged response.
    close all;
    figure('Name', 'mean responses', 'Position', [1, 1, scrsize(3),scrsize(4)/2]);
    
    for i = 1:length(onsets)
        responses(i,:) = data(onsets(i,3)-10:onsets(i,3)+250,2);
        targets(i) = str2double(raw_results{1,2}{i+1,1});
    end
    
    sort_responses = [targets' responses];sort_responses = sortrows(sort_responses,1);
    num_temp = 1; num_repeat = 1;trial_per_temperature{1,1}(num_repeat,:) = sort_responses(1,2:end); temp_names{1,1} = num2str(sort_responses(1,1));
    for i = 2:size(sort_responses,1)
        if sort_responses(i,1) == sort_responses(i-1,1)
            num_repeat = num_repeat + 1;
            trial_per_temperature{1,num_temp}(num_repeat,:) = sort_responses(i,2:end);
        else
            num_temp = num_temp+1; num_repeat = 1; trial_per_temperature{1,num_temp}(num_repeat,:) = sort_responses(i,2:end);
            temp_names{1,num_temp} = num2str(sort_responses(i,1));
        end
    end
    
    % MR: Removes instances where there is just one temp because cannot compute sd further down
    for i = 1:length(trial_per_temperature)
        if size(trial_per_temperature{1,i}, 1) < 1
            fprintf('\n WARNIG: cannot complete MEDOC checks because there is a target for which there is only trial: perhaps check "remove_last_temp" option in the help\n');
            
        end
    end
    
    
    
    
    
    color_vec = {'r', 'g', 'b', 'm', 'k', 'c', 'y', 'r', 'g', 'b', 'm', 'k', 'c', 'y' };
    for i = 1:length(trial_per_temperature)
        errorbar([-1000:100:25000], mean(trial_per_temperature{1,i}), std(trial_per_temperature{1,i}), color_vec{i});hold on;
        target = str2double(temp_names{1,i});
        plot([-1000 25000], [target target + 0.000001], color_vec{i}); hold on;
    end
    
    for i = [-1000:1000:25000]
        plot([i i+1], [30 50], 'k');
    end
    plot([-1000 25000], [32 32.000001], 'k');
    axis([-1000,25000, 30, 50]);
    
    
    fprintf('\n                                                                   mean responses');
    fprintf('\n=========================================================================================================================================================');
    
    
    drawnow;
    snapnow;
    close all;
    
    %%
    
    for i = 1:length(onsets)
        for j = 1:2000
            if data(onsets(i,3)+j,2) >= targets(i)-0.2
                time_to_target(i) = data(onsets(i,3)+j, 1) - onsets(i,1);
                break
            end
        end
    end
    
    fprintf('\n                 trial-by-trial');
    fprintf('\n===================================================');
    fprintf('\ntrial num   target     time to target      duration');
    
    for i = 1:length(targets)
        if i < 10
            fprintf(['\n    '    num2str(i) '         ' num2str(targets(i)) '            ' num2str(time_to_target(i)) '            ' num2str(stim_length_seconds(i)) '']);
        else
            fprintf(['\n    '    num2str(i) '        ' num2str(targets(i)) '            ' num2str(time_to_target(i)) '            ' num2str(stim_length_seconds(i)) '']);
        end
    end
    fprintf('\n===================================================\n');
    fprintf(' note: time to target is target minus 0.2C');
    
    %%
    all_data = [targets' time_to_target' stim_length_seconds'];
    
    clear trial_per_temperature temp_names
    sort_all_data = sortrows(all_data, 1);
    num_temp = 1; num_repeat = 1;trial_per_temperature{1,1}(num_repeat,:) = sort_all_data(1,1:end); temp_names{1,1} = num2str(sort_responses(1,1));
    for i = 2:size(sort_all_data,1)
        if sort_all_data(i,1) == sort_all_data(i-1,1)
            num_repeat = num_repeat + 1;
            trial_per_temperature{1,num_temp}(num_repeat,:) = sort_all_data(i,1:end);
        else
            num_temp = num_temp+1; num_repeat = 1; trial_per_temperature{1,num_temp}(num_repeat,:) = sort_all_data(i,1:end);
            temp_names{1,num_temp} = num2str(sort_responses(i,1));
        end
    end
    
    for i = 1:length(trial_per_temperature)
        averages(i,:) = mean(trial_per_temperature{1,i});
    end
    
    fprintf('\n\n\n              averages');
    fprintf('\n====================================');
    fprintf('\ntarget   time to target    duration');
    
    for i = 1:length(averages)
        
        fprintf(['\n' num2str(averages(i,1)) '            ' num2str(round(averages(i,2))) '            ' num2str(round(averages(i,3))) '']);
    end
    fprintf('\n=====================================\n');
    
    
end






%%


if F == 1|| F == 3
    
    fprintf('\n======================================================================================');
    fprintf('\n=                                                                                    =');
    fprintf('\n=                                      Calibration results                           =');
    fprintf('\n=                                                                                    =');
    fprintf('\n=                                                                                    =');
    fprintf('\n======================================================================================\n');
    
    color_vec = {'r', 'g', 'b', 'm', 'k', 'c', 'y', 'r', 'g', 'b', 'm', 'k', 'c', 'y' };
    
    % VT: for debugging
    %folder_path = 'C:\Users\Micheline\Dropbox\Vanessa_Mathieu\Pain_exec_data\subject_0333\calibration';
    
    %now get eprime
    cd(folder_path);
    file_name = ls('sens*.txt');
    if ~ispc
        FID = fopen([folder_path '/' file_name(1:end-1)]); %nom et emplacement du fichier texte
    else
        FID = fopen([folder_path '\' file_name]);
    end
    eprime_output = textscan(FID, '%s %s %s %s %s %s %s %s %s %s'); % le nombre de s doit correspondre au nombre de colonnes
    fclose('all');
    
    for i = 2:length(eprime_output{1,1})
        calib_data(i-1,1) = str2num(eprime_output{1,4}{i,1});
        calib_data(i-1,2) = str2num(eprime_output{1,3}{i,1});
        if eprime_output{1,5}{i,1}(1,1) == 'p' % If the warm or pain evaluation yielded 'pain'
            calib_data(i-1,3) = 1;
        else
            calib_data(i-1,3) = 0; % If the warm or pain eval yielded 'Warm' or 'none'
        end
        calib_data(i-1,4) = str2num(eprime_output{1,6}{i,1});
        calib_data(i-1,5) = str2num(eprime_output{1,8}{i,1});
        
        
        if str2num(eprime_output{1,10}{i,1}) == 9999 % If no unpleasantness eval was done, save this value as 'none'
            calib_data(i-1,6) = 0;
            calib_data(i-1,8) = NaN;
        else
            calib_data(i-1,6) = str2num(eprime_output{1,10}{i,1});
            calib_data(i-1,8) = str2num(eprime_output{1,9}{i,1});
        end
        
        calib_data(i-1,7) = str2num(eprime_output{1,7}{i,1});
        calib_data(i-1,9) = str2num(eprime_output{1,2}{i,1});
        
    end
    
    calib_data_names = { 'temperature' 'spot' 'pain=1' 'removed~=1' 'ratings_warmth_or_int' 'unp' 'rating_RT' 'unp_RT' 'trial_num' 'int_0to200' 'int_justpain'};
    
    % puts max pain rating for trials where arm was removed
    k = 0;
    for i=1:size(calib_data,1)
        if calib_data(i,4) ~= 1
            calib_data(i,3) = 1;
            calib_data(i,5) = max(calib_data(:,5));
            calib_data(i,6) = max(calib_data(:,6));
            calib_data(i,7) = NaN;
            calib_data(i,8) = NaN;
            
            k = k + 1;
            removed_trials(k,:) = [ i calib_data(i,:)];
            
        end
    end
    
    
    
    
    
    fprintf('\nWARNING: thermode removed on the following trials ');
    fprintf('\n==================================================');
    fprintf('\n  trial             temperature           spot    ');
    
    if exist('removed_trials')
        for i = 1:size(removed_trials, 1)
            fprintf(['\n    ' num2str(removed_trials(i,1)) '                   ' num2str(removed_trials(i,2)) '                  ' num2str(removed_trials(i,3)) '']);
        end
    end
    
    
    fprintf('\n==================================================\n');
    fprintf('\n note: ratings for trials where the thermode was  ');
    fprintf('\n removed are replaced by maximum valid rating     \n\n\n');
    
    %everything put on same scale
    clear ratings_0to200
    for i = 1:size(calib_data, 1)
        if calib_data(i,3) == 1%if was rated as painful
            ratings_0to200(i,1) = calib_data(i,5) + 100;
        else
            ratings_0to200(i,1) = calib_data(i,5);
        end
    end
    calib_data = [calib_data ratings_0to200];
    
    
    %% VT: d matrix and controlling for effects of sensitization-habituation
    
    % create d matrix.
    % Data matrix for use with Marieke's script
    %create a matrix d_cal that contains all the info needed to regress out
    %habituation and sensitization effects with Marieke's script afterwards.
    
    % Column 1: ID number
    % Column 2: Trialnumber (1 to 36)
    % Column 3: temperature (absolute heat or pain temperature)
    % Column 4: Armspot (1 to 4)
    % Column 5: pain rating
    % Column 6: pain residual.(derived from glmfit)
    
    d_cal = [];
    %ID = str2num(folder_path(end-15:end-12));
    ID = 9999;
    d_cal = ID*(ones(length(eprime_output{1})-1,1)); % Save participant ID
    d_cal = [d_cal calib_data(:,9) (calib_data(:,1)-32) calib_data(:,2) calib_data(:,10)];
    %                      9=trial num      1=temperature-32?       2=armspot      10=int_0to200
    
    % regress pain rating on temperature (0 to 200)
    %                             temp      temp             0to200
    [b,dev,stats]= glmfit([d_cal(:,3) d_cal(:,3).^2]  ,d_cal(:,5));
    d_cal = [d_cal stats.resid];
    
    %d_cal columns = 1)ID  
    %                2)trialnum 
    %                3)temperature
    %                4)armspot
    %                5)int_0to200
    %                6)stats.resid
    
    % Run Marieke's script to produce predicted intensity ratings, in predAll2.
    if ispc
        %scriptdir = 'C:\Users\labo-prainville\Desktop\PCDC\PCDC_data/scripts';
        scriptdir = 'C:\Users\Todd\Desktop\matlabcalibscripts';
        %scriptdir = basedir;
    else
        scriptdir = '/Users/VTabry/Dropbox/Vanessa_Mathieu/Pain_exec_data/scripts';
    end
    %cd(scriptdir);
    cd ..\..
    
    %% ******************************
    
    [predAll,RHOsq,correction,xParMin] = RunModel(d_cal);
    
    
    
    snapnow;
    
    
    % Remove the variance associated with predAll from the ratings.
    
    [b,dev,stats_corr] = glmfit(predAll, ratings_0to200);
    
    pred_y = stats_corr.resid; % MR- we are supposed to take these residuals and plot them,
    % but what exactly do they represent?
    
    % plot pred_y(residual) as a function of temperature.
    figure;
    scatter(calib_data(:,1),pred_y+stats_corr.beta(1)); hold on;
    
    scatter(calib_data(:,1),calib_data(:,10)); % Plot original ratings for comparison
    title('Residual of predicted rating on observed rating+ Beta','fontsize',16,'fontweight','bold');
    legend('Residual','observed','location','northwest');
    snapnow;
    
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
        
        close all; clear scrsize; scrsize = get(0, 'ScreenSize');
        figure('Name', 'calibration 0 to 200', 'Position', [1, 1, scrsize(3)/2,scrsize(4)/2]);
        scatter(x,y); hold on;
        
        % fit exponential function
        expfun = inline('p(1)*exp(p(2)*x)','p','x');
        
        
        funhandle = @(p, x) expfun(p, x);               % function handle to pass in
        [p,sse,fit] = nonlin_fit(y,x,'linktype', funhandle,'start',[1 1]);
        
        
        sserr(ppp) = sse;
        
        p_0to200{ppp} = p;
        
        exp_x = 36:0.1:49;
        exp_y = p(1)*exp(p(2)*exp_x);
        plot(exp_x, exp_y, 'b','LineWidth', 3); hold on;
        
        %VT: display exp functions below
        text(40,180,strcat('y =',num2str(p(1)), '*exp(', num2str(p(2)), '*x)'));
        
        clear exp_x exp_y
        exp_x = 0:0.1:60;
        exp_y = p(1)*exp(p(2)*exp_x);
        
        %detect pain threshold
        k = 0;  thresholds = [10:10:200]; clear deciles; %ADD THIS BACK IN FOR REAL THING
        %for i = 1:length(exp_x)
        for i = 2:length(exp_x)
            for j = 1:length(thresholds)
                
                if exp_y(i) > thresholds(j) & exp_y(i-1) < thresholds(j)
                    k = k + 1;
                    deciles(k, 1) = thresholds(j); deciles(k, 2) = exp_x(i);
                    break
                end
            end
        end
        deciles0to20{ppp} = deciles;
        
        threshold{ppp} = deciles(10,2);
        
        plot([deciles(10,2) deciles(10,2)+0.000000000001], [0 200], 'r'); hold on;
        plot([36 49], [100 100.00000000000001], 'r'); hold on;
        title(['Ratings as a function of temperature-' label{ppp}],'fontsize',16,'fontweight','bold');
        
        drawnow;
        snapnow;
        close all;
        
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
        
        
        close all;
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
            exp_x = 36:0.1:49;
            exp_y = p(1)*exp(p(2)*exp_x);
            plot(exp_x, exp_y, colors{ii},'LineWidth', 3); hold on;
            
            clear exp_x exp_y
            exp_x = 20:0.1:60;
            exp_y = p(1)*exp(p(2)*exp_x);
            
            %detect pain threshold
            k = 0;  thresholds = [10:10:100];
            for i = 2:length(exp_x) %CHANGE BACK TO 1???
                for j = 1:length(thresholds)
                    if exp_y(i) > thresholds(j) && exp_y(i-1) < thresholds(j)
                        k = k + 1;
                        deciles_column(k,1) = exp_x(i) ;
                        break
                    end
                end
            end
            deciles = [deciles deciles_column];
            
        end
        
        legend('intensity', 'intensity', 'unpleasantness', 'unpleasantness', 'Northwest');
        
        drawnow;
        snapnow;
        close all;
        
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
        
        
        close all;
        figure('Name', 'order effects per temperature', 'Position', [1, 1, scrsize(3)/2,scrsize(4)/2]);
        for i = 1:length(temp_per_temp)
            y = sortrows(temp_per_temp{1,i}, 9);
            temp_per_temp{1,i}(:, end + 1) = [1:1:size(temp_per_temp{1,i}, 1)]';
            legend_names{1,i} =  num2str(temp_per_temp{1,i}(1,1));
            plot([1:1:size(temp_per_temp{1,i}, 1)], y(:,10)', color_vec{i});hold on ;
        end
        legend(legend_names);
        
        drawnow;
        snapnow;
        close all;
        
        
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
                
                %fprintf('\ni = %i',i);
                
                if calib_data(i,2) == 1
                    dummy(i,:) = [1 0 0];
                    %fprintf('\n\tSpot = %i',1);
                    k = k + 1; anova_mat_obs(k, 1) = stats_ordereffects_tempcov_obs.resid(i);
                elseif calib_data(i,2) == 2
                    dummy(i,:) = [0 1 0];
                    %fprintf('\n\tSpot = %i',2);
                    
                    kk = kk + 1; anova_mat_obs(kk, 2) = stats_ordereffects_tempcov_obs.resid(i);
                elseif calib_data(i,2) == 3
                    dummy(i,:) = [0 0 1];
                    %fprintf('\n\tSpot = %i',3);
                    
                    kkk = kkk + 1; anova_mat_obs(kkk, 3) = stats_ordereffects_tempcov_obs.resid(i);
                elseif calib_data(i,2) == 4
                    %fprintf('\n\tSpot = %i',4);
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
            snapnow;
            close all;
            
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
            for i = 1:length(calib_data)
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
            
            [b,dev,stats_siteeffects_tempcov] = glmfit(dummy,stats_temp_effects_corr.resid);
            [b,dev,stats_ordereffects_tempcov_sitecov_corr] = glmfit(calib_data(:,9),stats_siteeffects_tempcov.resid);
            
            
            fprintf(['\n   for' label{ppp} ' ratings']);
            
            fprintf('\n   results of regression models (note: this requires stats toolbox)');
            fprintf('\n====================================================================');
            fprintf('\n           model                       b           t           p    \n');
            fprintf(['\n    temperature effects             '  num2str(stats_temp_effects_corr.beta(2)) '    ' num2str(stats_temp_effects_corr.t(2)) '    ' num2str(stats_temp_effects_corr.p(2))    '']);
            fprintf(['\n  order, controlling temp           '  num2str(stats_ordereffects_tempcov_corr.beta(2)) '    ' num2str(stats_ordereffects_tempcov_corr.t(2)) '    ' num2str(stats_ordereffects_tempcov_corr.p(2))    '']);
            fprintf(['\n order, controlling temp & site     '  num2str(stats_ordereffects_tempcov_sitecov_corr.beta(2)) '    ' num2str(stats_ordereffects_tempcov_sitecov_corr.t(2)) '    ' num2str(stats_ordereffects_tempcov_sitecov_corr.p(2))    '']);
            fprintf('\n====================================================================\n');
            
            fprintf('\n             site effects - results of ANOVA          ');
            fprintf('\n======================================================\n');
            
            [p,anova_table_corr,anova_stats_corr] = anova1(anova_mat_corr);
            
            drawnow;
            snapnow;
            close all;
            
            %*********************
            
            [b,dev,stats_prev_temp_corr] = glmfit(calib_data(1:end-1,1), calib_data(2:end,10));
            [b,dev,stats_prev_rating_corr] = glmfit(calib_data(1:end-1,10), calib_data(2:end,10));
            [b,dev,stats_prev_temp_ratingcov_corr] = glmfit(calib_data(1:end-1,1), stats_prev_rating_corr.resid);
            [b,dev,stats_prev_rating_tempcov_corr] = glmfit(calib_data(1:end-1,10), stats_prev_temp_corr.resid);
            
            
            fprintf('\n               previous stim and previous rating efects             ');
            fprintf('\n====================================================================');
            fprintf('\n           model                       b           t           p    \n');
            fprintf(['\n  previous temperature effects      '  num2str(stats_prev_temp_corr.beta(2)) '    ' num2str(stats_prev_temp_corr.t(2)) '    ' num2str(stats_prev_temp_corr.p(2))    '']);
            fprintf(['\n    previous ratings effects        '  num2str(stats_prev_rating_corr.beta(2)) '    ' num2str(stats_prev_rating_corr.t(2)) '    ' num2str(stats_prev_rating_corr.p(2))    '']);
            fprintf(['\n    previous temp, rating cov       '  num2str(stats_prev_temp_ratingcov_corr.beta(2)) '    ' num2str(stats_prev_temp_ratingcov_corr.t(2)) '    ' num2str(stats_prev_temp_ratingcov_corr.p(2))    '']);
            fprintf(['\n    previous rating, temp cov       '  num2str(stats_prev_rating_tempcov_corr.beta(2)) '    ' num2str(stats_prev_rating_tempcov_corr.t(2)) '    ' num2str(stats_prev_rating_tempcov_corr.p(2))    '']);
            fprintf('\n====================================================================\n');
            
            
            % find a good way to save these values separately in calib_output.
            
            
        end
    end
    
    calib_output.eprime_data.ratings_justpainunpleas = ratings_justpain;
    % TEST ABOVE
    
end



if F == 2|| F ==3
    
    calib_output.medoc_data.data = data;
    calib_output.medoc_data.data_description = {'resampled to 10 Hz, smoothed by moving avrage window of 5 samples'};
    calib_output.medoc_data.onsets = onsets;
    calib_output.medoc_data.offsets = offsets;
    calib_output.medoc_data.onsets_offsets_description = {'onsets in msec', 'threshold temperature', 'onset in samples'};
    calib_output.medoc_data.target_temperatures = targets;
    calib_output.medoc_data.time_to_target_msec = time_to_target;
    calib_output.medoc_data.stim_length_msec = stim_length_seconds;
    calib_output.medoc_data.average_time_to_target_and_duration = averages;
    
end

if F == 1|| F == 3
    
    calib_output.eprime_data.d = d_cal;
    
    calib_output.eprime_data.data = calib_data(:,1:11);
    calib_output.eprime_data.names = calib_data_names;
    calib_output.eprime_data.temperature_x_rating0to200_match_obs = deciles0to20{1};
    calib_output.eprime_data.temperature_x_rating0to200_match_corr = deciles0to20{2};
    
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
    calib_output.eprime_data.order_and_site_effects_corr.order_effects_tempcov_sitecov_b_t_p = [stats_ordereffects_tempcov_sitecov_corr.beta stats_ordereffects_tempcov_sitecov_corr.t stats_ordereffects_tempcov_sitecov_corr.p];
    calib_output.eprime_data.order_and_site_effects_corr.site_effects_covtemp_anova.data = anova_mat_corr;
    calib_output.eprime_data.order_and_site_effects_corr.site_effects_covtemp_anova.stats = anova_stats_corr;
    calib_output.eprime_data.order_and_site_effects_corr.site_effects_covtemp_anova.table = anova_table_corr;
    calib_output.eprime_data.order_and_site_effects_corr.prevtemp_effects_b_t_p = [stats_prev_temp_corr.beta stats_prev_temp_corr.t stats_prev_temp_corr.p];
    calib_output.eprime_data.order_and_site_effects_corr.prevtemp_effects_covrating_b_t_p = [stats_prev_temp_ratingcov_corr.beta stats_prev_temp_ratingcov_corr.t stats_prev_temp_ratingcov_corr.p];
    calib_output.eprime_data.order_and_site_effects_corr.prevrating_effects_b_t_p = [stats_prev_rating_corr.beta stats_prev_rating_corr.t stats_prev_rating_corr.p];
    calib_output.eprime_data.order_and_site_effects_corr.prevrating_effects_covtemp_b_t_p = [stats_prev_rating_tempcov_corr.beta stats_prev_rating_tempcov_corr.t stats_prev_rating_tempcov_corr.p];
    
    
    
    
    % find a way to generate, store and save the corrected data statistics.
    
    
    
end



end

