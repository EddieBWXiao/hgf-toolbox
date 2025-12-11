function sim = pal_tapas_sampHess(r,the_seed)

% Bowen Xiao 2025 adapting from Alex Hess code https://gitlab.ethz.ch/tnu/code/hessetal_spirl_analysis/-/blob/master/job_runner_12_main_results.m?ref_type=heads
% Line 102~169; turning the core operation into a function

% Input: r should be an est struct (e.g., fitted HGF)
% Output: sim struct, with parameters sampled from the Hessian

% Basically, find the free params, normrnd, then sim with tapas_simModel
% Initially attempt to use the full covariance matrix
% Switched to independent distributions
% Special thanks to Tim Sandhu for helpful discussions

% defaulting random seed for simulations:
if ~exist('the_seed','var')
    rng('shuffle');  % Automatically seeds with current time
    the_seed = rng().Seed;  % Get the actual seed value used
end

% find indices of the free parameters
[prc_ind, obs_ind,~,~,n_prc_pars,n_obs_pars] = pal_tapas_findFreePars(r);
prc_in_mat = 1:n_prc_pars;
obs_in_mat = n_prc_pars + (1:n_obs_pars);

% get the posterior mean and cov from the free parameters
    % check: is Sigma the covariance matrix? if so why called sigma (SD)?
posterior_mean_prc = r.p_prc.ptrans(prc_ind);
posterior_cov_prc =  inv(r.optim.H(prc_in_mat, prc_in_mat)); 
posterior_mean_obs = r.p_obs.ptrans(obs_ind);
posterior_cov_obs = inv(r.optim.H(obs_in_mat, obs_in_mat)); 
    % in H and Sigma, prc always before obs, so add prc pars before

% % a la tapas_fitModel line 580~583, ensure Sigma positive semi-definite
% posterior_cov_prc = tapas_nearest_psd(posterior_cov_prc);
% posterior_cov_obs = tapas_nearest_psd(posterior_cov_obs);
    
% prepare sampled_ptrans
sampled_ptrans_prc = r.p_prc.ptrans;
sampled_ptrans_obs = r.p_obs.ptrans;
% % sample new parameters
% --------------------------------
% try
%     sampled_ptrans_prc(prc_ind) = mvnrnd(posterior_mean_prc, abs(sqrt(posterior_cov_prc)));
%     sampled_ptrans_obs(obs_ind) = mvnrnd(posterior_mean_obs, abs(sqrt(posterior_cov_obs)));
%     % question: why abs(sqrt())? (Check the maths)
%     % can we skip abs() if we already ensured positive semi-definite?
% catch
%     disp('WARNING: failed to sample from multivariate normal. Discarding covariance and using normrnd.')
%     sa_prc = abs(sqrt(diag(posterior_cov_prc)));
%     sa_obs = abs(sqrt(diag(posterior_cov_obs)));
%     sampled_ptrans_prc(prc_ind) = normrnd(posterior_mean_prc(:), sa_prc(:));
%     sampled_ptrans_obs(obs_ind) = normrnd(posterior_mean_obs(:), sa_obs(:));
%         % used (:) to force both to be col vecs
% end
% --------------------------------
% sample new parameters: following Alex Hess code rather than trying mvnrnd
sa_prc = abs(sqrt(diag(posterior_cov_prc)));
sa_obs = abs(sqrt(diag(posterior_cov_obs)));
sampled_ptrans_prc(prc_ind) = normrnd(posterior_mean_prc(:), sa_prc(:));
sampled_ptrans_obs(obs_ind) = normrnd(posterior_mean_obs(:), sa_obs(:));

% simulate data using the sampled parameters
sim = tapas_simModel(r.u,...
    func2str(r.c_prc.prc_fun), r.c_prc.transp_prc_fun(r,sampled_ptrans_prc),...
    func2str(r.c_obs.obs_fun), r.c_obs.transp_obs_fun(r,sampled_ptrans_obs), the_seed);
end