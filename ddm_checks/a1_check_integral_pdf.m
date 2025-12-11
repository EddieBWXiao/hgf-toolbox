% Bowen Xiao 2025

% probability density function should integrate to 1
% checks it for both rt (s) and logrt (log ms)
% error will occur due to numerical precision, but should be low

addpath('../')

% precision threshold for the wiener pdf functions:
err = 1e-9;

% randomly sample parameter from reasonable ranges
alpha = unifrnd(eps, 5, 1);
tau = unifrnd(eps, 1, 1); 
beta = unifrnd(eps, 1-eps, 1);
delta = unifrnd(-3, 3, 1);
fprintf('Combo: %.3f, %.3f, %.3f, %.3f\n', ...
    alpha, tau, beta, delta);

%% for rt:
pdf_b1 = @(t) tapas_wiener_pdrts(t, alpha, tau, beta, delta, err);
pdf_b2 = @(t) tapas_wiener_pdrts(t, alpha, tau, 1-beta, -delta, err);

p1 = integral(pdf_b1, tau + eps, Inf, 'ArrayValued', true);
p2 = integral(pdf_b2, tau + eps, Inf, 'ArrayValued', true);
total_prob = p1 + p2;
fprintf('--- rt ---\n');
fprintf('Integral: %.6f\n', total_prob);
fprintf('Error:    %.g\n', abs(total_prob - 1));

%% for log rt
lower_bound_log = log(tau * 1000) + eps; 
upper_bound_log = Inf; % The tail extends infinitely

pdf_log_b1 = @(y) tapas_wiener_pdlogrt(y, alpha, tau, beta, delta, err);
pdf_log_b2 = @(y) tapas_wiener_pdlogrt(y, alpha, tau, 1-beta, -delta, err);

p1_log = integral(pdf_log_b1, lower_bound_log, upper_bound_log, 'ArrayValued', true);
p2_log = integral(pdf_log_b2, lower_bound_log, upper_bound_log, 'ArrayValued', true);

total_prob_log = p1_log + p2_log;

fprintf('--- logrt ---\n');
fprintf('Integral: %.6f\n', total_prob_log);
fprintf('Error:    %.g\n', abs(total_prob_log - 1));
