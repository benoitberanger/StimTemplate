sca
clear
clc

%% Setup

screenNumber = 1;

Colors = [
    0 0 0 % black
    127 127 127 % grey
    255 255 255 % white
    255 0 0 % red
    0 255 0 % green
    0 0 255 % blue
    ];


%% Open screen

Screen('Preference','VisualDebugLevel',1);

[windowPtr, windowRect] = Screen('OpenWindow', screenNumber,[0 0 0]);


%% Coords

% Screen('DrawLines', windowPtr, xy [,width] [,colors] [,center] [,smooth][,lenient]);

% Diagonal

l1 = [windowRect(1) windowRect(3) ; windowRect(2) windowRect(4)];
l2 = [windowRect(3) windowRect(1) ; windowRect(2) windowRect(4)];


% Horizontal

nHlines = windowRect(4)/2^6;
Hlines = zeros(2,2*nHlines+1);
for lineH = 1 : nHlines+1
    
    Hlines(1,2*lineH-1) = windowRect(1);
    Hlines(2,2*lineH-1) = (windowRect(4)/nHlines)*(lineH-1);
    Hlines(1,2*lineH  ) = windowRect(3);
    Hlines(2,2*lineH  ) = (windowRect(4)/nHlines)*(lineH-1);
    
end

Hlines(2,end-1) = Hlines(2,end-1) - 1;
Hlines(2,end)   = Hlines(2,end  ) - 1;


% Vertical

nVlines = windowRect(3)/2^6;
Vlines = zeros(2,2*nVlines+1);
for lineV = 1 : nVlines+1
    
    Vlines(1,2*lineV-1) = (windowRect(3)/nVlines)*(lineV-1);
    Vlines(2,2*lineV-1) = windowRect(2);
    Vlines(1,2*lineV  ) = (windowRect(3)/nVlines)*(lineV-1);
    Vlines(2,2*lineV  ) = windowRect(4);
    
end

Vlines(1,1) = Vlines(1,1) + 1;
Vlines(1,2) = Vlines(1,2) + 1;


%% Colors (+ Keyboard)

KbName('UnifyKeyNames')

nextLine = KbName('RightArrow');
prevLine = KbName('LeftArrow');

nextBG = KbName('UpArrow');
prevBG = KbName('DownArrow');

plusThick  = KbName('+');
minusThick = KbName('-');

escape   = KbName('Escape');

lineColors = Colors;
bgColors = Colors;


%% Draw

% Init
thickness = 1;
HideCursor
lineColors = circshift(lineColors,1,1);

% Draw white first
Screen('DrawLines', windowPtr, l1 , 1 , lineColors(1,:));
Screen('DrawLines', windowPtr, l2 , 1 , lineColors(1,:));
Screen('DrawLines', windowPtr, Hlines , 1 , lineColors(1,:));
Screen('DrawLines', windowPtr, Vlines , 1 , lineColors(1,:));
Screen('Flip', windowPtr);

while 1
    
    [keyIsDown, ~, keyCode] = KbCheck;
    
    if keyIsDown
        
        if keyCode(escape)
            sca
            break
            
        elseif  keyCode(nextLine)
            lineColors = circshift(lineColors,1,1);
        elseif keyCode(prevLine)
            lineColors = circshift(lineColors,-1,1);
            
        elseif  keyCode(nextBG)
            bgColors = circshift(bgColors,1,1);
        elseif  keyCode(prevBG)
            bgColors = circshift(bgColors,-1,1);
            
        elseif keyCode(plusThick)
            thickness = thickness + 1;
            if thickness > 10
                thickness = 10;
            end
        elseif keyCode(minusThick)
            thickness = thickness - 1;
            if thickness < 1
                thickness = 1;
            end
        end
        
        Screen('FillRect' , windowPtr, bgColors(1,:));
        
        Screen('DrawLines', windowPtr, l1     , thickness , lineColors(1,:));
        Screen('DrawLines', windowPtr, l2     , thickness , lineColors(1,:));
        Screen('DrawLines', windowPtr, Hlines , thickness , lineColors(1,:));
        Screen('DrawLines', windowPtr, Vlines , thickness , lineColors(1,:));
        
        Screen('Flip'     , windowPtr);
        
        WaitSecs(0.200); % don't want epilepsy
        
        
    end
    
end % while
