function [log,Calib_Int, dec_score] = CalibrateIntensity_RT(painStim, stimType, noPainInt, painMin, painMax)

% Input variables:
% PainStim: = boolean, to deliver stimulations or not.
% stimType = accepts 'Thermal' and "'Electrical'
% noPainInt = defines the intensity of the non paiful stim (420 = 42.0 degree celsius)
% painMin = the lower intensity of pain stimulation
% painMax = the highest intensity.

% The code will devide the diff between min and max in 6 even steps.

% noPainInt, painMin and painMax can be either in celsius or un mA
% according to the stimulator used. 
% If you choose the electrical stimulator, the intesity is set such that
% 0.3 = 30 mA.
% If the thermal stimulator is used, 420 = 42.0 degree celsius.

global gData
clc  
% Intialize some variables
totalTrials = 14;
numStim = 2;
practice = 1; 
trial= 1;
px = 'center';
TextSize = 65;
nextstep = 'baseline';
lengthBaseline = 20;
lengthWait = 1.1;
lengthStim = 3;
lengthRating = 4;
lengthITI = 6;
TR = gData.para.scans.TR;


switch stimType
    case 'Thermal'
        % Intialize the stimulator
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
            
            gData.calibInt.para.TCSfeedback.y_temperatures = {};
            gData.calibInt.para.TCSfeedback.x_times = {};
            gData.calibInt.para.neutral_temperature = neutral_temperature;
            gData.calibInt.para.target_temperature = target_temperature;

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

% Compute difference between pain min and max
painDiff = painMax-painMin;

% This will generate 7 intensities (1 non painful and 6 evenly distributed
% between painMin and painMax). The order will be randomized.
stim = [noPainInt*ones(1,numStim),(painMin+(1.*(painDiff/6)))*ones(1,numStim),(painMin+(2.*(painDiff/6)))*ones(1,numStim),(painMin+(3.*(painDiff/6)))*ones(1,numStim),(painMin+(4.*(painDiff/6)))*ones(1,numStim),(painMin+(5.*(painDiff/6)))*ones(1,numStim),(painMin+(6.*(painDiff/6)))*ones(1,numStim)];
reOrder = randperm(length(stim));
stim = stim(reOrder);

% define the define variable
define = gData.define.feedback;

% Defines an array that will hold the index of the TR where we should start
% decoding. This is updated in the WaitITI section for each trial. The TR
% values cannot be predicted in advance since they change as a function of
% the responses of the partticipants (ie. pain trials are longer to rate).
% It is sent out to the collector_Int_RT() during WaitITI as well.
gData.TR_to_decode = 10000*ones(1,totalTrials)';

% save the defined parameters to the gData variable
gData.calibInt.para.totalTrials = totalTrials;
gData.calibInt.para.numStim = numStim;
gData.calibInt.para.practice = practice;
gData.calibInt.para.px = px;
gData.calibInt.para.lengthBaseline = lengthBaseline;
gData.calibInt.para.lengthWait = lengthWait;
gData.calibInt.para.lengtStim = lengthStim;
gData.calibInt.para.lengthRating = lengthRating;
gData.calibInt.para.lengthITI = lengthITI;
gData.calibInt.para.noPainInt = noPainInt;
gData.calibInt.para.painMin = painMin;
gData.calibInt.para.painMax = painMax;
gData.calibInt.para.painDiff = painDiff;
gData.calibInt.para.stimType = stimType;
gData.calibInt.stim = stim;
gData.calibInt.TextSize = TextSize;

% Initialize the log file. This will write down the timing of all steps and
% keypress as well.
gData.calibInt.log = {};

% This will store the data
gData.calibInt.data_names = { 'temperature' 'spot' 'pain=1' 'removed~=1' 'ratings_warmth_or_int' 'unp' 'rating_RT' 'unp_RT' 'trial_num' 'int_0to200' 'int_justpain'};
gData.calibInt.data = [];
gData.calibInt.data(:,1) = stim';
gData.calibInt.data(:,2) = ones(1,length(stim));
gData.calibInt.data(:,4) = ones(1,length(stim));
gData.calibInt.data(:,9) = 1:length(stim);

