function pal_tapas_plotParRec(sims, fitted, param, param_name, ptransf)
% PAL_TAPAS_PLOTPARREC Plots simulated vs. fitted parameters for a specified parameter path
%
% Bowen Xiao 2025, aided by Claude
% 
% Inputs:
%   sims - Cell array of simulated parameter structures
%   fitted - Cell array of fitted parameter structures 
%   param - String specifying the parameter path (e.g., 'p_prc.om(2)')
%   ptransf - (Optional) Function handle for parameter transformation (e.g., @log)
%
% Example:
%   % Plot p_prc.om(2) without transformation
%   pal_tapas_plotParRec(sims, fitted, 'p_prc.om(2)');
%
%   % Plot p_obs.p(1) with log transformation
%   pal_tapas_plotParRec(sims, fitted, 'p_obs.p(1)', @log);

fitted_param  = pal_tapas_getProp(fitted, param);
sim_param  = pal_tapas_getProp(sims,param);

if exist('ptransf','var')
    pal_scat_ref_corr(ptransf(sim_param),ptransf(fitted_param))
else
    pal_scat_ref_corr(sim_param,fitted_param)
end
xlabel(sprintf('Simulated %s',param_name))
ylabel(sprintf('Recovered %s', param_name))

end