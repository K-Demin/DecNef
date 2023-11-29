function [] = calculation_score_RS(scan, cor_flag)

global gData

if gData.GPU
    label = gpuArray(nan(1, gData.data.roi_num,'single'));
else
    label = nan(1, gData.data.roi_num);
end
if cor_flag

  denoised_data = denoising_fmri_data(scan, gData.para.scans.regress_scan_num);

  for roi=1:gData.data.roi_num
    % Remove the voxels with nan values.
    scans =  find( sum( ~isnan( denoised_data{roi} ) ,2) );
    gData.data.roi_denoised_vol{roi}(scans,:) = denoised_data{roi}(scans,:);
    
    % If these baseline mean and std values are not computed already, do it
    % here.
    if sum( isnan(gData.data.roi_baseline_mean{roi}) ) || sum( isnan(gData.data.roi_baseline_std{roi}) )    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

      % 
      baseline_data = gData.data.roi_denoised_vol{roi}(baseline_scans,:);


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
  % Now that we have the baseline values, we want to get the trial data.
  % Since this is to compute the values in resting state, let's do this in
  % a sliding window.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  score_target_scans = gData.para.scans.score_target_scans(1,:);
  
  % Get the width of the decoding window
  window = (score_target_scans(2) - score_target_scans(1));
  %window = 0;
  
  % This will store the outputs 
  decoding_windows = [];
  
  % Go through the windows:
  for win = 1:(gData.para.scans.total_scan_num-window)
      test_scans = [ win:(win+window) ];
      
      % remove the not good scans.
      test_scans( gData.data.ng_scan(test_scans) ) = [];

      if length(test_scans)

        for roi=1:gData.data.roi_num
            
          % get the data from the test_scan window
          test_vol = gData.data.roi_denoised_vol{roi}(test_scans,:);

          roi_vox_num = gData.data.roi_vox_num(roi);	
          test_scan_num = length(test_scans);	

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

          decoding_windows(win) = gather(label(roi));
        end	
      end	
  end

end	

gData.data.RS.decoding_windows = decoding_windows;
gData.data.RS.realign_val = gData.data.realign_val;
gData.data.RS.corr_roi_template = gData.data.corr_roi_template;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inspect a bit the results. See correlation of decoder output with 
% Motion parameters and correlation with template.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(1)
r_motion = [];
p_motion = [];

pos = ~isnan(gData.data.realign_val((1:length(decoding_windows)),1));
for i = 1:6
    plot(gData.data.realign_val(15:end,i)')
    [r,p] = corr(decoding_windows(pos)',gData.data.realign_val(pos,i));
    gData.data.RS.r_motion(i) = r;
    gData.data.RS.p_motion(i) = p;
    [r,p] = corr(gData.data.corr_roi_template(pos),gData.data.realign_val(pos,i));
    gData.data.RS.r_motion_template(i) = r;
    gData.data.RS.p_motion_template(i) = p;
    hold on
end

plot(zscore(decoding_windows(pos)),'k','LineWidth',2)
xlabel('TRs')
ylabel('movement parameters (black line = decoder output')

if gData.GPU_Receiver
    saveas(gcf,[gData.para.files.templ_image_dir,'/RS_Decoding_and_motion_params_GPU.png']);
else
    saveas(gcf,[gData.para.files.templ_image_dir,'/RS_Decoding_and_motion_params_NoGPU.png']);
end

figure(2)

pos = ~isnan(gData.data.corr_roi_template((1:length(decoding_windows))));
plot(zscore(gData.data.corr_roi_template(pos))')
hold on
plot(zscore(decoding_windows(pos)),'k','LineWidth',2)
xlabel('TRs')
ylabel('Correlation with ROI template (black line = decoder output')

if gData.GPU_Receiver
    saveas(gcf,[gData.para.files.templ_image_dir,'/RS_Decoding_and_corr_with_template_GPU.png']);
else
    saveas(gcf,[gData.para.files.templ_image_dir,'/RS_Decoding_and_corr_with_template_NoGPU.png']);
end

% Correlation between prediction and template
[r,p] = corr(decoding_windows(pos)',gData.data.corr_roi_template(pos));
gData.data.RS.r_template = r;
gData.data.RS.p_template = p;

% Save mean and std for online computation
gData.data.RS.mean_dec = mean(decoding_windows(~isnan(decoding_windows)));
gData.data.RS.std_dec = std(decoding_windows(~isnan(decoding_windows)));


if cor_flag
  str = sprintf('R%d=%.3f, ', [1:gData.data.roi_num;label]);
  fprintf('label(%s) ', str(1:end-2));
end


