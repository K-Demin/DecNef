function [] = change_condition(pre_condition)

% This function will change the presentation as a function of the conditino
% change of the experiment.

global gData

% This is to deal with the situation where we were computing Feedback but 
% it was not computed in time (i.e., calc_score_flg was not writtent down
% in time).
if pre_condition == gData.define.scan_condition.FEEDBACK_SCORE && gData.data.calc_score_flg(gData.data.current_trial) == false
  % If we were supposed to provide real feedback. display the NG_SCORE
  % which is essentially to idnicate no feedback.
  if gData.para.score.score_mode == gData.define.score_mode.CALC_SCORE
    visual_feedback(gData.define.feedback.NG_SCORE);
  % Else compute something (that is only for sham feedback)
  else
    trial = gData.data.current_trial;
    calculation_score(trial, gData.para.scans.calc_score_scan(trial), false);
    visual_feedback(gData.define.feedback.SCORE);
  end
  pause(gData.define.default.NG_SCORE_DISPLAY_TIME);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the switch to determine all the changes that should be achived 
% when switching condition.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch gData.data.current_condition
  case gData.define.scan_condition.IDLING 
    fprintf('IDLING\n');
    
  case gData.define.scan_condition.PRE_TRIAL
    fprintf('PRE TRIAL start\n');
    visual_feedback(gData.define.feedback.PREP_REST1);

  case gData.define.scan_condition.PREP_REST1
    fprintf('PREP REST1 condition start\n');
    visual_feedback(gData.define.feedback.PREP_REST1);
    
  case gData.define.scan_condition.PREP_REST2
    fprintf('PREP REST2 condition start\n');
    visual_feedback(gData.define.feedback.PREP_REST2);
    
  case gData.define.scan_condition.REST
    % If the streak counter was at 3 at the previous trial, reset it.
    if gData.data.streak_counter==3
        gData.data.streak_counter=0;
    end
    fprintf('REST condition start\n');
    % This is to upgrade the main trial counter.
    gData.data.current_trial = gData.data.current_trial+1;
    visual_feedback(gData.define.feedback.REST);
    
    % prepare the dot motion for the test session. We need to feed the time
    % in seconds. That is TR time * test_scan_num 
    dotsX_prep(gData.para.scans.TR*gData.para.scans.test_scan_num)
    
  case gData.define.scan_condition.TEST
    % Test corresponds to the feedback period (not such an intuitive name
    % but...)
    fprintf('TEST condition start\n');
    visual_feedback(gData.define.feedback.TEST);
    
  case gData.define.scan_condition.DELAY
    %erase last dots, but leave up fixation and targets
    Screen('Flip', gData.dot.curWindow,0,gData.dot.dontclear);
    fprintf('DELAY scan start\n');
    % If it is a sleep test trial, do that.
    if find(gData.para.scans.sleep_check_trial == gData.data.current_trial)
      fprintf('Checking if subject is sleeping...\n');
    end
    %PREP_SCORE will be done here if the delay scan number is not 0 
    %(gData.para.scans.post_test_delay_scan_num ~= 0). Otherwis,e their
    %will be no DELAY condition and PREP_SCORE will be done when the CALC_SCORE comes up (see below).
    visual_feedback(gData.define.feedback.PREP_SCORE);
    
  case gData.define.scan_condition.CALC_SCORE

    fprintf('CALC_SCORE\n');
    % if the delay is 0, PREP_SCORE was not done during the DELAY above.
    % So do it here:
    if gData.para.scans.post_test_delay_scan_num == 0
      % If it is a sleep trial:
      if find(gData.para.scans.sleep_check_trial == gData.data.current_trial)
        fprintf('Checking if subject is sleeping...\n');
      end
      visual_feedback(gData.define.feedback.PREP_SCORE);
    end	
    
  case gData.define.scan_condition.FEEDBACK_SCORE
    %Present the feedback score.
    fprintf('FEEDBACK_SCORE\n');
    visual_feedback(gData.define.feedback.SCORE);
    
  case gData.define.scan_condition.FINISH

    fprintf('FINISH\n');
    if gData.para.feedback.finished_block_duration > 0
      visual_feedback(gData.define.feedback.FINISHED_BLOCK);

      switch gData.para.feedback.io_tool
            case gData.define.feedback.io_tool.PSYCHTOOLBOX
              WaitSecs(gData.para.feedback.finished_block_duration);
            case gData.define.feedback.io_tool.MATLAB
              pause(gData.para.feedback.finished_block_duration);
            case gData.define.feedback.io_tool.DO_NOT_USE
      end
    end	

  otherwise
    fprintf('??????\n');
    
end
