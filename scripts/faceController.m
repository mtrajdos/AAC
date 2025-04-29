classdef faceController
    properties
        angryFaces = []; % Will store texture pointers for angry faces
        neutralFaces = []; % Will store texture pointers for neutral faces
    end
    
    methods

            % Empty constructor
        function obj = faceController()
        end

        function obj = loadFaces(obj, window, angryFacesPath, neutralFacesPath)
            % Load angry faces
            numAngryFaces = length(angryFacesPath);
            obj.angryFaces = zeros(numAngryFaces, 1);
            
            for i = 1:numAngryFaces
                % Full path to the image file
                fileName = fullfile(angryFacesPath(i).folder, angryFacesPath(i).name);
                % Read the image
                img = imread(fileName);
                % Make texture and store the pointer
                obj.angryFaces(i) = Screen('MakeTexture', window, img);
                fprintf('Loaded angry face %d/%d: %s\n', i, numAngryFaces, angryFacesPath(i).name);
            end
            
            % Load neutral faces with similar logic
            numNeutralFaces = length(neutralFacesPath);
            obj.neutralFaces = zeros(numNeutralFaces, 1);
            
            for i = 1:numNeutralFaces
                fileName = fullfile(neutralFacesPath(i).folder, neutralFacesPath(i).name);
                img = imread(fileName);
                if size(img, 3) == 1 && ~islogical(img)
                    if ismatrix(img)
                        img = repmat(img, [1 1 3]);
                    end
                end
                obj.neutralFaces(i) = Screen('MakeTexture', window, img);
                fprintf('Loaded neutral face %d/%d: %s\n', i, numNeutralFaces, neutralFacesPath(i).name);
            end
            
            fprintf('Successfully preloaded %d angry faces and %d neutral faces into memory\n', ...
                numAngryFaces, numNeutralFaces);
        end
        
        function texture = getRandomFace(obj, faceType)
            switch faceType
                case 'angry'
                    if ~isempty(obj.angryFaces)
                        idx = randi(length(obj.angryFaces));
                        texture = obj.angryFaces(idx);
                    else
                        error('No angry faces have been loaded.');
                    end
                case 'neutral'
                    if ~isempty(obj.neutralFaces)
                        idx = randi(length(obj.neutralFaces));
                        texture = obj.neutralFaces(idx);
                    else
                        error('No neutral faces have been loaded.');
                    end
            end
        end

        function [width, height] = getImageSize(obj, texture)
            rect = Screen('Rect', texture);
            width = rect(3) - rect(1);
            height = rect(4) - rect(2);
        end

    end
end