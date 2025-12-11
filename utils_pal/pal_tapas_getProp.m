function values = pal_tapas_getProp(data, propPath)
% PAL_TAPAS_GETPROP Gets property values from structures or cell arrays of structures
%
% Written by Claude3.7
% checked briefly by Bowen Xiao 2025 on tapas est structs
% 
% Inputs:
%   data - Either a structure or a cell array of structures
%   propPath - String path to the property (e.g., 'p_prc.om(2)')
% 
% Output:
%   values - The value or array of values extracted
%
% Examples:
%   % For a single structure:
%   om2 = pal_tapas_getProp(sims{1}, 'p_prc.om(2)');
%   
%   % For a cell array:
%   sim_om2 = pal_tapas_getProp(sims, 'p_prc.om(2)');
%   fitted_ze = pal_tapas_getProp(fitted, 'p_obs.p(1)');

% Check if input is a cell array
if iscell(data)
    values = cellfun(@(x) getOneValue(x, propPath), data);
else
    values = getOneValue(data, propPath);
end
end

function value = getOneValue(structure, propPath)
% Parse the property path
parts = strsplit(propPath, '.');
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