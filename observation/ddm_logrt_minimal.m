function [logp, yhat, res] = ddm_logrt_minimal(r, infStates, ptrans)
% Calculates the log-probability of choice and reaction time
% Using a drift-diffusion response model (four parameter WFPT)
% With a minimalist coupling between infState and drift rate
% Compatible with rw_binary_ and (e)hgf_binary
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

% unpack params
drift_scaling = exp(ptrans(1)); % multiplies to infState
alpha = exp(ptrans(2)); %boundary separation
beta = tapas_sgm(ptrans(3),1); %relative starting point, 0-1 bound
tau = exp(ptrans(4)); %non-decision time
drift_bias = ptrans(5); %basically, v0

% Initialize returned log-probabilities, predictions,
% and residuals as NaNs so that NaN is returned for all
% irregualar trials
n = size(infStates,1);
logp = NaN(n,1);
yhat = NaN(n,1);
res  = NaN(n,1);

% get the responses and weed out trials
y_response = r.y(:,1);
logrt = r.y(:,2);
y_response(r.irr) = [];
logrt(r.irr) = [];
reg = ~ismember(1:n,r.irr);

% for the infStates (RL vhat, or can be HGF mu1)
x = infStates(:,1,pop);
x(r.irr) = [];

% logit transform x from 0~1 to -Inf~Inf;
    % for rw, centers on 0; for hgf, becomes second-level tendency
    % may seem silly that it goes to mu2... but this helps rw-hgf compatibility
    % echoes unitsq_sgm which is sigmoid with logit transform
%x_real = log(x./(1-x));%removed; no safeguard
x_bounded = max(eps, min(1-eps, x));
x_real = log(x_bounded./(1-x_bounded));

% IMPORTANT: coupling between infStates and DDM params
drift_rate = drift_scaling * x_real + drift_bias;

% apply the wiener pdf
ntrials = sum(reg);%sum of the number of regular trials
p1 = nan(ntrials,1);
p0 = nan(ntrials,1);
for iTrial = 1:ntrials
    % please note the sign flip here
    p0(iTrial) = wiener_pdlogrt(logrt(iTrial), alpha, tau, beta, drift_rate(iTrial));
    p1(iTrial) = wiener_pdlogrt(logrt(iTrial), alpha, tau, 1-beta, -drift_rate(iTrial));
end

% compute the choice prob based on its associated decision time
p_choice = NaN(ntrials,1);
p_choice(y_response==1) = p1(y_response==1);
p_choice(y_response==0) = p0(y_response==0);

%handle underlow and other numerical issues
p_choice(p_choice<eps) = eps; %using realmin seems to create optim difficulties for quasinewton_optim (giant AIC/BICs)
log_p_choice = log(p_choice);

% Calculate log-probabilities for non-irregular trials
logp(reg) = log_p_choice; 

% TO-DO: yhat and res

end