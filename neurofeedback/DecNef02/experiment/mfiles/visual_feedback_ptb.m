function [] = visual_feedback_ptb(status)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we have functions that will execute the 
% requested visual presentations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global gData

switch status
  case gData.define.feedback.INITIALIZE	
    init_feedback();
  case gData.define.feedback.GAZE
    gaze_feedback();
  case gData.define.feedback.PREP_REST1
    prep_rest1_feedback();
  case gData.define.feedback.PREP_REST2	
    prep_rest2_feedback();
  case gData.define.feedback.REST	
    rest_feedback();
  case gData.define.feedback.TEST
    test_feedback();
  case gData.define.feedback.PREP_SCORE	
    prep_score_feedback();
  case gData.define.feedback.SCORE
    score_feedback();
  case gData.define.feedback.NG_SCORE
    ng_score_feedback();
  case gData.define.feedback.SLEEP_CHECK
    sleep_check_feedback();
  case gData.define.feedback.FINISHED_BLOCK
    finished_block_feedback();
  case gData.define.feedback.FINISH	
    finish_feedback();
  otherwise,
end	

%Display on the right window
if gData.data.feedback.window_id >= 0
  Screen('Flip', gData.data.feedback.window_id);
end



function [] = init_feedback()
% This is to initialize the visul display
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

% MATLAB
%ListenChar(2);
% OpenGL
AssertOpenGL;
  
% This is to get the current time
GetSecs;

% This will wait for a keyboard input
myKeyCheck();

% This is not safe (visualisation parameters might be wrong)
% but it can be use to debug.
Screen('Preference', 'SkipSyncTests', 1);

gData.para.feedback.original_debuglevel =Screen('Preference', 'VisualDebugLevel', 3);
gData.para.feedback.original_warnlebel =Screen('Preference', 'SuppressAllWarnings', 1);


% Visual feedback
[gData.data.feedback.window_id,gData.data.feedback.rect] =Screen('OpenWindow', 0, define.color.BG);
%gData.data.feedback.window_id = Screen('Preference', 'SuppressAllWarnings', 1);
[gData.data.feedback.window_width, gData.data.feedback.window_height] =Screen('WindowSize', 0);

Screen('TextSize',gData.data.feedback.window_id, define.FONT_SIZE);
try	
  Screen('TextFont', gData.data.feedback.window_id, define.FONT_NAME);
end

Screen('Preference', 'TextRenderer', 1);

gData.data.feedback.window_center_x = round(gData.data.feedback.window_width/2);
gData.data.feedback.window_center_y = round(gData.data.feedback.window_height/2);

gData.data.feedback.prep_rest1_comment =...
    comment_string(gData.para.feedback.prep_rest1_comment);
gData.data.feedback.prep_rest2_comment =...
    comment_string(gData.para.feedback.prep_rest2_comment);
gData.data.feedback.rest_comment =...
    comment_string(gData.para.feedback.rest_comment);
gData.data.feedback.test_comment =...
    comment_string(gData.para.feedback.test_comment);
gData.data.feedback.prep_score_comment =...
    comment_string(gData.para.feedback.prep_score_comment);
gData.data.feedback.score_comment =...
    comment_string(gData.para.feedback.score_comment);
gData.data.feedback.ng_score_comment =...
    comment_string(gData.para.feedback.ng_score_comment);
gData.data.feedback.finished_block_comment =...
    comment_string(gData.para.feedback.finished_block_comment);



R = gData.para.feedback.gaze_frame_r;
gData.data.feedback.gaze_frame =...
    round( [...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.gaze(X_AXIS)-R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.gaze(Y_AXIS)-R,...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.gaze(X_AXIS)+R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.gaze(Y_AXIS)+R] );


R = gData.para.feedback.gaze_fill_r;
gData.data.feedback.gaze_fill =...
    round( [...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.gaze(X_AXIS)-R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.gaze(Y_AXIS)-R,...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.gaze(X_AXIS)+R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.gaze(Y_AXIS)+R] );


R = gData.para.feedback.sleep_fill_r;
gData.data.feedback.sleep_fill =...
    round( [...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.gaze(X_AXIS)-R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.gaze(Y_AXIS)-R,...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.gaze(X_AXIS)+R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.gaze(Y_AXIS)+R] );


R = gData.para.feedback.max_score_r;
gData.data.feedback.max_score =...
    round( [...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.score_corcle(X_AXIS)-R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_corcle(Y_AXIS)-R,...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.score_corcle(X_AXIS)+R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_corcle(Y_AXIS)+R] );


R = gData.para.feedback.max_score_r/2.0;
gData.data.feedback.half_score =...
    round( [...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.score_corcle(X_AXIS)-R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_corcle(Y_AXIS)-R,...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.score_corcle(X_AXIS)+R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_corcle(Y_AXIS)+R] );


function [dst] = comment_string(src)
dst = src;
dst( findstr(dst, '_') ) = ' ';


function [] = gaze_feedback()

