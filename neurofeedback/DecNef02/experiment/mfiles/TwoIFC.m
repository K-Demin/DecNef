function [log, two_IFC] = TwoIFC(ExpTempOne, ExpTempTwo, painStim, stimType)

global gData

% If you choose the electrical stimulator, the intesity is set such that
% 0.3 = 30 mA.
% If the thermal stimulator is used, 420 = 42.0 degree celsius.

% Intialize some variables
totalTrials = 40;
numStim = 10;
blocks = 2;
trial= 1;
px = 'center';
lengthBaseline = 20;
lengthWait = 2.1;
lengthStim = 5;
lengthRating = 4;
lengthITI = 6;

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

            gData.twoIFC.para.TCSfeedback.y_temperatures = {};
            gData.twoIFC.para.TCSfeedback.x_times = {};
            gData.twoIFC.para.neutral_temperature = neutral_temperature;
            gData.twoIFC.para.target_temperature = target_temperature;

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
stimOne = [ones(1,(numStim*2)),zeros(1,(numStim*2))];
stimTwo = [ones(1,numStim),zeros(1,numStim),ones(1,numStim),zeros(1,numStim)];
reOrder = randperm(totalTrials);
stimOne = stimOne(reOrder);
stimTwo = stimTwo(reOrder);

% This is to store the time it takes to read from the thermal probe.
% We will incorporate the same lag in the neurofeedback display so that the
% two dot motion presentation go exactly at the same speed.
gData.dot.time_TCS = [];

% define the define variable
define = gData.define.feedback;

gData.twoIFC.stimOne = stimOne;
gData.twoIFC.stimTwo = stimTwo;

% create the jitter for the stimulation (2xtotalTrials)
jitter = [rand([1,totalTrials])+1;rand([1,totalTrials])+1];

% save the defined parameters to the gData variable
gData.twoIFC.para.totalTrials = totalTrials;
gData.twoIFC.para.numStim = numStim;
gData.twoIFC.para.blocks = blocks;
gData.twoIFC.para.px = px;
gData.twoIFC.para.lengthBaseline = lengthBaseline;
gData.twoIFC.para.lengthWait = lengthWait;
gData.twoIFC.para.lengtStim = lengthStim;
gData.twoIFC.para.lengthRating = lengthRating;
gData.twoIFC.para.lengthITI = lengthITI;
gData.twoIFC.para.jitter = jitter;

% This will initialize the psychtoolbox screen
visual_feedback(gData.define.feedback.INITIALIZE);

% Initialize the log file. This will write down the timing of all steps and
% keypress as well.
gData.twoIFC.log = {};

gData.twoIFC.trial = 1;

% This will store the data
gData.twoIFC.data_names = { 'tempOne' 'tempTwo' 'trial_num' 'removed~=1' 'More_painful' 'spot' 'Condition' 'Resp_time'};
gData.twoIFC.data = [];

gData.twoIFC.data(:,1) = ExpTempOne * ones(1,totalTrials);
gData.twoIFC.data(:,2) = ExpTempTwo * ones(1,totalTrials);
gData.twoIFC.data(:,3) = 1:totalTrials;
gData.twoIFC.data(:,4) = ones(1,totalTrials);
gData.twoIFC.data(:,5) = zeros(1,totalTrials);
gData.twoIFC.data(:,6) = ones(1,totalTrials);
gData.twoIFC.data(:,8) = zeros(1,totalTrials);

% Put the condition in the twoIFC data:
% 1 = 0 - 0
% 2 = 0 - 1
% 3 = 1 - 0
% 4 = 1 - 1
for i = 1:size(gData.twoIFC.data,1)
    if stimOne(i) == 0 && stimTwo(i) == 0
        gData.twoIFC.data(i,7) = 1;
    elseif stimOne(i) == 0 && stimTwo(i) == 1
        gData.twoIFC.data(i,7) = 2;
    elseif stimOne(i) == 1 && stimTwo(i) == 0
        gData.twoIFC.data(i,7) = 3;
    elseif stimOne(i) == 1 && stimTwo(i) == 1
        gData.twoIFC.data(i,7) = 4;
    end
end

