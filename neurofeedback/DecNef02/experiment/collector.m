function collector(participant, day, GPU, condition, varargin)
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
%
% para_Calibration.txt is to be used with Calibration_FB.m if we want to 
% compute the value of the decoder in real-time.

%%%%%%%%%%
% Inputs:
%%%%%%%%%%
% participant: the participant ID (a string. Ex: 'VTD_Pilot').
% 
% day: represents the day (an int). Will be recoded to pre or post neurofeedback (a stringcalled time 'Pre' or 'Post')
%
% GPU: This tells the collector to do his comutations using the GPU.
%
% Condition: this is to determine up- or down-regulation of the decoder.
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

% This here is the group condition. 
% -1 = reverse association with the pain decoder (downregulation).
% 1 - direct associtation with thre pain decoder (upregulation).
% this is implemented in Collector side, more precisely in the
% calculation_score_Disp.m function.
% gData.data.source_score corresponds to the value before condition
% adjustment.
% The gData.data.scores corresponds with the value to display.
% gData.data.feedback corresponds to the value actually provided in feedback values.

gData.data.condition = condition;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%CAC 11/20/19 UCLA
%load in custom roi information to get weights for PCA and PCA
%transformation info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.streak_counter=0; %%initialize multi-trial bonus counter
gData.data.total_streaks=0; %keep track of how many high score streaks per run, cac 2/19/20

% displays the copyrights of the toolbox in the Matlab command window.
copyright(gData.version);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is to modify the port if a numeric variable is provided as 
% an input.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 5
      if isnumeric(varargin{1})
        gData.para.msocket.port = varargin{1};
      else
        error( usage_message(my_name) );
      end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some values initiated above will be changed by load_parameters() 
% It will thewm from the parameter file.
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
          % the parameters. Then, it will initiate the communication 
          % Between the instances and do the real-time processing. 
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if para_dialog()

              % This will essentially define the template image (i.e.,
              % mean.nii) Ifit is provided as a DICOM, this function will
              % convert it first.
              gData.para.files.templ_nifti_fname = cell(gData.para.receiver_num, 1);
              for ii=1:gData.para.receiver_num
                gData.para.files.templ_nifti_fname{ii} =temlpate_nifti_image(gData.version, gData.define, gData.para, ii);
              end	
              
              % This will get the data out of the ROI_SIIPS.txt file. 
              % This willget the decoder (stored in the 3rd column)
              % and the template pattern (stored in the 4th column)
              roi_data = get_roi_data(gData.define, gData.para);
              
              % This will update the gData structure.
              gData.data = set_roi_data(gData.para, gData.data, roi_data);
              
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % This will connect with each of the receivers and 
              % and with the Display.
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

              % This will save the cache file (remember, the MRI-RT and
              % MRI-STIM computers will share the same cache file).
              cache_file(true);
              
              % Load the RS data for the online adjustment of feedback.
              load([gData.para.files.templ_image_dir,'/RS.mat'])
              gData.data.RS = RS;

              % create the GPU array that will hold the volume data
              if gData.GPU
                   gData.data.roi_vol{1,1} = gpuArray(NaN(size(gData.data.roi_vol{1,1},1),size(gData.data.roi_vol{1,1},2),'single'));
                   gData.data.roi_denoised_vol{1,1} = gpuArray(NaN(size(gData.data.roi_denoised_vol{1,1},1),size(gData.data.roi_denoised_vol{1,1},2),'single'));
                   gData.data.roi_baseline_mean{1,1} = gpuArray(NaN(size(gData.data.roi_baseline_mean{1,1},1),size(gData.data.roi_baseline_mean{1,1},2),'single'));
                   gData.data.roi_baseline_std{1,1} = gpuArray(NaN(size(gData.data.roi_baseline_std{1,1},1),size(gData.data.roi_baseline_std{1,1},2),'single'));
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
                  
                    % If it is time to compute feedback
                    if gData.data.calc_score_flg(trial) == false && gData.data.received_scan_num >= gData.para.scans.calc_score_scan(trial)

                          % if we want to display feedback, set that flag
                          if gData.para.score.score_mode ~= gData.define.score_mode.CALC_SCORE &&...
                                gData.para.files.roi_fnum == 0
                                cor_flag = false;	
                          else
                                cor_flag = true;	
                          end
                          
                          % Compute the feedback
                          start = GetSecs;
                          calculation_score(trial, gData.para.scans.calc_score_scan(trial), cor_flag);
                          final = GetSecs - start;
                          gData.data.calc_time(trial) = final;
                          
                          % Set this variable t transfert the result to the
                          % display.
                          trans = {};
                          trans.tr_score = gData.data.score;
                          trans.tr_flag = gData.data.calc_score_flg;
                          trans.tr_received = gData.data.received_scan_num;
                          trans.tr_trial = trial;
                          trans.tr_streak = gData.data.streak_counter;
                          
                          msocket(gData.define, gData.define.msocket.SEND_DATA_DISP,gData.para, trans);
                          fprintf('Score computed and transmitted in : %s seconds\n', num2str(GetSecs - start));
                          %save([gData.para.files.roi_dir,'/feedback_',num2str(trial),'.mat'],'tr_score','tr_flag','tr_received');

                          if trial < gData.para.scans.trial_num
                                trial = trial+1;
                          else
                                gData.data.live_flag = false;
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
              mkdir([gData.para.files.save_dir,'\',participant]);
              mkdir([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
              
              save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_Collector.mat');
              save_file_name = fullfile([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)], save_matname);
              save(save_file_name,'gData');

              fprintf('Save online neurofeedback data (Matlab format)\n');
              fprintf('  Data store dir  = ''%s''\n', [gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)] );
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

