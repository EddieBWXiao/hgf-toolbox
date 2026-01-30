% Demo of simulation, fitting, & parameter recovery for the HGF-DDM 
% Bowen Xiao 2026

% Parameter recovery is sensitive to the model, the priors, and the task
% Multiple random initialisations (starting points for optimisation) 
    % - not just for avoiding local minima, but also prevents poor recovery due to optimisation problems
    % - furthermore... tapas_fminunc_optim_config penalises non-convergence by checking the hessian
    % - increasing nRandInit often necessary to get good convergence
% Random seeds are essential for reproducibility

% tested on R2020a and R2020b; expect good recoverability (r>0.7)

% path management: include the hgf-toolbox (with ddm + pal_tapasfunctions)
addpath(genpath('../../hgf-toolbox'))

% whether to use parallel computing for speed or not
% if false, may take 1hr or more to run in full
use_parfor = true;

%% load example task

% unfortunately, Iglesias u does not recover well with the posterior from Hein et al.
% use the first sequence from Hein et al. here for demo
u = load('./sequence1.txt');

%% set priors for the HGF

% perceptual model: the learner (u -> beliefs)
prc_config = tapas_ehgf_binary_config();

% specify priors based on the posterior of a study                   
prc_config.ommu(2) = -1.8; % mean from Hein et al.
prc_config.ommu(3) = -0.5; % mean from Hein et al.
prc_config.omsa(2) = 1.8; % variance from Hein et al. fit
prc_config.omsa(3) = 3.5; % variance from Hein et al. fit
prc_config = tapas_align_priors(prc_config);

%% set priors for the DDM

% observation model: map beliefs to response (y)
obs_config = tapas_ddm_logrt_pwrbp_config();

% specify priors based on the posterior of a study  
obs_config.logvscalemu = 0; % Hein et al. is even lower, -0.16
obs_config.logvscalesa = 0.2; % variance from Hein et al. fit
obs_config.logbbmu = 0.5; % mean from Hein et al.
obs_config.logbbsa = 0.1; % variance from Hein et al.
obs_config.logndtmu = -1; % mean from Hein et al.
obs_config.logndtsa = 0.02; % variance from Hein et al.
obs_config.v0mu = 0; % arbitrary (0 means no bias)
obs_config.v0sa = 0.05; % variance from Hein et al.
obs_config.logitbpmu = -0.5; % mean from Hein et al.
obs_config.logitbpsa = 0.3; % variance from Hein et al.

obs_config = tapas_align_priors(obs_config);

%% record the free parameter locations

% necessary for visualising parameter recovery
free_params.loc = {'p_prc.p(13)', 'p_prc.p(14)',...
    'p_obs.p(1)', 'p_obs.p(2)','p_obs.p(4)', 'p_obs.p(5)', 'p_obs.p(6)'};
free_params.names = {'omega2', 'omega3',...
    'drift rate scaling', 'bb', 'ndt', 'drift bias','bp'};

%% specify the optimisation approach

optim_config = tapas_fminunc_optim_config();
optim_config.nRandInit = 2; % 2 is generally ok (only one bad Hessian)

%% recovery loop

% number of simulations; bigger = better estimate of correlation
nsims = 100;

% pre-allocate
all_sims = cell(nsims ,1);
recov_results = cell(size(all_sims));

if ~use_parfor
    
    % for loop: create sample dataset, then fit
    for i = 1:nsims

        fprintf('============running sim %i ===========\n', i)

        %sample from the priors
        all_sims{i} = tapas_sampleModel(u,...
            prc_config,...
            obs_config,...
            i); %seed it

        % handle random seeds
        rng(i);
        optim_config.seedRandInit = i;

        % model fitting: same config as the simulation
        y = all_sims{i}.y;
        recov_results{i} = tapas_fitModel(y, u, prc_config, obs_config, optim_config);

    end
    
else
    
    % parallelised over the number of simulations
    parfor i = 1:nsims

        iter_optim_config = optim_config; 
        iter_optim_config.seedRandInit = i;

        fprintf('============running sim %i ===========\n', i);

        rng(i);
        sim_data = tapas_sampleModel(u, prc_config, obs_config, i);

        rng(i);
        est = tapas_fitModel(sim_data.y, u, prc_config, obs_config, iter_optim_config);

        all_sims{i} = sim_data;
        recov_results{i} = est;
    end
    
end

%% plot parameter recovery

pal_tapas_plotParRecAll(all_sims, recov_results, ...
  free_params.loc, ...
  free_params.names);

