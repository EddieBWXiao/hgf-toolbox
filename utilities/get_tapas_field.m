function values = get_tapas_field(s, field_path)
% 
% Written by Claude3.7
% checked briefly by Bowen Xiao 2025 on tapas est structs
% different from the matlab getfield behaviour
% 
% Inputs:
%   s - Either a structure or a cell array of structures
%   field_path - String path to the property (e.g., 'p_prc.om(2)')
% 
% Output:
%   values - The value or array of values extracted
%
% Examples:
%   % For a single structure:
%   om2 = get_tapas_field(sims{1}, 'p_prc.om(2)');
%   
%   % For a cell array:
%   sim_om2 = get_tapas_field(sims, 'p_prc.om(2)');
%   fitted_ze = get_tapas_field(fitted, 'p_obs.p(1)');

% Check if input is a cell array
if iscell(s)
    values = cellfun(@(x) getOneValue(x, field_path), s);
else
    values = getOneValue(s, field_path);
end
end
function value = getOneValue(structure, field_path)

% parse the property path
parts = strsplit(field_path, '.');
current = structure;

for i = 1:length(parts)
    part = parts{i};
    
    % Check if there's an array index
    if contains(part, '(')
        openBracket = find(part == '(', 1);
        closeBracket = find(part == ')', 1, 'last');
        
        % Get the field name
        fieldName = part(1:openBracket-1);
        
        % Get the index value
        indexStr = part(openBracket+1:closeBracket-1);
        index = str2double(indexStr);
        
        % Access the field and then the index
        current = current.(fieldName);
        current = current(index);
    else
        % No index, just access the field
        current = current.(part);
    end
end

value = current;

end