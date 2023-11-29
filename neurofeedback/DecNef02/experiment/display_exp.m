function [] = display_exp(participant, task, day, painStim, stimType, noPainInt, painMin, painMax, condition)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Decoded Neurofeedback(DecNef) experiment program
% (DecNef02)
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
% display_exp(): which should be executed on the diplay computer for visual
%               presentation to the participant.
% receiver(): which collects and process the dcm images written down by the
%               scanner.
% collector(): which collects the images processed by the receiver and run
%               the real-time decoding.
%
% the file parameters.txt should be used by defaul for neurofeedback and
% RS.
%
% The file parameters_Int.txt can be used for the online prediction of pain
% ratings.
%
%
%%%%%%%%%%
% Inputs:
%%%%%%%%%%
%
% participant: the participant number (a string. Ex: '001').
%
% task: Corresponds to one of the 4 tasks to run (feed as string):
%
%    'Calibrate_Intensity':    The procedure to determine the temperature
%                              to use in the experiment that corresponds to 
%                              a rating of 140.
% 'Calibrate_Intensity_RT':    Same as Calibrate_Int but this includes an
%                              online prediction of pain ratings.
%
%       'Calibrate_TwoIFC':    Procedure to determine the intensity of
%                              the second stimulation when the first one is
%                              set to the ExpTempOne determine in
%                              Calibrate_Intensity. This is to ensure that
%                              both stimulation will be perceived as equaly
%                              painful.
%
%                'TwoIFC':     This is the actual experiment ran with the
%                              ExpTempOne and ExpTempTwo determined using 
%                              the above functions.
%
%             'Intensity':     This is to determine how the experimental
%                              stimulus changes the intensity ratings
%                              (using ExpTempOne).
%
%          'Intensity_RT':     This is the same as Intensity but includes an 
%                              online prediction of the pain ratings.
%
%         'Resting_State':      Self-explanatory
%
%         'Neurofeedback':     Run the real-time procedure
%
%
% A few other parameters need to be passed:
% 
% day: represents the day (an int). Will be recoded to pre or post neurofeedback (a stringcalled time 'Pre' or 'Post')
%
% painStim: Are we delivering stimulations or not (boolean).
%
% stimType: 2 options: 'Thermal' or 'Electrical'
%
% noPainInt: defines the intensity of the non paiful stim (420 = 42.0 degree celsius; 0.3 = 30 mA)
%
% painMin: the lower intensity of pain stimulation
%
% painMax: the highest intensity.
%
% Condition: this defines the group of the participant (see log_display.m)

% -VTD-

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            few things to add to the MATLAB path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fullpath = which( mfilename );
[my_path, my_name, extension] = fileparts(deblank(fullpath));
addpath( my_path );
addpath( fullfile(my_path, 'mfiles') );
addpath( fullfile(my_path, 'mfiles', 'SensoryCalibration') );
addpath( fullfile(my_path, 'utility') );
addpath( fullfile(my_path, 'toolbox') );
addpath( fullfile(my_path, 'toolbox', 'msocket') );
addpath( fullfile(my_path, 'toolbox', 'SLR_dev') );
if exist('spm', 'file') == 0
  spm_search_path = {...
      '~/neurofeedback/toolbox/spm12',...
      '~/Users/neurofeedback/toolbox/spm12' };
  for ii=1:length(spm_search_path)
    if exist(spm_search_path{ii}, 'dir')
      addpath(spm_search_path{ii});
      break;
    end
  end
end	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       A function that initiates a lot of the variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gData
gData = create_global('neurofeedback');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% displays the copyrights of the toolbox in the Matlab command window.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
copyright(gData.version);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some values initiated above will be changed by load_parameters() 
% that will read the parameter file and generate a GUI for some input by 
% the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[gData.define, gData.para, err] = load_parameters(gData.define, gData.para);

% This here is the group condition. 
% -1 = reverse association with the pain decoder (downregulation).
% 1 - direct associtation with thre pain decoder (upregulation).
% this is implemented on the Collector's side. More precisely in the
% calculation_score_Disp.m function.
gData.data.condition = condition;

