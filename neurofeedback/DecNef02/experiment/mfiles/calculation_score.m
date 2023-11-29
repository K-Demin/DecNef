function [] = calculation_score(trial, scan, cor_flag)

global gData

if gData.GPU
    label = gpuArray(nan(1, gData.data.roi_num,'single'));
    value_fb = gpuArray(nan(1, gData.data.roi_num,'single'));
else
    label = nan(1, gData.data.roi_num);
    value_fb = nan(1, gData.data.roi_num);
end

if cor_flag
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %                        Denoising voxels
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  denoised_data = denoising_fmri_data(scan, gData.para.scans.regress_scan_num);

  for roi=1:gData.data.roi_num
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % select the denoised data that are not NaN (the first dummy scans are
    % registered as NaN).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    scans =  find( sum( ~isnan( denoised_data{roi} ) ,2) );
    gData.data.roi_denoised_vol{roi}(scans,:) = denoised_data{roi}(scans,:);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This is to determine the mean and standard deviation of each voxel
    % using the avaliable data. If this was not already done.
    % the idea is to gather the data of the PREP_REST 1 and 2 and REST
    % to compute the baseline.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    if sum( isnan(gData.data.roi_baseline_mean{roi}) ) || sum( isnan(gData.data.roi_baseline_std{roi}) )    

      scan_condition = gData.define.scan_condition;

      final_scan_of_first_trial = gData.para.scans.pre_trial_scan_num + gData.para.scans.first_trial_scan_num;

      first_trial_scans = scans(scans <= final_scan_of_first_trial);

      PREP_REST1 = gData.data.scan_condition(first_trial_scans) == scan_condition.PREP_REST1;
      PREP_REST2 = gData.data.scan_condition(first_trial_scans) == scan_condition.PREP_REST2;

      REST = gData.data.scan_condition(first_trial_scans) == scan_condition.REST;

      % Essentially, the baseline scans are the Rest_1, Rest_2 and Rest
      % scans
      baseline_scans = scans(PREP_REST1|PREP_REST2|REST);

      baseline_scans( find(baseline_scans > scan) ) = [];
      baseline_scans( find(baseline_scans < gData.para.scans.pre_trial_scan_num) ) = [];
      if 0
        baseline_scans( gData.data.ng_scan(baseline_scans) ) = [];
      end

      if isempty(baseline_scans)

            egg_msg = sprintf(...
                'BASELINE REST?��?��ROI template��ROI[%d]�̑��֌W?���\n', roi);
            egg_msg = sprintf('%s�S��臒l�����ł���?D\n', egg_msg);
            egg_msg = sprintf('%sBASELINE�f?[�^��?�?����鎖���ł��܂���?D\n',...
                egg_msg);
            errordlg(egg_msg, 'Error Dialog', 'modal');
            error( egg_msg );
      end

      % Get the baseline data from the denoised voxels
      baseline_data = gData.data.roi_denoised_vol{roi}(baseline_scans,:);

      % Get the mean and standard deviation (to zscore later)
      if isempty( find(isnan(baseline_data)) )

            gData.data.roi_baseline_mean{roi} = mean(baseline_data, 1);
            gData.data.roi_baseline_std{roi} = std(baseline_data, 0, 1);
      else

            roi_vox_num = gData.data.roi_vox_num(roi);	
            gData.data.roi_baseline_mean{roi} = nan(1, roi_vox_num);
            gData.data.roi_baseline_std{roi} = nan(1, roi_vox_num);
            fprintf('zscoring...');
            start = GetSecs;
            for ii=1:roi_vox_num
              p = ~isnan( baseline_data(:,ii) );
              gData.data.roi_baseline_mean{roi}(ii) = mean(baseline_data(p,ii));
              gData.data.roi_baseline_std{roi}(ii) = std(baseline_data(p,ii), 0);
            end
            finish = GetSecs;
            fprintf('Took =%8.3f (sec)\n',finish-start);
      end
      
    end	
  end	

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % Now that we have the mean and STD, we can compute the data for the time
  % window of interest.
  % 
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Get the window to analyse for this specific trial.
  score_target_scans = gData.para.scans.score_target_scans(trial,:);
  test_scans = [ score_target_scans(1):score_target_scans(2) ];
  
  test_scans( find(test_scans > scan) ) = [];
  test_scans( find(test_scans < gData.para.scans.pre_trial_scan_num) ) = [];

  test_scans( gData.data.ng_scan(test_scans) ) = [];


  if length(test_scans)
    
    for roi=1:gData.data.roi_num
      % get the data from the time window
      test_vol = gData.data.roi_denoised_vol{roi}(test_scans,:);

      roi_vox_num = gData.data.roi_vox_num(roi); % ROI
      test_scan_num = length(test_scans);	% Number of test scan

      % z score the data
      baseline_mean = ones(test_scan_num,1)*gData.data.roi_baseline_mean{roi};
      baseline_std = ones(test_scan_num,1)*gData.data.roi_baseline_std{roi};
      
      if isempty( find( gData.data.roi_baseline_std{roi} == 0.0 ) ) % if there are invariant voxels (essentiaslly, if nan values), else ...
	  % If we are using the GPU this will initialize the z_score variable.
          if gData.GPU
              z_score = gpuArray(nan(test_scan_num, roi_vox_num,'single'));
          else
              z_score = nan(test_scan_num, roi_vox_num);
          end
          z_score = (test_vol - baseline_mean)./baseline_std;

      else
          if gData.GPU
              z_score = gpuArray(nan(test_scan_num, roi_vox_num,'single'));
          else
              z_score = nan(test_scan_num, roi_vox_num);
          end
          p = gData.data.roi_baseline_std{roi} ~= 0.0;
          z_score(:,p) = (test_vol(:,p) - baseline_mean(:,p))./baseline_std(:,p);
      end

      % Here I changed the ATR script a bit to avoid looping over all
      % voxels in case of nan values (it takes way to long with ~200,000
      % voxels, even on GPUs).
      % This 'includenan' option will compute the mean voxel by voxel and 
      % will return nan for a voxel that includes a nan value.
      % These voxels will be weeded out below (see p and pp).
      
      z_score_mean = mean(z_score,1,'includenan');


      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %
      % This is where you actually compute the score of the time window.
      % 
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      % p is to get the index of the valid voxels
      p = ~isnan( z_score_mean ) & ~isinf(z_score_mean);
      % pp is the same but with an extra true to include the bias term
      % (this is to index the weights)
      pp = ~isnan( [z_score_mean, true] ) & ~isinf( [z_score_mean, true] );
      [a, label(roi)] = calc_label([z_score_mean(p),1], gData.data.roi_weight{roi}(pp)');
      
      % %%% scale by percentile
      est_prct=normcdf(label(roi),gData.data.RS.mean_dec,gData.data.RS.std_dec);
    
      value_fb(roi)=(est_prct-.3)/(.7-.3);
      if value_fb(roi)>1
          value_fb(roi)=1;
      elseif value_fb(roi)<0
          value_fb(roi)=0;
      end

    end	
  end	
  
end	

switch gData.para.score.score_mode
  case gData.define.score_mode.CALC_SCORE
    % This averages the values if multiple ROIs
    source_score = 100.*mean(value_fb);	
    
  case gData.define.score_mode.SHAM_RAND_SCORE
    source_score = normrnd(gData.para.score.normrnd_mu,...
	gData.para.score.normrnd_sigma);
  case gData.define.score_mode.SHAM_SCORE_FILE
    source_score = gData.para.score.sham_score(trial);
  otherwise
    error('Undefined : score_mode = %d', gData.para.score.score_mode);
    source_score = NaN;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This will compute the value to feedback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
score = round( source_score );

% If you are in condition -1 inverse the score.
if gData.data.condition == -1
    score = 100-score;
end

% Label is the actual output of the decoder:
gData.data.label(trial,:) = gather(label);
% Source score is value after our transformation:
gData.data.source_score(trial) = gather(source_score);
% Score is the source_score adjusted as a function of the group:
% 1 = upregulation
% -1 = downregulation
gData.data.score(trial) = gather(score);
gData.data.calc_score_flg(trial) = true;

%%CAC edit to count multi-trial high score streak 1/12/19
if score>=69

    gData.data.streak_counter=gData.data.streak_counter+1;
    % If more than 3 reset.
    if gData.data.streak_counter>3
        gData.data.streak_counter=1;
    end
else
    gData.data.streak_counter=0;
end


fprintf('Score = %4.0f \n', score);

