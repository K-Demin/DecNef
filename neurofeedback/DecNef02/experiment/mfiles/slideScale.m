function [position, RT, answer] = slideScale(screenPointer, question, rect, endPoints, color, center)
%SLIDESCALE This funtion draws a slide scale on a PSYCHTOOLOX 3 screen and returns the
% position of the slider spaced between -100 and 100 as well as the reaction time and if an answer was given.
%
%   Usage: [position, secs] = slideScale(ScreenPointer, question, center, rect, endPoints, varargin)
%   Mandatory input:
%    ScreenPointer  -> Pointer to the window.
%    question       -> Text string containing the question.
%    rect           -> Double contatining the screen size.
%                      Obtained with [myScreen, rect] = Screen('OpenWindow', 0);
%    endPoints      -> Cell containg the two text string of the left and right
%                      end of the scala. Exampe: endPoints = {'left, 'right'};
%
%   Varargin:
%    'linelength'     -> An integer specifying the lengths of the ticks in
%                        pixels. The default is 10.
%    'width'          -> An integer specifying the width of the scala line in
%                        pixels. The default is 3.
%    'range'          -> An integer specifying the type of range. If 1,
%                        then the range is from -100 to 100. If 2, then the
%                        range is from 0 to 100. Default is 1. 
%    'startposition'  -> Choose 'right', 'left' or 'center' start position.
%                        Default is center.
%    'scalalength'    -> Double value between 0 and 1 for the length of the
%                        scale. The default is 0.9.
%    'scalaposition'  -> Double value between 0 and 1 for the position of the
%                        scale. 0 is top and 1 is bottom. Default is 0.8.
%    'device'         -> A string specifying the response device. Either 'mouse' 
%                        or 'keyboard'. The default is 'mouse'.
%    'responsekeys'   -> Vector containing keyCodes of the keys from the keyboard to log the
%                        response and move the slider to the right and left. 
%                        The default is [KbName('return') KbName('left') KbName('right')].
%    'stepSize'       -> An integer specifying the number of pixel the
%                        slider moves with each step. Default is 1.
%    'slidercolor'    -> Vector for the color value of the slider [r g b] 
%                        from 0 to 255. The default is red [255 0 0].
%    'scalacolor'     -> Vector for the color value of the scale [r g b] 
%                        from 0 to 255.The default is black [0 0 0].
%    'aborttime'      -> Double specifying the time in seconds after which
%                        the function should be aborted. In this case no
%                        answer is saved. The default is Inf.
%    'image'          -> An image saved in a uint8 matrix. Use
%                        imread('image.png') to load an image file.
%    'displaypoition' -> If true, the position of the slider is displayed. 
%                        The default is false. 
%
%   Output:
%    'position'      -> Deviation from zero in percentage, 
%                       with -100 <= position <= 100 to indicate left-sided
%                       and right-sided deviation.
%    'RT'            -> Reaction time in milliseconds.
%    'answer'        -> If 0, no answer has been given. Otherwise this
%                       variable is 1.
%
%   Author: Joern Alexander Quent
%   e-mail: Alex.Quent@mrc-cbu.cam.ac.uk
%   Version history:
%                    1.0 - 4. January 2016 - First draft
%                    1.1 - 18. Feburary 2016 - Added abort time and option to
%                    choose between mouse and key board
%                    1.2 - 5. October 2016 - End points will be aligned to end
%                    ticks
%                    1.3 - 06/01/2017 - Added the possibility to display an
%                    image
%                    1.4 - 5. May 2017 - Added the possibility to choose a
%                    start position
%                    1.5 - 7. November 2017 - Added the possibility to display
%                    the position of the slider under the scale.
%                    1.6 - 27. November 2017 - The function now waits until
%                    all keys are released before exiting. 
%                    1.7 - 28. November 2017 - More than one screen
%                    supported now.
%                    1.8 - 29. November 2017 - Fixed issue that mouse is
%                    not properly in windowed mode.
%                    1.9 - 7. December 2017 - If an image is drawn, the
%                    corresponding texture is deleted at the end.
%                    1.10 - 28. December 2017 - Added the possibility to
%                    choose the type of range (0 to 100 or -100 to 100).
%                    1.11 - 7. May 2019 - Added the possibility to control
%                    the slider with keys only. Use keyboard as devices and
%                    select this keys for this function. In addition,
%                    default for aborttime was changed to Inf and one bug
%                    with slidercolor was fixed. 
%% Parse input arguments
% Default values
center        = round([rect(3) rect(4)]/2);
lineLength    = 30;
width         = 20;
scalaLength   = 0.75;
scalaPosition = 0.55;
sliderColor   = [255 0 0];
scaleColor    = [0 0 0];
device        = 'keyboard';
aborttime     = 4;
responseKeys  = [40  KbName('y') KbName('b')];
GetMouseIndices;
drawImage     = 0;
startPosition = 'random';
displayPos    = false;
rangeType     = 2;
stepSize      = 10;

% Sets the default key depending on choosen device
if strcmp(device, 'mouse')
    mouseButton   = 1; % X mouse button
end

%% Checking number of screens and parsing size of the global screen
screens       = Screen('Screens');
if length(screens) > 1 % Checks for the number of screens
    screenNum        = 1;
else
    screenNum        = 0;
end
globalRect          = Screen('Rect', screenNum);

% Set the font size


%% Coordinates of scale lines and text bounds
if strcmp(startPosition, 'right')
    x = rect(3)*scalaLength;
elseif strcmp(startPosition, 'center')
    x = rect(3)/2;
elseif strcmp(startPosition, 'left')
    %x = globalRect(3)*(1-scalaLength);
    x = rect(3)*(1-scalaLength);
elseif strcmp(startPosition, 'random')
    x = normrnd(rect(3)/2, (rect(3)*(1-scalaLength)/2));
else
    error('Only right, center and left are possible start positions');
end
%SetMouse(round(x), round(rect(4)*scalaPosition), screenPointer, 1);
midTick    = [center(1) rect(4)*scalaPosition - lineLength - 5 center(1) rect(4)*scalaPosition  + lineLength + 5];
leftTick   = [rect(3)*(1-scalaLength) rect(4)*scalaPosition - lineLength rect(3)*(1-scalaLength) rect(4)*scalaPosition  + lineLength];
rightTick  = [rect(3)*scalaLength rect(4)*scalaPosition - lineLength rect(3)*scalaLength rect(4)*scalaPosition  + lineLength];
horzLine   = [rect(3)*scalaLength rect(4)*scalaPosition rect(3)*(1-scalaLength) rect(4)*scalaPosition];
textBounds = [Screen('TextBounds', screenPointer, endPoints{1}); Screen('TextBounds', screenPointer, endPoints{2})];
if drawImage == 1
    rectImage  = [center(1) - imageSize(2)/2 rect(4)*(scalaPosition - 0.2) - imageSize(1) center(1) + imageSize(2)/2 rect(4)*(scalaPosition - 0.2)];
    if rect(4)*(scalaPosition - 0.2) - imageSize(1) < 0
        error('The height of the image is too large. Either lower your scale or use the smaller image.');
    end
end

% Calculate the range of the scale, which will be need to calculate the
% position
scaleRange        = round(rect(3)*(1-scalaLength)):round(rect(3)*scalaLength); % Calculates the range of the scale
scaleRangeShifted = round((scaleRange)-mean(scaleRange));                      % Shift the range of scale so it is symmetrical around zero

%% Loop for scale loop
t0                         = GetSecs;
answer                     = 0;
RT = 0;
while answer == 0
    % Parse user input for x location
    if strcmp(device, 'mouse')
        [x,~,buttons,~,~,~] = GetMouse(screenPointer, 1);
    elseif strcmp(device, 'keyboard')
        [~, ~, keyCode] = KbCheck;
        if keyCode(responseKeys(2)) == 1
            if RT == 0
                RT = GetSecs - t0;
            end
            x = x - stepSize; % Goes stepSize pixel to the left
        elseif keyCode(responseKeys(3)) == 1
            if RT == 0
                RT = GetSecs - t0;
            end
            x = x + stepSize; % Goes stepSize pixel to the right
        end
    else
        error('Unknown device');
    end
    
    % Stop at upper and lower bound
    if x > rect(3)*scalaLength
        x = rect(3)*scalaLength;
    elseif x < rect(3)*(1-scalaLength)
        x = rect(3)*(1-scalaLength);
    end
    
    % Draw image if provided
    if drawImage == 1
         Screen('DrawTexture', screenPointer, stimuli,[] , rectImage, 0);
    end
    
    % Drawing the question as text
    DrawFormattedText(screenPointer, question, 'center', rect(4)*(scalaPosition - 0.1),color,[],1); 
    
    % Drawing the end points of the scala as text
    DrawFormattedText(screenPointer, endPoints{1}, leftTick(1, 1) - textBounds(1, 3)/2,  rect(4)*scalaPosition+90, [],[],1,[],[],[],[]); % Left point
    DrawFormattedText(screenPointer, endPoints{2}, rightTick(1, 1) - textBounds(2, 3)/2,  rect(4)*scalaPosition+90, [],[],1,[],[],[],[]); % Right point
    
    % Drawing the scala
    Screen('DrawLine', screenPointer, color, midTick(1), midTick(2), midTick(3), midTick(4), width);         % Mid tick
    Screen('DrawLine', screenPointer, color, leftTick(1), leftTick(2), leftTick(3), leftTick(4), width);     % Left tick
    Screen('DrawLine', screenPointer, color, rightTick(1), rightTick(2), rightTick(3), rightTick(4), width); % Right tick
    Screen('DrawLine', screenPointer, color, horzLine(1), horzLine(2), horzLine(3), horzLine(4), width);     % Horizontal line
    
    % The slider
    Screen('DrawLine', screenPointer, sliderColor, x, rect(4)*scalaPosition - lineLength, x, rect(4)*scalaPosition  + lineLength, width);
    
    % Caculates position
    if rangeType == 1
        position = round((x)-mean(scaleRange));           % Calculates the deviation from the center
        position = (position/max(scaleRangeShifted))*100; % Converts the value to percentage
    elseif rangeType == 2
        position = round((x)-min(scaleRange));                       % Calculates the deviation from 0. 
        position = (position/(max(scaleRange)-min(scaleRange)))*100; % Converts the value to percentage
    end

    
    % Display position
    if displayPos
        DrawFormattedText(screenPointer, num2str(round(position)), 'center', rect(4)*(scalaPosition + 0.05)); 
    end
    
    % Flip screen
    Screen('Flip', screenPointer);
    
%     % Check if answer has been given
%     if strcmp(device, 'mouse')
%         secs = GetSecs;
%         if buttons(mouseButton) == 1
%             answer = 1;
%         end
%     elseif strcmp(device, 'keyboard')
%         [~, secs, keyCode] = KbCheck;
%         if keyCode(responseKeys(1)) == 1
%             answer = 1;
%         end
%     end
%     
    % Abort if answer takes too long
    if GetSecs - t0 >= aborttime 
        break
    end
end
%% Wating that all keys are released and delete texture
KbReleaseWait; %Keyboard
%KbReleaseWait(1); %Mouse
if drawImage == 1
    Screen('Close', stimuli);
end

end

