classdef trialController
    properties
        % Initialize parameters
        aversiveProbability = int32(0);
        sc = sliderController();
        fixationDur = 0.3;
        faceDur = 0.7;
    end
    
    methods
        function decisionHistory = runBaselineTrial(obj, window, windowRect, red, grey, white, fc, currentBaselineTrials, decisionHistory)
            % Get window dimensions
            [width, height] = Screen('WindowSize', window);
            
            % Load the slider
            slider = sliderController.loadSlider(window, windowRect);

            % Move slider to bottom of screen
            sliderYOffset = height * 0.7;
            slider.axesRect(2) = sliderYOffset;
            slider.axesRect(4) = sliderYOffset + slider.lineWidth;
            
            % Get random faces
            neutralFaceTexture = fc.getRandomNeutralFace();
            angryFaceTexture = fc.getRandomAngryFace();
            
            % Get original image sizes from the textures
            neutralRect = Screen('Rect', neutralFaceTexture);
            angryRect = Screen('Rect', angryFaceTexture);
            
            neutralWidth = neutralRect(3) - neutralRect(1);
            neutralHeight = neutralRect(4) - neutralRect(2);
            
            angryWidth = angryRect(3) - angryRect(1);
            angryHeight = angryRect(4) - angryRect(2);
            
            % Define vertical position just above the slider
            imageBottomY = sliderYOffset - 600;
                      
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
            
            % Add key for early exit
            escapeKey = KbName('Escape');
            enterKey = KbName('Return');
            
            % Nested function to display fixation point
            function drawFixation()
                % Draw background
                Screen('FillRect', window, grey);
                
                % Display fixation
                [xCenter, yCenter] = RectCenter(windowRect);
                Screen('FillOval', window, red, [xCenter-5 yCenter-5 xCenter+5 yCenter+5]);
                Screen('Flip', window);
                WaitSecs(obj.fixationDur);
            end
            
            % Nested function to draw trial screen
            function drawScreen()
                % Draw background
                Screen('FillRect', window, grey);
                
                % Display faces
                Screen('DrawTexture', window, neutralFaceTexture, [], neutralFaceRect, 0);
                Screen('DrawTexture', window, angryFaceTexture, [], angryFaceRect, 0);
                
                % Draw the slider
                Screen('FillRect', window, slider.scaleColor, [slider.axesRect, slider.ticRects]);
                
                % Make ticks visible
                for j = 1:slider.nSteps
                    Screen('FillRect', window, [0.7, 0.7, 0.7], slider.ticRects(:,j));
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
                
                % Draw instruction text
                Screen('TextSize', window, 24);
                DrawFormattedText(window, 'Move the marker using left/right arrows. Press ENTER to confirm. Press ESC to exit.', ...
                    'center', sliderYOffset + 120, white);
                
                Screen('Flip', window);
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
                    if keyCode(slider.lessKey)
                        % Move left
                        slider.currentPosition = max(1, slider.currentPosition - 1);
                        drawScreen();
                        WaitSecs(0.15); % Prevent rapid movement
                        
                    elseif keyCode(slider.moreKey)
                        % Move right
                        slider.currentPosition = min(slider.nSteps, slider.currentPosition + 1);
                        drawScreen();
                        WaitSecs(0.15); % Prevent rapid movement
                        
                    elseif keyCode(enterKey)
                        % Save final position and exit
                        slider.finalPosition = slider.currentPosition;
                        
                        % Store tick value
                        tickValue = str2double(slider.labels{slider.finalPosition});
                        obj.aversiveProbability = tickValue / 100;
                        
                        % Save decision with tick values
                        newDecision = struct('type', 'baseline', ...
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
                        
                    elseif keyCode(escapeKey)
                        % Early exit
                        fprintf('Trial interrupted by user pressing Escape key\n');
                        Screen('CloseAll');
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
            if rand() < obj.aversiveProbability 
                Screen('DrawTexture', window, angryFaceTexture, [], [], 0);
                Screen('Flip', window);
                WaitSecs(obj.faceDur)
            else
                Screen('FillRect', window, grey);
                Screen('Flip', window);
                WaitSecs(obj.faceDur)
            end
        end
    end
end