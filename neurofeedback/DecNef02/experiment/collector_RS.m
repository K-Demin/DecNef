function collector_RS(participant, day, GPU, GPU_Receiver, varargin)
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
% VTD edits (december 15th 2020):
%
% This is a modification of the collector script to be run during resting
% state. This script will run the decoder in a sliding window during
% resting state and use these values to scale the feedback in real-time.
%
% it will still comunicate with the display to start with the scanner but
% nothing needs to be sent back to the display computer.
%
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

gData.GPU_Receiver = GPU_Receiver;

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
          gData.para.files.dicom_fnameB =...
          sprintf(gData.data.block_gui.formatB, gData.para.current_block);
    
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          %          set the work directory
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          gData.para.files.work_dir = cell(gData.para.receiver_num, 1);
          for ii=1:gData.para.receiver_num
            gData.para.files.work_dir{ii} =fullfile(gData.para.files.save_dir,sprintf('%s_%s_%d', gData.para.save_name,gData.para.files.dicom_fnameB, ii));
          end

          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % This loop will first generate a GUI summarizing 
          % the parameters. Then ,it will initiate the communication 
          % Between the instances and do the real-time processing. 
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          if para_dialog()

              % This will essntially define the template image (i.e.,
              % mean.nii) Ifit is provided as a DICOM, this function will
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
              %gData.para.msocket.sock_Disp = msocket(gData.define,gData.define.msocket.INITIALIZE_SERVER_DISP, gData.para);

              %if gData.para.msocket.sock_Disp < 0 
              %     err = sprintf('msocket: Connection refused (server:%s, port=%d)\n',...
              %     gData.para.msocket.server_name, gData.para.msocket.port);
              %     error(err);
              %end

              % This will save the cache file (remember, the MRI-RT and
              % MRI-STIM computers will share the same cache file).
              cache_file(true);
              
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
              % Wait for the first TR to start
              fprintf('Waiting for the start signal (t key press) ... \n')
              FlushEvents('keyDown');
              while true
                  [KeyIsDown, Secs, Response] = KbCheck;
                  if Response(KbName('t'))
                      gData.data.start_time = GetSecs;
                      break;
                  end
              end

              % This will send the start signal to the receivers
              gData.data.live_flag = true;	
              msocket(gData.define, gData.define.msocket.SEND_DATA,gData.para, gData.define.command.SCAN_START);

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
                    else
                        gData.data.live_flag = false;
                    end
                    gData.data.received_scan_num = received_scan_num;

              end
              
              % Compute the feedback
              startComp = GetSecs;
              cor_flag = 1;
              calculation_score_RS(gData.para.scans.total_scan_num, cor_flag);
              
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % save the results
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Here we will save the collector data.
              % The display data will be saved by the display instance.

              mkdir([gData.para.files.save_dir,'\',participant]);
              mkdir([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
              
              if gData.GPU_Receiver
                 save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_RS_GPU.mat');
              else
                 save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_RS_NoGPU.mat');
              end
              save_file_name = fullfile([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)], save_matname);

              fprintf('Save Resting-state data (Matlab format)\n');
              fprintf('  Data store dir  = ''%s''\n', [gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)] );
              fprintf('  Data store file = ''%s''\n', save_matname);
              fprintf('  Data store dir  = ''%s''\n', [gData.para.files.templ_image_dir] );
              fprintf('  Data store file = RS.mat \n');
              
              % save those results in the reference and DATA directory.
              RS = gData.data.RS;
              save(save_file_name,'RS');
              save([gData.para.files.templ_image_dir,'/RS.mat'], 'RS')


              % Close the msocket connection
              if gData.data.quit_key >= gData.define.default.QUIT_KEY_INUM
                  command = gData.define.command.QUIT;
              else
                  command = gData.define.command.FINISH;
              end
              msocket(gData.define, gData.define.msocket.SEND_DATA, gData.para, command);
              pause(4.0);
              msocket(gData.define, gData.define.msocket.FINISH, gData.para);

              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Work directory remove Cache file
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              if gData.define.files.CLEANUP_WORK_FILES
                  cleanup_work_files(gData.define, gData.para);
              end
          end
      end
end

function [usage] = usage_message(my_name)

usage = '';
usage = sprintf('%s\tUSAGE : %s\n', usage, my_name);
usage = sprintf('%s\tUSAGE : %s(port)\n', usage, my_name);
usage = sprintf('%s\t  port = TCP/IP port number', usage);
usage = sprintf('%s (Value must be numeric.)\n', usage);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

