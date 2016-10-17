function ComputePulseSpacing( obj )
% obj.ComputePulseSpacing()
%
% Compute time between each "KeyIsDown", then plot it

for k = 1 : size(obj.KbEvents,1)
    
    if ~isempty(obj.KbEvents{k,2})
        
        if isempty(obj.KbEvents{k,2}{end,end})
            obj.KbEvents{k,2}{end,end} = 0;
        end
        
        data = cell2mat(obj.KbEvents{k,2});
        
        KeyIsDown_idx = data(:,2) == 1;
        KeyIsDown_onset = data(KeyIsDown_idx,1);
        KeyIsDown_spacing = diff(KeyIsDown_onset);
        
        figure( ...
            'Name'        , [mfilename ' : ' obj.KbEvents{k,1} ] , ...
            'NumberTitle' , 'off'                       , ...
            'Units'       , 'Normalized'                , ...
            'Position'    , [0.05, 0.05, 0.90, 0.80]      ...
            )
        
        subplot(2,2,[1 2])
        plot(KeyIsDown_spacing)
        
        subplot(2,2,3)
        hist(KeyIsDown_spacing)
        
        subplot(2,2,4)
        boxplot(KeyIsDown_spacing)
        grid on
        
    end
    
end

end % function
