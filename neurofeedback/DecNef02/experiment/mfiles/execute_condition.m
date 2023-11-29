function [] = execute_condition(LocalTime,time)

% This controls the diplay whenever this is not a condition change
global gData
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if there is a quit signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
key = keyboard_check();
if strcmp(gData.data.input_keyboard, key) == false && strcmpi(key, gData.define.key.QUIT_KEY)

  gData.data.quit_key = gData.data.quit_key+1;
  if gData.data.quit_key >= gData.define.default.QUIT_KEY_INUM
    fprintf('Quit neurofeedback experiment !!!\n');
    gData.data.live_flag = false;
  end
end
gData.data.input_keyboard = key;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this is the main switch statement to control 
% the display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch gData.data.current_condition
  case gData.define.scan_condition.IDLING

  case gData.define.scan_condition.PRE_TRIAL

  case gData.define.scan_condition.PREP_REST1

  case gData.define.scan_condition.PREP_REST2
 
  case gData.define.scan_condition.REST

  case gData.define.scan_condition.TEST
     %Here, present the dot motion during the test.
     %dotsX();
     
     % DotsX() was previously used but now I decouple the preparation of
     % the dots (DotsX_prep()) and the presentation (it was laging with the reading of the
     % thermode).
     % DotsX_stim() now should also integrate a little lag that should be
     % there if we were to read from the thermode probe. That way, both
     % speed of presentation should be the same.
     dotsX_stim(0, [], []);
      
  case gData.define.scan_condition.DELAY

    sleep_check_count =find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
    if ~isempty(sleep_check_count) && gData.data.sleep_check(sleep_check_count) == false && strcmpi(key, gData.define.key.SLEEP_CHECK_KEY)
      fprintf('Sleeping test is OK.\n');

      gData.data.sleep_check(sleep_check_count) = true;

      visual_feedback(gData.define.feedback.PREP_SCORE);
    end
    
  case gData.define.scan_condition.CALC_SCORE
    trans = [];
    trial = gData.data.current_trial;	
    
    % This is to get the values computed by the collector
    if gData.data.calc_score_flg(trial) == false %&& gData.data.received_scan_num >= gData.para.scans.calc_score_scan(trial)
        trans = msocket(gData.define, gData.define.msocket.RECEIVE_DATA_DISP, gData.para, [], gData.define.msocket.TIMEOUT);
        %load([gData.para.files.roi_dir,'/feedback_',num2str(trial),'.mat'],'tr_score','tr_flag','tr_received');
        if ~isempty(trans)
            gData.data.score = trans.tr_score;
            gData.data.calc_score_flg = trans.tr_flag;
            gData.data.received_scan_num = trans.tr_received;
            gData.data.streak_counter = trans.tr_streak;
            visual_feedback(gData.define.feedback.SCORE);
            fprintf('Feedback of trial %i is %8.3f (expected trial: %i) time=%8.3f (sec)...\n',trans.tr_trial, gData.data.score(trans.tr_trial), trial, time);
        end
    end

    % if it is a sleep check
    sleep_check_count =find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
    if ~isempty(sleep_check_count) && gData.data.sleep_check(sleep_check_count) == false && strcmpi(key, gData.define.key.SLEEP_CHECK_KEY)
      fprintf('Sleeping test is OK.\n');

      gData.data.sleep_check(sleep_check_count) = true;
      visual_feedback(gData.define.feedback.PREP_SCORE);
    end
    
  case gData.define.scan_condition.FEEDBACK_SCORE
    trans = [];
    trial = gData.data.current_trial;
    
    % This is to get the values computed by the collector
    if gData.data.calc_score_flg(trial) == false %&& gData.data.received_scan_num >= gData.para.scans.calc_score_scan(trial)
        trans = msocket(gData.define, gData.define.msocket.RECEIVE_DATA_DISP, gData.para, [], gData.define.msocket.TIMEOUT);
        
        if ~isempty(trans)
            gData.data.score = trans.tr_score;
            gData.data.calc_score_flg = trans.tr_flag;
            gData.data.received_scan_num = trans.tr_received;
            gData.data.streak_counter = trans.tr_streak;
            visual_feedback(gData.define.feedback.SCORE);
            fprintf('Feedback of trial %i is %8.3f (expected trial: %i) time=%8.3f (sec)...\n',trans.tr_trial, gData.data.score(trans.tr_trial), trial, time);
        end

    end
	

    sleep_check_count = find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
    if ~isempty(sleep_check_count) && gData.data.sleep_check(sleep_check_count) == false && strcmpi(key, gData.define.key.SLEEP_CHECK_KEY)

      fprintf('Sleeping test is OK.\n');

      gData.data.sleep_check(sleep_check_count) = true;

      visual_feedback(gData.define.feedback.SCORE);
    end
    
  case gData.define.scan_condition.FINISH

    if gData.data.received_scan_num == gData.para.scans.total_scan_num
      gData.data.live_flag = false;
    end
    
  otherwise
    fprintf('??????\n');
    
end	
