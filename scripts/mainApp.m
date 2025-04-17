% Set up PTB path
addpath(genpath('C:\Users\michal\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\Psychtoolbox-3-3.0.19.15\'))

% Initialize Psychtoolbox
PsychDefaultSetup(2);

% Set parameters
screens = Screen('Screens');
% screenNumber = max(screens);
screenNumber = 1

% Configure Screen preferences as found in the FFP2Scenes script
Screen('Preference', 'SkipSyncTests', 0);
Screen('Preference', 'SyncTestSettings', 0.001, [], [], []);
Screen('Preference', 'VisualDebugLevel', 0);

% Get color definitions
white = WhiteIndex(screenNumber);

% Open window with specific parameters (color depth and buffer count)
[window, windowRect] = Screen('OpenWindow', screenNumber, 0, [], 32, 2);

% Create instance
app = aac();

% Run phases
app.displayInstruction(window, white, "baseline");

% Clean up
WaitSecs(2);
Screen('CloseAll');