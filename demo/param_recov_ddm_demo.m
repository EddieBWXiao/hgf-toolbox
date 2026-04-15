%% Demo of parameter recovery

prc_model = 'uhgf'; 
obs_model = 'ddm_logrt_pwrbp';%'ddm_logrt_minimal';

% number of simulations
nsims = 30;

% use parfor or not (faster but depends on parallel computing toolbox)
use_parfor = true;

%% path management (alt setup routine)
if ~exist('fitModel', 'file')
    if ~endsWith(pwd, 'hgf-toolbox/demo')
        error('Not in hgf-toolbox/demo folder. Please cd to folder containing this script before running the demo.')
    end
    % add everything in the toolbox into the path
    addpath(genpath('../'))
end

%%
demodir = fileparts(which('hgf_demo_commands'));
%u = load(fullfile(demodir, 'example_binary_input.txt'));
u = load('/Users/xiaobowen/Desktop/tapas_dual_stream_fix/demo/hein1.txt');

%% specify the model

% define the perceptual model (a.k.a. the learning model)
switch prc_model
    case 'rw'
        prc_config = rw_binary_config();
        prc_params = {'al'};
        prc_params_loc = {'p_prc.al'};
        
    case 'ehgf'
        prc_config = ehgf_binary_config();
        prc_params = {'om2', 'om3'};
        prc_params_loc = {'p_prc.om(2)', 'p_prc.om(3)'};
        
    case 'hgf2l'
        prc_config = ehgf_binary_config();
        prc_params = {'om2'};
        prc_params_loc = {'p_prc.om(2)'};
        prc_config.logkamu(2) = -Inf;
        prc_config.logkasa(2) = 0;
        prc_config.omsa(3) = 0;
        prc_config = align_priors(prc_config);
    
    case 'uhgf'
        prc_config = uhgf_binary_config();
        prc_params = {'om2', 'om3'};
        prc_params_loc = {'p_prc.om(2)', 'p_prc.om(3)'};
end


switch obs_model
    case 'ddm_logrt_minimal'
        obs_config = ddm_logrt_minimal_config();
        obs_config.logvscalemu = -0.16; % Hein et al. is even lower, -0.16
        obs_config.logvscalesa = 0.2; % variance from Hein et al. fit
        obs_config.logamu = 0.5; % TO-CHECK
        obs_config.logasa = 0.1; % TO-CHECK
        obs_config.logndtmu = -1; % mean from Hein et al.
        obs_config.logndtsa = 0.02; % variance from Hein et al.
        obs_config.v0mu = 0; % arbitrary (0 means no bias)
        obs_config.v0sa = 0; % variance from Hein et al.
        obs_config = align_priors(obs_config);
        obs_params = {'drift rate scaling', 'boundary sep', 'ndt', 'drift bias'};
        obs_params_loc = {'p_obs.p(1)', 'p_obs.p(2)','p_obs.p(4)', 'p_obs.p(5)'};
    case 'ddm_logrt_pwrbp'
        obs_config = ddm_logrt_pwrbp_config();
        obs_config.logvscalemu = -0.16; % Hein et al. is even lower, -0.16
        obs_config.logvscalesa = 0.2; % variance from Hein et al. fit
        obs_config.logbbmu = 0.5; % mean from Hein et al.
        obs_config.logbbsa = 0.1; % variance from Hein et al.
        obs_config.logndtmu = -1; % mean from Hein et al.
        obs_config.logndtsa = 0.02; % variance from Hein et al.
        obs_config.logitzmu = 0; %arbitrary (0 means no bias)
        obs_config.logitzsa = 0.1; % free to show we can recov
        obs_config.v0mu = 0; % fix at no bias
        obs_config.v0sa = 0; % fix; in this set up, poor recov if z also free
        obs_config.logitbpmu = -0.5; % mean from Hein et al.
        obs_config.logitbpsa = 0.3; % variance from Hein et al.
        obs_config = align_priors(obs_config);
        obs_params = {'drift rate scaling', 'bb', 'z','ndt', 'bp'};
        obs_params_loc = {'p_obs.p(1)', 'p_obs.p(2)','p_obs.p(3)','p_obs.p(4)', 'p_obs.p(6)'};
end

params_loc = [prc_params_loc, obs_params_loc];
param_names = [prc_params, obs_params];

%% specify optimiser

optim_config = fminunc_optim_config();%quasinewton_optim_config();
optim_config.nRandInit = 1; %if specified, will use multi-start optimisation

%% loop for recovery

sims = cell(nsims,1);   
ests = cell(nsims,1);

% use for loop (serial) or parfor (faster parallel computing)
if ~use_parfor
    for i = 1:nsims
        
        % set a random seed for reproducibility 
        local_optim_config = optim_config;
        local_optim_config.seedRandInit = i;
        
        % simulate by sampling from the priors
        sim_data = sampleModel(u,...
            prc_config,...
            obs_config);
        
        % fit model
        est = fitModel(sim_data.y,...
            u,...
            prc_config,...
            obs_config,...
            local_optim_config);

        % store the result from this simulation-recovery pair
        sims{i} = sim_data;
        ests{i} = est;
    end
else
    parfor i = 1:nsims
        local_optim_config = optim_config;
        local_optim_config.seedRandInit = i; 
        sim_data = sampleModel(u,...
            prc_config,...
            obs_config);
        est = fitModel(sim_data.y,...
            u,...
            prc_config,...
            obs_config,...
            local_optim_config);
        sims{i} = sim_data;
        ests{i} = est;
    end
end

%%
plotParamRecov(sims, ests, params_loc, param_names)


