function [prc_ind, obs_ind, n_par, par_names, n_prc_pars, n_obs_pars] = find_free_params(r)

% find the free parameters in an est struct by looking at priorsas
% Copied out from tapas_fit_plotCorr by Bowen Xiao, Jun 2025
% added get_param_names for retrieving parameter names (par_names)
%
% INPUT:
% r: est from fitModel
%
% OUTPUT:
% prc/obs_ind: index for the positions of the free parameters in the c_prc/obs; numeric not logical
% n_par: total number of free parameters
% par_names: names of parameters from field names of the p_prc and p_obs;
    % (parameters with multiple levels will have the level as suffix)
% n_prc/obs_pars: number of free parameters, separate for the other models
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%               2025 Bowen Xiao University of Cambridge
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Goal: determine numerical indices of parameters to optimize (i.e., those that are not fixed and not NaN)

prc_ind = r.c_prc.priorsas;
prc_ind(isnan(prc_ind)) = 0;
prc_ind = find(prc_ind);

obs_ind = r.c_obs.priorsas;
obs_ind(isnan(obs_ind)) = 0;
obs_ind = find(obs_ind);

% count the number of free parameters
n_prc_pars = length(prc_ind);
n_obs_pars = length(obs_ind);
n_par   =  n_prc_pars + n_obs_pars;

% get the names of the free parameters
[expnms_prc, expnms_obs] = get_param_names(r);
par_names = {[expnms_prc(prc_ind); expnms_obs(obs_ind)]}; %select only the free pars

end
