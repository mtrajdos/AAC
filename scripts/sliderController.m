classdef sliderController
    methods (Static)
        function slider = loadSlider(window, windowRect)
            % Create a basic slider structure based on aw_likertScaleNew20241113
            slider = struct();
            % Store window info
            slider.window = window;
            slider.windowRect = windowRect;
            slider.nSteps = 7;
            % Labels based on the image (numbers 20-80)
            slider.labels = {'20', '30', '40', '50', '60', '70', '80'};
            % Set random initial position between 1 and 7
            slider.defaultPosition = randi([1, 7]);
            slider.currentPosition = slider.defaultPosition;
            slider.finalPosition = NaN;
            % Appearance settings
            slider.scaleWidth = round(windowRect(3)/1.2);
            slider.textSize = 20;
            slider.lineWidth = 5;
            slider.tickHeight = 20;
            slider.scaleColor = [255, 255, 255];
            slider.activeColor = [0, 255, 0];
            slider.ticTextGap = 3;
            % Calculate slider screen elements
            activeAddon = 3;
            [xCenter, yCenter] = RectCenter(windowRect);
            slider.axesRect = [xCenter - slider.scaleWidth/2; yCenter - slider.lineWidth; xCenter + slider.scaleWidth/2; yCenter];
            slider.ticPositions = linspace(xCenter - slider.scaleWidth/2, xCenter + slider.scaleWidth/2-slider.lineWidth, slider.nSteps);
            slider.ticRects = [slider.ticPositions; ones(1, slider.nSteps)*yCenter; slider.ticPositions + slider.lineWidth; ones(1, slider.nSteps)*yCenter+slider.tickHeight];
            slider.activeTicRects = [slider.ticPositions-activeAddon; ones(1, slider.nSteps)*yCenter-activeAddon; slider.ticPositions + slider.lineWidth+activeAddon; ones(1, slider.nSteps)*yCenter+slider.tickHeight+activeAddon];
            
            % Load the manekin image
            try
                % Use fullfile to create proper file path
                imageFile = fullfile('.', 'sprites', 'Manekin.png');
                
                % Check if file exists
                if ~exist(imageFile, 'file')
                    warning('Image file not found: %s', imageFile);
                    slider.hasImage = false;
                else
                    % Load the image with alpha channel
                    [imageData, ~, alpha] = imread(imageFile);
                    
                    % Get image dimensions
                    [imageHeight, imageWidth, ~] = size(imageData);
                    
                    % Add alpha channel to image data
                    imageRGBA = zeros(imageHeight, imageWidth, 4, 'uint8');
                    imageRGBA(:,:,1:3) = imageData;
                    imageRGBA(:,:,4) = alpha;
                    
                    % Create texture with alpha blending enabled
                    slider.imageTexture = Screen('MakeTexture', window, imageRGBA);
                    
                    % Store image information
                    slider.hasImage = true;
                    slider.imageWidth = imageWidth;
                    slider.imageHeight = imageHeight;
                    
                    % Calculate position (centered horizontally above the slider ticks)
                    slider.imageRect = [0, 0, imageWidth, imageHeight];
                end
            catch e
                warning('Failed to load image: %s', e.message);
                slider.hasImage = false;
            end
        end
    end
end