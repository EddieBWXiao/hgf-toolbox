function [temp_file_dir, df] = compare_tapas_wiener_RWiener(alpha, tau, beta, delta, do_vis)

% Bowen Xiao 20250606; updated for tapas_wiener in 20251202
% calls an Rscript to compute probability density of a range of RTs
% at a given combination of 4par DDM params
% then, compare the output of RWiener::dwiener to tapas_wfpt

if nargin < 5, do_vis = true; end

%% run RWiener::dwiener
% Create unique filename to avoid race conditions
temp_file_dir = sprintf('check_RWiener_log_p_%d.csv', randi(999999));
% Use %.17g or %.17f to ensure full double precision is passed to R
cmd = sprintf('/usr/local/bin/Rscript compare_tapas_wiener_RWiener.R %.17f %.17f %.17f %.17f %s', ...
              alpha, tau, beta, delta, temp_file_dir);
system(cmd);

%% load R results and find the same lpdf in MATLAB
df = readtable(temp_file_dir);

% handling of small prob - sync with wiener_lpdf!!!
df.log_p_upper = log(max(df.p_upper, eps));
df.log_p_lower = log(max(df.p_lower, eps));

my_p_upper = nan(size(df.rt));
my_p_lower = nan(size(df.rt));

for i = 1:height(df)
    % note that there is an upper-lower switch...
    my_p_upper(i) = tapas_wiener_pdrts(df.rt(i), alpha, tau, 1-beta, -delta);
    my_p_lower(i) = tapas_wiener_pdrts(df.rt(i), alpha, tau, beta, delta);
end

% handling of small prob
df.tapas_log_p_upper = log(max(my_p_upper, eps));
df.tapas_log_p_lower = log(max(my_p_lower, eps));

% compute absolute difference
upper_err = max(abs(df.log_p_upper - df.tapas_log_p_upper));
lower_err = max(abs(df.log_p_lower - df.tapas_log_p_lower));

writetable(df,temp_file_dir);

%% visualise
if do_vis
    subplot(2,2,1)
    pal_scat_ref_corr(df.log_p_upper,my_p_upper)
    xlabel('RWiener pdf Upper')

    subplot(2,2,2)
    pal_scat_ref_corr(df.log_p_lower,my_p_lower)
    xlabel('RWiener pdf Lower')

    subplot(2,2,3)
    plot(df.rt, exp(my_p_upper),'-')
    hold on
    plot(df.rt, exp(df.log_p_upper),'--')
    hold off
    xlabel('Reaction time')
    ylabel('Probability density')
    title(sprintf('\\bfα=%.2f, τ=%.2f, β=%.2f, δ=%.2f', alpha, tau, beta, delta))

    subplot(2,2,4)
    plot(df.rt, exp(my_p_lower),'-')
    hold on
    plot(df.rt, exp(df.log_p_lower),'--')
    hold off
    xlabel('Reaction time')
    ylabel('Probability density')
    title(sprintf('\\bfα=%.2f, τ=%.2f, β=%.2f, δ=%.2f', alpha, tau, beta, delta))
    
    sgtitle(sprintf('Max error for upper: %.0e\nMax error for lower: %.0e', upper_err, lower_err))
end

end