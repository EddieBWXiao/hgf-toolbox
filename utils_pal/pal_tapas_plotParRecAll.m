function pal_tapas_plotParRecAll(sims, fitted, params, param_names, transforms)
% PAL_TAPAS_PLOTPARRECALL Creates a multi-panel figure with parameter recovery plots
% Written by Claude, checked by Bowen Xiao 2025
% Inputs:
%   sims - Cell array of simulated tapas structures
%   fitted - Cell array of fitted tapas structures 
%   params - Cell array of parameter path strings (e.g., {'p_obs.p(1)', 'p_prc.om(2)'})
%   param_names - (Optional) Cell array of parameter names to show on axes
%   transforms - (Optional) Cell array of function handles for parameter transformations
%
% Examples:
%   % Basic usage with 3 parameters, no transformations
%   pal_tapas_plotParRecAll(sims, fitted, ...
%       {'p_obs.p(1)', 'p_prc.om(2)', 'p_prc.om(3)'}, ...
%       {'\zeta', '\omega_2', '\omega_3'});
%
%   % With transformation for the first parameter
%   pal_tapas_plotParRecAll(sims, fitted, ...
%       {'p_obs.p(1)', 'p_prc.om(2)', 'p_prc.om(3)', 'p_obs.p(2)'}, ...
%       {'logspace \zeta', '\omega_2', '\omega_3', 'choice bias'}, ...
%       {@log, [], [], []});

numParams = length(params);

% Default values if not provided
if nargin < 4 || isempty(param_names)
    param_names = params; % Use parameter paths as titles
end

if nargin < 5 || isempty(transforms)
    transforms = cell(1, numParams); % No transformations by default
end

% Create figure if one doesn't exist
figure;


% Determine subplot layout (2x2 or 3x3 based on number of parameters)
if numParams <= 4
    rows = 2;
    cols = 2;
elseif numParams <= 9
    rows = 3;
    cols = 3;
else
    rows = ceil(sqrt(numParams));
    cols = ceil(numParams / rows);
end

% Create subplots for each parameter
for i = 1:numParams
    subplot(rows, cols, i);
    
    % Get the transformation for this parameter (or empty if none)
    transform = transforms{i};
    
    % Create the parameter recovery plot
    if isempty(transform)
        pal_tapas_plotParRec(sims, fitted, params{i}, param_names{i});
    else
        pal_tapas_plotParRec(sims, fitted, params{i}, param_names{i}, transform);
    end
    
end

% Set figure size (can be adjusted based on number of subplots)
if numParams <= 4
    set(gcf, 'Position', [450 296 519 476]);
end

end