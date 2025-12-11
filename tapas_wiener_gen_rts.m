function y = tapas_wiener_gen_rts(alpha, tau, beta, delta, opts)
% Generative model for (four-parameter) drift-diffusion models
% called by various _sim functions relating to ddm
% 
% Returns:
% y: column vector; col1 = 0 or 1 for choice; col2 = reaction time in seconds
% note that 0 is the lower boundary
% 
% Inputs:
% - alpha: boundary separation (>0)
% - tau: non-decision time (>0; unit in seconds)
% - beta: bias ("starting point"); bound between 0-1
% - delta: drift rate (any real number; can be negative)
% - opts: struct to specify timestep (precision-related) and max time limit
%
% Usage:
% - One or all of the alpha, tau, beta, delta inputs can be column vectors
% - Allows constant params mixed with trial-by-trial params
% - Size of y determined by longest column vector
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao University of Cambridge
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

%% parse input & conduct checks

% unpack settings, with defaults
if ~exist('opts', 'var')
    opts = struct();
end
if ~isfield(opts, 'dt')
    % default timestep size in simulation (1ms)
    dt = 0.001;
else
    dt = opts.dt;
end
if ~isfield(opts, 'max_t')
    % maximum time (will cut off here!)
    max_t = 10;
else
    max_t = opts.max_t;
end

% handle the possibility of vector inputs
params = {alpha(:), tau(:), beta(:), delta(:)}; % force col vec here
par_lens = cellfun(@numel, params);
n_trials = max(par_lens);
if any(par_lens ~= 1 & par_lens ~= n_trials)
    error('All vector parameters must have the same length');
end
for i = 1:4
    if numel(params{i}) == 1
        params{i} = repmat(params{i}, n_trials, 1);
    end
end
[alpha, tau, beta, delta] = params{:};

%% model
% preallocate output
rt = nan(n_trials, 1);
choice = nan(n_trials, 1);

% convert starting point to absolute
z_absolute = beta.*alpha;

% loop through trials
for i = 1:n_trials

    % start at initial
    x = z_absolute(i);

    % time counter (add non-decision time later)
    drift_time = 0;

    % run until a boundary is reached or max time exceeded
    while (x > 0 && x < alpha(i) && drift_time < max_t)
        % accumulated evidence; with noise ~N(0, 1) scaled with size of timestep
        x = x + delta(i)*dt + sqrt(dt)*randn();
        
        % keep track of the time
        drift_time = drift_time + dt;
    end
    
    % record reaction time
    rt(i) = drift_time + tau(i);  % add non-decision time

    % generate choice by looking at which boundary was hit
    if x >= alpha(i)
        choice(i) = 1;  % hit upper boundary
    elseif x <= 0
        choice(i) = 0;  % hit lower boundary
    else
        % if max time was reached, randomly assign a boundary
        choice(i) = round(rand());
        rt(i) = max_t + tau(i);
    end
    
end

% output format: always choice (0 and 1) first
y = [choice, rt];

end