function RestingState(participant, day)

global gData
	
% Intialize some variables
totalTrials = 14;
blocks = 1;
numInt = 7;
numStim = 1;
practice = 1;
clc   
trial= 1;
px = 'center';
nextstep = 'baseline';
lengthBaseline = 600;
lengthWait = 1.1;
lengthStim = 3;
lengthRating = 4;
lengthITI = 6;


define = gData.define.feedback;

% This will initialize the psychtoolbox screen
visual_feedback(gData.define.feedback.INITIALIZE);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Initialize the client
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%gData.para.msocket.port_Disp = gData.para.msocket.port(1)+gData.para.receiver_num;
%gData.para.msocket.sock_Disp = msocket(gData.define,gData.define.msocket.INITIALIZE_CLIENT_DISP, gData.para);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Wait for the trigger from the scanner ('t' key)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_fmrt_trigger();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the timing of the trigger
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if gData.para.feedback.io_tool == gData.define.feedback.io_tool.PSYCHTOOLBOX
  gData.data.start_time = GetSecs;
else					
  gData.data.start_time = tic;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send the start signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%msocket(gData.define, gData.define.msocket.SEND_DATA_DISP,gData.para, gData.define.command.SCAN_START);
gData.data.live_flag = true;

%Start the experiment loop
doneexp = 0;
while ~doneexp
    switch nextstep
        case 'baseline'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Baseline: ', num2str((GetSecs-gData.data.start_time),5)]);

            start = GetSecs;
            while (GetSecs - start) < lengthBaseline
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            doneexp = 1;
    end
end

X_AXIS = 1;
Y_AXIS = 2;
DrawFormattedText(gData.data.feedback.window_id,...
    'Thank you!', px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT,[],1);
Screen('Flip', gData.data.feedback.window_id);
disp(['End: ', num2str((GetSecs-gData.data.start_time),5)]);

start = GetSecs;
while (GetSecs - start) < lengthITI
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        doneexp = 1;
        break;
    end
end

visual_feedback(gData.define.feedback.FINISH);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we will save the Display data.
% The collector data will be saved by the collector instance.

mkdir([gData.para.files.save_dir,'\',participant]);
mkdir([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);

save_matname = sprintf('%s_%s%s',gData.para.save_name, gData.para.files.dicom_fnameB,'_RS_Display.mat');
save_file_name = fullfile([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)], save_matname);
save(save_file_name,'gData');

fprintf('Save online neurofeedback data (Matlab format)\n');
fprintf('  Data store dir  = ''%s''\n', [gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)] );
fprintf('  Data store file = ''%s''\n', save_matname);







            

