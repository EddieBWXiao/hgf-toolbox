function [fitted_corr, sim_corr] = pal_tapas_plotParIdentifia(sims, fitted, corr_type, which_plot, params, param_names, transforms)
% Bowen Xiao 2025 in collab with Claude
% Inputs:
%   sims - Cell array of simulated tapas structures
%   fitted - Cell array of fitted tapas structures 
%   corr_type - Type of correlation ('Pearson', 'Spearman', etc.)
%   which_plot - String specifying what to plot:
%                'scat_recov' - Scatter plot of fitted parameters
%                'scat_sim' - Scatter plot of simulated parameters  
%                'corr_recov' - Correlation matrix of fitted parameters
%                'corr_sim' - Correlation matrix of simulated parameters
%   params - Cell array of parameter path strings (e.g., {'p_obs.p(1)', 'p_prc.om(2)'})
%   param_names - (Optional) Cell array of parameter names to show on axes
%   transforms - (Optional) Cell array of function handles for parameter transformations
    % PLEASE NOTE THAT THE TRANSFORMS PART HAS NOT BEEN TESTED MUCH!!!
    
numParams = length(params);

% Switch-case logic to control plotting behavior
switch lower(which_plot)
    case 'scat_recov'
        do_scat = true;
        do_corr_matrix = false;
        use_fitted = true;
        plot_title_suffix = 'Recovered';
        
    case 'scat_sim'
        do_scat = true;
        do_corr_matrix = false;
        use_fitted = false;
        plot_title_suffix = 'Simulated';
        
    case 'corr_recov'
        do_scat = false;
        do_corr_matrix = true;
        use_fitted = true;
        plot_title_suffix = 'Recovered';
        
    case 'corr_sim'
        do_scat = false;
        do_corr_matrix = true;
        use_fitted = false;
        plot_title_suffix = 'Simulated';
        
    otherwise
        error('Invalid which_plot option. Use: scat_recov, scat_sim, corr_recov, or corr_sim');
end
 
% Default values if not provided
if nargin < 6 || isempty(param_names)
    param_names = params; % Use parameter paths as titles
end
 
if nargin < 7 || isempty(transforms)
    % Create identity transforms (no transformation)
    transforms = cell(1, numParams);
    for k = 1:numParams
        transforms{k} = @(x) x;
    end
    the_title_prefix = 'Parameters in Native Space';
else
    % Fill in missing transforms with identity function
    for k = 1:numParams
        if k > length(transforms) || isempty(transforms{k})
            transforms{k} = @(x) x;
        end
    end
    the_title_prefix = 'Transformed Parameters';
end
 
sim_corr = nan(numParams);
fitted_corr = nan(numParams);

% Create scatter plot if requested
if do_scat
    figure;
    for i = 1:numParams
        % Get parameter values for current parameter
        if use_fitted
            param_i = pal_tapas_getProp(fitted, params{i});
        else
            param_i = pal_tapas_getProp(sims, params{i});
        end
        
        % Apply transform
        param_i = transforms{i}(param_i);
        
        for j = 1:numParams
            % Get parameter values for comparison parameter
            if use_fitted
                param_j = pal_tapas_getProp(fitted, params{j});
            else
                param_j = pal_tapas_getProp(sims, params{j});
            end
            
            % Apply transform
            param_j = transforms{j}(param_j);
            
            % Create subplot and plot
            subplot_index = (i-1) * numParams + j;
            subplot(numParams, numParams, subplot_index)
            plot(param_i, param_j, '.')
            xlabel(param_names{i})
            ylabel(param_names{j})
        end
    end
    
    sgtitle(sprintf('%s, %s', the_title_prefix, plot_title_suffix))
    set(gcf,'Position',[270 45 960 753])
end

% Calculate correlations for both fitted and simulated (always computed for output)
for i = 1:numParams
    % Get fitted parameter values for current parameter
    fitted_param_i = pal_tapas_getProp(fitted, params{i});
    % Get simulated parameter values for current parameter
    sim_param_i = pal_tapas_getProp(sims, params{i});
    
    % Apply transforms
    fitted_param_i = transforms{i}(fitted_param_i);
    sim_param_i = transforms{i}(sim_param_i);
    
    for j = 1:numParams
        % Get fitted parameter values for comparison parameter
        fitted_param_j = pal_tapas_getProp(fitted, params{j});
        % Get simulated parameter values for comparison parameter
        sim_param_j = pal_tapas_getProp(sims, params{j});
        
        % Apply transforms
        fitted_param_j = transforms{j}(fitted_param_j);
        sim_param_j = transforms{j}(sim_param_j);
        
        % Calculate correlations
        fitted_corr(i,j) = corr(fitted_param_i, fitted_param_j, 'type', corr_type);
        sim_corr(i,j) = corr(sim_param_i, sim_param_j, 'type', corr_type);
    end
end

% Create correlation matrix plot if requested
if do_corr_matrix
    figure;
    
    % Choose which correlation matrix to display
    if use_fitted
        corr_matrix = fitted_corr;
    else
        corr_matrix = sim_corr;
    end
    
    imagesc(corr_matrix, [-1, 1]);
    colorbar;
    
    % Set axis labels
    set(gca, 'XTick', 1:numParams, 'XTickLabel', param_names,'FontSize',12);
    set(gca, 'YTick', 1:numParams, 'YTickLabel', param_names,'FontSize',12);
    
    % Rotate x-axis labels for better readability
    xtickangle(45);
    
    % Add title
    title(sprintf('%s Correlations Amongst %s Parameters', corr_type, plot_title_suffix));
    
    % Add correlation values as text on the plot
    for i = 1:numParams
        for j = 1:numParams
            text(j, i, sprintf('%.2f', corr_matrix(i,j)), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'FontSize', 12);
        end
    end
end
 
end