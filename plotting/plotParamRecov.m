function plotParamRecov(sims, ests, params_loc, param_names)

numParams = length(params_loc);

% Default values if not provided
if nargin < 4 || isempty(param_names)
    param_names = param_loc; % Use parameter paths as titles
end

% Create figure if one doesn't exist
figure;

% Determine subplot layout (2x2 or 3x3 based on number of parameters)
if numParams == 1
    rows = 1;
    cols = 1;
elseif numParams <= 4
    rows = 2;
    cols = 2;
elseif numParams <= 9
    rows = 3;
    cols = 3;
else
    rows = ceil(sqrt(numParams));
    cols = ceil(numParams / rows);
end

% create subplots for each parameter
for i = 1:numParams
    subplot(rows, cols, i);
    plot_single_param_recov(sims, ests, params_loc{i}, param_names{i});
end

end
function plot_single_param_recov(sims, ests, param_loc, param_name)

sim_param = get_tapas_field(sims, param_loc);
est_param = get_tapas_field(ests, param_loc);
plotScatRefCorr(sim_param, est_param);
xlabel(sprintf('Simulated %s',param_name))
ylabel(sprintf('Recovered %s', param_name))

end