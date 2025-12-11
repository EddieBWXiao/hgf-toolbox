function traj_table = pal_tapas_trajHGF2table(traj)
 
% Create a table from the trajectory results
% Written by Claude and edited by Bowen Xiao May 2025
    
    % Initialize table variable names
    var_names = {};
    
    %% extra code to prepare for pre-allocation
    % Extract each field and determine total number of columns
    fields = fieldnames(traj);
    total_cols = 0;
    for i = 1:length(fields)
        field = fields{i};
        field_size = size(traj.(field));
        n_cols = field_size(2); % Get actual number of columns
        total_cols = total_cols + n_cols;
    end
    % Get number of rows from data
    n_rows = size(traj.(fields{1}), 1);
    
    % Initialize data array with proper dimensions
    data = zeros(n_rows, total_cols);
    
    %% loop through each field and add to data, recording the col name
    % Extract each field and create appropriate column names
    col_idx = 1; % counter for the column in the final mat, data, that is being processed
    for i = 1:length(fields)
        field = fields{i};
        field_data = traj.(field);
        n_cols = size(field_data, 2);
        
        % Add data to the main data array
        data(:, col_idx:(col_idx + n_cols - 1)) = field_data;
        
        % IMPORTANT: create column names for this field; 
        % format = muhat1, muhat2 etc.
        for j = 1:n_cols
            var_names{end+1} = sprintf('%s%d', field, j);
        end
        
        col_idx = col_idx + n_cols;
    end
    
    % make into a table
    traj_table = array2table(data, 'VariableNames', var_names);
end