if err.status % If parameters were loaded properly
    % This will set the value for each TR (e.g., wait, test, delay, feedback,...)
    gData.data = init_data(gData.define, gData.para, gData.data);  
    [gData.data.scan_condition, gData.para.scans.calc_score_scan, gData.para.scans.score_target_scans] = set_scan_condition(gData.define, gData.para);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %              Work directory
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gData.para.files.work_dir = cell(gData.para.receiver_num, 1);
    for ii=1:gData.para.receiver_num
      gData.para.files.work_dir{ii} =fullfile(gData.para.files.save_dir,sprintf('%s_%s_%d', gData.para.save_name,gData.para.files.dicom_fnameB, ii));
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           Block and para dialog
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if strcmp(task, 'Calibrate_Intensity')
        
        % Run the calibration procedure
        [log,Calib_Int] = CalibrateIntensity(painStim, stimType, noPainInt, painMin, painMax);
        
        % Save the results
        cd(gData.para.files.save_dir);
        mkdir(participant);
        cd([gData.para.files.save_dir,'\',participant]);
        mkdir(['Day_',num2str(day)]);
        cd([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Calib_Int');

        % This calls the procedure that will fit an exponential curve to
        % our ratings and stim intensities. This will determine the
        % intensity stimulation required to obtain a painrating of 140 (i.e., ExpTempOne).
        Calib_Int_Output = pain_calib_correction_VTD(Calib_Int,pwd,participant,day,stimType);
        ExpTempOne = Calib_Int_Output.eprime_data.ExpTempOne;
        
        gData.calibInt.ExpTempOne = Calib_Int_Output.eprime_data.ExpTempOne;
        disp(['Stimulation intensity equivalent to 140 in pain rating is: ', num2str(ExpTempOne)]);
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Calib_Int','Calib_Int_Output','ExpTempOne');
        
        % Generate a condition file for SPM
        Generate_Cond_Calib_Int(log,task,participant);
        cd(my_path);
        
    elseif strcmp(task, 'Calibrate_Intensity_RT')
        
        % This is for the GUI that will get the paths to the DICOM, template and
        % ROI files (see header of function).
        [gData.define, gData.para, err] = GUI_images_path(gData.define, gData.para);
        
        if block_dialog(participant,day)
            
            % These are to record the answers from the gui
            gData.para.receiver_num = gData.data.block_gui.receiver_num;
            gData.para.msocket.port = gData.data.block_gui.port;
            gData.para.current_block = gData.data.block_gui.current_block;
            gData.para.files.dicom_fnameB = sprintf(gData.data.block_gui.formatB, gData.para.current_block);

            if para_dialog()
                
                % Run the calibration procedure
                [log,Calib_Int,dec_score] = CalibrateIntensity_RT(painStim, stimType, noPainInt, painMin, painMax);
            end
        end
        
        % Save the results
        cd(gData.para.files.save_dir);
        mkdir(participant);
        cd([gData.para.files.save_dir,'\',participant]);
        mkdir(['_Day_',num2str(day)]);
        cd([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Calib_Int','dec_score');
        
        % This calls the procedure that will fit an exponential curve to
        % our ratings and stim intensities. This will determine the
        % intensity stimulation required to obtain a painrating of 140 (i.e., ExpTempOne).
        Calib_Int_Output = pain_calib_correction_VTD(Calib_Int,pwd,participant,day,stimType);
        ExpTempOne = Calib_Int_Output.eprime_data.ExpTempOne;
        
        gData.calibInt.ExpTempOne = Calib_Int_Output.eprime_data.ExpTempOne;
        disp(['Stimulation intensity equivalent to 140 in pain rating is: ', num2str(ExpTempOne)]);
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Calib_Int','Calib_Int_Output','ExpTempOne','dec_score');
        
        % Generate a condition file for SPM
        Generate_Cond_Calib_Int(log,task,participant);
        
        % This is to predict the pain ratings with the predictions of the
        % brain decoders (in dec_score: 1st column is SIIPS second column
        % is NPS).
        [Calib_Dec_Output,models] = pain_calib_correction_RT(Calib_Int, pwd, participant,day, dec_score(1:gData.calibInt.para.totalTrials,:));
        save([participant,'_Day_',num2str(day),'_',task,'_Models_Results.mat'], 'models','Calib_Dec_Output');
        cd(my_path);


    elseif strcmp(task, 'Calibrate_TwoIFC')

        cd([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
        if isfile([participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_Results.mat'])

            % Load ExpTempOne and run the calibration procedure to get
            % ExpTempTwo (i.e., the temperature that makes the second
            % stimulation as painful as the 1st stimulation).
            load([participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_Results.mat'],'ExpTempOne','Calib_Int_Output');
            tempCorr = Calib_Int_Output.eprime_data.temperature_x_rating0to200_match_corr; 
            
            % This is to make sure that we won't be delivering
            % stimulations that are too high. Second stim will be
            % defined to be max of 160 according to the calibrate
            % intensity procedure).
            posThres = find(tempCorr(:,1) == 140);
            disp(['The intensity of the first stimulation will be: ',num2str(tempCorr((posThres),2))]);
            disp(['The intensity of the second stimulation will vary']); 
            disp(['between: ', num2str(tempCorr((posThres-2),2)), ' and ', num2str(tempCorr((posThres+2),2)),'. Press enter if this is OK.']);
            
            % Wait for the answer to continue
            while true
                [KeyIsDown, Secs, Response] = KbCheck;
                if Response(KbName('return'))
                    break;
                end
            end
            
            % Run the calibrate TwoIFC procedure
            [log, Calib_TwoIFC] = CalibrateTwoIFC(ExpTempOne, painStim, tempCorr, stimType);
            % save the results
            save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Calib_TwoIFC');
            
            % fit the psychometric function. This will determine the point
            % of subjective equality. The intensity of the second stim
            % will be defined with that point.
            Calib_TwoIFC_Output = pain_calib_correction_IFC_VTD(Calib_TwoIFC, pwd, participant, day);
            
            ExpTempTwo = Calib_TwoIFC_Output.eprime_data.ExpTempTwo;
            disp(['The intensity of the second stimulation is set to: ', num2str(ExpTempTwo)]);
            save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Calib_TwoIFC','Calib_TwoIFC_Output','ExpTempTwo');
        else
            disp('You must run Calibrate_Intensity first...')
        end
        cd(my_path);

    elseif strcmp(task, 'TwoIFC')
        % Load the intensity of the first stim (ExpTempOne)
        cd([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
        if isfile([participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_Results.mat'])
            load([participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_Results.mat'],'ExpTempOne');
        else
            disp('You must run Calibrate_Intensity first...')
        end
        % Load the intensity of the second stim (ExpTempTwo)
        if isfile([participant,'_Day_',num2str(day),'_Calibrate_TwoIFC_Results.mat'])
            load([participant,'_Day_',num2str(day),'_Calibrate_TwoIFC_Results.mat'],'ExpTempTwo');
        else
            disp('You must run Calibrate TwoIFC first...')
        end
        
        % Run the TwoIFC procedure
        [log, Two_IFC] = TwoIFC(ExpTempOne, ExpTempTwo,painStim, stimType);
        %b Save the results
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Two_IFC');
        cd(my_path);

    elseif strcmp(task, 'Intensity')
        cd([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
        % Load Calib_Int_Output (which will be used to determine the
        % intensity of stimulations).
        if isfile([participant,'_Day_',num2str(day),'_Calibrate_Intensity_Results.mat'])
            load([participant,'_Day_',num2str(day),'_Calibrate_Intensity_Results.mat'],'Calib_Int_Output');
            calib_corr_table = Calib_Int_Output.eprime_data.temperature_x_rating0to200_match_corr;
        else
            disp('You must run Calibrate_Intensity first...')
        end
        
        % Run the intensity procedure
        [log, Int] = Intensity(calib_corr_table, painStim, stimType);
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Int');
        cd(my_path);
        
    elseif strcmp(task, 'Intensity_RT')
        cd([gData.para.files.save_dir,'\',participant,'\Day_',num2str(day)]);
        % Load Calib_Int_Output (which will be used to determine the
        % intensity of stimulations).
        if isfile([participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_Results.mat'])
            load([participant,'_Day_',num2str(day),'_Calibrate_Intensity_RT_Results.mat'],'Calib_Int_Output');
            calib_corr_table = Calib_Int_Output.eprime_data.temperature_x_rating0to200_match_corr;
        else
            disp('You must run Calibrate_Intensity first...')
        end
        
        % This is for the GUI that will get the paths to the DICOM, template and
        % ROI files (see header of function).
        [gData.define, gData.para, err] = GUI_images_path(gData.define, gData.para);
        
        if block_dialog(participant,day)
            
            % These are to record the answers from the gui
            gData.para.receiver_num = gData.data.block_gui.receiver_num;
            gData.para.msocket.port = gData.data.block_gui.port;
            gData.para.current_block = gData.data.block_gui.current_block;
            gData.para.files.dicom_fnameB = sprintf(gData.data.block_gui.formatB, gData.para.current_block);

            if para_dialog()
                % Run the calibration procedure
                [log,Int,dec_score] = Intensity_RT(calib_corr_table, painStim, stimType);
            end
        end
        % Save the results
        save([participant,'_Day_',num2str(day),'_',task,'_Results.mat'], 'gData', 'log','Int','dec_score');
        cd(my_path);
        

    elseif strcmp(task, 'Resting_State')
        
        % Run resting state
        RestingState(participant, day);
        cd(my_path);

    elseif strcmp(task, 'Neurofeedback')
        % This is for the GUI that will get the paths to the DICOM, template and
        % ROI files (see header of function).
        [gData.define, gData.para, err] = GUI_images_path(gData.define, gData.para);
        
        % This will set the value for each TR (e.g., wait, test, delay, feedback,...)
        gData.data = init_data(gData.define, gData.para, gData.data);  
        [gData.data.scan_condition, gData.para.scans.calc_score_scan, gData.para.scans.score_target_scans] =set_scan_condition(gData.define, gData.para);

        if block_dialog(participant,day)
            
            % These are to record the answers from the gui
            gData.para.receiver_num = gData.data.block_gui.receiver_num;
            gData.para.msocket.port = gData.data.block_gui.port;
            gData.para.current_block = gData.data.block_gui.current_block;
            gData.para.files.dicom_fnameB = sprintf(gData.data.block_gui.formatB, gData.para.current_block);

            if para_dialog()
                % Run the neurofeedback procedure
                neurofeedback(participant, day);
            end
        end
        cd(my_path);
    end

end	


function [usage] = usage_message(my_name)

usage = '';
usage = sprintf('%s\tUSAGE : %s\n', usage, my_name);
usage = sprintf('%s\tUSAGE : %s(port)\n', usage, my_name);
usage = sprintf('%s\t  port = TCP/IP port number', usage);
usage = sprintf('%s (Value must be numeric.)\n', usage);

