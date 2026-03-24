function r = pal_tapas_simFromConfig(inputs, prc_input, prc_pvec, varargin)
% like tapas_simModel, but can use config struct and not a string to specify the model
% should be "backward compatible" (same usage as tapas_simModel possible)
% allows other customised things in config, such as predorpost, to be inherited
%
% The model identifier is critical for tapas:
% e.g., "tapas_hgf_binary" or "tapas_unitsq_sgm"
% add suffixes to it to find all the functions that define this model
% Some functions may not have config, in which case the string will work
% Some functions have config, but the "model" field might be different from this identifier
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2018 Christoph Mathys, TNU, UZH & ETHZ
% Modified by Bowen Xiao 2026 from tapas_simModel
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Check if inputs look like column vectors
if size(inputs,1) <= size(inputs,2)
    disp(' ')
    disp('Warning: ensure that input sequences are COLUMN vectors.')
end

% Initialize data structure to be returned
r = struct;

% Store inputs
r.u  = inputs;

% Determine ignored trials
ign = [];
for k = 1:size(r.u,1)
    if isnan(r.u(k,1))
        ign = [ign, k];
    end
end

r.ign = ign;

if isempty(ign)
    ignout = 'none';
else
    ignout = ign;
end
disp(['Ignored trials: ', num2str(ignout)])

% parse input: struct for full config or string for model name
if isstruct(prc_input)
    prc_config = prc_input;
    prc_config_provided = true;

    % get the model identifier from the config contents
    prc_identifier = func2str(prc_config.prc_fun);
else
    prc_config = [];
    prc_config_provided = false;

    % get the model identifier, which IS the user input
    prc_identifier = prc_input; % the name may not be the true identifier
end

% Remember perceptual model
r.c_sim.prc_model = prc_identifier;

% Store perceptual parameters
prc_namep_fun = str2func([prc_identifier, '_namep']);
r.p_prc   = prc_namep_fun(prc_pvec);
r.p_prc.p = prc_pvec;

% Store the config
if prc_config_provided
    % Instead of "Read configuration of perceptual model", just store it
    r.c_prc = prc_config;
else
    % When using a string of the model's name
    try
        prc_config_fun = str2func([prc_identifier, '_config']);
        r.c_prc = prc_config_fun();
    catch
        r.c_prc = [];
    end
end

% Get function handle to perceptual model
prc_fun = str2func(prc_identifier); %if c_prc exists, should be same as "r.c_prc.prc_fun;"

% Compute perceptual states
[r.traj, infStates] = prc_fun(r, r.p_prc.p);

% Check inferred states for NaN values (due to numerical problems when taking log)
if contains(prc_identifier,'hgf') && contains(prc_identifier,'binary')
    r.traj.muhat(r.ign,:) = []; % weed out ignored trials
    if any(any(isnan(r.traj.muhat)))
        error('tapas:hgf:VarApproxInvalid',...
            'NaNs in infStates (muhat). Probably due to numerical problems when taking logarithms close to 1.');
    end
    r.traj.sahat(r.ign,:) = []; % weed out ignored trials
    if any(any(isnan(r.traj.sahat)))
        error('tapas:hgf:VarApproxInvalid',...
            'NaNs in infStates (muhat). Probably due to numerical problems when taking logarithms close to 1.');
    end
end

%% obs model
if nargin > 4
    
    % parse input: struct for full config or string for model name
    obs_input = varargin{1};
    if isstruct(obs_input)
        obs_config = obs_input;
        obs_config_provided = true;
        
        % get the model identifier from the config contents
        obs_identifier = func2str(obs_config.obs_fun);
    else
        obs_config = [];
        obs_config_provided = false;
        
        % get the model identifier, which IS the user input
        obs_identifier = obs_input; % the name may not be the true identifier
    end
    
    % Remember observation model
    r.c_sim.obs_model = obs_identifier;
    
    % Store observation parameters
    obs_pvec = varargin{2};
    obs_namep_fun = str2func([obs_identifier, '_namep']);
    r.p_obs   = obs_namep_fun(obs_pvec);
    r.p_obs.p = obs_pvec;
    
    % Store the config
    if obs_config_provided
        r.c_obs = obs_config;
    else
        try
            obs_config_fun = str2func([obs_identifier, '_config']);
            r.c_obs = obs_config_fun();
        catch
            r.c_obs = [];
        end
    end
    
    % Set seed for random number generator
    r.c_sim.seed = NaN;
    if nargin > 5
        r.c_sim.seed = varargin{3};
    end
    
    % Get function handle to observation model
    obs_fun = str2func([obs_identifier, '_sim']);
    
    % Simulate decisions
    try
        % different response streams
        [r.y, r.yhat] = obs_fun(r, infStates, r.p_obs.p);
    catch
        % single response stream
        r.y = obs_fun(r, infStates, r.p_obs.p);
    end
    
end


end