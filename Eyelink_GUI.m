function varargout = Eyelink_GUI
% Eyelink_GUI is the function that creates (or bring to focus) Eyelink_GUI.
% Then, Eyelink_main is always called to start each task. It is the
% "main" program.

% debug=1 closes previous figure and reopens it, and send the gui handles
% to base workspace.
debug = 0;


%% Open a singleton figure, or gring the actual into focus.

% Is the GUI already open ?
figPtr = findall(0,'Tag',mfilename);

if ~isempty(figPtr) % Figure exists so brings it to the focus
    
    figure(figPtr);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        close(figPtr); %#ok<UNRCH>
        Eyelink_GUI;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
else % Create the figure
    
    clc
    rng('default')
    rng('shuffle')
    
    % Create a figure
    figHandle = figure( ...
        'HandleVisibility', 'off',... % close all does not close the figure
        'MenuBar'         , 'none'                   , ...
        'Toolbar'         , 'none'                   , ...
        'Name'            , mfilename                , ...
        'NumberTitle'     , 'off'                    , ...
        'Units'           , 'Pixels'                 , ...
        'Position'        , [20, 20, 600, 300] , ...
        'Tag'             , mfilename                );
    
    figureBGcolor = [0.9 0.9 0.9]; set(figHandle,'Color',figureBGcolor);
    buttonBGcolor = figureBGcolor - 0.1;
    % editBGcolor   = [1.0 1.0 1.0];
    
    % Create GUI handles : pointers to access the graphic objects
    handles = guihandles(figHandle);
    
    
    %% Panel proportions
    
    panelProp.xposP = 0.05; % xposition of panel normalized : from 0 to 1
    panelProp.wP    = 1 - panelProp.xposP * 2;
    
    panelProp.vect  = ...
        [ 2 1 ]; % relative proportions of each panel, from bottom to top
    
    panelProp.vectLength    = length(panelProp.vect);
    panelProp.vectTotal     = sum(panelProp.vect);
    panelProp.adjustedTotal = panelProp.vectTotal + 1;
    panelProp.unitWidth     = 1/panelProp.adjustedTotal;
    panelProp.interWidth    = panelProp.unitWidth/panelProp.vectLength;
    
    panelProp.countP = panelProp.vectLength + 1;
    panelProp.yposP  = @(countP) panelProp.unitWidth*sum(panelProp.vect(1:countP-1)) + 0.80*countP*panelProp.interWidth;
    
    
    %% Dummy mode
    
    dummy_shift = 0.30;
    
    p_dummy.x = panelProp.xposP;
    p_dummy.w = dummy_shift*0.85;
    
    panelProp.countP = panelProp.countP - 1;
    p_dummy.y = panelProp.yposP(panelProp.countP);
    p_dummy.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_dummy = uibuttongroup(handles.(mfilename),...
        'Title','Dummy',...
        'Units', 'Normalized',...
        'Position',[p_dummy.x p_dummy.y p_dummy.w p_dummy.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn','');
    
    p_dummy.nbO    = 2; % Number of objects
    p_dummy.Ow     = 1/(p_dummy.nbO + 1); % Object width
    p_dummy.countO = 0; % Object counter
    p_dummy.xposO  = @(countO) p_dummy.Ow/(p_dummy.nbO+1)*countO + (countO-1)*p_dummy.Ow;
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Dummy OFF
    
    p_dummy.countO = p_dummy.countO + 1;
    r_eloff.x   = p_dummy.xposO(p_dummy.countO);
    r_eloff.y   = 0.10 ;
    r_eloff.w   = p_dummy.Ow;
    r_eloff.h   = 0.80;
    r_eloff.tag = 'radiobutton_DummyOff';
    handles.(r_eloff.tag) = uicontrol(handles.uipanel_dummy,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_eloff.x r_eloff.y r_eloff.w r_eloff.h],...
        'String','Off',...
        'HorizontalAlignment','Center',...
        'Tag',r_eloff.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    % ---------------------------------------------------------------------
    % RadioButton : Dummy ON
    
    p_dummy.countO = p_dummy.countO + 1;
    r_elon.x   = p_dummy.xposO(p_dummy.countO);
    r_elon.y   = 0.10 ;
    r_elon.w   = p_dummy.Ow;
    r_elon.h   = 0.80;
    r_elon.tag = 'radiobutton_DummyOn';
    handles.(r_elon.tag) = uicontrol(handles.uipanel_dummy,...
        'Style','radiobutton',...
        'Units', 'Normalized',...
        'Position',[r_elon.x r_elon.y r_elon.w r_elon.h],...
        'String','On',...
        'HorizontalAlignment','Center',...
        'Tag',r_elon.tag,...
        'BackgroundColor',figureBGcolor,...
        'Visible','On');
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    p_parport.x = panelProp.xposP + dummy_shift;
    p_parport.w = panelProp.wP - dummy_shift;
    
    p_parport.y = panelProp.yposP(panelProp.countP);
    p_parport.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_parport = uibuttongroup(handles.(mfilename),...
        'Title','Parallel port',...
        'Units', 'Normalized',...
        'Position',[p_parport.x p_parport.y p_parport.w p_parport.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_EyelinkMode_SelectionChangeFcn);
    
    
    
    p_parport.vect          = [ 1 3 ]; % Object relative widthn from left to right
    p_parport.vectLength    = length(p_parport.vect);
    p_parport.vectTotal     = sum(p_parport.vect);
    p_parport.adjustedTotal = p_parport.vectTotal + 1;
    p_parport.unitWidth     = 1/p_parport.adjustedTotal;
    p_parport.interWidth    = p_parport.unitWidth/p_parport.vectLength;
    
    p_parport.countO = p_parport.vectLength + 1;
    p_parport.xposO  = @(countP) p_parport.unitWidth*sum(p_parport.vect(1:countP-1)) + 0.8*countP*p_parport.interWidth;
    
    p_parport.countO = 0;
    
    buttun_y = 0.10;
    buttun_h = 0.85;
    
    
    % ---------------------------------------------------------------------
    % Checkbox : Parallel port
    
    p_parport.countO = p_parport.countO + 1;
    c_pp.x = p_parport.xposO(p_parport.countO);
    c_pp.y = buttun_y ;
    c_pp.w = p_parport.unitWidth*p_parport.vect(p_parport.countO);
    c_pp.h = buttun_h;
    handles.checkbox_ParPort = uicontrol(handles.uipanel_parport,...
        'Style','checkbox',...
        'Units', 'Normalized',...
        'Position',[c_pp.x c_pp.y c_pp.w c_pp.h],...
        'String','PP',...
        'HorizontalAlignment','Center',...
        'TooltipString','Send messages via parallel port : useful for Eyelink',...
        'BackgroundColor',figureBGcolor,...
        'Value',1,...
        'Callback',@checkbox_ParPort_Callback,...
        'ButtonDownFcn','edit GUI.Checkbox_ParPort_Callback');
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Initialize
    
    p_parport.countO = p_parport.countO + 1;
    b_sendtriggers.x = p_parport.xposO(p_parport.countO);
    b_sendtriggers.y = buttun_y ;
    b_sendtriggers.w = p_parport.unitWidth*p_parport.vect(p_parport.countO);
    b_sendtriggers.h = buttun_h;
    handles.pushbutton_SendTriggers = uicontrol(handles.uipanel_parport,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_sendtriggers.x b_sendtriggers.y b_sendtriggers.w b_sendtriggers.h],...
        'String','Send triggers from 0 to 255',...
        'BackgroundColor',buttonBGcolor,...
        'Callback',@pushbutton_SendTriggers_Callback,...
        'Visible','On');
    
    
    %% Panel : Commands
    
    command_shift = 0.30;
    
    p_command.x = panelProp.xposP + command_shift;
    p_command.w = panelProp.wP - command_shift ;
    
    panelProp.countP = panelProp.countP - 1;
    p_command.y = panelProp.yposP(panelProp.countP);
    p_command.h = panelProp.unitWidth*panelProp.vect(panelProp.countP);
    
    handles.uipanel_Commands = uibuttongroup(handles.(mfilename),...
        'Title','Functions',...
        'Units', 'Normalized',...
        'Position',[p_command.x p_command.y p_command.w p_command.h],...
        'BackgroundColor',figureBGcolor,...
        'SelectionChangeFcn',@uipanel_EyelinkMode_SelectionChangeFcn);
    
    
    % ---------------------------------------------------------------------
    % Listbox : Screens
    
    l_sc.x = panelProp.xposP;
    l_sc.w = command_shift - panelProp.xposP;
    
    l_sc.y = 0.10 ;
    l_sc.h = p_command.h * 0.8;
    
    handles.listbox_Screens = uicontrol(handles.(mfilename),...
        'Style','listbox',...
        'Units', 'Normalized',...
        'Position',[l_sc.x l_sc.y l_sc.w l_sc.h],...
        'String',{'a' 'b' 'c'},...
        'TooltipString','Select the display mode   PTB : 0 for extended display (over all screens) , 1 for screen 1 , 2 for screen 2 , etc.',...
        'HorizontalAlignment','Center',...
        'CreateFcn',@GUI.Listbox_Screens_CreateFcn,...
        'ButtonDownFcn','edit GUI.Listbox_Screens_CreateFcn');
    
    
    % ---------------------------------------------------------------------
    % Text : ScreenMode
    
    t_sm.x = panelProp.xposP;
    t_sm.w = command_shift - panelProp.xposP;
    
    t_sm.y = l_sc.y + l_sc.h ;
    t_sm.h = p_command.h * 0.15;
    
    handles.text_ScreenMode = uicontrol(handles.(mfilename),...
        'Style','text',...
        'Units', 'Normalized',...
        'Position',[t_sm.x t_sm.y t_sm.w t_sm.h],...
        'String','Screen mode selection',...
        'TooltipString','Output of Screen(''Screens'')   Use ''Screen Screens?'' in Command window for help',...
        'HorizontalAlignment','Center',...
        'BackgroundColor',figureBGcolor);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    p_command_up.nbO    = 2; % Number of objects
    p_command_up.Ow     = 1/(p_command_up.nbO + 1); % Object width
    p_command_up.countO = 0; % Object counter
    p_command_up.xposO  = @(countO) p_command_up.Ow/(p_command_up.nbO+1)*countO + (countO-1)*p_command_up.Ow;
    p_command_up.y      = 0.55;
    p_command_up.h      = 0.4;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Initialize
    
    p_command_up.countO = p_command_up.countO + 1;
    b_init.x = p_command_up.xposO(p_command_up.countO);
    b_init.y = p_command_up.y ;
    b_init.w = p_command_up.Ow;
    b_init.h = p_command_up.h;
    handles.pushbutton_Initialize = uicontrol(handles.uipanel_Commands,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_init.x b_init.y b_init.w b_init.h],...
        'String','Initialize',...
        'BackgroundColor',buttonBGcolor,...
        'Callback',@DispatcherForInitialize,...
        'ButtonDownFcn',@common_ButtonDownFcn);
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink IsConnected
    
    p_command_up.countO = p_command_up.countO + 1;
    b_isco.x = p_command_up.xposO(p_command_up.countO);
    b_isco.y = p_command_up.y ;
    b_isco.w = p_command_up.Ow;
    b_isco.h = p_command_up.h;
    handles.pushbutton_IsConnected = uicontrol(handles.uipanel_Commands,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_isco.x b_isco.y b_isco.w b_isco.h],...
        'String','IsConnected',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.IsConnected',...
        'ButtonDownFcn',@common_ButtonDownFcn);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    p_command_dw.nbO    = 2; % Number of objects
    p_command_dw.Ow     = 1/(p_command_dw.nbO + 1); % Object width
    p_command_dw.countO = 0; % Object counter
    p_command_dw.xposO  = @(countO) p_command_dw.Ow/(p_command_dw.nbO+1)*countO + (countO-1)*p_command_dw.Ow;
    p_command_dw.y      = 0.10;
    p_command_dw.h      = 0.4 ;
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink Calibration
    
    p_command_dw.countO = p_command_dw.countO + 1;
    b_cal.x   = p_command_dw.xposO(p_command_dw.countO);
    b_cal.y   = p_command_dw.y ;
    b_cal.w   = p_command_dw.Ow;
    b_cal.h   = p_command_dw.h;
    b_cal.tag = 'pushbutton_EyelinkCalibration';
    handles.(b_cal.tag) = uicontrol(handles.uipanel_Commands,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_cal.x b_cal.y b_cal.w b_cal.h],...
        'String','Calibration',...
        'BackgroundColor',buttonBGcolor,...
        'Tag',b_cal.tag,...
        'Callback',@pushbutton_Calibration_Callback,...
        'ButtonDownFcn',@common_ButtonDownFcn);
    
    
    % ---------------------------------------------------------------------
    % Pushbutton : Eyelink force shutdown
    
    p_command_dw.countO = p_command_dw.countO + 1;
    b_fsd.x = p_command_dw.xposO(p_command_dw.countO);
    b_fsd.y = p_command_dw.y ;
    b_fsd.w = p_command_dw.Ow;
    b_fsd.h = p_command_dw.h;
    handles.pushbutton_ForceShutDown = uicontrol(handles.uipanel_Commands,...
        'Style','pushbutton',...
        'Units', 'Normalized',...
        'Position',[b_fsd.x b_fsd.y b_fsd.w b_fsd.h],...
        'String','ForceShutDown',...
        'BackgroundColor',buttonBGcolor,...
        'Callback','Eyelink.ForceShutDown',...
        'ButtonDownFcn',@common_ButtonDownFcn);
    
    
    %% End of opening
    
    % IMPORTANT
    guidata(figHandle,handles)
    % After creating the figure, dont forget the line
    % guidata(figHandle,handles) . It allows smart retrive like
    % handles=guidata(hObject)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEBUG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if debug
        assignin('base','handles',handles) %#ok<UNRCH>
        disp(handles)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figPtr = figHandle;
    
    checkbox_ParPort_Callback(handles.checkbox_ParPort)
    
    ffprintf('Right click @ pushbutton => open script \n')
    
    
