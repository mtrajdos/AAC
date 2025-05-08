classdef instructionController
    properties
        % Medal thresholds
        bronzeThreshold;
        silverThreshold;
        goldThreshold;

        % Instruction text
        instrStr = [''];

        % Text settings
        textSize = 25;

        % How many characters in each line until wrapping a new one
        textWrapping = 120;

        % Vertical spacing (distance between text lines)
        vSpacing = 1.1;

        % Text style (1 for bold in PTB TextSize Screen call)
        textStyle = 1;

        % Font
        textFont = 'Arial';
    end
    
    methods (Static)

        function obj = instructionController(bronze, silver, gold)
            obj.bronzeThreshold = bronze;
            obj.silverThreshold = silver;
            obj.goldThreshold = gold;
        end

        function displayInstruction(obj, window, white, lang, instrIndex)
            % Get screen dimensions and center coordinates
            windowRect = Screen('Rect', window);
            [width, height] = Screen('WindowSize', window);
            [xCenter, yCenter] = RectCenter(windowRect);
            
            Screen('TextSize', window, obj.textSize);
            Screen('TextStyle', window, obj.textStyle);
            Screen('TextFont', window, obj.textFont);
            
            % Get instruction text based on language and instruction index
            switch instrIndex
                case 0
                    % Baseline phase instructions
                    if strcmp(lang, 'de')
                        obj.instrStr = ['In der folgenden Aufgabe werden Sie auf jedem Bildschirm ein neutrales Gesicht auf der linken Seite ' ...
                        'und ein wütendes Gesicht auf der rechten Seite sehen. ' ...
                        'Ein Markierungspunkt wird zufällig auf einer Linie zwischen diesen Gesichtern platziert. ' ...
                        'Sie haben 6 Sekunden Zeit, diesen Markierungspunkt zu bewegen. Je näher Sie ' ...
                        'den Punkt am wütenden Gesicht platzieren, ' ...
                        'desto höher ist die Wahrscheinlichkeit, dass ein unangenehmes Bild ' ...
                        '(ein schreiendes Gesicht) erscheint. ' ...
                        'Wenn kein unangenehmes Bild erscheint, sehen Sie einen leeren Bildschirm.' ...
                        'Wenn Sie bereit sind, drücken Sie bitte die Leertaste, um mit der Aufgabe zu beginnen.'];
                    else
                        obj.instrStr = ['In the following task, you will see a neutral face on the left side of each screen and an angry face ' ...
                        'on the right side.  ' ...
                        'A marker point will be randomly placed on a line between these faces.  ' ...
                        'You have 6 seconds to move this marker point. The closer you place the point to the angry face,  ' ...
                        'the higher the probability that an unpleasant image (a screaming face) will appear.  ' ...
                        'If no unpleasant image appears, you will see a blank screen.' ...
                        '    ' ...
                        'When you are ready, please press the spacebar to begin the task.'];
                    end
                    
                    % Center the text and use wrapat to define the width
                    DrawFormattedText(window, obj.instrStr, 'center', 'center', white, obj.textWrapping, [], [], obj.vSpacing);
                    
                case 1
                if strcmp(lang, 'de')
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
                else
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
                end

                    DrawFormattedText(window, obj.instrStr, 'center', (height * 0.3), white, obj.textWrapping, [], [], obj.vSpacing);
                    
                    % Display medal images for conflict phase
                    displayMedals(window, white, medalLabels, xCenter, height);
                    
                otherwise
                    error('Input index "%d" is invalid', instrIndex);
            end
            
            % Flip the screen to show the instructions
            Screen('Flip', window);
            
            % Nested function to display medals (only used in conflict phase)
            function displayMedals(window, white, medalLabels, xCenter, height)
                % Define medal image paths
                medalPaths = {
                    fullfile('.', 'sprites', 'medals', 'bronze.png'),
                    fullfile('.', 'sprites', 'medals', 'silver.png'),
                    fullfile('.', 'sprites', 'medals', 'gold.png')
                };
                
                % Define medal display parameters
                medalScale = 0.8;  % Scaling factor for medal size
                medalSpacing = 200;  % Horizontal spacing between medals
                medalY = height * 0.72;  % Vertical position for medals
                
                % Calculate horizontal positions (centered trio of medals)
                medalX = [
                    xCenter - medalSpacing,
                    xCenter,
                    xCenter + medalSpacing
                ];
                
                % Load and display each medal
                for i = 1:3
                    % Load the medal image with alpha channel
                    try
                        % Check if file exists
                        if ~exist(medalPaths{i}, 'file')
                            warning('Medal image file not found: %s', medalPaths{i});
                            continue;
                        end
                        
                        % Load the image with alpha channel
                        [imageData, ~, alpha] = imread(medalPaths{i});
                        
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
                        medalTexture = Screen('MakeTexture', window, imageRGBA);
                        
                        % Create destination rectangle centered on the medal position
                        destRect = CenterRectOnPoint([0, 0, scaledWidth, scaledHeight], medalX(i), medalY);
                        
                        % Enable alpha blending for transparency
                        Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                        
                        % Draw the medal
                        Screen('DrawTexture', window, medalTexture, [], destRect, 0);
                        
                        % Clean up texture
                        Screen('Close', medalTexture);
                        
                        % Set text size for medal labels
                        Screen('TextSize', window, 22);
                        
                        % Draw label under the medal
                        labelY = medalY + scaledHeight/2 + 30;  % Position below medal
                        DrawFormattedText(window, medalLabels{i}, 'center', labelY, white, [], [], [], [], [], [medalX(i)-medalSpacing/2 0 medalX(i)+medalSpacing/2 height]);
                        
                    catch error
                        rethrow(error);
                    end
                end
            end
        end

        function displayCompletion(window, white, grey, instrIndex)
            if instrIndex == 0
                WaitSecs(0.5)
                Screen('FillRect', window, grey);
                DrawFormattedText(window, 'Baseline phase complete!', 'center', 'center', white);
                Screen('Flip', window);
                WaitSecs(2);
            elseif instrIndex == 1
                WaitSecs(0.5)
                Screen('FillRect', window, grey);
                DrawFormattedText(window, 'Conflict phase complete!', 'center', 'center', white);
                Screen('Flip', window);
                WaitSecs(2);
            else
                WaitSecs(0.5)
                Screen('FillRect', window, grey);
                DrawFormattedText(window, 'Experiment finished. Closing the app...', 'center', 'center', white);
                Screen('Flip', window);
                WaitSecs(2);
            end
        end
    end
end