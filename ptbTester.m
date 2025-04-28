% Basic text test with red background
try
    % Initialize
    PsychDefaultSetup(2);
    screens = Screen('Screens');
    screenNumber = max(screens);
    Screen('Preference', 'SkipSyncTests', 1);
    
    % Colors
    white = [255 255 255]; % Pure white in RGB
    
    % Open window with red background (so we know window is showing)
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, [255 0 0]);
    
    % Get dimensions
    [width, height] = Screen('WindowSize', window);
    
    % Set text parameters - very large text
    Screen('TextSize', window, 100); % Very large font
    Screen('TextFont', window, 'Arial');
    Screen('TextStyle', window, 1); % Bold
    
    % Draw text
    DrawFormattedText(window, 'TEST TEXT', 'center', 'center', white);
    Screen('Flip', window);
    
    % Wait for keypress to continue
    fprintf('Red screen with white text should be visible now. Press any key to exit.\n');
    KbStrokeWait;
    
    % Clean up
    Screen('CloseAll');
    
catch error
    Screen('CloseAll');
    rethrow(error);
end