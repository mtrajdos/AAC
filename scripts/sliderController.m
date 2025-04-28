classdef sliderController
    properties
    % Initialize parameters
    end
    
    methods (Static)
        function slider = loadSlider(window, windowRect)
            % Create a basic slider structure based on aw_likertScaleNew20241113
            slider = struct();
            
            % Store window info
            slider.window = window;
            slider.windowRect = windowRect;
            
            % Set to 7 steps as shown in the image
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
            
            % Use KbName for key mappings - PTB compatible
            KbName('UnifyKeyNames');
            slider.lessKey = KbName('LeftArrow');
            slider.moreKey = KbName('RightArrow');
            slider.confirmKey = KbName('space');
            slider.escapeKey = KbName('ESCAPE');
            
            % Calculate slider screen elements exactly like in the original script
            activeAddon = 3;
            [xCenter, yCenter] = RectCenter(windowRect);
            slider.axesRect = [xCenter - slider.scaleWidth/2; yCenter - slider.lineWidth; xCenter + slider.scaleWidth/2; yCenter];
            slider.ticPositions = linspace(xCenter - slider.scaleWidth/2, xCenter + slider.scaleWidth/2-slider.lineWidth, slider.nSteps);
            slider.ticRects = [slider.ticPositions; ones(1, slider.nSteps)*yCenter; slider.ticPositions + slider.lineWidth; ones(1, slider.nSteps)*yCenter+slider.tickHeight];
            slider.activeTicRects = [slider.ticPositions-activeAddon; ones(1, slider.nSteps)*yCenter-activeAddon; slider.ticPositions + slider.lineWidth+activeAddon; ones(1, slider.nSteps)*yCenter+slider.tickHeight+activeAddon];
            
            % Include center coordinates for drawing text
            slider.xCenter = xCenter;
            slider.yCenter = yCenter;
            
            % Add info text field
            slider.infoTextSize = 30; 
            slider.infoTextYoffset = 100;
        end
    end
end