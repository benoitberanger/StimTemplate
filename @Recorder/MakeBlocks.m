function MakeBlocks( self )
% self.MakeBlocks()
%
% Transform self.Data Events into Block
% IMPORTANT : do NOT applay self.ComputeDurations, you need to
% fill the duration column manually

% Find the blocks
[ ~ , ~ , indC ] = unique_stable( self.Data(:,1) );

% Where do they start ?
blockStart = vertcat( -1 , diff(indC) );
for b = 1 : length(blockStart)
    if b > 1
        if self.Data{b-1,2} + self.Data{b-1,3} < self.Data{b,2} - self.Data{b-1,3} % if huge gap between two events with the same name
            blockStart(b) = 1; % add a start block
        end
        
    end
end
blockStart_idx = find(blockStart);

% Create a cell, equivalent of self.Data, but for the blocks
blockData = cell(length(blockStart_idx),size(self.Data,2));
for b = 1 : length(blockStart_idx)
    
    % Copy line
    blockData(b,:) = self.Data(blockStart_idx(b),:);
    
    % Change the duration : block duration
    if b ~= length(blockStart_idx)
        blockData{b,3} = sum( cell2mat( self.Data( blockStart_idx(b) : blockStart_idx(b+1)-1 , 3 ) ) );
    end
    
end

% Store
self.BlockData = blockData;

end % function
