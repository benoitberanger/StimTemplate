function ClearEmptySamples( self )

if self.SampleCount == 0
    self.Data = [];
    return
end

self.Data(self.SampleCount+1:end,:) = [];

end % function
