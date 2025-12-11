function c = tapas_ddm_logrt_pwrbp_config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% configuration for a drift diffusion observation model using log reaction time in milliseconds
% with boundary separation changing across the task as per Pedersen et al., 2017
% (https://github.com/CCS-Lab/hBayesDM/blob/develop/commons/stan_files/pstRT_rlddm6.stan)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% NOTES:
% vscale: drift_scaling in the model
% bb: the baseline alpha, modulated by bp
% z: beta; starting point bias of 0~1 (as frac of boundary separation)
% ndt: tau; non-decision time (the unit is always in seconds, not log rt)
% v0: drift_bias; the drift rate when the infState is 0
% bp: the power law parameter controlling the decay or increase of bb as the trials go on
% IMPORTANT: z and v0 are not free by default
% 
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao, University of Cambridge
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Config structure
c = struct;

% Model name
c.model = 'tapas_ddm_logrt_pwrbp';

% Is the decision based on predictions or posteriors? Comment as appropriate.
c.predorpost = 1; % Predictions
%c.predorpost = 2; % Posteriors

% drift rate multiplier on the infState
c.logvscalemu = 0;
c.logvscalesa = 1;
% boundary separation (baseline; log transformed)
c.logbbmu = 0;
c.logbbsa = 1;
% z (starting point)
c.logitzmu = 0; % defaults to fixed value of 0.5
c.logitzsa = 0;
% ndt (log transformed to go non-neg; no upper bound like hBayesDM)
c.logndtmu = log(0.100); %100ms as an arbitrary but reasonable default
c.logndtsa = 1;
% drift bias (allow negative, but DO NOT FREE IT by default)
c.v0mu = 0;
c.v0sa = 1;
% power parameter for the trial number to scale the drift rate
c.logitbpmu = 0;
c.logitbpsa = 1;
    % logit, but the de facto transform is bounded (-0.3 to 0.3)
    % this is a rather arbitrary choice in search of consistency with
    % Pedersen et al., 2017

    
% Gather prior settings in vectors
c.priormus = [
    c.logvscalemu,...
    c.logbbmu,...
    c.logitzmu,...
    c.logndtmu,...
    c.v0mu,...
    c.logitbpmu,...
         ];

c.priorsas = [
    c.logvscalesa,...
    c.logbbsa,...
    c.logitzsa,...
    c.logndtsa,...
    c.v0sa,...
    c.logitbpsa,...
         ];

% Model filehandle
c.obs_fun = @tapas_ddm_logrt_pwrbp;

% Handle to function that transforms observation parameters to their native space
% from the space they are estimated in
c.transp_obs_fun = @tapas_ddm_logrt_pwrbp_transp;

return;
