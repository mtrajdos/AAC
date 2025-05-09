classdef trialController < handle
    %% Initialize parameters
    properties

        % Language of the experiment
        lang;

        % Time allocated for subject's decision
        decisionWindow;

        % Placeholder for aversive outcome probability
        aversiveProbability = 0;

        % Instances of controllers required for trials
        sc = sliderController();
        pc = pointController();
        fc = faceController();
        
        % Point reward storage for individual trials
        currentTrialPoints = 0;

        % Individual faces per trial basis
        angryFaceTexture;
        neutralFaceTexture;

        % Main path placeholder
        mainPath;

        % Properties of the constant aversive outcome
        aversiveTexture;
        aversiveOutcomeRect;
        aversiveOutcomePath;
        avatarImagePath;

        % Paths for all face folders
        angryFacesPath;
        neutralFacesPath;

        % Durations of texture displays (s)
        fixationDur = 0.3;
        faceDur = 0.7;

        % Set scaling factor (e.g., 1.5 for 150% size)
        scale = 2;

        % PTB window properties
        window;
        windowRect;
        xCenter;
        yCenter;
        height;
        width;

        % Set reward info box properties
        boxWidth = 750;
        boxHeight = 60;
        boxRect;
        
        % Properties for constant PTB rectangles across trials
        sliderYOffset;
        neutralFaceRect;
        angryFaceRect;

        % Slider object
        slider;

        % Text informing about number of points to win
        pointsText;

        % Total score property
        score;
    end
    
    methods
        % Constructor loading all constant
        % graphical components of each trial
        function obj = trialController(lang, decisionTime, currentScript, window, windowRect, xCenter, yCenter, width, height)

            % Initialize path strings
            obj.mainPath = fileparts(fileparts(currentScript));
            obj.angryFacesPath = dir([obj.mainPath filesep 'sprites/faces/angry/', '*.jpg']);
            obj.neutralFacesPath = dir([obj.mainPath filesep 'sprites/faces/neutral/', '*.jpg']);
            obj.aversiveOutcomePath = [obj.mainPath filesep 'sprites/faces/angry/faces_03_ang_f.jpg'];
            obj.avatarImagePath = [obj.mainPath filesep 'sprites/Manekin.png'];

            % Set PTB window properties in the instance
            obj.window = window;
            obj.windowRect = windowRect;
            obj.xCenter = xCenter;
            obj.yCenter = yCenter;
            obj.width = width;
            obj.height = height;

            % Set language
            obj.lang = lang;

            % Initialize score counter
            obj.score = int32(0);

            % Set time for participant's decision
            obj.decisionWindow = decisionTime;

            % Preload all faces to face controller instance
            obj.fc = obj.fc.loadFaces(obj.window, obj.angryFacesPath, obj.neutralFacesPath);
            
            % Load the slider and info texts
            obj.slider = obj.sc.loadSlider(obj.window, obj.windowRect, obj.avatarImagePath);
                switch lang
                    case 'de'
                        obj.sc.sliderStr = 'Bitte den Marker mit den Pfeiltasten links/rechts bewegen. Drücken Sie ENTER zum Bestätigen. Drücken Sie ESC zum Beenden.';
                        obj.pointsText = 'Chance auf %d Punkte zu gewinnen';
                    case 'en'
                        obj.sc.sliderStr = 'Move the marker using left/right arrows. Press ENTER to confirm. Press ESC to exit';
                        obj.pointsText = 'Chance to win %d points';
                end
            
            % Initialize constant aversive outcome
            obj.aversiveTexture = obj.fc.getAversiveOutcome(obj.window, obj.aversiveOutcomePath);
            obj.aversiveOutcomeRect = obj.fc.scaleAversiveOutcomeImage(obj.aversiveTexture, obj.scale, obj.xCenter, obj.yCenter);
            
            % Pre-calculate slider position
            obj.sliderYOffset = obj.height * 0.7;
            obj.slider.axesRect(2) = obj.sliderYOffset;
            obj.slider.axesRect(4) = obj.sliderYOffset + obj.slider.lineWidth;
            
            % Update tick positions
            for i = 1:obj.slider.nSteps
                obj.slider.ticRects(2, i) = obj.sliderYOffset;
                obj.slider.ticRects(4, i) = obj.sliderYOffset + obj.slider.tickHeight;
                obj.slider.activeTicRects(2, i) = obj.sliderYOffset - 3;
                obj.slider.activeTicRects(4, i) = obj.sliderYOffset + obj.slider.tickHeight + 3;
            end
            
            % Face texture rectangles
            [neutralWidth, neutralHeight] = obj.fc.getImageSize(obj.fc.getRandomFace('neutral'));
            [angryWidth, angryHeight] = obj.fc.getImageSize(obj.fc.getRandomFace('angry'));
            
            % Define vertical position just above the slider
            imageBottomY = obj.sliderYOffset - 700;
            
            % Get X centers of the leftmost and rightmost slider ticks
            leftTickX = obj.slider.ticRects(1, 1) + obj.slider.lineWidth / 2;
            rightTickX = obj.slider.ticRects(1, end) + obj.slider.lineWidth / 2;
            
            % Create centered destination rectangles
            obj.neutralFaceRect = CenterRectOnPoint([0 0 neutralWidth neutralHeight], ...
                                            leftTickX, imageBottomY + neutralHeight / 2);
            
            obj.angryFaceRect = CenterRectOnPoint([0 0 angryWidth angryHeight], ...
                                           rightTickX, imageBottomY + angryHeight / 2);
                                           
            % Reward info box
            obj.boxRect = CenterRectOnPointd([0 0 obj.boxWidth obj.boxHeight], obj.xCenter, obj.sliderYOffset - 300);
        end

        % Clean up at variables and textures at early exit or experiment conclusion
        function cleanUp(obj)
                        
            % Close specific textures first
            if exist('neutralFaceTexture', 'var')
               Screen('Close', obj.neutralFaceTexture);
            end
                        
            if exist('angryFaceTexture', 'var')
               Screen('Close', obj.angryFaceTexture);
            end
                        
            if exist('aversiveTexture', 'var')
               Screen('Close', obj.aversiveTexture);
            end
                        
            if isfield(obj.slider, 'avatarTexture')
               Screen('Close', obj.slider.avatarTexture);
            end
                        
            % Clear all variables
            clear aversiveTexture neutralFaceTexture angryFaceTexture slider;
                        
            % Reset persistent variables
            clear functions;
                        
            % Close remaining textures
            Screen('Close');
                        
            % Clear screen
            sca;
                        
            % Reset priority
            Priority(0);
                        
            % Show cursor
            ShowCursor;
                        
            % Restore keyboard
            RestrictKeysForKbCheck([]);
                        
            % Clear memory
            WaitSecs(0.1);
            clear mex;      % Clear MEX files
            clear all;      % Clear all variables
        end

        function [decisionHistory, score] = runTrial(obj, red, grey, white, kc, currentTrialCount, targetTrialCount, decisionHistory, trialType)

            % Draw random slider position
            obj.slider.currentPosition = randi([1, obj.slider.nSteps]);
            
            % If conflict phase, randomize a reward (2, 4 or 6 points)
            if strcmp(trialType, 'conflict') 
            obj.pc = obj.pc.drawReward(targetTrialCount);
            obj.currentTrialPoints = obj.pc.reward; % Store for use in drawTrialScreen
            end
            
            % Store initial slider position
            initialPosition = obj.slider.currentPosition;

            % Get faces for this trial
            obj.neutralFaceTexture = obj.fc.getRandomFace('neutral');
            obj.angryFaceTexture = obj.fc.getRandomFace('angry');
            
            % Display fixation point
            function drawFixation()
                % Draw background
                Screen('FillRect', obj.window, grey);
                
                % Display fixation
                Screen('FillOval', obj.window, red, [obj.xCenter-5 obj.yCenter-5 obj.xCenter+5 obj.yCenter+5]);
                Screen('Flip', obj.window);
                WaitSecs(obj.fixationDur);
            end

            function drawTextBox(message)
                Screen('FillRect', obj.window, [80 80 80], obj.boxRect);
                Screen('FrameRect', obj.window, white, obj.boxRect, 2);
                DrawFormattedText(obj.window, message, 'center', 'center', white, [], [], [], [], [], obj.boxRect);
            end
            
            % Assemble graphical components of
            % the trial screen and display them
            function drawTrialScreen()
                % Draw background
                Screen('FillRect', obj.window, grey);
            
                % Display faces
                Screen('DrawTexture', obj.window, obj.neutralFaceTexture, [], obj.neutralFaceRect, 0);
                Screen('DrawTexture', obj.window, obj.angryFaceTexture, [], obj.angryFaceRect, 0);
            
                % Display information about points to win, if applicable
                if strcmp(trialType, 'conflict') == 1
                    % Get point reward for this trial
                    pts = eval('obj.currentTrialPoints');
                    pointsInfo = sprintf(obj.pointsText, pts);
                    drawTextBox(pointsInfo);  % This now only prepares the elements without flipping
                end
                
                % Draw the slider
                Screen('FillRect', obj.window, obj.slider.scaleColor, [obj.slider.axesRect, obj.slider.ticRects]);
                
                % Make ticks visible
                for j = 1:obj.slider.nSteps
                    Screen('FillRect', obj.window, [0.7, 0.7, 0.7], obj.slider.ticRects(:,j));
                end
                
                % Draw the avatar image if available
                if isfield(obj.slider, 'hasImage') && obj.slider.hasImage
                    % Enable alpha blending for transparency
                    Screen('BlendFunction', obj.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                    
                    % Center the image above the current tick position
                    currentTickX = obj.slider.ticRects(1, obj.slider.currentPosition) + obj.slider.lineWidth / 2;
                    
                    % Position 5px above the tick
                    avatarRect = CenterRectOnPoint(obj.slider.avatarRect, currentTickX, obj.slider.ticRects(2, obj.slider.currentPosition) - 5 - obj.slider.imageHeight/2);
                    
                    % Draw the image with transparency
                    Screen('DrawTexture', obj.window, obj.slider.avatarTexture, [], avatarRect, 0);
                end
                
                % Highlight current position
                Screen('FillRect', obj.window, obj.slider.activeColor, obj.slider.activeTicRects(:, obj.slider.currentPosition));
            
                for j = 1:obj.slider.nSteps
                    textRect = Screen('TextBounds', obj.window, obj.slider.labels{j});
                    Screen('DrawText', obj.window, obj.slider.labels{j}, ...
                        round(obj.slider.ticRects(1,j)-textRect(3)/2), ...
                        obj.slider.ticRects(4,j) + obj.slider.ticTextGap, white);
                end
            
                % Draw instruction text
                DrawFormattedText(obj.window, obj.sc.sliderStr, 'center', obj.sliderYOffset + 120, white);
                
                % Now flip the screen to show everything at once
                Screen('Flip', obj.window);
            end

            function finalizeDecision(wasTimeout)
                % Save final position
                obj.slider.finalPosition = obj.slider.currentPosition;
                
                % Store tick value
                tickValue = str2double(obj.slider.labels{obj.slider.finalPosition});
                obj.aversiveProbability = tickValue / 100;
                
                % Calculate reaction time
                if wasTimeout
                    % For timeouts, use the full decision window
                    reactionTime = obj.decisionWindow;
                else
                    % For user decisions, calculate the actual time taken
                    reactionTime = GetSecs() - startTime;
                end
                
                % Save decision with tick values
                newDecision = struct('type', trialType, ...
                                    'trialNo', currentTrialCount, ...
                                    'start', str2double(obj.slider.labels{initialPosition}), ...
                                    'end', tickValue, ...
                                    'pointsAwarded', 0, ...
                                    'reactionTime', reactionTime, ...
                                    'wasTimeout', wasTimeout);  % Also record if it was a timeout
                
                % Append to decisions array
                if isempty(decisionHistory)
                    decisionHistory = newDecision;
                else
                    decisionHistory(end+1) = newDecision; %#ok<AGROW>
                end
                
                % Set flag to exit the loop
                isDecisionMade = true;
            end
            
            % Display fixation point first
            drawFixation();
            
            % Then show the main trial screen
            drawTrialScreen()
            
            % Process key presses
            isDecisionMade = false;

            startTime = GetSecs();
            endTime = startTime + obj.decisionWindow;
    
            while ~isDecisionMade
                % Check if time has expired
                currentTime = GetSecs();
                if currentTime >= endTime
                    % Time expired - automatically finalize with current position
                    finalizeDecision(true);
                    break;
                end

                % Ignore mouse input
                [~, ~, ~] = GetMouse(obj.window);
                
                [keyIsDown, ~, keyCode] = KbCheck;
                
                if keyIsDown
                    if keyCode(kc.left)
                        % Move left
                        obj.slider.currentPosition = max(1, obj.slider.currentPosition - 1);
                        drawTrialScreen()
                        
                    elseif keyCode(kc.right)
                        % Move right
                        obj.slider.currentPosition = min(obj.slider.nSteps, obj.slider.currentPosition + 1);
                        drawTrialScreen()
                        
                    elseif keyCode(kc.enter)
                        finalizeDecision(false) % Save decision (not a timeout, but a subject decision)
                        
                    elseif keyCode(kc.escape)
                        % Early exit - perform thorough cleanup
                        fprintf('Trial interrupted by user pressing Escape key. Cleaning up...\n');
                        
                        obj.cleanUp(obj);

                        return
                    end
                    
                    % Wait for key release
                    while KbCheck; end
                end
            end
            
            % Display fixation point after decision
            drawFixation();

            % Display angry face based on probability, otherwise empty screen
                if rand() <= obj.aversiveProbability
                    % Aversive outcome displays
                    Screen('DrawTexture', obj.window, obj.aversiveTexture, [], obj.aversiveOutcomeRect, 0);
                    Screen('Flip', obj.window);
                    WaitSecs(obj.faceDur);
                    
                    % Award points only in conflict trials
                    if strcmp(trialType, 'conflict')
                        obj.score = obj.score + obj.pc.reward;
                        decisionHistory(end).pointsAwarded = obj.pc.reward;
                
                        switch obj.lang
                            case 'de'
                                pointsAnnouncement = 'Sie haben %d Punkte gewonnen! Aktuelle Punkte: %d + %d = %d';
                            case 'en'
                                pointsAnnouncement = 'You won %d points! Current score: %d + %d = %d';
                        end
                
                        message = sprintf(pointsAnnouncement, obj.pc.reward, (obj.score - obj.pc.reward), obj.pc.reward, obj.score);
                        
                        % Draw the entire feedback screen
                        Screen('FillRect', obj.window, grey);
                        drawTextBox(message);
                        Screen('Flip', obj.window);
                        WaitSecs(2);
                    end
                else
                    % No aversive outcome
                    Screen('FillRect', obj.window, grey);
                    Screen('Flip', obj.window);
                    WaitSecs(obj.faceDur);
                
                    if strcmp(trialType, 'conflict')
                        switch obj.lang
                            case 'de'
                                pointsAnnouncement = 'Sie haben keine Punkte gewonnen. Aktuelle Punkte: %d';
                            case 'en'
                                pointsAnnouncement = 'You did not win any points. Current score: %d';
                        end
                
                        message = sprintf(pointsAnnouncement, obj.score);
                        
                        % Draw the entire feedback screen
                        Screen('FillRect', obj.window, grey);
                        drawTextBox(message);
                        Screen('Flip', obj.window);
                        WaitSecs(2);
                    end
                end
            score = obj.score;
        end
    end
end