% This will initialize the psychtoolbox screen
visual_feedback(gData.define.feedback.INITIALIZE);


% Set the font size for the screen
Screen('TextSize',gData.data.feedback.window_id, TextSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Initialize the msocket client
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gData.para.msocket.port_Disp = gData.para.msocket.port(1)+gData.para.receiver_num;
gData.para.msocket.sock_Disp = msocket(gData.define,gData.define.msocket.INITIALIZE_CLIENT_DISP, gData.para);


% Wait for the first TR to start
fprintf('Waiting for trigger from fMRI ... \n')
FlushEvents('keyDown');
while true
    [KeyIsDown, Secs, Response] = KbCheck;
    if Response(KbName('t'))
        gData.data.start_time = GetSecs;
        break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      Send the start signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
msocket(gData.define, gData.define.msocket.SEND_DATA_DISP,gData.para, gData.define.command.SCAN_START);

% Log the start time
gData.calibInt.log(end+1) = {['Start time: ', num2str(gData.data.start_time,5)]};

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
            gData.calibInt.log(end+1) = {['Baseline: ', num2str((GetSecs-gData.data.start_time),5)]};
            
            start = GetSecs;
            while (GetSecs - start) < lengthBaseline
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'waitPractice';
            
        case 'waitPractice'
            disp(['------ Practice trial: ',num2str(trial),'------'])
            gData.calibInt.log(end+1) = {['------ Practice trial: ',num2str(trial),'------']};
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait One: ', num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Wait One: ', num2str((GetSecs-gData.data.start_time),5)]};
            start = GetSecs;
            % Define the target temperature right away (or target
            % intensity for shocks)
            target_temperature = stim(randperm(totalTrials,1));
            % If electrical stimulator, set the intensity right away to
            % save time later.
            if painStim
                switch stimType
                      case 'Electrical'
                          % 2 - set the intensity
                            % Set the intensity (e.g., 0.3 = 30 mA)
                            ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioTDAC_COMMUNICATION', 'LJ_chTDAC_UPDATE_DACA',target_temperature, 0);
                      case 'Thermal'
                        TcsSetTemperatures( tcs, [ round(target_temperature,1), round(target_temperature,1), round(target_temperature,1), round(target_temperature,1), round(target_temperature,1) ] ); %set target temperatures for 5 zones
                end
            end

            while (GetSecs - start) < lengthWait
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'Stim';
            
        case 'waitCalib'
            disp(['------ Calibration trial: ',num2str(trial),'------'])
            gData.calibInt.log(end+1) = {['------ Calibration trial: ',num2str(trial),'------']};
                
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait One: ', num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Wait One: ', num2str((GetSecs-gData.data.start_time),5)]};

            % Define thew target temperature right away (or target
            % intensity for shocks)
            target_temperature = stim(trial);
            % If electrical stimulator, set the intensity right away to
            % save time later.
            if painStim
                switch stimType
                    case 'Electrical'
                          % 2 - set the intensity
                          % Set the intensity (e.g., 0.3 = 30 mA)
                          ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioTDAC_COMMUNICATION', 'LJ_chTDAC_UPDATE_DACA', stim(trial), 0);
                    case 'Thermal'
                        TcsSetTemperatures( tcs, [ round(target_temperature,1), round(target_temperature,1), round(target_temperature,1), round(target_temperature,1), round(target_temperature,1) ] ); %set target temperatures for 5 zones

                end
            end
            
            start = GetSecs;
            while (GetSecs - start) < lengthWait
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'Stim';
            
        case 'Stim'
            disp(['Trial starts: ',num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Trial starts: ',num2str((GetSecs-gData.data.start_time),5)]};
            
            Screen('FrameOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_frame, 20, 20);
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            start = GetSecs;
            stimDone = 0;
            tic; %set start time
            % to count the temperature readings from the probe
            cpt = 0;
            while (GetSecs - start) < lengthStim
                if (GetSecs - start) <= 2 && stimDone ~= 1
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
                    end
                    disp(['Stimulation (', num2str(target_temperature),'): ',num2str((GetSecs-gData.data.start_time),5)]);
                    gData.calibInt.log(end+1) = {['Stimulation (', num2str(target_temperature),') :',num2str((GetSecs-gData.data.start_time),5)]};
                    stimDone = 1;   
                end
                
                % This is to record the actual temperature from the
                % thermode
                if painStim
                    switch stimType

                        case 'Thermal'                
                            cpt = cpt + 1;
                            currentTemperatures = TcsGetTemperatures( tcs ); %array of 5 temperatures ( = 5 zones )
                            %disp( currentTemperatures ); %disp current temp
                            gData.calibInt.para.TCSfeedback.y_temperatures{trial}( cpt, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                            currentTime = toc; %get current time
                            gData.calibInt.para.TCSfeedback.x_times{trial}( cpt, 1 ) = currentTime; %record time in x_temperatures
                    end
                end
                    
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                 end
            end

            nextstep = 'waitTwo';
            
        case 'waitTwo'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait Two: ', num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Wait Two: ', num2str((GetSecs-gData.data.start_time),5)]};
            start = GetSecs;
            while (GetSecs - start) < lengthWait
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'ratingOne';
            
        case 'ratingOne'
            X_AXIS = 1;
            Y_AXIS = 2;
            DrawFormattedText(gData.data.feedback.window_id,...
                'Was this stimulation painful?\n \n(Left) Not painful          (Right) Painful', px,...
                gData.data.feedback.window_center_y...
                - define.offset_ptb.condition_comment(Y_AXIS),...
                gData.define.feedback.color.TEXT,[],1);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Ratings: ', num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Ratings: ', num2str((GetSecs-gData.data.start_time),5)]};
            start = GetSecs;
            resp = 0;
            RT = [];
            while (GetSecs - start) < lengthRating
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;

                elseif keyCode(KbName('y'))
                    gData.calibInt.data(trial,10) = GetSecs - start;
                    resp = 'Pain';
                    
                elseif keyCode(KbName('b'))
                    gData.calibInt.data(trial,10) = GetSecs - start;
                    resp = 'No Pain';
                end
            end
            if resp
                disp(['Answer: ', resp,' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]);
                gData.calibInt.log(end+1) = {['Answer: ', resp,' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.calibInt.log(end+1) = {'Answer: No answer!!'};   
                gData.calibInt.data(trial,4) = 0;
            end
         
            if strcmp(resp, 'Pain')
                % If painful, change the
                nextstep = 'ratingPain';
                gData.calibInt.data(trial,3) = 1;
            else
                % else, do this
                nextstep = 'ratingNoPain';
                gData.calibInt.data(trial,3) = 0;
            end
            
        case 'ratingPain'
            X_AXIS = 1;
            Y_AXIS = 2;
            % The code below creates as slider scale form 0 to 100 for keyboard use with
            % left starting position. The left and right control keys are used to
            % control the slider and enter is used to log the response.
            % (note to self: remember to cite this guy)
            % For the VAS
            question  = 'How painful was the stimulation?';
            endPoints = {'Extremely painful','No pain at all'};
            [position, RT, answer] = slideScale(gData.data.feedback.window_id, ...
                question, ...
                gData.data.feedback.rect, ...
                endPoints, ...
                gData.define.feedback.color.TEXT);
            
            % flip the position because of the mirror display in the MRI.
            position = 50 + (50 - position);
            
            gData.calibInt.data(trial,5) = position;
            gData.calibInt.data(trial,7) = RT*1000;

            if RT
                disp(['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]);
                gData.calibInt.log(end+1) = {['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.calibInt.log(end+1) = {'Answer: No answer!!'};  
                gData.calibInt.data(trial,4) = 0;
            end
            
            question  = 'How unpleasant was the stimulation?';
            endPoints = {'Extremely unpleasant', 'No unpleasant at all'};
            [position, RT, answer] = slideScale(gData.data.feedback.window_id, ...
                question, ...
                gData.data.feedback.rect, ...
                endPoints, ...
                gData.define.feedback.color.TEXT);
            
            % flip the position because of the mirror display in the MRI.
            position = 50 + (50 - position);
            
            gData.calibInt.data(trial,6) = position;
            gData.calibInt.data(trial,8) = RT*1000;

            if RT
                disp(['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]);
                gData.calibInt.log(end+1) = {['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.calibInt.log(end+1) = {'Answer: No answer!!'};  
                gData.calibInt.data(trial,4) = 0;
            end
            if trial == 4 && practice == 1
                nextstep = 'PracticeDone';
                                
            else
                nextstep = 'waitITI';
            end
            
        case 'ratingNoPain'
            X_AXIS = 1;
            Y_AXIS = 2;
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
            
            gData.calibInt.data(trial,5) = position;
            gData.calibInt.data(trial,7) = RT*1000;
            gData.calibInt.data(trial,6) = 9999;
            gData.calibInt.data(trial,8) = 9999;
            
            if RT
                disp(['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]);
                gData.calibInt.log(end+1) = {['Answer: ', num2str(position),' Response Time: ', num2str((GetSecs-gData.data.start_time),5)]};
            else
                disp('Answer: No answer!!');
                gData.calibInt.log(end+1) = {'Answer: No answer!!'};  
                gData.calibInt.data(trial,4) = 0;
            end
            if trial == 4 && practice == 1
                nextstep = 'PracticeDone';
                
            else
                nextstep = 'waitITI';
            end
            
        case 'PracticeDone'
            X_AXIS = 1;
            Y_AXIS = 2;
            DrawFormattedText(gData.data.feedback.window_id,...
                'Beginning of sensory calibration.', px,...
                gData.data.feedback.window_center_y...
                - define.offset_ptb.condition_comment(Y_AXIS),...
                gData.define.feedback.color.TEXT,[],1);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Practice Done: ', num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Practice Done: ', num2str((GetSecs-gData.data.start_time),5)]};
            start = GetSecs;
            resp = 0;
            while (GetSecs - start) < lengthRating
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            practice = 0;
            trial = 0;
            nextstep = 'waitITI';
            
        case 'waitITI'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait ITI: ', num2str((GetSecs-gData.data.start_time),5)]);
            gData.calibInt.log(end+1) = {['Wait ITI: ', num2str((GetSecs-gData.data.start_time),5)]};
            
            if trial < totalTrials
                trial = trial + 1;
                if practice == 1
                    nextstep = 'waitPractice';
                elseif practice == 0
                    nextstep = 'waitCalib';
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %            Send the TR to decode
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Essentially, get the current time minus the start time. Add
                    % the length of the ITI (next while),the length of the wait
                    % before the stim(lengthStim)and the stimlength.
                    % This value divided by the TR and rounded. 
                    
                    % I also add the value of post_test_delay_scan_num which is essentially the
                    % number of TRs to wait to account for the HRF.
                    
                    % The value that is sent to Collector_Int_RT() is
                    % essentially the same as the one that would be in
                    % gData.para.scans.calc_score_scan() to start the
                    % decoding. It represents the last expected TR to
                    % decode in a trial.
                    gData.TR_to_decode(trial) = round(((GetSecs - gData.data.start_time)+ lengthITI +lengthWait+lengthStim)/TR)+ gData.para.scans.post_test_delay_scan_num;
                    msocket(gData.define, gData.define.msocket.SEND_DATA_DISP, gData.para, gData.TR_to_decode);

                end
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
    gData.data.label = trans;
end

DrawFormattedText(gData.data.feedback.window_id,...
    'Thank you!', px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT,[],1);
Screen('Flip', gData.data.feedback.window_id);
disp(['End: ', num2str((GetSecs-gData.data.start_time),5)]);
gData.calibInt.log(end+1) = {['End: ', num2str((GetSecs-gData.data.start_time),5)]};
start = GetSecs;
while (GetSecs - start) < lengthITI
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        doneexp = 1;
        break;
    elseif keyCode(KbName('t'))
        gData.calibInt.log(end+1) = {['TR: ', num2str((secs-gData.data.start_time),5)]};
    end
end

visual_feedback(gData.define.feedback.FINISH);
gData.calibInt.log = gData.calibInt.log';
log = gData.calibInt.log;
Calib_Int = gData.calibInt.data;
dec_score = gData.data.label;



            

