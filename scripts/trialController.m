classdef trialController
    properties
        % Initialize parameters
        aversiveProbability = int32(0);
        sc = sliderController();
    end
    
    methods
        function decisionHistory = runBaselineTrial(obj, window, windowRect, grey, white, fc, currentBaselineTrials, decisionHistory)
            % Get window dimensions
            [width, height] = Screen('WindowSize', window);
            
            % Load the slider
            slider = sliderController.loadSlider(window, windowRect);
            
            % Get random faces
            neutralFaceTexture = fc.getRandomNeutralFace();
            angryFaceTexture = fc.getRandomAngryFace();
            
            % Calculate face positions
            faceWidth = 150;
            faceHeight = 180;
            neutralFaceRect = [50, height/5-faceHeight/2, 50+faceWidth, height/5+faceHeight/2];
            angryFaceRect = [width-50-faceWidth, height/5-faceHeight/2, width-50, height/5+faceHeight/2];
            
            % Move slider to bottom of screen
            sliderYOffset = height * 0.7;
            slider.axesRect(2) = sliderYOffset;
            slider.axesRect(4) = sliderYOffset + slider.lineWidth;
            
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
            
            % Draw background
            Screen('FillRect', window, grey);

            % Display faces
            Screen('DrawTexture', window, neutralFaceTexture, [], neutralFaceRect);
            Screen('DrawTexture', window, angryFaceTexture, [], angryFaceRect);
            
            % Draw the slider
            Screen('FillRect', window, slider.scaleColor, [slider.axesRect, slider.ticRects]);
            
            % Make ticks visible
            for i = 1:slider.nSteps
                Screen('FillRect', window, [0.7, 0.7, 0.7], slider.ticRects(:,i));
            end
            
            % Highlight current position
            Screen('FillRect', window, slider.activeColor, slider.activeTicRects(:, slider.currentPosition));
            
            % Draw labels
            Screen('TextSize', window, slider.textSize);
            for i = 1:slider.nSteps
                textRect = Screen('TextBounds', window, slider.labels{i});
                Screen('DrawText', window, slider.labels{i}, ...
                    round(slider.ticRects(1,i)-textRect(3)/2), ...
                    slider.ticRects(4,i) + slider.ticTextGap, white);
            end
            
            % Draw instruction text
            Screen('TextSize', window, 24);
            DrawFormattedText(window, 'Move the marker using left/right arrows. Press ENTER to confirm. Press ESC to exit.', ...
                'center', sliderYOffset + 120, white);
            
            Screen('Flip', window);
            
            % Process key presses
            enterKey = KbName('Return');
            while true
                % Ignore mouse input
                [~, ~, ~] = GetMouse(window);
                
                [keyIsDown, ~, keyCode] = KbCheck;
                
                if keyIsDown
                    if keyCode(slider.lessKey)
                        % Move left
                        slider.currentPosition = max(1, slider.currentPosition - 1);
                        
                        % Redraw everything
                        Screen('FillRect', window, grey);
                        Screen('DrawTexture', window, neutralFaceTexture, [], neutralFaceRect);
                        Screen('DrawTexture', window, angryFaceTexture, [], angryFaceRect);
                        Screen('FillRect', window, slider.scaleColor, [slider.axesRect, slider.ticRects]);
                        
                        % Draw ticks
                        for i = 1:slider.nSteps
                            Screen('FillRect', window, [0.7, 0.7, 0.7], slider.ticRects(:,i));
                        end
                        
                        Screen('FillRect', window, slider.activeColor, slider.activeTicRects(:, slider.currentPosition));
                        
                        % Draw labels
                        Screen('TextSize', window, slider.textSize);
                        for i = 1:slider.nSteps
                            textRect = Screen('TextBounds', window, slider.labels{i});
                            Screen('DrawText', window, slider.labels{i}, ...
                                round(slider.ticRects(1,i)-textRect(3)/2), ...
                                slider.ticRects(4,i) + slider.ticTextGap, white);
                        end
                        
                        % Draw instruction text
                        Screen('TextSize', window, 24);
                        DrawFormattedText(window, 'Move the marker using left/right arrows. Press ENTER to confirm. Press ESC to exit.', ...
                            'center', sliderYOffset + 120, white);
                        
                        Screen('Flip', window);
                        WaitSecs(0.15);
                        
                    elseif keyCode(slider.moreKey)
                        % Move right
                        slider.currentPosition = min(slider.nSteps, slider.currentPosition + 1);
                        
                        % Redraw everything
                        Screen('FillRect', window, grey);
                        Screen('DrawTexture', window, neutralFaceTexture, [], neutralFaceRect);
                        Screen('DrawTexture', window, angryFaceTexture, [], angryFaceRect);
                        Screen('FillRect', window, slider.scaleColor, [slider.axesRect, slider.ticRects]);
                        
                        % Draw ticks
                        for i = 1:slider.nSteps
                            Screen('FillRect', window, [0.7, 0.7, 0.7], slider.ticRects(:,i));
                        end
                        
                        Screen('FillRect', window, slider.activeColor, slider.activeTicRects(:, slider.currentPosition));
                        
                        % Draw labels
                        Screen('TextSize', window, slider.textSize);
                        for i = 1:slider.nSteps
                            textRect = Screen('TextBounds', window, slider.labels{i});
                            Screen('DrawText', window, slider.labels{i}, ...
                                round(slider.ticRects(1,i)-textRect(3)/2), ...
                                slider.ticRects(4,i) + slider.ticTextGap, white);
                        end
                        
                        % Draw instruction text
                        Screen('TextSize', window, 24);
                        DrawFormattedText(window, 'Move the marker using left/right arrows. Press ENTER to confirm. Press ESC to exit.', ...
                            'center', sliderYOffset + 120, white);
                        
                        Screen('Flip', window);
                        WaitSecs(0.15);
                        
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
                        
                        break;
                        
                    elseif keyCode(escapeKey)
                        % Early exit
                        fprintf('Trial interrupted by user pressing Escape key\n');
                        Screen('CloseAll');
                    end
                    
                    % Wait for key release
                    while KbCheck; end
                end
            end
            
            % Flash the selection briefly to give feedback
            Screen('FillRect', window, grey);
            Screen('DrawTexture', window, neutralFaceTexture, [], neutralFaceRect);
            Screen('DrawTexture', window, angryFaceTexture, [], angryFaceRect);
            Screen('FillRect', window, slider.scaleColor, [slider.axesRect, slider.ticRects]);
            Screen('FillRect', window, [0.8, 0.8, 0.8], slider.activeTicRects(:, slider.finalPosition));
            Screen('Flip', window);
            WaitSecs(0.5);
        end
    end
end