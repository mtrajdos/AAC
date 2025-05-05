classdef pointController
    properties
        lowRewardCount = 0;
        midRewardCount = 0;
        highRewardCount = 0;
        totalPoints = 0;
        pointsToWin = 0;
    end
    
    methods
        function obj = drawReward(obj)
            % Check if all reward conditions have reached 19
            if obj.lowRewardCount >= 19 && obj.midRewardCount >= 19 && obj.highRewardCount >= 19
                obj.pointsToWin = NaN;
                return;
            end
            
            % Keep trying until we find a valid reward
            while true
                % Randomly select a reward (1=Low, 2=Mid, 3=High)
                rewardType = randi(3);
                
                % Check if the selected reward type is still available
                if (rewardType == 1 && obj.lowRewardCount < 19) || ...
                   (rewardType == 2 && obj.midRewardCount < 19) || ...
                   (rewardType == 3 && obj.highRewardCount < 19)
                    
                    % Assign reward based on type
                    switch rewardType
                        case 1
                            obj.pointsToWin = 2;
                            obj.lowRewardCount = obj.lowRewardCount + 1;
                        case 2
                            obj.pointsToWin = 4;
                            obj.midRewardCount = obj.midRewardCount + 1;
                        case 3
                            obj.pointsToWin = 6;
                            obj.highRewardCount = obj.highRewardCount + 1;
                    end
                    break;
                end
            end
        end

        function pointsToWinString = getPointsToWinText(obj)
            pointsToWinString = string(obj.pointsToWin);
        end
    end
end