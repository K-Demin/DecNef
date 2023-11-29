function [] = neurofeedback(participant, day)
% Decoded Neurofeedback(DecNef) experiment main function

global gData		  
scan = 0;
gData.data.current_scan = scan;
gData.data.live_flag = true; % Live flag
gData.data.current_trial = 0;
gData.data.current_condition = gData.define.scan_condition.IDLING;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the screen for visual display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
visual_feedback(gData.define.feedback.INITIALIZE);
visual_feedback(gData.define.feedback.GAZE);

% If there are sleep check trials.
tmp = sprintf(' %d,', gData.para.scans.sleep_check_trial);
fprintf('sleep_check_trial =%s\n', tmp(1:end-1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%CAC 11/20/19 UCLA
%load in custom roi information to get weights for PCA and PCA
%transformation info
% The counter is defined in the Collector and sent to the display.
% Total streak is computed only in this instance here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.data.total_streaks=0; %keep track of how many high score streaks per run, cac 2/19/20
gData.data.streak_counter=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Initialize the client
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.para.msocket.port_Disp = gData.para.msocket.port(1)+gData.para.receiver_num;
gData.para.msocket.sock_Disp = msocket(gData.define,gData.define.msocket.INITIALIZE_CLIENT_DISP, gData.para);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Wait for the trigger from the scanner ('t' key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_fmrt_trigger();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   Get the timing of the trigger
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gData.para.feedback.io_tool == gData.define.feedback.io_tool.PSYCHTOOLBOX
  gData.data.start_time = GetSecs;
else					
  gData.data.start_time = tic;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Send the start signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msocket(gData.define, gData.define.msocket.SEND_DATA_DISP, gData.para, gData.define.command.SCAN_START);
gData.data.live_flag = true;

% run this until the live_flag turns off.
while gData.data.live_flag
  
  % Get the current time.
  if gData.para.feedback.io_tool == gData.define.feedback.io_tool.PSYCHTOOLBOX
    time = GetSecs - gData.data.start_time;
  else
    time = toc(gData.data.start_time);
  end
  
  % RestTime indicate when we should enter a new scan. Therefore, when
  % this gets below or equal to 0, this means that a new TR can be executed 
  % and we enter the next "if" statement.
  
  % LocalTime is the time elapsed since the last scan. 
  RestTime = scan*gData.para.scans.TR - time;
  LocalTime = time - (scan-1)*gData.para.scans.TR;
  
  % If we have not yet executed the current scan and the RestTime is below or
  % equal to 0.
  if scan <= gData.para.scans.total_scan_num && RestTime <= 0.0	
        % Update the TR number (here scan)
        scan = scan+1;
        gData.data.current_scan = scan;

        % Set what was the condition of the previous scan
        pre_condition = gData.data.current_condition;

        % If the experiment is over write down the FINISH signal.
        % Else, display a few information and get the current scan condition
        if scan > gData.para.scans.total_scan_num
          fprintf('scan(Finished) (received=%3d) time=%8.3f (sec)\n',gData.data.received_scan_num, time);
          gData.data.current_condition = gData.define.scan_condition.FINISH;
          gData.data.live_flag = false;
        else
          fprintf('scan(%3d->%3d) (received=%3d) time=%8.3f (sec)\n',scan-1, scan, gData.data.received_scan_num, time);
          gData.data.current_condition = gData.data.scan_condition(scan);
        end

        % If this scan changes the condition, execute change_condition()
        if pre_condition ~= gData.data.current_condition
          change_condition(pre_condition);
        end
  end	
    
  execute_condition(LocalTime,time);
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we will save the Display data.
% The collector data will be saved by the collector instance.

mkdir([gData.para.files.save_dir,'\',participant]);
mkdir([gData.para.files.save_dir,'\',participant,'\DecNef\']);
mkdir([gData.para.files.save_dir,'\',participant,'\DecNef\Day_',num2str(day)]);

save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_Display.mat');
save_file_name = fullfile([gData.para.files.save_dir,'\',participant,'\DecNef\Day_',num2str(day)], save_matname);
save(save_file_name,'gData');

fprintf('Save online neurofeedback data (Matlab format)\n');
fprintf('  Data store dir  = ''%s''\n', [gData.para.files.save_dir,'\',participant,'\DecNef\Day_',num2str(day)] );
fprintf('  Data store file = ''%s''\n', save_matname);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This will generate a list to display:
% - the number of TRs contaminated by movements
% - the results of each trials and average.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
str = make_exp_result_string(gData.para, gData.data);
fprintf('\n');
for ii=1:length(str)
  fprintf('%s\n', str{ii});
end

% Close the screen
visual_feedback(gData.define.feedback.FINISH);

if gData.para.roi_vol_graph_flag && gData.data.roi_num && gData.data.current_trial > 1
  draw_roi_volume();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Work directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gData.define.files.CLEANUP_WORK_FILES
  cleanup_work_files(gData.define, gData.para);
end

