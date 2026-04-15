function [prc_config, obs_config] = posterior2cfg(posterior, prc_config, obs_config, round_to)

% Bowen Xiao 2025
% input: posterior should be the output of est2posterior
% assign value to ptrans in a config
% align_priors_fields(cfg) %hope this func works with no bug
% then the new cfg can be used for parameter recovery 

% round(,), rather than taking the whole float; prevents error of accidentally freeing a parameter
% small caveat: badly scaled parameters may be fixed to no variance
if ~exist('round_to', 'var')
    round_to = 6;
end

if isempty(prc_config)
   do_prc = false; 
   prc_config = struct;
else
   do_prc = true;
end
if isempty(obs_config)
   do_obs = false; 
   obs_config = struct;
else
   do_obs = true;
end

if do_prc
    if ~strcmp(posterior.c_prc.model, prc_config.model)
        error('ERROR: model in posterior different from model in prc_config')
    end
    
    % extract original priors
    original_mus = prc_config.priormus;
    original_sas = prc_config.priorsas;
    % identify which parameters should be updated (free parameters only)
    is_free = original_sas > 0; % priorsas always non-negative
    
    % update ONLY the free parameters
    new_mus = original_mus;
    new_sas = original_sas;
    new_mus(is_free) = round(posterior.prc_ptrans_mu(is_free), round_to);
    new_sas(is_free) = round(posterior.prc_ptrans_sa(is_free), round_to);
    
    % ensure fixed parameters stay fixed (sa = 0)
    new_sas(~is_free) = original_sas(~is_free);
    
    % finally assign prior
    prc_config.priormus(:) = new_mus(:);
    prc_config.priorsas(:) = new_sas(:);
    prc_config = align_priors_fields(prc_config);
    
end

if do_obs
    if ~strcmp(posterior.c_obs.model, obs_config.model)
        error('ERROR: model in posterior different from model in obs_config')
    end

    % extract original priors
    original_mus = obs_config.priormus;
    original_sas = obs_config.priorsas;
    % identify which parameters should be updated (free parameters only)
    is_free = original_sas > 0; % priorsas always non-negative
    
    % update ONLY the free parameters
    new_mus = original_mus;
    new_sas = original_sas;
    new_mus(is_free) = round(posterior.obs_ptrans_mu(is_free), round_to);
    new_sas(is_free) = round(posterior.obs_ptrans_sa(is_free), round_to);
    
    % ensure fixed parameters stay fixed (sa = 0)
    new_sas(~is_free) = original_sas(~is_free);
    
    obs_config.priormus(:) = new_mus(:);
    obs_config.priorsas(:) = new_sas(:);
    obs_config = align_priors_fields(obs_config);
end

end
