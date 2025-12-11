% Bowen Xiao 2025
% Minimal Wiener parameter recovery
% Samples params from uniform, generates with tapas_wiener_gen_logrt
% fits with fmincon on tapas_wiener_logrt_lpdf

addpath(genpath('../'))

n_trials = 100; % should recover well even with very few trials
nsims = 100;

%% Sample true parameters from uniform distributions
alpha_true = unifrnd(0.5, 2.0, [nsims,1]);      % boundary separation
tau_true   = unifrnd(0.1, 0.4, [nsims,1]);      % non-decision time (seconds)
beta_true  = unifrnd(0.3, 0.7, [nsims,1]);      % starting point bias
delta_true = unifrnd(-2, 2, [nsims,1]);         % drift rate

%% fmincon settings
x0 = [1, 0.2, 0.5, 0]; 
lb = [0.1, 0.01, 0.01, -5]; 
ub = [5, 1, 0.99, 5];

options = optimoptions('fmincon', 'Display', 'off');

%% loop 

alpha_recov = nan(size(alpha_true));
tau_recov = nan(size(tau_true));
beta_recov = nan(size(beta_true));
delta_recov = nan(size(delta_true));

for i = 1:nsims
    fprintf('simulation %i \n', i)
    
    % simulate
    y = tapas_wiener_gen_logrt(alpha_true(i), tau_true(i), beta_true(i), delta_true(i) * ones(n_trials, 1));
    choice = y(:, 1);
    logrt = y(:, 2);
    
    % fit
    nll = @(p) compute_nll(p, choice, logrt);
    rec_params = fmincon(nll, x0, [], [], [], [], lb, ub, [], options);
    
    % plug in
    alpha_recov(i) = rec_params(1);
    tau_recov(i) = rec_params(2);
    beta_recov(i) = rec_params(3);
    delta_recov(i) = rec_params(4);
end
%% check recovery

figure;
subplot(2,2,1)
pal_scat_ref_corr(delta_true, delta_recov)
xlabel('True drfit rate')
ylabel('Recovered drfit rate')
subplot(2,2,2)
pal_scat_ref_corr(alpha_true, alpha_recov)
xlabel('True boundary separation')
ylabel('Recovered boundary separation')
subplot(2,2,3)
pal_scat_ref_corr(tau_true, tau_recov)
xlabel('True non-decision time')
ylabel('Recovered non-decision time')
subplot(2,2,4)
pal_scat_ref_corr(beta_true, beta_recov)
xlabel('True starting point')
ylabel('Recovered starting point')

%% the func
function nll = compute_nll(params, choice, logrt)
    alpha = params(1);
    tau   = params(2);
    beta  = params(3);
    delta = params(4);
    
    n = length(choice);
    ll = 0;
    
    for i = 1:n
        if choice(i) == 0
            % lower boundary: use beta, delta
            prob = tapas_wiener_pdlogrt(logrt(i), alpha, tau, beta, delta);
        else
            % upper boundary: flip beta and delta
            prob = tapas_wiener_pdlogrt(logrt(i), alpha, tau, 1 - beta, -delta);
        end
        ll = ll + log(max(prob, eps));
    end
    
    nll = -ll;
    
end