addpath(genpath('../'))

% Bowen Xiao 20250321; modified for re-wrriten wiener in Dec 2025
% testing recovy for rw-ddm in tapas

%% create task for simulation

u = load('example_binary_input.txt');
%u = repmat(u,[3,1]); %can increase length to debug

%% settings
nsims = 30;
%which_optim = 'default';%for standard quasinewton_optim
which_optim = 'fminunc';

%% load default priors
prc_config = tapas_rw_binary_config();
obs_config = tapas_ddm_logrt_minimal_config();

%% set priors

%prc_config.logitalmu = 0; %lower the learning rate

% can increase vscale here to test effect of decreasing noise
obs_config.logvscalemu = log(3);

% free the bias terms
obs_config.logitzsa = 1;
obs_config.v0sa = 1;

% update prior configs
prc_config = tapas_align_priors(prc_config);
obs_config = tapas_align_priors(obs_config);

%% configure the fitting
switch which_optim
    case 'default'
        optim_config = tapas_quasinewton_optim_config();
        optim_config.nRandInit = 1; %multiple initializations 
        optim_config.maxIter = 200; % iteration, increased from 100;
        optim_config.maxRst = 20; %max reset, increased from 10;
    case 'fminunc'
        optim_config = tapas_fminunc_optim_config;
        optim_config.nRandInit = 1;
end
%% loop for recovery
% preallocate
sims = cell(nsims,1);   
fitted = cell(nsims,1);
is_err = false(nsims,1);

% use for loop
for i = 1:nsims
    sims{i} = tapas_sampleModel(u,...
        prc_config,...
        obs_config);
    try
        fitted{i} = tapas_fitModel(sims{i}.y,...
            u,...
            prc_config,...
            obs_config,...
            optim_config);
    catch ME
        fitted{i} = ME;
        disp('Warning: error in fitModel. Simulation skipped.')
        disp(ME)
        is_err(i) = true;
    end
end

%% report any errors
sims_valid = sims(~is_err);
fitted_valid = fitted(~is_err);

sims_err = sims(is_err);
fitted_err = fitted(is_err);

if any(is_err)
    disp('Errors encountered during fit. Please check sims_err and fitted_err!')
    fprintf('A total of %i errors found in %i simulations \n', sum(is_err), length(is_err))
end

%% plotting parameter recovery results
pal_tapas_plotParRecAll(sims_valid, fitted_valid, ...
  {'p_prc.p(2)','p_obs.p(1)', 'p_obs.p(2)','p_obs.p(3)', 'p_obs.p(4)','p_obs.p(5)'}, ...
  {'lr','v', 'a','z','ndt','v0'});
set(gcf, 'Position', [450 124 591 648])
