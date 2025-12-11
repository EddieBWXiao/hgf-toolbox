function posterior = pal_tapas_estArray2posterior(ests)

% from a cell array of est structs, get group-level posterior of parameters
% Bowen Xiao 2025

% steps:
% use pal_tapas_findFreePars(r)
% get vec of mean and variance from ptrans and pvec 
%
% IMPORTANT: ptrans should be used for setting posteriors (in normpdf space)
% IMPORTANT: priorsa is variance

% Bowen Xiao Dec 2025 note:
% current bug: consistent Inf or -Inf returns NaN as the variance, not 0...
% critical for logkamu(2)=-Inf in two-level HGF
% this is handled by pal_tapas_posterior2cfg downstream

% important: ests should be in a column; only one dimension
ests = ests(:);
% find the free parameters for each ptp
[prc_ind, obs_ind, n_par, par_names] = cellfun(@(x)pal_tapas_findFreePars(x),...
    ests,'UniformOutput',false);

%% check: all the same for params?
% Convert cell arrays to matrices
prc_ind_mat = cell2mat(prc_ind);
obs_ind_mat = cell2mat(obs_ind);
n_par_mat = cell2mat(n_par);

% check if all rows are equal for each matrix (i.e. same free par for all people)
if ~isempty(prc_ind_mat) % note that some prc models may have no free pars
    prc_rows_equal = all(all(prc_ind_mat == prc_ind_mat(1,:), 2));
else
    prc_rows_equal = true;
end
obs_rows_equal = all(all(obs_ind_mat == obs_ind_mat(1,:), 2));
n_par_rows_equal = all(all(n_par_mat == n_par_mat(1,:), 2));
par_names_extracted = cellfun(@(x) x{1}, par_names, 'UniformOutput', false);
par_names_equal = all(cellfun(@(x) isequaln(x, par_names_extracted{1}), par_names_extracted));

if any([~prc_rows_equal,~obs_rows_equal,~n_par_rows_equal,~par_names_equal])
    disp('Warning: cell array has different contents after applying pal_tapas_findFreePars.')
end

%% record the free param indices
if ~isempty(prc_ind_mat) % note that some prc models may have no free pars
    posterior.prc_ind = prc_ind_mat(1,:);
else
    disp('Note: No free parameters for the perceptual model. prc_ind empty')
    posterior.prc_ind = [];
end
if ~isempty(obs_ind_mat) % same if for obs
    posterior.obs_ind = obs_ind_mat(1,:);
else
    disp('Note: No free parameters for the perceptual model. obs_ind empty')
    posterior.obs_ind = [];    
end

posterior.free_pars = par_names_extracted{1};
posterior.c_prc = ests{1}.c_prc;
posterior.c_obs = ests{1}.c_obs;

%% actually set the prior mean and variances
%extract the transformed params
posterior.prc_ptrans = cell2mat(cellfun(@(x) x.p_prc.ptrans, ests, 'UniformOutput',false));
posterior.obs_ptrans = cell2mat(cellfun(@(x) x.p_obs.ptrans, ests, 'UniformOutput',false));
posterior.prc_pvec = cell2mat(cellfun(@(x) x.p_prc.p, ests, 'UniformOutput',false));
posterior.obs_pvec = cell2mat(cellfun(@(x) x.p_obs.p, ests, 'UniformOutput',false));

% take mean and variance of the transformed parameters
posterior.prc_ptrans_mu = mean(posterior.prc_ptrans, 1);
posterior.prc_ptrans_sa = var(posterior.prc_ptrans, [], 1); %note: this could be non-zero for fixed pars due to numerical precision...
posterior.obs_ptrans_mu = mean(posterior.obs_ptrans, 1);
posterior.obs_ptrans_sa = var(posterior.obs_ptrans, [], 1);

% don't think pvec will be any useful, but export since we are already here
posterior.prc_pvec_mu = mean(posterior.prc_pvec, 1);
posterior.prc_pvec_sa = var(posterior.prc_pvec, [], 1);
posterior.obs_pvec_mu = mean(posterior.obs_pvec, 1);
posterior.obs_pvec_sa = var(posterior.obs_pvec, [], 1);

end