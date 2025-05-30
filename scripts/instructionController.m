classdef instructionController
    properties
        % Medal thresholds
        bronzeThreshold;
        silverThreshold;
        goldThreshold;

        % PTB window properties
        window;
        xCenter;
        height;

        % Instruction text
        instrStr = [''];

        % Completion text
        complStr = [''];

        % Reward text;
        rewardStr = [''];

        % How many characters in each line until wrapping a new one
        textWrapping = 120;

        % Vertical spacing (distance between text lines)
        vSpacing = 1.2;

        % Pointers for medal images
        medals;
        
        % Storage for medal textures and data
        medalTextures = {};
        medalImageData = {};
        medalAlpha = {};
    end
    
    methods
        function obj = instructionController(bronze, silver, gold, medalsPath, window, xCenter, height)
            obj.bronzeThreshold = bronze;
            obj.silverThreshold = silver;
            obj.goldThreshold = gold;
            obj.medals = {
                fullfile(medalsPath, 'bronze.png'), ... 
                fullfile(medalsPath, 'silver.png'), ...
                fullfile(medalsPath, 'gold.png'),
            };
            
            % Initialize arrays for storing medal data
            obj.medalTextures = cell(1, 3);
            obj.medalImageData = cell(1, 3);
            obj.medalAlpha = cell(1, 3);

            % Set PTB window properties in the instance
            obj.window = window;
            obj.xCenter = xCenter;
            obj.height = height;

        end

        function obj = displayInstruction(obj, white, lang, instrIndex)
            % Dynamic top padding calculation
            topPadding = obj.height * 0.3;
            
            % Get instruction text based on language and instruction index
            switch instrIndex
                case 0
                switch lang
                    case 'de'
                        obj.instrStr = ['In der folgenden Aufgabe werden Sie auf jedem Bildschirm ein neutrales Gesicht auf der linken Seite ' ...
                        'und ein wütendes Gesicht auf der rechten Seite sehen. ' ...
                        'Ein Markierungspunkt wird zufällig auf einer Linie zwischen diesen Gesichtern platziert. ' ...
                        'Sie haben 6 Sekunden Zeit, diesen Markierungspunkt zu bewegen. Je näher Sie ' ...
                        'den Punkt am wütenden Gesicht platzieren, ' ...
                        'desto höher ist die Wahrscheinlichkeit, dass ein unangenehmes Bild ' ...
                        '(ein schreiendes Gesicht) erscheint. ' ...
                        'Wenn kein unangenehmes Bild erscheint, sehen Sie einen leeren Bildschirm.' ...
                        'Wenn Sie bereit sind, drücken Sie bitte die Leertaste, um mit der Aufgabe zu beginnen.'];
                        obj.complStr = 'Erste Phase abgeschlossen!';
                    case 'en'
                        obj.instrStr = ['In the following task, you will see a neutral face on the left side of each screen and an angry face ' ...
                        'on the right side.  ' ...
                        'A marker point will be randomly placed on a line between these faces.  ' ...
                        'You have 6 seconds to move this marker point. The closer you place the point to the angry face,  ' ...
                        'the higher the probability that an unpleasant image (a screaming face) will appear.  ' ...
                        'If no unpleasant image appears, you will see a blank screen.' ...
                        '    ' ...
                        'When you are ready, please press the spacebar to begin the task.'];
                        obj.complStr = 'First phase complete!';
                 end
                    
                    DrawFormattedText(obj.window, obj.instrStr, 'center', 'center', white, obj.textWrapping, [], [], obj.vSpacing);
                    
                case 1
                switch lang
                    case 'de'
                    obj.instrStr = ['Bei dieser Aufgabe können Sie Punkte sammeln. ' ...
                    'In jedem Durchgang sehen Sie ein neutrales Gesicht links und ein wütendes Gesicht rechts. ' ...
                    'Ein Marker erscheint auf einer Linie zwischen diesen Gesichtern. ' ...
                    'Sie haben 6 Sekunden Zeit, um die Position anzupassen. ' ...
                    'Je näher am wütenden Gesicht, desto höher die Wahrscheinlichkeit, ein unangenehmes Bild zu sehen. ' ...
                    'Wenn das unangenehme Bild erscheint, erhalten Sie je nach Phase 2, 4 oder 6 Punkte. ' ...
                    'Wenn kein unangenehmes Bild erscheint, werden keine Punkte vergeben. ' ... 
                    'Vor jeder Phase werden Sie über die möglichen Punkte informiert.' ...
                    '\n\nMedaillen-Punkteschwellen: ' ...
                    'Bronze: 50-80 Punkte,' ...
                    ' Silber: 81-120 Punkte,' ...
                    ' Gold: 121+ Punkte' ...
                    '\n\nDrücken Sie die Leertaste, wenn Sie bereit sind.'];
                    
                    medalLabels = {
                        sprintf('Bronze: %d-%d', obj.bronzeThreshold, obj.silverThreshold-1),
                        sprintf('Silber: %d-%d', obj.silverThreshold, obj.goldThreshold-1),
                        sprintf('Gold: %d+', obj.goldThreshold)
                    };

                    obj.complStr = 'Zweite Phase abgeschlossen!';
                    case 'en'
                    obj.instrStr = ['In this task, you can earn points. ' ...
                    'Each trial shows a neutral face on the left and an angry face on the right. ' ...
                    'A marker appears on a line between these faces. ' ...
                    'You have 6 seconds to adjust its position. ' ...
                    'The closer to the angry face, the higher the chance of seeing an unpleasant image. ' ...
                    'If the unpleasant image appears, you earn 2, 4, or 6 points depending on the stage. ' ...
                    'If no unpleasant image appears, no points are awarded. ' ...
                    'You will be informed about possible points before each phase.' ...
                    '\n\nMedal point thresholds: ' ...
                    'Bronze: 50-80 points,' ...
                    ' Silver: 81-120 points,' ...
                    ' Gold: 121+ points' ...
                    '\n\nPress the spacebar when ready.'];
                    
                    medalLabels = {
                        sprintf('Bronze: %d-%d', obj.bronzeThreshold, obj.silverThreshold-1),
                        sprintf('Silver: %d-%d', obj.silverThreshold, obj.goldThreshold-1),
                        sprintf('Gold: %d+', obj.goldThreshold)
                    };

                    obj.complStr = 'Second phase complete!';
                end

                    DrawFormattedText(obj.window, obj.instrStr, 'center', topPadding, white, obj.textWrapping, [], [], obj.vSpacing);

                    % Display medal images for conflict phase
                    obj = displayMedals(obj, white, medalLabels);

                otherwise
                    error('Input index "%d" is invalid', instrIndex);
            end
            
            % Flip the screen to show the instructions
            Screen('Flip', obj.window);
            
            % Nested function to display medals (only used in conflict phase)
            function obj = displayMedals(obj, white, medalLabels)
                
                % Define medal display parameters
                medalScale = 0.8;  % Scaling factor for medal size
                medalSpacing = 200;  % Horizontal spacing between medals
                medalY = obj.height * 0.72;  % Vertical position for medals
                
                % Calculate horizontal positions (centered trio of medals)
                medalX = [obj.xCenter - medalSpacing, obj.xCenter, obj.xCenter + medalSpacing];
                
                % Load and display each medal
                for i = 1:3
                    % Load the medal image with alpha channel
                    try
                        % Check if file exists
                        if ~exist(obj.medals{i}, 'file')
                            warning('Medal image file not found: %s', obj.medals{i});
                            continue;
                        end
                        
                        % Load the image with alpha channel
                        [imageData, ~, alpha] = imread(obj.medals{i});
                        
                        % Store the image data
                        obj.medalImageData{i} = imageData;
                        obj.medalAlpha{i} = alpha;
                        
                        % Get image dimensions
                        [imageHeight, imageWidth, ~] = size(imageData);
                        
                        % Scale dimensions
                        scaledWidth = round(imageWidth * medalScale);
                        scaledHeight = round(imageHeight * medalScale);
                        
                        % Add alpha channel to image data
                        imageRGBA = zeros(imageHeight, imageWidth, 4, 'uint8');
                        imageRGBA(:,:,1:3) = imageData;
                        imageRGBA(:,:,4) = alpha;
                        
                        % Create medal texture with alpha blending enabled
                        medalTexture = Screen('MakeTexture', obj.window, imageRGBA);
                        
                        % Store the medal texture
                        obj.medalTextures{i} = medalTexture;
                        
                        % Create destination rectangle centered on the medal position
                        destRect = CenterRectOnPoint([0, 0, scaledWidth, scaledHeight], medalX(i), medalY);
                        
                        % Enable alpha blending for transparency
                        Screen('BlendFunction', obj.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                        
                        % Draw the medal
                        Screen('DrawTexture', obj.window, medalTexture, [], destRect, 0);
                        
                        % Draw label under the medal
                        labelY = medalY + scaledHeight/2 + 30;  % Position below medal
                        DrawFormattedText(obj.window, medalLabels{i}, 'center', labelY, white, [], [], [], [], [], [medalX(i)-medalSpacing/2 0 medalX(i)+medalSpacing/2 obj.height]);
                        
                    catch error
                        rethrow(error);
                    end
                end
            end
        end

        function displayCompletion(obj, white, grey)
                WaitSecs(0.5);
                Screen('FillRect', obj.window, grey);
                DrawFormattedText(obj.window, obj.complStr, 'center', 'center', white);
                Screen('Flip', obj.window);
                WaitSecs(2);
        end

        function displayReward(obj, white, grey, score, lang)

                WaitSecs(0.5);
                Screen('FillRect', obj.window, grey);

                switch lang
                    case 'de'
                        if score < obj.bronzeThreshold
                            obj.rewardStr = sprintf('Leider haben Sie keine Medaille gewonnen. Ihre Punktzahl: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', 'center', white);
                        elseif score >= obj.bronzeThreshold && score < obj.silverThreshold
                            obj.rewardStr = sprintf('Herzlichen Glückwunsch! Sie haben die Bronzemedaille gewonnen! Ihre Punktzahl: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', obj.height * 0.3, white);
                            
                            % Display bronze medal
                            displayMedalImage(1);

                        elseif score >= obj.silverThreshold && score < obj.goldThreshold
                            obj.rewardStr = sprintf('Herzlichen Glückwunsch! Sie haben die Silbermedaille gewonnen! Ihre Punktzahl: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', obj.height * 0.3, white);
                            
                            % Display silver medal
                            displayMedalImage(2);

                        else % score >= obj.goldThreshold
                            obj.rewardStr = sprintf('Herzlichen Glückwunsch! Sie haben die Goldmedaille gewonnen! Ihre Punktzahl: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', obj.height * 0.3, white);
                            
                            % Display gold medal
                            displayMedalImage(3);
                        end
                        
                    case 'en'
                        if score < obj.bronzeThreshold
                            obj.rewardStr = sprintf('Unfortunately, you did not win a medal. Your score: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', 'center', white);
                        elseif score >= obj.bronzeThreshold && score < obj.silverThreshold
                            obj.rewardStr = sprintf('Congratulations! You won the Bronze medal! Your score: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', obj.height * 0.3, white);
                            
                            % Display bronze medal
                            displayMedalImage(1);
                        elseif score >= obj.silverThreshold && score < obj.goldThreshold
                            obj.rewardStr = sprintf('Congratulations! You won the Silver medal! Your score: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', obj.height * 0.3, white);
                            
                            % Display silver medal
                            displayMedalImage(2);
                        else % score >= obj.goldThreshold
                            obj.rewardStr = sprintf('Congratulations! You won the Gold medal! Your score: %d', score);
                            DrawFormattedText(obj.window, obj.rewardStr, 'center', obj.height * 0.3, white);
                            
                            % Display gold medal
                            displayMedalImage(3);
                        end
                end
                
                Screen('Flip', obj.window);
                WaitSecs(7);
                
                % Nested function to display medal image
                function displayMedalImage(medalIndex)
                    % Check if we already have the medal texture loaded
                    if ~isempty(obj.medalTextures{medalIndex})
                        % Get image dimensions
                        [imageHeight, imageWidth, ~] = size(obj.medalImageData{medalIndex});
                        
                        % Scale dimensions - larger for the reward display
                        medalScale = 1.2;
                        scaledWidth = round(imageWidth * medalScale);
                        scaledHeight = round(imageHeight * medalScale);
                        
                        % Create destination rectangle centered on screen
                        destRect = CenterRectOnPoint([0, 0, scaledWidth, scaledHeight], obj.xCenter, obj.height * 0.6);
                        
                        % Enable alpha blending for transparency
                        Screen('BlendFunction', obj.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                        
                        % Draw the medal
                        Screen('DrawTexture', obj.window, obj.medalTextures{medalIndex}, [], destRect, 0);
                    else
                        % If texture isn't available, load it from file
                        try
                            if exist(obj.medals{medalIndex}, 'file')
                                [imageData, ~, alpha] = imread(obj.medals{medalIndex});
                                
                                % Get image dimensions
                                [imageHeight, imageWidth, ~] = size(imageData);
                                
                                % Scale dimensions
                                medalScale = 1.2;  % Larger scale for reward display
                                scaledWidth = round(imageWidth * medalScale);
                                scaledHeight = round(imageHeight * medalScale);
                                
                                % Add alpha channel to image data
                                imageRGBA = zeros(imageHeight, imageWidth, 4, 'uint8');
                                imageRGBA(:,:,1:3) = imageData;
                                imageRGBA(:,:,4) = alpha;
                                
                                % Create medal texture with alpha blending enabled
                                medalTexture = Screen('MakeTexture', obj.window, imageRGBA);
                                
                                % Create destination rectangle centered on the medal position
                                destRect = CenterRectOnPoint([0, 0, scaledWidth, scaledHeight], obj.xCenter, obj.height * 0.6);
                                
                                % Enable alpha blending for transparency
                                Screen('BlendFunction', obj.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                                
                                % Draw the medal
                                Screen('DrawTexture', obj.window, medalTexture, [], destRect, 0);
                                
                                % Clean up texture after drawing
                                Screen('Close', medalTexture);
                            end
                        catch error
                            warning('Could not display medal image: %s', error);
                        end
                    end
                end
        end
    end
end