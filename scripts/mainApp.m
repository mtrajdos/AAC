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
    
    % PTB window parameters
    [window, windowRect] = Screen('OpenWindow', screenNumber, grey);
    [xCenter, yCenter] = RectCenter(windowRect);
    [width, height] = Screen('WindowSize', window);
    
    % Get timing parameters (from FFP2Direct)
    FrameDurationInSeconds = Screen('GetFlipInterval', window);
    Slack = FrameDurationInSeconds * 0.5;
    
    % Set text properties
    Screen('TextFont', window, 'Arial');
    Screen('TextSize', window, 24);
    Screen('TextStyle', window, 1);  % Bold

%% Initialize experiment parameters

% Set language
lang = 'de';

% Set number of seconds that the subject will have in each trial
decisionTime = double(6.00000);

% Starting with baseline trial number 1, test until 18 baseline trials
currentBaselineTrials = 17;
targetBaselineTrials = 18;

% Starting with conflict trial number 1, test until 54 conflict trials
% targetConflictTrials needs to be divisible by 3 due to
% 3 different reward tiers
currentConflictTrials = 53;
targetConflictTrials = 54;

% Initialize array for subject decisions
decisionHistory = [];

% Initialize score receiver
score;

% Set point thresholds for rewards
bronze = 50;
silver = 81;
gold = 121;

% Run the experiment
try

    % Populate the current script variable
    currentScript = mfilename("fullpath");

    % Pointer for path with medal images
    medalsPath = fullfile(fileparts(fileparts(currentScript)), 'sprites', 'medals');

    % Create module instancess
    tc = trialController(lang, decisionTime, currentScript, window, windowRect, xCenter, yCenter, width, height);
    ic = instructionController(bronze, silver, gold, medalsPath, window, xCenter, height);
    kc = keyboardController();

    % Display instructions for baseline phase indexed as 0
    ic = ic.displayInstruction(white, lang, 0);
    
    % Wait for a spacebar press before continuing
    % Only allow Spacebar key to be detected
    RestrictKeysForKbCheck(kc.space);
    KbStrokeWait;
    RestrictKeysForKbCheck([]);  % Restore all keys

    ShowCursor;

    % Run baseline trials
    while currentBaselineTrials <= targetBaselineTrials

        % Run the trial
        decisionHistory = tc.runTrial(red, grey, white, kc, currentBaselineTrials, targetBaselineTrials, decisionHistory, 'baseline');
        
        % Check if this was the last trial
        if currentBaselineTrials == targetBaselineTrials
            % Overwrite the fixation with completion screen
            ic.displayCompletion(white, grey);
            break;
        end
        
        % Increment the counter for the next trial
        currentBaselineTrials = currentBaselineTrials + 1;
    end

    % Display subject decisions
    disp('Subject decisions after baseline phase: ');
    disp(struct2table(decisionHistory));

    % Display instructions for conflict phase indexed as 1
    ic = ic.displayInstruction(white, lang, 1);

    % Wait for a spacebar press before continuing
    % Only allow Spacebar key to be detected
    RestrictKeysForKbCheck(kc.space);
    KbStrokeWait;
    RestrictKeysForKbCheck([]);  % Restore all keys

    % Run conflict trials
    while currentConflictTrials <= targetConflictTrials

        % Run the trial
        [decisionHistory, score] = tc.runTrial(red, grey, white, kc, currentConflictTrials, targetConflictTrials, decisionHistory, 'conflict');
        
        % Check if this was the last trial
        if currentConflictTrials == targetConflictTrials
            % Overwrite the fixation with completion screen
            ic.displayCompletion(white, grey);
            break;
        end 
        
        % Increment the counter for the next trial
        currentConflictTrials = currentConflictTrials + 1;
    end

    % Display subject's score after conflict phase
    fprintf('[Score: %d]\nSubject decisions after conflict phase:\n', score);
    disp(struct2table(decisionHistory));

    % Display reward screen at the end of the experiment
    ic.displayReward(white, grey, score, lang);

    % Conclude the experiment
    Screen('FillRect', window, grey);

    switch lang
        case 'en'
        DrawFormattedText(window, 'Experiment finished. Closing the app...', 'center', 'center', white);
        case 'de'
        DrawFormattedText(window, 'Experiment beendet. App schließen...', 'center', 'center', white);
    end

    Screen('Flip', window);
    WaitSecs(2);

    % Clean up remaining textures
    tc.cleanUp();

    Screen('CloseAll');

catch error
    % Clean up in case of error
    Screen('CloseAll');
    ShowCursor;
    
    % Display error information
    rethrow(error);
end