function ComputePulseSpacing( self , graph )
% self.ComputePulseSpacing() no plot, or self.ComputePulseSpacing(1) to plot
%
% Compute time between each "KeyIsDown", then plot it if asked

if ~exist('graph','var')
    graph = 0;
end

for k = 1 : size(self.KbEvents,1)
    
    if ~isempty(self.KbEvents{k,2})
        
        if isempty(self.KbEvents{k,2}{end,end})
            self.KbEvents{k,2}{end,end} = 0;
        end
        
        data = cell2mat(self.KbEvents{k,2});
        
        KeyIsDown_idx = data(:,2) == 1;
        KeyIsDown_onset = data(KeyIsDown_idx,1);
        KeyIsDown_spacing = diff(KeyIsDown_onset);
        
        fprintf('N = %d \n',length(KeyIsDown_onset));
        fprintf('mean = %f ms \n',mean(KeyIsDown_spacing)*1000);
        fprintf('std = %f ms \n',std(KeyIsDown_spacing)*1000);
        
        if graph
            
            figure( ...
                'Name'        , [mfilename ' : ' self.KbEvents{k,1} ] , ...
                'NumberTitle' , 'off'                                      )
            
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