end

if nargout > 0
    
    varargout{1} = guidata(figPtr);
    
end


end % function


%% GUI Functions


% -------------------------------------------------------------------------
function DispatcherForInitialize(hObject, ~)
handles = guidata(hObject); % retrieve GUI data

switch get(get(handles.uipanel_dummy,'SelectedObject'),'Tag')
    
    case 'radiobutton_DummyOff'
        Eyelink.Initialize
    case 'radiobutton_DummyOn'
        Eyelink.InitializeDummy
    otherwise
        error('WTF ?')
end

end % function


% -------------------------------------------------------------------------
function pushbutton_Calibration_Callback(hObject, ~)
handles = guidata(hObject); % retrieve GUI data

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay = get(handles.listbox_Screens,'Value');
screenNumber = str2double(AvalableDisplays(SelectedDisplay));

Eyelink.OpenCalibration(screenNumber);

end % function


% -------------------------------------------------------------------------
function common_ButtonDownFcn(hObject, ~)

fcn = get(hObject, 'String');

edit( ['Eyelink.' fcn] )

end % function


% -------------------------------------------------------------------------
function checkbox_ParPort_Callback(hObject, ~)
handles = guidata(hObject);

GUI.Checkbox_ParPort_Callback(hObject);

switch get(hObject,'Value')
    case 0
        set(handles.pushbutton_SendTriggers,'Visible','off')
    case 1
        set(handles.pushbutton_SendTriggers,'Visible','on')
end

end % function

% -------------------------------------------------------------------------
function pushbutton_SendTriggers_Callback(~, ~)

% Init
OpenParPort
WriteParPort(0);

ffprintf('Sending triggers... \n')

duration = 0.003; % seconds

% Send the train of triggers
for n = 0:255
    WriteParPort(n);
    WaitSecs(duration);
    WriteParPort(0);
    WaitSecs(duration);
end

ffprintf('... done. \n')

% Close
CloseParPort

end % function
