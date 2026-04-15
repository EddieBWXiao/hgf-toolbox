function c = ddm_logrt_minimal_config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% configuration for a basic drift diffusion observation model using log reaction time in milliseconds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% NOTES:
% vscale: drift_scaling in the model
% boundary separation: alpha
% z: beta; starting point bias of 0~1 (as frac of boundary separation)
% ndt: tau; non-decision time (the unit is always in seconds, not log rt)
% v0: drift_bias; the drift rate when the infState is 0
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
c.model = 'ddm_logrt_minimal';

% Is the decision based on predictions or posteriors? Comment as appropriate.
c.predorpost = 1; % Predictions
%c.predorpost = 2; % Posteriors

% drift rate multiplier on the infState
c.logvscalemu = 0;
c.logvscalesa = 1;
% boundary separation (log transformed)
c.logamu = 0;
c.logasa = 1;
% z (starting point)
c.logitzmu = 0; % defaults to fixed value of 0.5
c.logitzsa = 0;
% ndt (log transformed to go non-neg; no upper bound like hBayesDM)
c.logndtmu = log(0.100); %100ms as an arbitrary but reasonable default
c.logndtsa = 1;
% drift bias (allow negative, but DO NOT FREE IT by default) 
c.v0mu = 0;
c.v0sa = 0;

% Gather prior settings in vectors
c.priormus = [
    c.logvscalemu,...
    c.logamu,...
    c.logitzmu,...
    c.logndtmu,...
    c.v0mu,...
         ];

c.priorsas = [
    c.logvscalesa,...
    c.logasa,...
    c.logitzsa,...
    c.logndtsa,...
    c.v0sa,...
         ];

% Model filehandle
c.obs_fun = @ddm_logrt_minimal;

% Handle to function that transforms observation parameters to their native space
% from the space they are estimated in
c.transp_obs_fun = @ddm_logrt_minimal_transp;

return;
