function ComputePulseSpacing( obj , graph )
% obj.ComputePulseSpacing() no plot, or obj.ComputePulseSpacing(1) to plot
%
% Compute time between each "KeyIsDown", then plot it if asked

if ~exist('graph','var')
    graph = 0;
end

for k = 1 : size(obj.KbEvents,1)
    
    if ~isempty(obj.KbEvents{k,2})
        
        if isempty(obj.KbEvents{k,2}{end,end})
            obj.KbEvents{k,2}{end,end} = 0;
        end
        
        data = cell2mat(obj.KbEvents{k,2});
        
        KeyIsDown_idx = data(:,2) == 1;
        KeyIsDown_onset = data(KeyIsDown_idx,1);
        KeyIsDown_spacing = diff(KeyIsDown_onset);
        
        fprintf('N = %d \n',length(KeyIsDown_onset));
        fprintf('mean = %f ms \n',mean(KeyIsDown_spacing)*1000);
        fprintf('std = %f ms \n',std(KeyIsDown_spacing)*1000);
        
        if graph
            
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
            
            if ~isempty(which('boxplot'))
                subplot(2,2,4)
                boxplot(KeyIsDown_spacing)
                grid on
            end
            
        end
        
    end
    
end

end % function
