%function [calib_output] = pain_calib(folder_path)
function [calib_output] = pain_calib_correction_IFC_VTD(calib_data,folder_path,participant,day)

% This function starts by removing trials where theparticipant didn't
% answered. Then, it will proceed to compute the proportion of trial at
% each intensity that were perceived as more painful than the first
% stimulation.
% It will draw the psychometric function over the curve and find the point
% of subjective equivalence (PSE) at .5.
%
% -VTD-

fprintf('\n======================================================================================');
fprintf('\n=                           Calibration Two IFC results                              =');
fprintf('\n======================================================================================\n');

calib_data(:,5) = ones(1,size(calib_data,1));

% remove the data without response.
k = 0;
removed_trials = [];
for i=1:size(calib_data,1)
    if calib_data(i,3) ~= 1
        k = k + 1;
        removed_trials(k,:) = [ i calib_data(i,:)];
    end
end

% remove the data without responses.
if ~isempty(removed_trials)
    calib_data(removed_trials(:,1),:) = [];
end

% Get the unique intensity values. we want to get the proportion of response at
% each intensity (done in the next for loop)
int_values = unique(calib_data(:,1));

prop = [];

for i = 1:length(int_values)
    pos = find(calib_data(:,1) == int_values(i));
    % Here the mean will = the proportion of response.
    prop(i) = mean(calib_data(pos,4));
end

% Plot the data
figure, scatter(int_values,prop)
hold on
ylabel('Proportion of "second" responses')
xlabel('Intensity')

% Take a look at this website:
%http://matlaboratory.blogspot.co.uk/2015/04/introduction-to-psychometric-curves-and.html
%http://matlaboratory.blogspot.com/2015/04/introduction-to-psychometric-curves-and.html#:~:text=Psychometric%20curves%20are%20models%20fit,with%20a%20logit%20link%20function.

% Fit psychometirc functions
targets = [0.25, 0.5, 0.75]; % 25%, 50% and 75% performance
weights = ones(1,length(int_values)); % No weighting

% Transpose if necessary
if size(int_values,1)<size(int_values,2)
    int_values=int_values';
end
if size(prop,1)<size(prop,2)
    prop=prop';
end
if size(weights,1)<size(weights,2)
    weights=weights';
end

% Check range of data
if min(prop)<0 || max(prop)>1  
     % Attempt to normalise data to range 0 to 1
    prop = prop/(mean([min(prop), max(prop)])*2);
end

% Perform fit
coeffs = glmfit(int_values, [prop, weights], 'binomial','link','logit');

% Create a new xAxis with higher resolution
fineX = linspace(min(int_values),max(int_values),numel(int_values)*50);
% Generate curve from fit
curve = glmval(coeffs, fineX, 'logit');
curve = [fineX', curve];

% This will get the threshold for the proportion in targets.
% We are looking for the point on the y axis (intensity) where the proportion of response is 50%
threshold = (log(targets./(1-targets))-coeffs(1))/coeffs(2);


% Plot psychometic curves
plot(curve(:,1), curve(:,2), 'LineStyle', '--')
legend('Proportion of response', 'psychometric function ');
saveas(gcf,[participant,'_Day_',num2str(day),'_Calibrate_TwoIFC_Psychometric_function.png']);
close all;

% Stuff to return:
calib_output.eprime_data.ExpTempTwo = threshold(2);
calib_output.eprime_data.prop = prop;
calib_output.int_values = int_values;
end



