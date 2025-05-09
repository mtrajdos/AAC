classdef pointController
    properties
        lowRewardCount = 1;
        midRewardCount = 1;
        highRewardCount = 1;
        reward = int32(0);
    end
    
    methods
        function obj = drawReward(obj, targetConflictTrials)
            % Check if reward tiers are evenly distributed
            oneThirdOfNumberConflictTrials = targetConflictTrials / 3;
            if obj.lowRewardCount > oneThirdOfNumberConflictTrials && ... 
                obj.midRewardCount > oneThirdOfNumberConflictTrials && ... 
                obj.highRewardCount > oneThirdOfNumberConflictTrials
                obj.reward = NaN;
                return;
            end
            
            % Keep trying until we find a valid reward
            while true
                % Randomly select a reward (1=Low, 2=Mid, 3=High)
                rewardType = randi(3);
                
                % Check if the selected reward type is still available
                if (rewardType == 1 && obj.lowRewardCount <= oneThirdOfNumberConflictTrials) || ...
                   (rewardType == 2 && obj.midRewardCount <= oneThirdOfNumberConflictTrials) || ...
                   (rewardType == 3 && obj.highRewardCount <= oneThirdOfNumberConflictTrials)
                    
                    % Assign reward based on type
                    switch rewardType
                        case 1
                            obj.reward = 2;
                            obj.lowRewardCount = obj.lowRewardCount + 1;
                        case 2
                            obj.reward = 4;
                            obj.midRewardCount = obj.midRewardCount + 1;
                        case 3
                            obj.reward = 6;
                            obj.highRewardCount = obj.highRewardCount + 1;
                    end
                    break;
                end
            end
        end

        function pointsToWinString = getPointsToWinText(obj)
            pointsToWinString = string(obj.reward);
        end
    end
end