%Start the experiment loop
doneexp = 0;
while ~doneexp
    for z = 1:blocks
        % Wait for the first TR to start
        fprintf('Waiting for trigger from fMRI ... \n')
        FlushEvents('keyDown');
        while true
            [KeyIsDown, Secs, Response] = KbCheck;
            if Response(KbName('t'))
                gData.twoIFC.start_time = GetSecs;
                if z == 1
                    gData.twoIFC.Block_One_start_time = gData.twoIFC.start_time;
                elseif z == 2
                    gData.twoIFC.Block_One_start_time = gData.twoIFC.start_time;
                end
                break;
            end
        end
        nextstep = 'baseline';

        gData.twoIFC.log(end+1) = {['Start time: ', num2str(gData.twoIFC.start_time,5)]};
        doneBlock = 0;
        while ~doneBlock
            switch nextstep
                case 'baseline'
                    Screen('FillOval', gData.data.feedback.window_id,...
                        gData.define.feedback.color.GAZE,...
                        gData.data.feedback.gaze_fill);
                    Screen('Flip', gData.data.feedback.window_id);
                    disp(['Baseline: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Baseline: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    while (GetSecs - start) < lengthBaseline
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;
                        end
                    end
                    nextstep = 'waitOne';
                case 'waitOne'
                    Screen('FillOval', gData.data.feedback.window_id,...
                        gData.define.feedback.color.GAZE,...
                        gData.data.feedback.gaze_fill);
                    Screen('Flip', gData.data.feedback.window_id);
                    
                    disp(['------ Trial trial: ',num2str(trial),'------'])
                    gData.twoIFC.log(end+1) = {['------ Trial: ',num2str(trial),'------']};

                    gData.twoIFC.log(end+1) = {['trial: ', num2str(trial)]};
                    disp(['Wait One: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Wait One: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    
                    % If electrical stimulator, set the intensity right away to
                    % save time later.
                    if painStim
                        switch stimType
                              case 'Electrical'
                                  % 2 - set the intensity
                                  % Set the intensity (e.g., 0.3 = 30 mA)
                                  ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioTDAC_COMMUNICATION', 'LJ_chTDAC_UPDATE_DACA', ExpTempOne, 0);
                              case 'Thermal'
                                  TcsSetTemperatures( tcs, [ round(ExpTempOne,1), round(ExpTempOne,1), round(ExpTempOne,1), round(ExpTempOne,1), round(ExpTempOne,1) ] ); %set target temperatures for 5 zones
                        end
                    end
                    % If the there is dot motion, prep here.
                    if stimOne(trial) == 1
                        dotsX_prep(gData.twoIFC.para.lengtStim)
                    end
                    
                    while (GetSecs - start) < lengthWait
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;
                        end
                    end
                    nextstep = 'StimOne';
                case 'StimOne'
                    disp(['Start Presentation One (', num2str(stimOne(trial)),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Start Presentation One (', num2str(stimOne(trial)),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    % this tic and cpt are for the readout of the
                    % temperature from the probe.
                    tic;
                    % This is the counter for the reading of the thermal stimulation
                    gData.dot.cpt_tcs = 0;
                    if stimOne(trial) == 1
                        gData.dot.maxDotTime = jitter(1,trial);
                        [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs);
                        gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{1} = y_temperatures;
                        gData.twoIFC.para.TCSfeedback.x_times{trial}{1} = x_times;
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
                           disp(['Stimulation (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]);
                           gData.twoIFC.log(end+1) = {['Stimulation (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]};
                        end
                        
                        % Continue with dot motion until the end of the
                        % trial.
                        gData.dot.maxDotTime = lengthStim - (GetSecs - start);
                        [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs);
                        gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{1} = [gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{1}; y_temperatures];
                        gData.twoIFC.para.TCSfeedback.x_times{trial}{1} = [gData.twoIFC.para.TCSfeedback.x_times{trial}{1};x_times];
                        
                        %erase last dots, but leave up fixation and targets
                        Screen('Flip', gData.dot.curWindow,0,gData.dot.dontclear);
                        
                        
                    else % If no dot motion
                        Screen('FrameOval', gData.data.feedback.window_id,...
                            gData.define.feedback.color.GAZE,...
                            gData.data.feedback.gaze_frame, 20, 20);
                        Screen('FillOval', gData.data.feedback.window_id,...
                            gData.define.feedback.color.GAZE,...
                            gData.data.feedback.gaze_fill);
                        Screen('Flip', gData.data.feedback.window_id);
                        start = GetSecs;
                        stimDone = 0;

                        while (GetSecs - start) < lengthStim
                            
                            
                            if (GetSecs - start) >= jitter(1,trial) && stimDone ~= 1
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
                                   disp(['Stimulation (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]);
                                   gData.twoIFC.log(end+1) = {['Stimulation (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]};
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
                                        gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{1}( gData.dot.cpt_tcs, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                                        currentTime = toc; %get current time
                                        gData.twoIFC.para.TCSfeedback.x_times{trial}{1}( gData.dot.cpt_tcs, 1 ) = currentTime; %record time in x_temperatures
                                end
                            end

                            [keyIsDown,secs, keyCode] = KbCheck;
                            if keyCode(KbName('ESCAPE'))
                                doneexp = 1;
                                doneBlock = 1;
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
                    disp(['Wait Two: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Wait Two: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    % If electrical stimulator, set the intensity right away to
                    % save time later.
                    if painStim
                        switch stimType
                              case 'Electrical'
                                  % 2 - set the intensity
                                  % Set the intensity (e.g., 0.3 = 30 mA)
                                  ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioTDAC_COMMUNICATION', 'LJ_chTDAC_UPDATE_DACA', ExpTempTwo, 0);
                              case 'Thermal'
                                  TcsSetTemperatures( tcs, [ round(ExpTempTwo,1), round(ExpTempTwo,1), round(ExpTempTwo,1), round(ExpTempTwo,1), round(ExpTempTwo,1) ] ); %set target temperatures for 5 zones
                        end
                    end
                    % If the there is dot motion, prep here.
                    if stimTwo(trial) == 1
                        dotsX_prep(gData.twoIFC.para.lengtStim)
                    end
                    start = GetSecs;
                    while (GetSecs - start) < lengthWait
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;
                        end
                    end
                    nextstep = 'StimTwo';
                case 'StimTwo'
                    disp(['Start Presentation Two (',num2str(stimTwo(trial)),'): ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Start Presentation Two (',num2str(stimTwo(trial)),'): ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    % this tic and cpt are for the readout of the
                    % temperature from the probe.
                    tic;
                    % This is the counter for the reading of the thermal stimulation
                    gData.dot.cpt_tcs = 0;
                    if stimTwo(trial) == 1
                        % Start the dots until the stim
                        gData.dot.maxDotTime = jitter(2,trial);
                        [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs);
                        gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{2} = y_temperatures;
                        gData.twoIFC.para.TCSfeedback.x_times{trial}{2} = x_times;

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

                            disp(['Stimulation (', num2str(ExpTempTwo),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]);
                            gData.twoIFC.log(end+1) = {['Stimulation (', num2str(ExpTempTwo),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]};
                        end
                        %Continue the dot motion for the remaining time
                        gData.dot.maxDotTime = lengthStim - (GetSecs - start);
                        [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs);
                        gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{2} = [gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{2}; y_temperatures];
                        gData.twoIFC.para.TCSfeedback.x_times{trial}{2} = [gData.twoIFC.para.TCSfeedback.x_times{trial}{2};x_times];
                        
                        %erase last dots, but leave up fixation and targets
                        Screen('Flip', gData.dot.curWindow,0,gData.dot.dontclear);
                        
                    else % If there is no dot motion
                        Screen('FrameOval', gData.data.feedback.window_id,...
                            gData.define.feedback.color.GAZE,...
                            gData.data.feedback.gaze_frame, 20, 20);
                        Screen('FillOval', gData.data.feedback.window_id,...
                            gData.define.feedback.color.GAZE,...
                            gData.data.feedback.gaze_fill);
                        Screen('Flip', gData.data.feedback.window_id);
                        start = GetSecs;
                        stimDone = 0;
                        while (GetSecs - start) < lengthStim
                            if (GetSecs - start) >= jitter(2,trial) && stimDone ~= 1
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
                                disp(['Stimulation (', num2str(ExpTempTwo),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]);
                                gData.twoIFC.log(end+1) = {['Stimulation (', num2str(ExpTempTwo),'): ',num2str((GetSecs-gData.twoIFC.start_time),5)]};
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
                                        gData.twoIFC.para.TCSfeedback.y_temperatures{trial}{2}( gData.dot.cpt_tcs, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                                        currentTime = toc; %get current time
                                        gData.twoIFC.para.TCSfeedback.x_times{trial}{2}( gData.dot.cpt_tcs, 1 ) = currentTime; %record time in x_temperatures
                                end
                            end

                            
                            [keyIsDown,secs, keyCode] = KbCheck;
                            if keyCode(KbName('ESCAPE'))
                                doneexp = 1;
                                break;
                             end
                        end
                    end
                    nextstep = 'waitThree';
                case 'waitThree'
                    Screen('FillOval', gData.data.feedback.window_id,...
                        gData.define.feedback.color.GAZE,...
                        gData.data.feedback.gaze_fill);
                    Screen('Flip', gData.data.feedback.window_id);
                    disp(['Wait Three: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Wait Three: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    while (GetSecs - start) < lengthWait
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;
                        end
                    end
                    nextstep = 'rating';
                case 'rating'
                   X_AXIS = 1;
                    Y_AXIS = 2;
                    DrawFormattedText(gData.data.feedback.window_id,...
                        'Which stimulation was the most painful?\n \n     (1) First          (2) Second', px,...
                        gData.data.feedback.window_center_y...
                        - define.offset_ptb.condition_comment(Y_AXIS),...
                        gData.define.feedback.color.TEXT,[],1);
                    Screen('Flip', gData.data.feedback.window_id);
                    disp(['Ratings: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Ratings: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    resp = 0;
                    while (GetSecs - start) < lengthRating
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;

                        elseif keyCode(KbName('y'))
                            resp = 'Second';

                        elseif keyCode(KbName('b'))
                            resp = 'First';
                        end    
                    end
                    if resp
                        disp(['Answer: ', resp,' Response Time: ', num2str((secs-gData.twoIFC.start_time),5)]);
                        gData.twoIFC.log(end+1) = {['Answer: ', resp,' Response Time: ', num2str((secs-gData.twoIFC.start_time),5)]};
                        if strcmp(resp,'Second')
                            gData.twoIFC.data(trial,5) = 1;
                        end

                    else
                        disp('Answer: No answer!!');
                        gData.twoIFC.data(trial,4) = 0;
                        gData.twoIFC.log(end+1) = {'Answer: No answer!!'};   
                    end
                    nextstep = 'waitITI';

                case 'waitITI'
                    Screen('FillOval', gData.data.feedback.window_id,...
                        gData.define.feedback.color.GAZE,...
                        gData.data.feedback.gaze_fill);
                    Screen('Flip', gData.data.feedback.window_id);
                    disp(['Wait ITI: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Wait ITI: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
                    start = GetSecs;
                    while (GetSecs - start) < lengthITI
                        [keyIsDown,secs, keyCode] = KbCheck;
                        if keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;
                        elseif keyCode(KbName('t'))
                            gData.twoIFC.log(end+1) = {['TR: ', num2str((secs-gData.twoIFC.start_time),5)]};
                        end
                    end

                    if trial < totalTrials
                        trial = trial + 1;
                        nextstep = 'waitOne';
                    else
                        doneexp = 1;
                        doneBlock = 1;
                    end
                    
                    if trial == 20
                        trial = trial + 1;
                        nextstep = 'BlockDone';
                    end
                    
                case 'BlockDone'
                    X_AXIS = 1;
                    Y_AXIS = 2;
                    DrawFormattedText(gData.data.feedback.window_id,...
                        ['Block ',num2str(z),' is completed. \n You can take a short break.'], px,...
                        gData.data.feedback.window_center_y...
                        - define.offset_ptb.condition_comment(Y_AXIS),...
                        gData.define.feedback.color.TEXT,[],1);
                    Screen('Flip', gData.data.feedback.window_id);
                    disp(['Block ',num2str(z),' Done: ', num2str((GetSecs-gData.data.start_time),5)]);
                    gData.twoIFC.log(end+1) = {['Block ', num2str(z),' Done: ', num2str((GetSecs-gData.data.start_time),5)]};
                    start = GetSecs;
                    resp = 0;
                    FlushEvents('keyDown');
                    while true
                        [KeyIsDown, Secs, Response] = KbCheck;
                        if Response(KbName('RETURN'))
                            doneBlock = 1;
                            break;
                        elseif keyCode(KbName('ESCAPE'))
                            doneexp = 1;
                            doneBlock = 1;
                            break;
                        end
                    end
                        
            end
        end
    end
end
DrawFormattedText(gData.data.feedback.window_id,...
    'Thank you!', px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT,[],1);
Screen('Flip', gData.data.feedback.window_id);
disp(['End: ', num2str((GetSecs-gData.twoIFC.start_time),5)]);
gData.twoIFC.log(end+1) = {['End: ', num2str((GetSecs-gData.twoIFC.start_time),5)]};
start = GetSecs;
while (GetSecs - start) < lengthITI
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        doneexp = 1;
        break;
%     elseif keyCode(KbName('t'))
%         gData.twoIFC.log(end+1) = {['TR: ', num2str((secs-gData.twoIFC.start_time),5)]};
    end
end

visual_feedback(gData.define.feedback.FINISH);
gData.twoIFC.log = gData.twoIFC.log';
log = gData.twoIFC.log;
two_IFC = gData.twoIFC.data;
   

