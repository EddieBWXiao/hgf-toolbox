addpath('../')
addpath(genpath('../../tapas'))

% wrapper around compare_tapas_wiener_RWiener
% randomly generates parameter value combinations
% reports the absolute deviation (error) in log probability density between
% RWiener::dwiener and tapas_wiener_l

% you can also run, e.g.,
% compare_tapas_wiener_RWiener(1, 0.2, 0.1, 10, true)
% to individually visualise

% number of parameter combinations to test
n_tests = 30;

err_tol = 1e-8;
param_digit_precision = 3; %control numerical precision; 
    % if parameters are numerically too precise, e.g., 1.10203030...
    % R and MATLAB can yield different answers

% Generate random parameter combinations
% round() to control for numerical precision
alpha = round(unifrnd(eps, 5, [n_tests, 1]), param_digit_precision);    % Boundary separation
tau = round(unifrnd(eps, 1, [n_tests, 1]), param_digit_precision);   % Non-decision time
beta = round(unifrnd(eps, 1-eps, [n_tests, 1]), param_digit_precision);   % Starting point bias
delta = round(unifrnd(-3, 3, [n_tests, 1]), param_digit_precision);     % Drift rate

% Initialize error storage
upper_errors = nan(n_tests, 1);
lower_errors = nan(n_tests, 1);

% Test each parameter combination
disp('Script will generate and then delete .csv files.')
fprintf('Testing %d parameter combinations...\n', n_tests);
for i = 1:n_tests
    fprintf('Test %d/%d: %.3f, %.3f, %.3f, %.3f\n', ...
        i, n_tests, alpha(i), tau(i), beta(i), delta(i));
    
    % Run comparison function (now only returns temp file directory)
    temp_file_dir = compare_tapas_wiener_RWiener(alpha(i), tau(i), beta(i), delta(i), true);
    
    % Read the CSV file with results
    df = readtable(temp_file_dir);
    delete(temp_file_dir)
    
    % Compute absolute difference
    upper_err = max(abs(df.log_p_upper - df.tapas_log_p_upper));
    lower_err = max(abs(df.log_p_lower - df.tapas_log_p_lower));
    
    % Check for large deviations
    if upper_err > err_tol || lower_err > err_tol
        warning('Large deviation of %.0e from RWiener::dwiener detected for test %d', max([upper_err, lower_err]),i);
    end
    
    % Store errors
    upper_errors(i) = upper_err;
    lower_errors(i) = lower_err;
    
end

%% Display results
max_upper_error = max(upper_errors);
max_lower_error = max(lower_errors);

fprintf('\n=== RESULTS: Deviation between tapas_wiener_lpdf and dwiener ===\n');
fprintf('Largest upper boundary error: %.2e\n', max_upper_error);
fprintf('Largest lower boundary error: %.2e\n', max_lower_error);
fprintf('Overall maximum error: %.2e\n', max(max_upper_error, max_lower_error));
