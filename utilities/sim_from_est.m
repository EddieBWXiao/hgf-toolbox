function sim_from_est(est, the_seed)

% Bowen Xiao 2025
% turns est (output from fitModel) into a sim struct by calling simModel
% ensures that the parameters and model components are passed on

% inputs:
    % est: should be a single output from a single call of fitModel
    % the_seed is a random seed (int) that will be passedinto simModel
% output: sim from simModel
    
% Input validation and return of []: TBD
if isempty(est)
    disp('warning: empty input') %somehow warning cannot be printed??
    sim = [];
    return
end
if ~exist('the_seed','var')
    sim = simModel(est.u,...
        func2str(est.c_prc.prc_fun),...
        est.p_prc.p,...
        func2str(est.c_obs.obs_fun),...
        est.p_obs.p);
else
    sim = simModel(est.u,...
        func2str(est.c_prc.prc_fun),...
        est.p_prc.p,...
        func2str(est.c_obs.obs_fun),...
        est.p_obs.p,...
        the_seed);
end

end