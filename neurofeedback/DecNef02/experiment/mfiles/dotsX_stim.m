function [y_temperatures, x_times] = dotsX_stim(painStim, stimType, tcs)
%
%
% Dot positions are computed in dotsX_prep() to make it the easiest to
% record thermal stim at the same time (otherwise it lags).
% This was based on a script from Cody Cushing.
% -VTD-
% 
global gData

% If we do not deliver painful stimulations, then we will have to wait a
% similar amount of time as it requires to read from the probe (which is on average 0.0085 sec).
% here, start pause so that we can use it later on.
if painStim == 0
    pause on
end

y_temperatures = [];
x_times = [];

gData.dot.curWindow = gData.data.feedback.window_id;    %window on which to plot dots
gData.dot.center = [gData.data.feedback.window_center_x,gData.data.feedback.window_center_y];       %center of the screen in pixels

curWindow = gData.dot.curWindow;
dotColor = gData.dot.dotColor;
dotSize = gData.dot.dotSize; % probably better to leave this in pixels, but not sure
center = gData.dot.centerDisp;

%disp('after one loop')
% loop length is determined by the field "dotInfo.maxDotTime"
continue_show = round(gData.dot.maxDotTime*gData.dot.monRefresh);

% THE MAIN LOOP
dontclear = gData.dot.dontclear;
rtTimer=GetSecs;

Screen('DrawingFinished',curWindow,dontclear);
cpt = gData.dot.cpt;
while continue_show

    % after all computations, flip
    Screen('Flip', curWindow,0,dontclear);
    
    % now do drawing commands
    Screen('DrawDots', curWindow, gData.dot.dot_show{cpt}, dotSize, dotColor, center(1,:));

    % This is to show the fixation during dotmotion.
    Screen('FrameOval', gData.data.feedback.window_id, gData.define.feedback.color.GAZE, gData.data.feedback.gaze_frame, 20, 20);
    Screen('FillOval', gData.data.feedback.window_id, gData.define.feedback.color.GAZE, gData.data.feedback.gaze_fill);
    
    % tell ptb to get ready while doing computations for next dots
    % presentation
    Screen('DrawingFinished',curWindow,dontclear);    
    
    % check for end of loop
    if (GetSecs - rtTimer) >= gData.dot.maxDotTime  
        continue_show = 0;  
    else
        cpt = cpt + 1;
    end
       
    if painStim
        % Read the final temperature (other wise it slows down the display
        % too much)
        switch stimType
            case 'Thermal'
                if mod(cpt,3) == 0
                    % start_tcs can be used to compute the average time
                    % it takes to read from the probe (Already did and it is 0.0085s). 
                    %start_tcs = GetSecs;
                    % Thi is to read the temperature from the thermode
                    gData.dot.cpt_tcs = gData.dot.cpt_tcs + 1;
                    currentTemperatures = TcsGetTemperatures( tcs ); %array of 5 temperatures ( = 5 zones )
                    %disp( currentTemperatures ); %disp current temp
                    y_temperatures( gData.dot.cpt_tcs, 1:5 ) = currentTemperatures; %record temperatures in y_temperatures
                    currentTime = toc; %get current time
                    x_times( gData.dot.cpt_tcs, 1 ) = currentTime; %record time in x_temperatures
                    %gData.dot.time_TCS(end+1) = start_tcs - GetSecs;
                end
        end
    else
        if mod(cpt,3) == 0
            % There are no painful stimulations during neurofeedback. Here, I
            % computed the average time of reading from the probe and I will
            % stall the execution for a similar amount of time. That way, the
            % resulting speed should be the same.
            pause(0.0085)
        end
    end
end
gData.dot.cpt = cpt;

end_time = GetSecs;
%Priority(0);
