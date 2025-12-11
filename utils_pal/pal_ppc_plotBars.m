function pal_ppc_plotBars(real_data_vectors, sim_data_vectors, condition_labels, display_names)
    % Combined function to plot bar comparisons of real vs simulated data
    % Drafted by Claude in May 2025
    % Inputs:
    %   real_data_vectors: cell array of vectors containing real data for each condition
    %   sim_data_vectors: cell array of vectors containing simulated data for each condition  
    %   condition_labels: (optional) cell array of strings for x-axis labels
    %   display_names: (optional) cell array of 3 strings for legend labels 
    %                  {bar_name, scatter_name, error_name}. If not provided, no legend is shown.
    
    % Validate inputs
    if length(real_data_vectors) ~= length(sim_data_vectors)
        error('Number of real and simulated data vectors must match');
    end
    
    % Check if condition_labels is provided
    if nargin < 3 || isempty(condition_labels)
        use_labels = false;
    else
        use_labels = true;
        if length(real_data_vectors) ~= length(condition_labels)
            error('Number of data vectors must match number of condition labels');
        end
    end
    
    % Check if display_names is provided
    if nargin < 4 || isempty(display_names)
        show_legend = false;
        display_names = {'', '', ''}; % Empty names when no legend
    else
        show_legend = true;
        if length(display_names) ~= 3
            error('display_names must contain exactly 3 strings for {bar, scatter, error} labels');
        end
    end
    
    n_conditions = length(real_data_vectors);
    
    % Initialize handles for legend (will use handles from first condition)
    h_bar = [];
    h_scatter = [];
    h_error = [];
    
    % Plot each condition using pal_ppcRealScatSimBar
    for i = 1:n_conditions
        [h_b, h_s, h_e] = pal_ppcRealScatSimBar(real_data_vectors{i}, sim_data_vectors{i}, i, [], display_names);
        
        % Store handles from first condition for legend
        if i == 1
            h_bar = h_b;
            h_scatter = h_s;
            h_error = h_e;
        end
        
        hold on;
    end
    
    % Customize plot only if labels are provided
    if use_labels
        set(gca, 'XTick', 1:n_conditions, 'XTickLabel', condition_labels, 'FontSize', 14);
    else
        set(gca, 'FontSize', 14);
    end
    
    % Add legend if requested
    if show_legend && ~isempty(h_bar)
        legend([h_bar, h_scatter, h_error], 'Location', 'Northwest', 'FontSize', 12);
    end
    
    hold off;
end
function [h_bar, h_scatter, h_error] = pal_ppcRealScatSimBar(real_data, sim_data, x_loc, offset, display_names)
    % Simple plot: sim mean as bar, real data as scatter with error bar
    % Returns handles for creating legends
    if ~exist('offset','var') || isempty(offset)
        offset = 0.15;
    end
    
    % Set default display names if not provided
    if ~exist('display_names','var') || isempty(display_names)
        display_names = {'Real Data', 'Real data (95% CI)','Model Mean'};
    end
    
    sim_mean = nanmean(sim_data);
    real_mean = nanmean(real_data);
    real_std = nanstd(real_data);
    real_ci = 1.96 * real_std / sqrt(sum(~isnan(real_data))); % 95% CI
    
    % Create bar plot and store handle
    h_bar = bar(x_loc, sim_mean, 0.6, 'FaceColor', [0.9 0.9 0.9], 'EdgeColor', 'k', 'DisplayName', display_names{3}); 
    hold on;
    
    % Create scatter plot and store handle
    h_scatter = scatter(x_loc*ones(size(real_data))-offset, real_data, 30, 'red', 'filled', 'MarkerFaceAlpha', 0.5, 'DisplayName', display_names{1});
    
    % Create error bar plot and store handle
    h_error = errorbar(x_loc+offset, real_mean, real_ci, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'white', 'LineWidth', 2, 'DisplayName', display_names{2});
    
    hold off
end