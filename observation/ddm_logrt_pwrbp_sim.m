function y = ddm_logrt_pwrbp_sim(r, infStates, p)
% Generative model for ddm_logrt_pwrbp
% Simulate choice and RT for ddm_logrt_pwrbp
% y: column 1 - choice (0 for lower bound, 1 for upper); 
%    column 2 - log rt (log milliseconds)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao, University of Cambridge
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Predictions or posteriors?
pop = 1; % Default: predictions
if r.c_obs.predorpost == 2
    pop = 3; % Alternative: posteriors
end

% IMPORTANT: defaults for simulation
ddm_sim_opts.max_t = 10; %response more than 10s NEVER generated
ddm_sim_opts.dt = 0.0001; %0.1ms for extra precision

% unpack params
drift_scaling = p(1); % multiplies to infState
bb = p(2); %boundary separation (BASELINE)
beta = p(3); %relative starting point, 0-1 bound
tau = p(4); %non-decision time
drift_bias = p(5); %basically, v0
bp = p(6); % power on trial number to decrease alpha

% Initialize random number generator
if isnan(r.c_sim.seed)
    rng('shuffle');
else
    rng(r.c_sim.seed);
end

% for the infStates (RL vhat, or can be HGF mu1)
x = infStates(:,1,pop);
ntrials = length(x); % infer the full number of trials
trial_number = 1:ntrials; % trial number

% logit transform x from 0~1 to -Inf~Inf;
x_bounded = max(eps, min(1-eps, x));
x_real = log(x_bounded./(1-x_bounded));

% IMPORTANT: coupling between infStates and DDM params
drift_rate = drift_scaling * x_real + drift_bias;

% Pedersen et al., 2017 equation 7
alpha = bb*(trial_number/10).^bp;

% simulate
y = wiener_gen_logrt(alpha, tau, beta, drift_rate, ddm_sim_opts);

end