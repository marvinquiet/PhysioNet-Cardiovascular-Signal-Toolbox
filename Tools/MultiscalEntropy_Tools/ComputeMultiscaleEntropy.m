function mse = ComputeMultiscaleEntropy(data, m, r, maxTau)

% mse = ComputeMultiscaleEntropy(data, m, r, max_tau, entropy_script)
%
% Overview
%	Calculates multiscale entropy on a vector of input data.
%
% Input
%	data        - data to analyze; vector of doubles
%   m           - pattern length; int
%   r           - radius of similarity (% of std); double
%   maxTau      - maximum number of coarse-grainings; int
%
% Output
%   mse          - vector of [max_tau, 1] doubles
%
% Example
%   data = rand(1e4, 1); % generate random data
%   m = 2; % template length
%   r = 0.2; % radius of similarity
%   maxTau = 4; % calculate sample entropy over four coarse grainings
%   mse = multiscaleEntropy(data, m, r, maxTau, entropyType);
% 
% Dependencies
%   https://github.com/cliffordlab/
%
% Reference(s)
% 
% Copyright (C) 2017 Erik Reinertsen <er@gatech.edu>
% All rights reserved.
%
% 
% 08-23-2017 Modyfied by Giulia Da Poian for the VOSIM HRV Toolbox 
% Removed the possibility to use different types of entropy, only
% fastSampen method in this version
%
% 10-10-2017 Modyfied by Giulia Da Poian, use FastSampEn in series < 34000
% otherwise use traditional SampEn that is faster for long series 
%
% This software may be modified and distributed under the terms
% of the BSD license. See the LICENSE file in this repo for details.


% Initialize output vector
mse = NaN(maxTau, 1);


% Check data length, if < 34000 use Fast Implementation (introduced GDP) 
SampEnType = 'Slow';

if length(data)<34000
    SampEnType = 'Fast'; 
end

% Loop through each timescale
% Note: i_tau == 1 is the original time series
for i_tau = 1:maxTau
        
    
    switch SampEnType
        case 'Fast'
           mse(i_tau) = fastSampen(data, m, r);
        otherwise
           mse(i_tau) = sampenMaxim(data, m, r); 
    end
    % Coarse-grain data (default: halving method)
    data = coarsegrain(data);
    
end % end for loop

end % end function
