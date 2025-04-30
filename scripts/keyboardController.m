classdef keyboardController
    properties
        enter
        left
        right
        escape
        space
    end
    methods
        function obj = keyboardController()
            KbName('UnifyKeyNames');
            obj.enter = KbName('Return');
            obj.left = KbName('LeftArrow');
            obj.right = KbName('RightArrow');
            obj.escape = KbName('Escape');
            obj.space = KbName('Space');
        end
    end
end