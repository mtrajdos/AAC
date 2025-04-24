%% Initialize PTB and its parameters

    % Initialize Psychtoolbox
    PsychDefaultSetup(1); 
    
    % Set parameters
    screens = Screen('Screens');
    screenNumber = max(screens);
    
    % Configure Screen preferences as in FFP2Direct
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'ConserveVRAM', 64);
    
    % Define colors
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    grey = white / 2;
    midgray = round((white+black)/2);
    inc = white-midgray;
    
    % Open window
    [window, windowRect] = Screen('OpenWindow', screenNumber, grey);
    
    % Get timing parameters (from FFP2Direct)
    FrameDurationInSeconds = Screen('GetFlipInterval', window);
    Slack = FrameDurationInSeconds * 0.5;
    
    % Get screen dimensions
    [xCenter, yCenter] = RectCenter(windowRect);
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    
    % Set text properties
    if screenXpixels == 1024 && screenYpixels == 768
        textSize = 18;
    else
        textSize = 24;
    end
    Screen('TextFont', window, 'Courier New');
    Screen('TextSize', window, textSize);
    Screen('TextStyle', window, 1+2);  % Bold + Italic

    % Hide cursor and suppress keypresses to Matlab window
    HideCursor;


%% Initialize experiment parameters

lang = 'de';

n_baselineTrials = 18;
n_conflictTrials = 54;

angryFaces = dir(fullfile('../sprites/faces/angry', '*.jpg'));
neutralFaces = dir(fullfile('../sprites/faces/neutral', '*.jpg'));
decisionWindow = double(4.000000);

aversiveProbability = int32(0);
score = int32(0);

% Run the application

try
    % Create module instances
    ic = instructionController();

    % Display initial instruction
    ic.displayInstruction(window, white, lang, 0)
    
    % Wait for a key press before continuing
    KbStrokeWait;

    % Clean up
    Screen('CloseAll');
    ShowCursor;
    
catch error
    % Clean up in case of error
    Screen('CloseAll');
    ShowCursor;
    
    % Display error information
    rethrow(error);
end