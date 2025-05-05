%% Initialize PTB and its parameters

    % Initialize Psychtoolbox
    PsychDefaultSetup(1); 
    
    % Set parameters
    screens = Screen('Screens');
    screenNumber = min(screens) + 1;
    
    % Configure Screen preferences as in FFP2Direct
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'ConserveVRAM', 64);
    
    % Define colors
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);
    red = [255 0 0];
    grey = [110 110 110]; % Match the background of face images
    midgray = round((white+black)/2);
    inc = white-midgray;
    
    % Open window
    [window, windowRect] = Screen('OpenWindow', screenNumber, grey);
    
    % Get timing parameters (from FFP2Direct)
    FrameDurationInSeconds = Screen('GetFlipInterval', window);
    Slack = FrameDurationInSeconds * 0.5;
    
    % Get screen dimensions
    [xCenter, yCenter] = RectCenter(windowRect);
    
    % Set text properties
    textSize = 24;

    Screen('TextFont', window, 'Arial');
    Screen('TextSize', window, textSize);
    Screen('TextStyle', window, 1);  % Bold + Italic

    % Hide cursor and suppress keypresses to Matlab window
    ShowCursor;


%% Initialize experiment parameters

lang = 'de';

currentBaselineTrials = 1;
targetBaselineTrials = 18;

currentConflictTrials = 1;
targetConflictTrials = 54;

angryFacesPath = dir(fullfile('./sprites/faces/angry', '*.jpg'));
neutralFacesPath = dir(fullfile('./sprites/faces/neutral', '*.jpg'));

decisionWindow = double(4.000000);
decisionHistory = [];

score = int32(0);

% Run the application

try
    % Create module instances and preload faces
    fc = faceController();
    fc = fc.loadFaces(window, angryFacesPath, neutralFacesPath);
    tc = trialController();
    ic = instructionController();
    kc = keyboardController();

    % Debug
    fprintf('Found %d angry face images\n', length(angryFacesPath));
    fprintf('Found %d neutral face images\n', length(neutralFacesPath));

    if ~isempty(angryFacesPath)
        fprintf('First angry face path: %s\n', fullfile(angryFacesPath(1).folder, angryFacesPath(1).name));
    end
    
    if ~isempty(neutralFacesPath)
        fprintf('First neutral face path: %s\n', fullfile(neutralFacesPath(1).folder, neutralFacesPath(1).name));
    end

    % Display instructions for baseline phase indexed as 0
    ic.displayInstruction(window  , white, lang, 0)
    
    % Wait for a spacebar press before continuing
    % Only allow Spacebar key to be detected
    RestrictKeysForKbCheck(kc.space);
    KbStrokeWait;
    RestrictKeysForKbCheck([]);  % Restore all keys

    % Run baseline trials
    while currentBaselineTrials <= targetBaselineTrials

        % Run the trial
        decisionHistory = tc.runTrial(window, windowRect, red, grey, white, fc, kc, currentBaselineTrials, decisionHistory, lang, 'baseline');
        
        % Check if this was the last trial
        if currentBaselineTrials == targetBaselineTrials
            % Overwrite the fixation with completion screen
            ic.displayCompletion(window, white, grey, 0)
            break;
        end
        
        % Increment the counter for the next trial
        currentBaselineTrials = currentBaselineTrials + 1;
    end

    disp('Subject decisions after baseline phase: ');
    disp(struct2table(decisionHistory));

    % Display instructions for conflict phase indexed as 1
    ic.displayInstruction(window, white, lang, 1)

    % Wait for a spacebar press before continuing
    % Only allow Spacebar key to be detected
    RestrictKeysForKbCheck(kc.space);
    KbStrokeWait;
    RestrictKeysForKbCheck([]);  % Restore all keys

    % Run baseline trials
    while currentConflictTrials <= targetConflictTrials

        % Run the trial
        [decisionHistory, score] = tc.runTrial(window, windowRect, red, grey, white, fc, kc, currentConflictTrials, decisionHistory, lang, 'conflict');
        
        % Check if this was the last trial
        if currentConflictTrials == targetConflictTrials
            % Overwrite the fixation with completion screen
            ic.displayCompletion(window, white, grey, 1)
            break;
        end
        
        % Increment the counter for the next trial
        currentConflictTrials = currentConflictTrials + 1;
    end

    fprintf('Subject decisions after conflict phase with %d points:', score);
    disp(struct2table(decisionHistory));

    % Display conslusive message at the end of the experiment
    ic.displayCompletion(window, white, grey, 2);

    Screen('CloseAll');

catch error
    % Clean up in case of error
    Screen('CloseAll');
    ShowCursor;
    
    % Display error information
    rethrow(error);
end