global gData
Screen('FillOval', gData.data.feedback.window_id,gData.define.feedback.color.GAZE,gData.data.feedback.gaze_fill);



function [] = prep_rest1_feedback()
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

if define.offset_ptb.condition_comment(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x + define.offset_ptb.condition_comment(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.prep_rest1_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT);

gaze_feedback();


function [] = prep_rest2_feedback()
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

if define.offset_ptb.condition_comment(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x + define.offset_ptb.condition_comment(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.prep_rest2_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT);

gaze_feedback();

function [] = rest_feedback()

global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

if define.offset_ptb.condition_comment(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x + define.offset_ptb.condition_comment(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.rest_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT);

gaze_feedback();


function [] = test_feedback()

global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

Screen('FrameOval', gData.data.feedback.window_id,gData.define.feedback.color.GAZE,gData.data.feedback.gaze_frame, 20, 20);

if define.offset_ptb.condition_comment(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x...
      + define.offset_ptb.condition_comment(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.test_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT);

gaze_feedback();


function [] = prep_score_feedback()
% This is only for the sleep check.
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

if define.offset_ptb.condition_comment(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x + define.offset_ptb.condition_comment(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.prep_score_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.condition_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT);

sleep_check_count = find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) && gData.data.sleep_check(sleep_check_count) == false
  sleep_check_feedback();
else

  gaze_feedback();
end

function [] = score_feedback()
% This is to display the feedback. Either using the txt mode
% or the circle mode (These functions are defined below).
global gData
switch gData.para.feedback.feedback_type
  case gData.define.feedback.feedback_type.TEXT_MODE
    score_text_mode();
  case gData.define.feedback.feedback_type.CIRCLE_MODE
    score_circle_mode();
  otherwise
end

sleep_check_count =find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) && gData.data.sleep_check(sleep_check_count) == false
  sleep_check_feedback();
else
  gaze_feedback();
end


function [] = score_text_mode()
% I never used that and do not intend to.
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

score = gData.data.score(gData.data.current_trial);
if ~isnan(score)
  if define.offset_ptb.condition_comment(X_AXIS) == 0
    px = 'center';
  else
    px = gData.data.feedback.window_center_x...
	+ define.offset_ptb.condition_comment(X_AXIS);
  end
  DrawFormattedText(gData.data.feedback.window_id,...
      gData.data.feedback.score_comment, px,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.condition_comment(Y_AXIS),...
      gData.define.feedback.color.TEXT);
  

  if define.offset_ptb.score_text(X_AXIS) == 0
    px = 'center';
  else
    px = gData.data.feedback.window_center_x...
	+ define.offset_ptb.score_text(X_AXIS);
  end
  DrawFormattedText(gData.data.feedback.window_id,...
      sprintf('%d', score), px,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_text(Y_AXIS),...
      gData.define.feedback.color.TEXT);
end


function [] = score_circle_mode()
% We use that feedback function here.
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

% If scores have not been computed, they are NaN. Here, first check
% a score as been computed for the current trial. If so, Display the feedback.
score = gData.data.score(gData.data.current_trial);

if ~isnan(score)
    
  % If there is no score limit (meaning we don't want to rescale the score
  % value).
  if sum( isnan(gData.para.score.score_limit) )
    tmp = abs(score)/100.0;
    R = round( tmp * gData.para.feedback.max_score_r );
    if score >= 0.0,	color = gData.define.feedback.color.SCORE_CIRCLE_PLUS;
    else		color = gData.define.feedback.color.SCORE_CIRCLE_MINUS;
    end
    
  % Else. if we want to scale the value between 0 and 100 for instance 
  % (defined in gData.para.score.score_limit).
  else
    score_limit = gData.para.score.score_limit;
    % subtract the lower bound to the current score and divide by the
    % difference between both scores in the interval (for instance, 0 and
    % 100 = 100). We want a value between 0 and 1 to rescale the radius
    % below.
    tmp = (score - score_limit(gData.define.MIN))/diff(score_limit);
    
    % Here max score R is the radius of the circle
    R = round( tmp * gData.para.feedback.max_score_r );
    color = gData.define.feedback.color.SCORE_CIRCLE;
  end
  score_rect = round( [...
	gData.data.feedback.window_center_x...
	+ define.offset_ptb.score_corcle(X_AXIS)-R,...
	gData.data.feedback.window_center_y...
	- define.offset_ptb.score_corcle(Y_AXIS)-R,...
	gData.data.feedback.window_center_x...
	+ define.offset_ptb.score_corcle(X_AXIS)+R,...
	gData.data.feedback.window_center_y...
	- define.offset_ptb.score_corcle(Y_AXIS)+R] );

  %%CAC edit, if subject hits third high score trial, change feedback disk
  %%to blue and display message
%   if exist('gData.data.streak_counter','var')
  if gData.data.streak_counter==3
      color=[0 0 255];
 
  end

  Screen('FillOval', gData.data.feedback.window_id, color, score_rect);
  
  Screen('FrameOval', gData.data.feedback.window_id,...
      gData.define.feedback.color.MAX_SCORE_FRAME,...
      gData.data.feedback.max_score, 20, 20);

  Screen('FrameOval', gData.data.feedback.window_id,...
      gData.define.feedback.color.HALF_SCORE_FRAME,...
      gData.data.feedback.half_score, 20, 20);
  
  if gData.data.streak_counter==3
      DrawFormattedText(gData.data.feedback.window_id,'High score streak!\nExtra bonus!','center',gData.data.feedback.window_center_y-(R+100),color);
      % No need to managethe streak here, this is done by the collector()
      % and sent with the trans function.
      %gData.data.streak_counter=0;
      gData.data.total_streaks=gData.data.total_streaks+1;
  end
  % record the actual feedback value that was displayed.
  gData.data.feedback_value(gData.data.current_trial) = score;
end



function [] = ng_score_feedback()
% Provide a null feedback
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;


if define.offset_ptb.score_text(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x...
      + define.offset_ptb.score_text(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.ng_score_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.score_text(Y_AXIS),...
    gData.define.feedback.color.TEXT);
  
sleep_check_count =...
    find(gData.para.scans.sleep_check_trial == gData.data.current_trial);
if ~isempty(sleep_check_count) &&...
      gData.data.sleep_check(sleep_check_count) == false
  sleep_check_feedback();
else
  gaze_feedback();
end



function [] = sleep_check_feedback()

global gData

Screen('FillRect', gData.data.feedback.window_id,...
    gData.define.feedback.color.GAZE,...
    gData.data.feedback.sleep_fill);


function [] = finished_block_feedback()
% Info to present at the end of the Block.
% These two functions are defined below.
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

switch gData.para.feedback.feedback_type
  case gData.define.feedback.feedback_type.TEXT_MODE
    ave_score_text_mode();
  case gData.define.feedback.feedback_type.CIRCLE_MODE
    ave_score_circle_mode();
  otherwise
end

if define.offset_ptb.finished_comment(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x...
      + define.offset_ptb.finished_comment(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    gData.data.feedback.finished_block_comment, px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.finished_comment(Y_AXIS),...
    gData.define.feedback.color.TEXT);

gaze_feedback();


function [] = ave_score_text_mode()

global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

tmp = 1:gData.para.scans.trial_num;
tmp( isnan(gData.data.score) ) = [];
Score = round( mean( gData.data.score(tmp) ) );
if define.offset_ptb.score_text(X_AXIS) == 0
  px = 'center';
else
  px = gData.data.feedback.window_center_x...
      + define.offset_ptb.score_text(X_AXIS);
end
DrawFormattedText(gData.data.feedback.window_id,...
    sprintf('%d', Score), px,...
    gData.data.feedback.window_center_y...
    - define.offset_ptb.score_text(Y_AXIS),...
    gData.define.feedback.color.TEXT);



function [] = ave_score_circle_mode()
global gData

X_AXIS = 1;
Y_AXIS = 2;
define = gData.define.feedback;

tmp = 1:gData.para.scans.trial_num;
tmp( isnan(gData.data.score) ) = [];
score = round( mean( gData.data.score(tmp) ) );

if sum( isnan(gData.para.score.score_limit) )

  tmp = abs(score)/100.0;
  R = round( tmp * gData.para.feedback.max_score_r );
  if score >= 0.0,	color = gData.define.feedback.color.SCORE_CIRCLE_PLUS;
  else			color = gData.define.feedback.color.SCORE_CIRCLE_MINUS;
  end
else

  score_limit = gData.para.score.score_limit;
  tmp = (score - score_limit(gData.define.MIN))/diff(score_limit);
  R = round( tmp * gData.para.feedback.max_score_r );
  color = gData.define.feedback.color.SCORE_CIRCLE;
end
score_rect = round( [...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.score_corcle(X_AXIS)-R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_corcle(Y_AXIS)-R,...
      gData.data.feedback.window_center_x...
      + define.offset_ptb.score_corcle(X_AXIS)+R,...
      gData.data.feedback.window_center_y...
      - define.offset_ptb.score_corcle(Y_AXIS)+R] );
Screen('FillOval', gData.data.feedback.window_id, color, score_rect);


Screen('FrameOval', gData.data.feedback.window_id,...
    gData.define.feedback.color.MAX_SCORE_FRAME,...
    gData.data.feedback.max_score, 20, 20);

Screen('FrameOval', gData.data.feedback.window_id,...
    gData.define.feedback.color.HALF_SCORE_FRAME,...
    gData.data.feedback.half_score, 20, 20);


function [] = finish_feedback()

global gData

Screen('CloseAll');

Screen('Preference', 'VisualDebugLevel',gData.para.feedback.original_debuglevel);
Screen('Preference', 'SuppressAllWarnings',gData.para.feedback.original_warnlebel);

ListenChar(0);

gData.data.feedback.window_id = -1;

