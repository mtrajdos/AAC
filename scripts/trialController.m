classdef trialController
    %% Initialize parameters
    properties
        % Placeholder for aversive outcome probability
        aversiveProbability = 0;

        % Slider controller instance
        sc = sliderController();

        % Point controller instance
        pc = pointController();

        % Durations of texture displays (s)
        fixationDur = 0.3;
        faceDur = 0.7;

        % Info string under slider
        sliderStr = '';

        % Set scaling factor (e.g., 1.5 for 150% size)
        scale = 2;

        % Set reward info box properties
        boxWidth = 400;
        boxHeight = 90;

        % Point reward storage for individual trials
        currentTrialPoints = 0;
    end
    
    methods
        function [decisionHistory, varargout] = runTrial(obj, window, windowRect, red, grey, white, fc, kc, currentBaselineTrials, decisionHistory, lang, trialType)

            % Initialize constant aversive outcome
            persistent aversiveTexture;

            % Initialize score
            score = obj.pc.totalPoints;

            % If conflict phase, randomize a reward (2, 4 or 6 points)
            if strcmp(trialType, 'conflict') 
            obj.pc = obj.pc.drawReward();
            obj.currentTrialPoints = obj.pc.pointsToWin; % Store for use in drawScreen
            end
            
            % Get window dimensions and center coordinates
            [width, height] = Screen('WindowSize', window);
            [xCenter, yCenter] = RectCenter(windowRect);
            
            % Load the slider
            slider = sliderController.loadSlider(window, windowRect);

            % Move slider to bottom of screen
            sliderYOffset = height * 0.7;
            slider.axesRect(2) = sliderYOffset;
            slider.axesRect(4) = sliderYOffset + slider.lineWidth;
            
            % Get faces
            neutralFaceTexture = fc.getRandomFace('neutral');
            angryFaceTexture = fc.getRandomFace('angry');

            if isempty(aversiveTexture)
            aversiveTexture = fc.getAversiveOutcome(window, './sprites/faces/angry/faces_03_ang_f.jpg');
            end
  
            % Get original image sizes
            [neutralWidth, neutralHeight] = fc.getImageSize(neutralFaceTexture);
            [angryWidth, angryHeight] = fc.getImageSize(angryFaceTexture);
            aversiveOutcomeRect = fc.scaleAversiveOutcomeImage(aversiveTexture, obj.scale, xCenter, yCenter);
            
            % Define vertical position just above the slider
            imageBottomY = sliderYOffset - 700;
                      
            % Get X centers of the leftmost and rightmost slider ticks
            leftTickX = slider.ticRects(1, 1) + slider.lineWidth / 2;
            rightTickX = slider.ticRects(1, end) + slider.lineWidth / 2;
            
            % Create centered destination rectangles
            neutralFaceRect = CenterRectOnPoint([0 0 neutralWidth neutralHeight], ...
                                                leftTickX, imageBottomY + neutralHeight / 2);
            
            angryFaceRect = CenterRectOnPoint([0 0 angryWidth angryHeight], ...
                                               rightTickX, imageBottomY + angryHeight / 2);
            
            for i = 1:slider.nSteps
                slider.ticRects(2, i) = sliderYOffset;
                slider.ticRects(4, i) = sliderYOffset + slider.tickHeight;
                slider.activeTicRects(2, i) = sliderYOffset - 3;
                slider.activeTicRects(4, i) = sliderYOffset + slider.tickHeight + 3;
            end
            
            % Store initial slider position
            initialPosition = slider.currentPosition;
            
            % Nested function to display fixation point
            function drawFixation()
                % Draw background
                Screen('FillRect', window, grey);
                
                % Display fixation
                Screen('FillOval', window, red, [xCenter-5 yCenter-5 xCenter+5 yCenter+5]);
                Screen('Flip', window);
                WaitSecs(obj.fixationDur);
            end
            
            function drawScreen(~)
                
                % Draw background
                Screen('FillRect', window, grey);
                
                % Display faces
                Screen('DrawTexture', window, neutralFaceTexture, [], neutralFaceRect, 0);
                Screen('DrawTexture', window, angryFaceTexture, [], angryFaceRect, 0);

                
                % Display information about points to win, if applicable
                if strcmp(trialType, 'conflict') == 1

                    % Get point reward for this trial
                    pts = eval('obj.currentTrialPoints');

                    switch lang
                    case 'de'
                        pointsText = sprintf('Chance auf %d Punkte zu gewinnen', pts);
                    case 'en'
                        pointsText = sprintf('Chance to win %d points', pts);
                    end

                    boxRect = CenterRectOnPointd([0 0 obj.boxWidth obj.boxHeight], xCenter, sliderYOffset - 300);
                    Screen('FillRect', window, [80 80 80], boxRect);
                    Screen('FrameRect', window, white, boxRect, 2);

                    % Set text size
                    Screen('TextSize', window, 24);
        
                    % Draw the text centered in the box
                    DrawFormattedText(window, pointsText, 'center', boxRect(2) + obj.boxHeight/2 - 12, white);
                end
                
                % Draw the slider
                Screen('FillRect', window, slider.scaleColor, [slider.axesRect, slider.ticRects]);
                
                % Make ticks visible
                for j = 1:slider.nSteps
                    Screen('FillRect', window, [0.7, 0.7, 0.7], slider.ticRects(:,j));
                end
                
                % Draw the manekin image if available
                if isfield(slider, 'hasImage') && slider.hasImage
                    % Enable alpha blending for transparency
                    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    
                    % Center the image above the current tick position
                    currentTickX = slider.ticRects(1, slider.currentPosition) + slider.lineWidth / 2;
                    
                    % Position 5px above the tick
                    imageRect = CenterRectOnPoint(slider.imageRect, currentTickX, slider.ticRects(2, slider.currentPosition) - 5 - slider.imageHeight/2);
                    
                    % Draw the image with transparency
                    Screen('DrawTexture', window, slider.imageTexture, [], imageRect, 0);
                end
                
                % Highlight current position
                Screen('FillRect', window, slider.activeColor, slider.activeTicRects(:, slider.currentPosition));
                
                % Draw labels
                Screen('TextSize', window, slider.textSize);
                for j = 1:slider.nSteps
                    textRect = Screen('TextBounds', window, slider.labels{j});
                    Screen('DrawText', window, slider.labels{j}, ...
                        round(slider.ticRects(1,j)-textRect(3)/2), ...
                        slider.ticRects(4,j) + slider.ticTextGap, white);
                end
            
                switch lang
                    case 'de'
                        obj.sliderStr = 'Bitte den Marker mit den Pfeiltasten links/rechts bewegen. Drücken Sie ENTER zum Bestätigen. Drücken Sie ESC zum Beenden.';
                    case 'en'
                        obj.sliderStr = 'Move the marker using left/right arrows. Press ENTER to confirm. Press ESC to exit';
                end
            
                % Draw instruction text
                Screen('TextSize', window, 24);
                DrawFormattedText(window, obj.sliderStr, 'center', sliderYOffset + 120, white);
                Screen('Flip', window);

                if nargin > 0
                    
                end

            end
            
            % Display fixation point first
            drawFixation();
            
            % Then show the main trial screen
            drawScreen();
            
            % Process key presses
            isDecisionMade = false;
            while ~isDecisionMade
                % Ignore mouse input
                [~, ~, ~] = GetMouse(window);
                
                [keyIsDown, ~, keyCode] = KbCheck;
                
                if keyIsDown
                    if keyCode(kc.left)
                        % Move left
                        slider.currentPosition = max(1, slider.currentPosition - 1);
                        drawScreen();
                        WaitSecs(0.15); % Prevent rapid movement
                        
                    elseif keyCode(kc.right)
                        % Move right
                        slider.currentPosition = min(slider.nSteps, slider.currentPosition + 1);
                        drawScreen();
                        WaitSecs(0.15); % Prevent rapid movement
                        
                    elseif keyCode(kc.enter)
                        % Save final position and exit
                        slider.finalPosition = slider.currentPosition;
                        
                        % Store tick value
                        tickValue = str2double(slider.labels{slider.finalPosition});
                        obj.aversiveProbability = tickValue / 100;
                        
                        % Save decision with tick values
                        newDecision = struct('type', trialType, ...
                                            'trialNo', currentBaselineTrials, ...
                                            'start', str2double(slider.labels{initialPosition}), ...
                                            'end', tickValue);
                        
                        % Append to decisions array
                        if isempty(decisionHistory)
                            decisionHistory = newDecision;
                        else
                            decisionHistory(end+1) = newDecision; %#ok<AGROW>
                        end
                        
                        isDecisionMade = true;
                        
                    elseif keyCode(kc.escape)
                        % Early exit - perform thorough cleanup
                        fprintf('Trial interrupted by user pressing Escape key. Cleaning up...\n');
                        
                        % Close specific textures first
                        if exist('neutralFaceTexture', 'var') && neutralFaceTexture > 0
                            Screen('Close', neutralFaceTexture);
                        end
                        
                        if exist('angryFaceTexture', 'var') && angryFaceTexture > 0
                            Screen('Close', angryFaceTexture);
                        end
                        
                        if exist('aversiveTexture', 'var') && aversiveTexture > 0
                            Screen('Close', aversiveTexture);
                        end
                        
                        if isfield(slider, 'imageTexture') && slider.imageTexture > 0
                            Screen('Close', slider.imageTexture);
                        end
                        
                        % Clear all variables
                        clear aversiveTexture neutralFaceTexture angryFaceTexture slider;
                        
                        % Reset persistent variables
                        clear functions;
                        
                        % Close all textures
                        Screen('Close');
                        
                        % Close all windows
                        Screen('CloseAll');
                        
                        % Clear screen
                        sca;
                        
                        % Reset priority
                        Priority(0);
                        
                        % Show cursor
                        ShowCursor;
                        
                        % Restore keyboard
                        RestrictKeysForKbCheck([]);
                        
                        % Clear memory
                        WaitSecs(0.1);  % Brief pause to let operations complete
                        clear mex;      % Clear MEX files
                        clear all;      % Clear all variables
                        return
                    end
                    
                    % Wait for key release
                    while KbCheck; end
                end
            end
            
            % Display fixation point after decision
            drawFixation();

            % Display angry face based on probability,
            % otherwise empty screen
            if rand() <= obj.aversiveProbability 
                Screen('DrawTexture', window, aversiveTexture, [], aversiveOutcomeRect, 0);
                Screen('Flip', window);
                WaitSecs(obj.faceDur)
                obj.pc.totalPoints = obj.pc.totalPoints + obj.pc.pointsToWin;
            else
                Screen('FillRect', window, grey);
                Screen('Flip', window);
                WaitSecs(obj.faceDur)
            end

        score = obj.pc.totalPoints;

        % Check if points output is requested
        if nargout > 1
            varargout{1} = score;
        end
        end
    end
end