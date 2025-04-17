classdef aac
    properties
        % Initialize parameters
        totalScore = 0;
        trialCount = 0;
        phases = ["baseline", "experimental"];
        medals = struct('bronze', 50, 'silver', 75, 'gold', 100);
    end
    
    methods
        function displayInstruction(obj, window, white, phase)
            if any(strcmp(phase, obj.phases))
                if strcmp(phase, "baseline")
                    Screen('TextSize', window, 20);
                    Screen('TextFont', window, 'Arial');
                    DrawFormattedText(window, 'Baseline Instruction', 'center', 'center', white);
                elseif strcmp(phase, "experimental")
                    Screen('TextSize', window, 20);
                    Screen('TextFont', window, 'Arial');
                    DrawFormattedText(window, 'Experimental Instruction', 'center', 'center', white);
                end
            else
                error('Input phase "%s" is invalid - needs to be either baseline or experimental', phase);
            end
        end
    end
end