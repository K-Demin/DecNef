function [log,Int, dec_score] = Intensity(calib_corr_table, painStim,stimType)

global gData
	
% This function will conduct the intensity procedure.
% Here stimulations of 4 intensities will be delivered in 3 different
% contexts:
% 1- Dot motion
% 2- Imagine dot motion
% 3- Imagine nothing.
%
% -VTD-

% Intialize some variables
% 2 stim per intensity * 4 intensities * 3 conditions = 24 total trials
totalTrials = 24;

% Total number of stim for each intensity
numStim = 6;
clc   
trial= 1;
px = 'center';
nextstep = 'baseline';
lengthBaseline = 20;
lengthWaitOne = 1.1;
lengthWaitTwo = 8.1;
TR = gData.para.scans.TR;

% The length stim should include the jitter time. So, stim duration + 2
% sec.
lengthStim = 5;
lengthRating = 4;
lengthITI = 3;

% Size of the text on the screen
TextSize = 65;

% Declare tcs (for situation where there tcs is not initiated because there
% is no stimulation)
tcs = [];

switch stimType
    case 'Thermal'
        if painStim
            neutral_temperature = 40.0;
            target_temperature = 40.0;
            tcs = TcsOpenCom( 'COM5' );

            %set TCS in "quiet mode"
            %otherwise TCS sends regularly temperature data
            %( @1Hz if no stimulation, @100Hz during stimulation )
            TcsQuietMode( tcs );

            %set parameters
            TcsSetBaseLine( tcs, neutral_temperature ); %set baseline 31°C
            TcsSetDurations( tcs, [ 3.0, 3.0, 3.0, 3.0, 3.0 ] ); %set durations for 5 zones
            %TcsSetRampSpeed( tcs, [ 75.0, 75.0, 75.0, 75.0, 75.0 ] ); %set ramp speed for 5 zones
            %TcsSetReturnSpeed( tcs, [ 75.0, 75.0, 75.0, 75.0, 75.0 ] ); %set return speed for 5 zones
            TcsSetTemperatures( tcs, [ target_temperature, target_temperature, target_temperature, target_temperature, target_temperature ] ); %set target temperatures for 5 zones

            gData.Int.para.TCSfeedback.y_temperatures = {};
            gData.Int.para.TCSfeedback.x_times = {};
            gData.Int.para.neutral_temperature = neutral_temperature;
            gData.Int.para.target_temperature = target_temperature;
        end

    case 'Electrical'
        if painStim
            % 1 - Initialize the labjack
            % Make the UD .NET assembly visible in MATLAB.
            ljasm = NET.addAssembly('LJUDDotNet');
            ljudObj = LabJack.LabJackUD.LJUD;
            % Open the first found LabJack U3.
            [ljerror, ljhandle] = ljudObj.OpenLabJackS('LJ_dtU3', 'LJ_ctUSB', '0', true, 0);
            % Tell the driver which pin the LJtick is on
            ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioPUT_CONFIG', 'LJ_chTDAC_SCL_PIN_NUM', 4, 0);
        end
end

% Randomize the order of the trials
stim = [calib_corr_table(find(calib_corr_table(:,1) == 100),2)*ones(1,numStim),calib_corr_table(find(calib_corr_table(:,1) == 120),2)*ones(1,numStim),calib_corr_table(find(calib_corr_table(:,1) == 140),2)*ones(1,numStim),calib_corr_table(find(calib_corr_table(:,1) == 160),2)*ones(1,numStim)];

condition = [];
for i = 1:6
    condition = [condition,1,1,2,2,3,3];
end
reOrder = randperm(totalTrials);
stim = stim(reOrder);
condition = condition(reOrder);
define = gData.define.feedback;
gData.Int.stim = stim;
gData.Int.condition = condition;

% Defines an array that will hold the index of the TR where we should start
% decoding. This is updated in the WaitITI section for each trial. The TR
% values cannot be predicted in advance since they change as a function of
% the responses of the partticipants (ie. pain trials are longer to rate).
% It is sent out to the collector_Int_RT() during WaitITI as well.
gData.TR_to_decode = 10000*ones(1,totalTrials)';

% create the jitter for the stimulation (1xtotalTrials)
jitter = rand([1,totalTrials])+1;

