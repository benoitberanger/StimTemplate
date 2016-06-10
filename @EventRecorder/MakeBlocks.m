function MakeBlocks( obj )
% obj.MakeBlocks()
%
% Transform obj.Data Events into Block
% IMPORTANT : do NOT applay obj.ComputeDurations, you need to
% fill the duration column manually

% Find the blocks
[ ~ , ~ , indC ] = unique_stable( obj.Data(:,1) );

% Where do they start ?
blockStart = vertcat( -1 , diff(indC) );
for b = 1 : length(blockStart)
    if b > 1
        if obj.Data{b-1,2} + obj.Data{b-1,3} < obj.Data{b,2} - obj.Data{b-1,3} % if huge gap between two events with the same name
            blockStart(b) = 1; % add a start block
        end
        
    end
end
blockStart_idx = find(blockStart);

% Create a cell, equivalent of obj.Data, but for the blocks
blockData = cell(length(blockStart_idx),size(obj.Data,2));
for b = 1 : length(blockStart_idx)
    
    % Copy line
    blockData(b,:) = obj.Data(blockStart_idx(b),:);
    
    % Change the duration : block duration
    if b ~= length(blockStart_idx)
        blockData{b,3} = sum( cell2mat( obj.Data( blockStart_idx(b) : blockStart_idx(b+1)-1 , 3 ) ) );
    end
    
end

% Store
obj.BlockData = blockData;

end
