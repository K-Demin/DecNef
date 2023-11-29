function [log, Calib_IFC] = CalibrateTwoIFC(ExpTempOne, painStim, tempCorr, stimType)

global gData
	
% Intialize some variables
totalTrials = 14;
numStim = 2;
trial= 1;
px = 'center';
nextstep = 'baseline';
lengthBaseline = 20;
lengthWait = 2.1;
lengthStim = 6;
lengthRating = 4;
lengthITI = 6;



% Intialize the stimulator

switch stimType
    case 'Thermal'

        % Define the temprature for the stimulation.
        posThres = find(tempCorr(:,1) == 140);
        midOne = ((tempCorr((posThres-1),2) + tempCorr((posThres),2)) /2);
        midTwo = ((tempCorr((posThres+1),2) + tempCorr((posThres),2)) /2);

        % Randomize the order of the trials
        TempCalibTwoIFC = [round((tempCorr((posThres-2),2))*ones(1,numStim),1),round((tempCorr((posThres-1),2))*ones(1,numStim),1),round(midOne*ones(1,numStim),1),round(ExpTempOne*ones(1,numStim),1),round(midTwo*ones(1,numStim),1),round((tempCorr((posThres+1),2))*ones(1,numStim),1),round((tempCorr((posThres+2),2))*ones(1,numStim),1)];
        jitter = [rand([1,totalTrials])+1;rand([1,totalTrials])+1];
        reOrder = randperm(totalTrials);
        TempCalibTwoIFC = TempCalibTwoIFC(reOrder);
        
        gData.calibIFC.TempCalibTwoIFC = TempCalibTwoIFC;
        
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

            gData.calibIFC.para.TCSfeedback.y_temperatures = {};
            gData.calibIFC.para.TCSfeedback.x_times = {};
            gData.calibIFC.para.neutral_temperature = neutral_temperature;
            gData.calibIFC.para.target_temperature = target_temperature;

        end


    case 'Electrical'
        % Define the temprature for the stimulation.
        posThres = find(tempCorr(:,1) == 140);
        midOne = ((tempCorr((posThres-1),2) + tempCorr((posThres),2)) /2);
        midTwo = ((tempCorr((posThres+1),2) + tempCorr((posThres),2)) /2);

        % Randomize the order of the trials
        TempCalibTwoIFC = [tempCorr((posThres-2),2)*ones(1,numStim),tempCorr((posThres-1),2)*ones(1,numStim),midOne*ones(1,numStim),ExpTempOne*ones(1,numStim),midTwo*ones(1,numStim),tempCorr((posThres+1),2)*ones(1,numStim),tempCorr((posThres+2),2)*ones(1,numStim)];
        %The ExpTempOne and tempCorr value needs to be divided to match
        %what the stimulator is expecting:
%             ExpTempOne = ExpTempOne/100;
%             TempCalibTwoIFC = TempCalibTwoIFC /100;

        % Randomize
        reOrder = randperm(totalTrials);
        TempCalibTwoIFC = TempCalibTwoIFC(reOrder);
        gData.calibIFC.TempCalibTwoIFC = TempCalibTwoIFC;

        % Crreate jitters
        jitter = [rand([1,totalTrials])+1;rand([1,totalTrials])+1];
        
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


% define the define variable
define = gData.define.feedback;

% save the defined parameters to the gData variable
gData.calibIFC.para.totalTrials = totalTrials;
gData.calibIFC.para.numStim = numStim;
gData.calibIFC.para.px = px;
gData.calibIFC.para.lengthBaseline = lengthBaseline;
gData.calibIFC.para.lengthWait = lengthWait;
gData.calibIFC.para.lengtStim = lengthStim;
gData.calibIFC.para.lengthRating = lengthRating;
gData.calibIFC.para.lengthITI = lengthITI;
gData.calibIFC.para.jitter = jitter;