% save the defined parameters to the gData variable
gData.Int.para.totalTrials = totalTrials;
gData.Int.para.numStim = numStim;
gData.Int.para.px = px;
gData.Int.para.lengthBaseline = lengthBaseline;
gData.Int.para.lengthWaitOne = lengthWaitOne;
gData.Int.para.lengthWaitTwo = lengthWaitTwo;
gData.Int.para.lengtStim = lengthStim;
gData.Int.para.lengthRating = lengthRating;
gData.Int.para.lengthITI = lengthITI;
gData.Int.stim = stim;
gData.Int.TextSize = TextSize;


% Initialize the log file. This will write down the timing of all steps and
% keypress as well.
gData.Int.log = {};
gData.Int.trial = 1;

% This will store the data
gData.Int.data_names = { 'temperature' 'condition' 'pain=1' 'removed~=1' 'ratings_warmth_or_int' 'unp' 'rating_RT' 'unp_RT' 'trial_num' 'int_0to200' 'int_justpain'};
gData.Int.data = [];
gData.Int.data(:,1) = stim';
gData.Int.data(:,2) = condition';
gData.Int.data(:,4) = ones(1,length(stim));
gData.Int.data(:,9) = 1:length(stim);

% This will initialize the psychtoolbox screen
visual_feedback(gData.define.feedback.INITIALIZE);

% Initialize the log file. This will write down the timing of all steps and
% keypress as well.
gData.Int.log = {};

% Set the font size for the screen
Screen('TextSize',gData.data.feedback.window_id, TextSize);

X_AXIS = 1;
Y_AXIS = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                     Initialize the msocket client
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.para.msocket.port_Disp = gData.para.msocket.port(1)+gData.para.receiver_num;
gData.para.msocket.sock_Disp = msocket(gData.define,gData.define.msocket.INITIALIZE_CLIENT_DISP, gData.para);

% Wait for the first TR to start
fprintf('Waiting for trigger from fMRI ... \n')
FlushEvents('keyDown');
while true
    [KeyIsDown, Secs, Response] = KbCheck;
    if Response(KbName('t'))
        gData.Int.start_time = GetSecs;
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Send the start signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msocket(gData.define, gData.define.msocket.SEND_DATA_DISP,gData.para, gData.define.command.SCAN_START);

% Log the start time
gData.Int.log(end+1) = {['Start time: ', num2str(gData.Int.start_time,5)]};

