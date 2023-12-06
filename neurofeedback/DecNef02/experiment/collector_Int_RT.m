function collector_Int_RT(participant, day, task, GPU, GPU_Receiver, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decoded Neurofeedback(DecNef) experiment program
%                                             (DecNef02)
%   USAGE : neurofeedback
%           neurofeedback(port)
%           port : TCP/IP port number
% 
% Copyright 2013 All Rights Reserved.
% ATR Brain Information Communication Research Lab Group. 
% ------------------------------------------------------------------
% Toshinori YOSHIOKA
% 2-2-2 Hikaridai, Seika-cho, Sorakugun, Kyoto,
% 619-0288, Japan (Keihanna Science city)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% VTD edits (november 24th 2020):
%
% This is a modification of the neurofeedback.m file to conduct the 
% calibration and experiment using the same visual parameters as the 
% neurofeedback sessions. 
%
% Unlike the original code by ATR, there are now 3 instances:
% display(): which should be executed on the diplay computer for visual
%               presentation to the participant.
% receiver(): which collects and process the dcm images written down by the
%               scanner. This is executed on the processing computer.
% collector(): which collects the images processed by the receiver and run
%               the real-time computations. This is executed on the processing computer.
%
% the file parameters.txt should be used by default.
% Konstantin "Kostya" Demin: fixed file separators in a few places


%%%%%%%%%%
% Inputs:
%%%%%%%%%%

% participant: the participant ID (a string. Ex: 'VTD_Pilot').
%
% task: Corresponds to one of the 2 intensity tasks from which we might want to compute in real-time:
%
%    'Calibrate_Intensity' or 'Intensity'     
%
% A few other parameters need to be passed:
% 
% day: represents the day (an int). Will be recoded to pre or post neurofeedback (a stringcalled time 'Pre' or 'Post')
%
% GPU: This tells the collector to do his comutations using the GPU.
%
% GPU_Receiver: this Tells us if the GPU was used by the receiver (this is
% only used in the calculation_score_RS() function, which is disabled by
% default)
% 
% varargin: can be the port to use in order to communicate with the
% receivers.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% few things to add to the MATLAB path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fullpath = which( mfilename );
[my_path, my_name, extension] = fileparts(deblank(fullpath));
addpath( my_path );
addpath( fullfile(my_path, 'mfiles') );
addpath( fullfile(my_path, 'utility') );
addpath( fullfile(my_path, 'toolbox') );
addpath( fullfile(my_path, 'toolbox', 'msocket') );
addpath( fullfile(my_path, 'toolbox', 'SLR_dev') );
if exist('spm', 'file') == 0
  spm_search_path = {'~/neurofeedback/toolbox/spm12','~/Users/neurofeedback/toolbox/spm12' };
  for ii=1:length(spm_search_path)
    if exist(spm_search_path{ii}, 'dir')
      addpath(spm_search_path{ii});
      break;
    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A function that initiates a lot of the variables.
% Later on the functions block_dialog() and para_dialog() will
% also generate the interface to input some variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gData
gData = create_global('neurofeedback');

% This sets the option to do computation using GPU arrays if possible.
gData.GPU = GPU;

% This is to determine ifthe receiver were also using the GPU option. This
% is to compute statistics on processing time.
gData.GPU_Receiver = GPU_Receiver;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CAC 11/20/19 UCLA
%load in custom roi information to get weights for PCA and PCA
%transformation info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gData.data.streak_counter=0; %%initialize multi-trial bonus counter
gData.data.total_streaks=0; %keep track of how many high score streaks per run, cac 2/19/20

% Defines the time value (to save and load files)
if day == 1
  time = 'Pre';
elseif day ==5
  time = 'Post';
end
% displays the copyrights of the toolbox in the Matlab command window.
copyright(gData.version);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to modify the port if a numeric variable is provided as 
% the last input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 6
      if isnumeric(varargin{1})
        gData.para.msocket.port = varargin{1};
      else
        error( usage_message(my_name) );
      end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some values initiated above will be changed by load_parameters() 
% that will read the parameter file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[gData.define, gData.para, err] = load_parameters(gData.define, gData.para);

% This is for the GUI that will get the paths to the DICOM, template and
% ROI files (see header of function).
[gData.define, gData.para, err] = GUI_images_path(gData.define, gData.para);

if err.status
      % This will set the value for each TR (e.g., wait, test, delay, feedback,...)
      gData.data = init_data(gData.define, gData.para, gData.data);  
      [gData.data.scan_condition, gData.para.scans.calc_score_scan, gData.para.scans.score_target_scans] =set_scan_condition(gData.define, gData.para);
    
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %                Block dialog
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      if block_dialog(participant,day)
          % These are to record the answers from the gui
          gData.para.receiver_num = gData.data.block_gui.receiver_num;
          gData.para.msocket.port = gData.data.block_gui.port;
          gData.para.current_block = gData.data.block_gui.current_block;
          gData.para.files.dicom_fnameB = sprintf(gData.data.block_gui.formatB, gData.para.current_block);
    
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %          set the work directory
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          gData.para.files.work_dir = cell(gData.para.receiver_num, 1);
          for ii=1:gData.para.receiver_num
            gData.para.files.work_dir{ii} =fullfile(gData.para.files.save_dir, sprintf('%s_%s_%d', gData.para.save_name,gData.para.files.dicom_fnameB, ii));
          end

          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % This loop will first generate a GUI summarizing 
          % the parameters. Then ,it will initiate the communication 
          % Between the instances and do the real-time processing. 
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if para_dialog()

              % This will essentially define the template image (i.e.,
              % mean.nii) If it is provided as a DICOM, this function will
              % convert it first.
              gData.para.files.templ_nifti_fname = cell(gData.para.receiver_num, 1);
              for ii=1:gData.para.receiver_num
                gData.para.files.templ_nifti_fname{ii} =temlpate_nifti_image(gData.version, gData.define, gData.para, ii);
              end	
              
              % This will get the data out of the ROI.txt file. 
              % This will provide the decoder (stored in the 3rd column)
              % and the template pattern (stored in the 4th column)
              roi_data = get_roi_data(gData.define, gData.para);
              % This will update the gData structure.
              gData.data = set_roi_data(gData.para, gData.data, roi_data);
              
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % This here will connect with each of the receivers and 
              % and with the Display..
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              
              PORT = zeros(gData.para.receiver_num, 1);
              SOCK = zeros(gData.para.receiver_num, 1);
              
              % This is to set up the receiver
              for ii=1:gData.para.receiver_num

                  cache_file(true);	% Cache file
                  PORT(ii) = gData.para.msocket.port;
                  SOCK(ii) = msocket(gData.define,gData.define.msocket.INITIALIZE_SERVER, gData.para);

                  if find( SOCK(ii) < 0 )
                       err = sprintf('msocket: Connection refused (server:%s, port=%d)\n',...
                       gData.para.msocket.server_name, gData.para.msocket.port);
                       error(err);
                  end
                  % Update the port name in order to connect the next
                  % receiver.
                  gData.para.msocket.port = gData.para.msocket.port+1;
              end
              
              % This will initialise the port of the display as the next
              % port after the receivers.
              gData.para.msocket.port_Disp = gData.para.msocket.port;
              
              % This is to store the port and socket of the receiver.
              gData.para.msocket.port = PORT;
              gData.para.msocket.sock = SOCK; 
              
              % This is to connect with the diplay computer.
              gData.para.msocket.sock_Disp = msocket(gData.define,gData.define.msocket.INITIALIZE_SERVER_DISP, gData.para);

              if gData.para.msocket.sock_Disp < 0 
                   err = sprintf('msocket: Connection refused (server:%s, port=%d)\n',...
                   gData.para.msocket.server_name, gData.para.msocket.port);
                   error(err);
              end
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % A few variables that are specific to the Int_RT
              % decoding.
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              
              % This is to hard code the number of trials
              if strcmp(task, 'Calibrate_Intensity')
                  gData.para.scans.trial_num = 14;
                  
              elseif strcmp(task, 'Intensity')
                  gData.para.scans.trial_num = 24;
                  % If it is the intensity session, load the models for the
                  % prediction of the ratings.
                  load(fullpath(gData.para.files.save_dir, participant, time, [participant,'_',time,'_Calibrate_Intensity_RT_Models_Results.mat']),'models');
                  % Initialise the variable to store the predicted values.
                  gData.data.model_pred = nan(gData.para.scans.trial_num,3);
              end
               
              % Set up the TR_to_decode variable. We set arbitrary high
              % numbers that won't trigger the decoding. These number will
              % be changed when the display instance sends out the actual
              % TR_to_decode values.
              gData.TR_to_decode = 10000*ones(1,gData.para.scans.trial_num)';
              
              % This variable will define the decoding window (and
              % overwrite the previous one)
              gData.para.scans.score_target_scans = [gData.TR_to_decode,gData.TR_to_decode];
              
              % This variable will hard code the condition to be 1 = we do
              % not want to invert the decoder prediction
              gData.data.condition = 1;
              

              % This will save the cache file (remember, the MRI-RT and
              % MRI-STIM computers will share the same cache file).
              cache_file(true);
              
              % Load the RS data for the online adjustment of feedback.
              load([gData.para.files.templ_image_dir,'/RS.mat'])
              gData.data.RS = RS;

              % create the GPU array that will hold the volume data
              if gData.GPU
                   gData.data.roi_vol{1} = gpuArray(NaN(size(gData.data.roi_vol{1,1},1),size(gData.data.roi_vol{1,1},2),'single'));
                   gData.data.roi_denoised_vol{1} = gpuArray(NaN(size(gData.data.roi_denoised_vol{1,1},1),size(gData.data.roi_denoised_vol{1,1},2),'single'));
                   gData.data.roi_baseline_mean{1} = gpuArray(NaN(size(gData.data.roi_baseline_mean{1,1},1),size(gData.data.roi_baseline_mean{1,1},2),'single'));
                   gData.data.roi_baseline_std{1} = gpuArray(NaN(size(gData.data.roi_baseline_std{1,1},1),size(gData.data.roi_baseline_std{1,1},2),'single'));
                   
                   if gData.data.roi_num > 1
                       gData.data.roi_vol{2} = gpuArray(NaN(size(gData.data.roi_vol{2},1),size(gData.data.roi_vol{2},2),'single'));
                       gData.data.roi_denoised_vol{2} = gpuArray(NaN(size(gData.data.roi_denoised_vol{2},1),size(gData.data.roi_denoised_vol{2},2),'single'));
                       gData.data.roi_baseline_mean{2} = gpuArray(NaN(size(gData.data.roi_baseline_mean{2},1),size(gData.data.roi_baseline_mean{2},2),'single'));
                       gData.data.roi_baseline_std{2} = gpuArray(NaN(size(gData.data.roi_baseline_std{2},1),size(gData.data.roi_baseline_std{2},2),'single'));
                   end
              end
              
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % This here will send the global data to the receivers.
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              global_data = gData;
              global_data.file_dialog = [];
              msocket(gData.define, gData.define.msocket.SEND_DATA, gData.para, global_data);

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Wait for the start signal from the display_exp
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              command = msocket(gData.define, gData.define.msocket.RECEIVE_DATA_DISP, gData.para, [], -1.0);

              if command == gData.define.command.SCAN_START	
                  % This will send the start signal to the receivers
                  gData.data.live_flag = true;	
                  msocket(gData.define, gData.define.msocket.SEND_DATA,gData.para, gData.define.command.SCAN_START);
              else
                  gData.data.live_flag = false;	
              end
            
              trial = 1;
              while gData.data.live_flag

                    receiver = msocket(gData.define, gData.define.msocket.RECEIVE_DATA,...
                      gData.para, gData.data.receiver, gData.define.msocket.TIMEOUT);
                  
                    for ii=1:gData.para.receiver_num
                        if receiver{ii}.scan
                            [gData.para, gData.data] =set_receiver_data(gData.para, gData.data, receiver{ii});
                            fprintf('TR: %s received\n', num2str(receiver{ii}.scan));
                        end
                    end
                    % Find where we are at.
                    received_scan_num = length( find(gData.data.received_scan) );
                    if received_scan_num < gData.para.scans.total_scan_num
                        received_scan_num = min(find(gData.data.received_scan==0))-1;
                    end
                    gData.data.received_scan_num = received_scan_num;
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % See if the display is sending the value for the TR to
                    % decode for the next trial.
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    TR_to_decode = msocket(gData.define, gData.define.msocket.RECEIVE_DATA_DISP, gData.para, [], gData.define.msocket.TIMEOUT);
                  
                    if ~isempty(TR_to_decode)
                        % This will set up the value of TR-to_decode based
                        % on what we received from the display computer
                        gData.TR_to_decode = TR_to_decode;
                        % This is to set up this variable which defines the
                        % TRs that bound the decoding window. This will be
                        % needed in calculation_score_Disp()
                        gData.para.scans.score_target_scans(:,1) = TR_to_decode - 3;
                        gData.para.scans.score_target_scans(:,2) = TR_to_decode;
                    end
                        
                    % If it is time to compute feedback
                    if gData.data.calc_score_flg(trial) == false && gData.data.received_scan_num >= gData.TR_to_decode(trial)

                          % if we want to display feedback, set that flag
                          if gData.para.score.score_mode ~= gData.define.score_mode.CALC_SCORE &&...
                                gData.para.files.roi_fnum == 0
                                cor_flag = false;	
                          else
                                cor_flag = true;	
                          end
                          
                          % Compute the feedback
                          start = GetSecs;
                          calculation_score(trial, gData.TR_to_decode(trial), cor_flag);
                          final = GetSecs - start;
                          gData.data.calc_time(trial) = final;
                          
                          % What we will do with the predicted valuers will change 
                          % if we are running Calibrate_Intensity or Intensity
                          if strcmp(task, 'Calibrate_Intensity')
                              fprintf('Prediction SIIPS: %s \n', num2str(gData.data.label(trial,1)));
                              fprintf('Prediction NPS: %s \n', num2str(gData.data.label(trial,2)));
                              
                          elseif strcmp(task, 'Intensity')
                              % Here we used the model computed during
                              % Calibrate_Intensity, in order to predict
                              % the values in real time:
                              % models(1) = is the SIIPS model
                              % models(2) = is the NPS model
                              % models(3) = is the model combining both.

                              gData.data.model_pred(trial,1) = predict(models{1},gData.data.label(trial,1));
                              gData.data.model_pred(trial,2) = predict(models{2},gData.data.label(trial,2));
                              gData.data.model_pred(trial,3) = predict(models{3},gData.data.label(trial,1:2));
                              
                              fprintf('Prediction SIIPS model: %s \n', num2str(gData.data.model_pred(trial,1)));
                              fprintf('Prediction NPS model: %s \n', num2str(gData.data.model_pred(trial,2)));
                              fprintf('Prediction both: %s \n', num2str(gData.data.model_pred(trial,3)));
                          end
                              
                          fprintf('Score computed and transmitted in : %s seconds\n', num2str(GetSecs - start));
                          %save([gData.para.files.roi_dir,'/feedback_',num2str(trial),'.mat'],'tr_score','tr_flag','tr_received');

                          if trial < gData.para.scans.trial_num
                                trial = trial+1;
                          else
                                gData.data.live_flag = false;
                                % If we just completed the last trial we
                                % can send the results of the decoding to
                                % the display computer.
                                % If it is the Intensity section: send out
                                % the predicted values by the models.
                                if strcmp(task, 'Calibrate_Intensity')
                                    msocket(gData.define, gData.define.msocket.SEND_DATA_DISP,gData.para, gData.data.label);
                                elseif strcmp(task, 'Intensity')
                                    msocket(gData.define, gData.define.msocket.SEND_DATA_DISP,gData.para, gData.data.model_pred);
                                end
                          end
                    end
              end
              
              if gData.data.quit_key >= gData.define.default.QUIT_KEY_INUM
                  command = gData.define.command.QUIT;
              else
                  command = gData.define.command.FINISH;
              end
              msocket(gData.define, gData.define.msocket.SEND_DATA, gData.para, command);
              pause(4.0);
              msocket(gData.define, gData.define.msocket.FINISH, gData.para);
              

              if gData.data.received_scan_num > gData.para.scans.pre_trial_scan_num

                  scans = [1:gData.data.received_scan_num];
                  [gData.data.FD(scans), delta_realign_val] =calc_fd(gData.data.realign_val, scans, gData.para);
              
                  gData.data.ng_scan(scans) = set_ng_scan(...
                      gData.data.corr_roi_template(scans,:), gData.data.FD(scans),...
                  gData.para.score.corr_roi_template_threshold,...
                  gData.para.score.FD_threshold);
              end

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % save the results
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Here we will save the collector data.
              % The display data will be saved by the display instance.

              mkdir(fullfile(gData.para.files.save_dir, participant));
              mkdir(fullfile(gData.para.files.save_dir, participant,['Day_',num2str(day)]));

              if strcmp(task, 'Calibrate_Intensity')
                 save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_Collector_Calib_Int_RT.mat');

              elseif strcmp(task, 'Intensity')
                 save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_Collector_Int_RT.mat');
              end
              
              save_file_name = fullfile(gData.para.files.save_dir, participant, ['Day_',num2str(day)], save_matname);
              save(save_file_name,'gData');

              fprintf('Save online neurofeedback data (Matlab format)\n');
              fprintf('  Data store dir  = ''%s''\n', fullfile(gData.para.files.save_dir, participant,['Day_', num2str(day)]));
              fprintf('  Data store file = ''%s''\n', save_matname);

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % This should not be used with whole-brain data.
              % Way too heavy.
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              if gData.para.roi_vol_graph_flag && gData.data.roi_num && gData.data.current_trial > 1
                  draw_roi_volume();
              end

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Work directory remove Cache file
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              if gData.define.files.CLEANUP_WORK_FILES
                  cleanup_work_files(gData.define, gData.para);
              end
          end
      end
end
cd(my_path)

function [usage] = usage_message(my_name)

usage = '';
usage = sprintf('%s\tUSAGE : %s\n', usage, my_name);
usage = sprintf('%s\tUSAGE : %s(port)\n', usage, my_name);
usage = sprintf('%s\t  port = TCP/IP port number', usage);
usage = sprintf('%s (Value must be numeric.)\n', usage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