% This will initialize the psychtoolbox screen
visual_feedback(gData.define.feedback.INITIALIZE);

% Initialize the log file. This will write down the timing of all steps and
% keypress as well.
gData.calibIFC.log = {};

gData.calibIFC.trial = 1;

% This will store the data
gData.calibIFC.data_names = { 'temperature' 'trial_num' 'removed~=1' 'More_painful' 'spot'};
gData.calibIFC.data = [];
gData.calibIFC.data(:,1) = TempCalibTwoIFC';
gData.calibIFC.data(:,2) = 1:length(TempCalibTwoIFC);
gData.calibIFC.data(:,3) = ones(1,length(TempCalibTwoIFC));
gData.calibIFC.data(:,4) = zeros(1,length(TempCalibTwoIFC));
gData.calibIFC.data(:,5) = ones(1,length(TempCalibTwoIFC));


% Wait for the first TR to start
fprintf('Waiting for trigger from fMRI ... \n')
FlushEvents('keyDown');
while true
    [KeyIsDown, Secs, Response] = KbCheck;
    if Response(KbName('t'))
        gData.calibIFC.start_time = GetSecs;
        break;
    end
end

gData.calibIFC.log(end+1) = {['Start time: ', num2str(gData.calibIFC.start_time,5)]};

%Start the experiment loop
doneexp = 0;
while ~doneexp
    switch nextstep
        case 'baseline'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Baseline: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Baseline: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
            start = GetSecs;
            while (GetSecs - start) < lengthBaseline
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'waitOne';
            
        case 'waitOne'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['------ Calibration trial: ',num2str(trial),'------'])
            gData.calibIFC.log(end+1) = {['------ Calibration trial: ',num2str(trial),'------']};
            disp(['Wait One: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Wait One: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
            
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

            start = GetSecs;
            while (GetSecs - start) < lengthWait
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                end
            end
            nextstep = 'StimOne';
            
        case 'StimOne'
            disp(['Start Presentation One (', num2str(ExpTempOne),') :',num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Start Presentation One (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.calibIFC.start_time),5)]};

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
                    disp(['Stimulation (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.calibIFC.start_time),5)]);
                    gData.calibIFC.log(end+1) = {['Stimulation (', num2str(ExpTempOne),'): ',num2str((GetSecs-gData.calibIFC.start_time),5)]};
                    end
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
                            gData.calibIFC.para.TCSfeedback.y_temperatures{trial}{1}( cpt, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                            currentTime = toc; %get current time
                            gData.calibIFC.para.TCSfeedback.x_times{trial}{1}( cpt, 1 ) = currentTime; %record time in x_temperatures
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
            disp(['Wait Two: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Wait Two: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
            
            % If electrical stimulator, set the intensity right away to
            % save time later.
            if painStim
                switch stimType
                      case 'Electrical'
                          % 2 - set the intensity
                          % Set the intensity (e.g., 0.3 = 30 mA)
                          ljerror = ljudObj.ePutSS(ljhandle, 'LJ_ioTDAC_COMMUNICATION', 'LJ_chTDAC_UPDATE_DACA', TempCalibTwoIFC(trial), 0);
                
                      case 'Thermal'
                          TcsSetTemperatures( tcs, [ round(TempCalibTwoIFC(trial),1), round(TempCalibTwoIFC(trial),1), round(TempCalibTwoIFC(trial),1), round(TempCalibTwoIFC(trial),1), round(TempCalibTwoIFC(trial),1) ] ); %set target temperatures for 5 zones
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
            nextstep = 'StimTwo';
            
        case 'StimTwo'
            disp(['Start Presentation Two (',num2str(TempCalibTwoIFC(trial)),') :', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Start Presentation Two (',num2str(TempCalibTwoIFC(trial)),'): ', num2str((GetSecs-gData.calibIFC.start_time),5)]};

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
                    disp(['Stimulation (', num2str(TempCalibTwoIFC(trial)),'): ',num2str((GetSecs-gData.calibIFC.start_time),5)]);
                    gData.calibIFC.log(end+1) = {['Stimulation (', num2str(TempCalibTwoIFC(trial)),'): ',num2str((GetSecs-gData.calibIFC.start_time),5)]};
                    end
                    
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
                            gData.calibInt.para.TCSfeedback.y_temperatures{trial}{2}( cpt, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                            currentTime = toc; %get current time
                            gData.calibInt.para.TCSfeedback.x_times{trial}{2}( cpt, 1 ) = currentTime; %record time in x_temperatures
                    end
                end
                
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                 end
            end

            nextstep = 'waitThree';
            
        case 'waitThree'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait Three: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Wait Three: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
            start = GetSecs;
            while (GetSecs - start) < lengthWait
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
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
            disp(['Ratings: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Ratings: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
            start = GetSecs;
            resp = 0;
            while (GetSecs - start) < lengthRating
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                    
                elseif keyCode(KbName('y'))
                    resp = 'Second';
                    
                elseif keyCode(KbName('b'))
                    resp = 'First';
                end    
            end
            if resp
                disp(['Answer: ', resp,' Response Time: ', num2str((secs-gData.calibIFC.start_time),5)]);
                gData.calibIFC.log(end+1) = {['Answer: ', resp,' Response Time: ', num2str((secs-gData.calibIFC.start_time),5)]};
                if strcmp(resp,'Second')
                    gData.calibIFC.data(trial,4) = 1;
                end
                    
            else
                disp('Answer: No answer!!');
                gData.calibIFC.data(trial,3) = 0;
                gData.calibIFC.log(end+1) = {'Answer: No answer!!'};   
            end
            nextstep = 'waitITI';
            
        case 'waitITI'
            Screen('FillOval', gData.data.feedback.window_id,...
                gData.define.feedback.color.GAZE,...
                gData.data.feedback.gaze_fill);
            Screen('Flip', gData.data.feedback.window_id);
            disp(['Wait ITI: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
            gData.calibIFC.log(end+1) = {['Wait ITI: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
            start = GetSecs;
            while (GetSecs - start) < lengthITI
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(KbName('ESCAPE'))
                    doneexp = 1;
                    break;
                elseif keyCode(KbName('t'))
                    gData.calibIFC.log(end+1) = {['TR: ', num2str((secs-gData.calibIFC.start_time),5)]};
                end
            end
            
            if trial < totalTrials
                trial = trial + 1;
                nextstep = 'waitOne';
            else
                doneexp = 1;
            end
    end
end
DrawFormattedText(gData.data.feedback.window_id,...
    'Thank you!', px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT,[],1);
Screen('Flip', gData.data.feedback.window_id);
disp(['End: ', num2str((GetSecs-gData.calibIFC.start_time),5)]);
gData.calibIFC.log(end+1) = {['End: ', num2str((GetSecs-gData.calibIFC.start_time),5)]};
start = GetSecs;
while (GetSecs - start) < lengthITI
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        doneexp = 1;
        break;

    end
end

visual_feedback(gData.define.feedback.FINISH);
gData.calibIFC.log = gData.calibIFC.log';
log = gData.calibIFC.log;
Calib_IFC = gData.calibIFC.data;

% Code to test that the 4 categories are still well balanced.

% test = [stimOne',stimTwo'];
% one = 0;
% two = 0;
% three = 0;
% four = 0;
% 
% for i = 1:60
%     if stimOne(i) == 0 && stimTwo(i) == 0
%         one = one+1;
%     elseif stimOne(i) == 1 && stimTwo(i) == 0
%         two = two+1;
%     elseif stimOne(i) == 0 && stimTwo(i) == 1
%         three = three+1;
%     elseif stimOne(i) == 1 && stimTwo(i) == 1
%         four = four+1;
%     end
% end

            

