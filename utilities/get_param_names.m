function [expnms_prc, expnms_obs] = get_param_names(r, auto_levelSuffix)

% get the names of parameters from the fields of an est struct
% Modified from tapas_fit_plotCorr by Bowen Xiao, Jun 2025
% original script does not allow indexing to be written out (e.g., om2 and om3)
% Modified to allow indexing in collaboration with Claude
% 
% INPUT: 
% r: est from fitModel
% auto_levelSuffix: logical; if true, add level (l) as suffix; if false, will have duplicate param names
% 
% OUTPUT:
% expnms_prc/expnms_obs: cell array of strings for parameter names from the
% field names of the p_prc and p_obs
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%               2025 Bowen Xiao, University of Cambridge
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

if ~exist('auto_levelSuffix','var')
    auto_levelSuffix = true;
end

% Find names of optimized perceptual parameters
names_prc = fieldnames(r.p_prc);
fields = struct2cell(r.p_prc);
expnms_prc = {};

for k = 1:length(names_prc)
    field_length = length(fields{k});
    if field_length == 1
        % Single parameter within the field - no suffix needed
        expnms_prc = [expnms_prc; names_prc{k}];
    else
        % Multiple parameters - add numeric suffixes if required
        for l = 1:field_length
            if auto_levelSuffix
                param_name = [names_prc{k}, num2str(l)];
            else
                param_name = names_prc{k};
            end
            expnms_prc = [expnms_prc; param_name];
        end
    end
end

% Truncate to actual number of parameters
expnms_prc = expnms_prc(1:length(r.p_prc.p));

% Find names of optimized observation parameters
names_obs = fieldnames(r.p_obs);
fields = struct2cell(r.p_obs);
expnms_obs = {};

for k = 1:length(names_obs)
    field_length = length(fields{k});
    if field_length == 1
        % Single parameter - no suffix needed
        expnms_obs = [expnms_obs; names_obs{k}];
    else
        % Multiple parameters - add numeric suffixes if required
        for l = 1:field_length
            if auto_levelSuffix
                param_name = [names_obs{k}, num2str(l)];
            else
                param_name = names_obs{k};
            end
            expnms_obs = [expnms_obs; param_name];
        end
    end
end

% Truncate to actual number of parameters
expnms_obs = expnms_obs(1:length(r.p_obs.p));

end
