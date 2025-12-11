function sim = pal_tapas_est2sim(est, the_seed)

% Bowen Xiao 2025
% turns est (output from tapas_fitModel) into a sim struct by calling tapas_simModel
% ensures that the parameters and model components are passed on

% inputs:
    % est: should be a single output from a single call of tapas_fitModel
    % the_seed is a random seed (int) that will be passedinto tapas_simModel
% output: sim from tapas_simModel
    
% Input validation and return of []: TBD
if isempty(est)
    disp('warning: empty input') %somehow warning cannot be printed??
    sim = [];
    return
end
if ~exist('the_seed','var')
    sim = tapas_simModel(est.u,...
        func2str(est.c_prc.prc_fun),...
        est.p_prc.p,...
        func2str(est.c_obs.obs_fun),...
        est.p_obs.p);
else
    sim = tapas_simModel(est.u,...
        func2str(est.c_prc.prc_fun),...
        est.p_prc.p,...
        func2str(est.c_obs.obs_fun),...
        est.p_obs.p,...
        the_seed);
end

end