%Start the experiment loop
doneexp = 0;
while ~doneexp
    switch nextstep
        case 'baseline'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Baseline: ', num2str((GetSecs-gData.Int.start_time),5)]);
            gData.Int.log(end+1) = {['Baseline: ', num2str((GetSecs-gData.Int.start_time),5)]};
            start = GetSecs;
            
            if trial == 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Send the TR to decode
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Essentially, get the current time minus the start time. Add
                % the length of the ITI (next while) and the length of the wait
                % before the stim(lengthStim). Also need to add, the stimlength.
                % This value divided by the TR and rounded. 
                % I also add the value of post_test_delay_scan_num which is essentially the
                % number of TRs to wait to account for the HRF.
                % The value that is sent to Collector_Int_RT() is
                % essentially the same as the one that would be in
                % gData.para.scans.calc_score_scan() to start the
                % decoding. It represents the last expected TR to
                % decode in a trial.
                gData.TR_to_decode(trial) = round(((GetSecs - gData.Int.start_time)+ lengthBaseline + lengthWaitOne + lengthStim)/TR)+ gData.para.scans.post_test_delay_scan_num;
                msocket(gData.define, gData.define.msocket.SEND_DATA_DISP, gData.para, gData.TR_to_decode);
            end
            
            while (GetSecs - start) < lengthBaseline
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'waitOne';
            
        case 'waitOne'
            disp(['------ Trial: ',num2str(trial),'------'])
            gData.Int.log(end+1) = {['------ Trial: ',num2str(trial),'------']};
            
            disp(['Wait One (Calib: ',num2str(trial),'): ', num2str((GetSecs-gData.Int.start_time),5)]);
            gData.Int.log(end+1) = {['Wait One (Calib: ',num2str(trial),'): ', num2str((GetSecs-gData.Int.start_time),5)]};
            
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            start = GetSecs;
            
            % If electrical stimulator, set the intensity right away to
            % save time later.
            if painStim
                switch stimType
                      case 'Electrical'
                          % 2 - set the intensity
                          % Set the intensity (e.g., 0.3 = 30 mA)
                          ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioTDAC_COMMUNICATION', 'LJ_chTDAC_UPDATE_DACA', stim(trial), 0);
                      case 'Thermal'
                          TcsSetTemperatures( tcs, [ round(stim(trial),1), round(stim(trial),1), round(stim(trial),1), round(stim(trial),1), round(stim(trial),1) ] ); %set target temperatures for 5 zones
                end
            end
            
            % If there will be dot motion, prep here:
            if condition(trial) == 1
                dotsX_prep(gData.Int.para.lengtStim)
            end

            
            while (GetSecs - start) < lengthWaitOne
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'Stim';
            
        case 'Stim'
            disp(['Trial starts: (', num2str(condition(trial)),'): ',num2str((GetSecs-gData.Int.start_time),5)]);
            gData.Int.log(end+1) = {['Trial starts: (', num2str(condition(trial)),'): ',num2str((GetSecs-gData.Int.start_time),5)]};            

            start = GetSecs;
            % this tic and cpt are for the readout of the
            % temperature from the probe.
            tic;
            % This is the counter for the reading of the thermal stimulation
            gData.dot.cpt_tcs = 0;
            if condition(trial) == 1
                gData.dot.maxDotTime = jitter(trial);
                gData.dot.stop = 0;
                [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs);
                gData.Int.para.TCSfeedback.y_temperatures{trial} = y_temperatures;
                gData.Int.para.TCSfeedback.x_times{trial} = x_times;
                % If we want to send stimulations then choose which
                % one.
                if painStim
                    switch stimType

                        case 'Thermal'
                            TcsStimulate( tcs );

                        case 'Electrical'
                            % 3 - send the TTL
                            % Start by using the pin_configuration_reset IOType so that all
                            % pin assignments are in the factory default condition.
                            ljerror = ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

                            % Set digital output FIO4 to output-high.
                            ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', 3, 1, 0, 0);
                            ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', 3, 0, 0, 0);
                            ljudObj.GoOne(ljhandle);

                            % Get all the results just to check for errors.
                            [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);
                            %gData.calibInt.para.ElectricFeedback{trial} = [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl];
                    end 
                
                disp(['Stimulation (', num2str(stim(trial)),'): ',num2str((GetSecs-gData.Int.start_time),5)]);
                gData.Int.log(end+1) = {['Stimulation (', num2str(stim(trial)),') :',num2str((GetSecs-gData.Int.start_time),5)]};
                end
                
                gData.dot.maxDotTime = lengthStim - (GetSecs - start);
                gData.dot.stop = 1;
                [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs);
                gData.Int.para.TCSfeedback.y_temperatures{trial} = [gData.Int.para.TCSfeedback.y_temperatures{trial}; y_temperatures];
                gData.Int.para.TCSfeedback.x_times{trial} = [gData.Int.para.TCSfeedback.x_times{trial};x_times];

                %erase last dots, but leave up fixation and targets
                Screen('Flip', gData.dot.curWindow,0,gData.dot.dontclear);
            else
                Screen('FrameOval', gData.data.feedback.window_id,...
                    gData.define.feedback.color.GAZE,...
                    gData.data.feedback.gaze_frame, 20, 20);
                Screen('FillOval', gData.data.feedback.window_id,...
                    gData.define.feedback.color.GAZE,...
                    gData.data.feedback.gaze_fill);
                
                % If it is condition 2 or 3 display their associated text:
                % "Imagine rightward dot motion" "imagine nothing"
                if condition(trial) == 2
                    DrawFormattedText(gData.data.feedback.window_id,...
                        'Imagine rightward dot motion', px,...
                        gData.data.feedback.window_center_y + 150,...
                        gData.define.feedback.color.TEXT,[],1);
                elseif condition(trial) == 3
                   DrawFormattedText(gData.data.feedback.window_id,...
                        'Imagine a square', px,...
                        gData.data.feedback.window_center_y + 150,...
                        gData.define.feedback.color.TEXT,[],1);
                end
            
                Screen('Flip', gData.data.feedback.window_id);
                start = GetSecs;
                stimDone = 0;
                while (GetSecs - start) < lengthStim
                    if (GetSecs - start) >= jitter(trial) && stimDone ~= 1
                        
                        % If we want to send stimulations then choose which
                        % one.
                        if painStim
                            switch stimType

                                case 'Thermal'
                                    TcsStimulate( tcs );

                                case 'Electrical'
                                    % 3 - send the TTL
                                    % Start by using the pin_configuration_reset IOType so that all
                                    % pin assignments are in the factory default condition.
                                    ljerror = ljudObj.ePutS(ljhandle, 'LJ_ioPIN_CONFIGURATION_RESET', 0, 0, 0);

                                    % Set digital output FIO4 to output-high.
                                    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', 3, 1, 0, 0);
                                    ljudObj.AddRequestS(ljhandle, 'LJ_ioPUT_DIGITAL_BIT', 3, 0, 0, 0);
                                    ljudObj.GoOne(ljhandle);

                                    % Get all the results just to check for errors.
                                    [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl] = ljudObj.GetFirstResult(ljhandle, 0, 0, 0, 0, 0);
                                    %gData.calibInt.para.ElectricFeedback{trial} = [ljerror, ioType, channel, dblValue, dummyInt, dummyDbl];
                            end 
                            disp(['Stimulation (', num2str(stim(trial)),'): ',num2str((GetSecs-gData.Int.start_time),5)]);
                            gData.Int.log(end+1) = {['Stimulation (', num2str(stim(trial)),') :',num2str((GetSecs-gData.Int.start_time),5)]};
                        end
                        stimDone = 1;   
                    end
                    
                    % Record the temperature of the stim.
                    if painStim
                        switch stimType

                            case 'Thermal'                
                                gData.dot.cpt_tcs = gData.dot.cpt_tcs + 1;
                                currentTemperatures = TcsGetTemperatures( tcs ); %array of 5 temperatures ( = 5 zones )
                                %disp( currentTemperatures ); %disp current temp
                                gData.Int.para.TCSfeedback.y_temperatures{trial}( gData.dot.cpt_tcs, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                                currentTime = toc; %get current time
                                gData.Int.para.TCSfeedback.x_times{trial}( gData.dot.cpt_tcs, 1 ) = currentTime; %record time in x_temperatures
                        end
                    end

                            
                    [keyIsDown,secs, keyCode] = KbCheck;
                    if keyCode(KbName('ESCAPE'))
                        doneexp = 1;
                        break;
                     end
                end
            end

            nextstep = 'waitTwo';
            
        case 'waitTwo'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait Two: ', num2str((GetSecs-gData.Int.start_time),5)]);
            gData.Int.log(end+1) = {['Wait Two: ', num2str((GetSecs-gData.Int.start_time),5)]};
            start = GetSecs;
            while (GetSecs - start) < lengthWaitTwo
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'ratingOne';
            
        case 'ratingOne'
            DrawFormattedText(gData.data.feedback.window_id,...
                'Was this stimulation painful?\n \n(1) Not painful          (2) Painful', px,...
                gData.data.feedback.window_center_y...
                - define.offset_ptb.condition_comment(Y_AXIS),...
                gData.define.feedback.color.TEXT,[],1);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Ratings: ', num2str((GetSecs-gData.Int.start_time),5)]);
            gData.Int.log(end+1) = {['Ratings: ', num2str((GetSecs-gData.Int.start_time),5)]};
            start = GetSecs;
            resp = 0;
            RT = [];
            while (GetSecs - start) < lengthRating
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;

                elseif keyCode(KbName('y'))
                    gData.Int.data(trial,10) = GetSecs -start;
                    resp = 'Pain';
                    
                elseif keyCode(KbName('b'))
                    gData.Int.data(trial,10) = GetSecs -start;
                    resp = 'No Pain';
                end
            end
            if resp
                disp(['Answer: ', resp,' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]);
                gData.Int.log(end+1) = {['Answer: ', resp,' Response Time: ',num2str((GetSecs-gData.data.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.Int.log(end+1) = {'Answer: No answer!!'};   
                gData.Int.data(trial,4) = 0;
            end
         
            if strcmp(resp, 'Pain')
                % If painful, change the
                nextstep = 'ratingPain';
                gData.Int.data(trial,3) = 1;
            else
                % else, do this
                nextstep = 'ratingNoPain';
                gData.Int.data(trial,3) = 0;
            end
            
        case 'ratingPain'
            % The code below creates as slide scale form 0 to 100 for keyboard use with
            % left starting position. The left and right control keys are used to
            % control the slider and enter is used to log the response.
            % (note to self: remember to cite this guy)
            % For the VAS
            question  = 'How intense was the stimulation?';
            endPoints = {'Extremely intense','No pain at all'};
            [position, RT, answer] = slideScale(gData.data.feedback.window_id, ...
                question, ...
                gData.data.feedback.rect, ...
                endPoints, ...
                gData.define.feedback.color.TEXT);
            
            % flip the position because of the mirror display in the MRI.
            position = 50 + (50 - position);
            
            gData.Int.data(trial,5) = position;
            gData.Int.data(trial,7) = RT*1000;

            if RT
                disp(['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]);
                gData.Int.log(end+1) = {['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.Int.log(end+1) = {'Answer: No answer!!'};  
                gData.Int.data(trial,4) = 0;
            end
            
            question  = 'How unpleasant was the stimulation?';
            endPoints = {'Extremely unpleasant','No unpleasant at all'};
            [position, RT, answer] = slideScale(gData.data.feedback.window_id, ...
                question, ...
                gData.data.feedback.rect, ...
                endPoints, ...
                gData.define.feedback.color.TEXT);
            
            % flip the position because of the mirror display in the MRI.
            position = 50 + (50 - position);
            
            gData.Int.data(trial,6) = position;
            gData.Int.data(trial,8) = RT*1000;

            if RT
                disp(['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]);
                gData.Int.log(end+1) = {['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.Int.log(end+1) = {'Answer: No answer!!'};  
                gData.Int.data(trial,4) = 0;
            end

            nextstep = 'waitITI';

            
        case 'ratingNoPain'
            % The code below creates as slide scale form 0 to 100 for keyboard use with
            % left starting position. The left and right control keys are used to
            % control the slider and enter is used to log the response.
            % (note to self: remember to cite this guy)
            question  = 'How intense was the stimulation?';
            endPoints = {'Very intense, without pain', 'Not intense at all'};
            [position, RT, answer] = slideScale(gData.data.feedback.window_id, ...
                question, ...
                gData.data.feedback.rect, ...
                endPoints, ...
                gData.define.feedback.color.TEXT);
            
            % flip the position because of the mirror display in the MRI.
            position = 50 + (50 - position);
            
            gData.Int.data(trial,5) = position;
            gData.Int.data(trial,7) = RT*1000;
            gData.Int.data(trial,6) = 9999;
            gData.Int.data(trial,8) = 9999;
            
            if RT
                disp(['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]);
                gData.Int.log(end+1) = {['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.Int.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.Int.log(end+1) = {'Answer: No answer!!'};  
                gData.Int.data(trial,4) = 0;
            end
            
            nextstep = 'waitITI';

        case 'waitITI'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait ITI: ', num2str((GetSecs-gData.Int.start_time),5)]);
            gData.Int.log(end+1) = {['Wait ITI: ', num2str((GetSecs-gData.Int.start_time),5)]};

            if trial < totalTrials
                trial = trial + 1;
                nextstep = 'waitOne';
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Send the TR to decode
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Essentially, get the current time minus the start time. Add
                % the length of the ITI (next while) and the length of the wait
                % before the stim(lengthStim). Also need to add, the stimlength.
                % This value divided by the TR and rounded. 
                % I also add the value of post_test_delay_scan_num which is essentially the
                % number of TRs to wait to account for the HRF.
                % The value that is sent to Collector_Int_RT() is
                % essentially the same as the one that would be in
                % gData.para.scans.calc_score_scan() to start the
                % decoding. It represents the last expected TR to
                % decode in a trial.
                gData.TR_to_decode(trial) = round(((GetSecs - gData.Int.start_time)+ lengthITI + lengthWaitOne + lengthStim)/TR)+ gData.para.scans.post_test_delay_scan_num;
                msocket(gData.define, gData.define.msocket.SEND_DATA_DISP, gData.para, gData.TR_to_decode);
            else
                doneexp = 1;
            end
            
            start = GetSecs;
            while (GetSecs - start) < lengthITI
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            
    end
end

% At the end of the session, the collector will send the predicted labels
% to the display rigt here:
trans = msocket(gData.define, gData.define.msocket.RECEIVE_DATA_DISP, gData.para, [], 20);

if ~isempty(trans)
    gData.data.model_pred = trans;
end

DrawFormattedText(gData.data.feedback.window_id,...
    'Thank you!', px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT,[],1);
Screen('Flip', gData.data.feedback.window_id);
disp(['End: ', num2str((GetSecs-gData.Int.start_time),5)]);
gData.Int.log(end+1) = {['End: ', num2str((GetSecs-gData.Int.start_time),5)]};
start = GetSecs;
while (GetSecs - start) < lengthITI
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        doneexp = 1;
        break;
    elseif keyCode(KbName('t'))
        gData.Int.log(end+1) = {['TR: ', num2str((secs-gData.Int.start_time),5)]};
    end
end

visual_feedback(gData.define.feedback.FINISH);
gData.Int.log = gData.Int.log';
log = gData.Int.log;
Int = gData.Int.data;
dec_score = gData.data.label;



            

