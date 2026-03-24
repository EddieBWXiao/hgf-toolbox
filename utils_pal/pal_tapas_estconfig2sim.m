function sim = pal_tapas_estconfig2sim(est, the_seed)

% Bowen Xiao 2025
% turns est (output from tapas_fitModel) into a sim struct by calling tapas_simModel
% ensures that the parameters and model components are passed on
% difference from est2sim: passes config into pal_tapas_simFromConfig

% inputs:
    % est: should be a single output from a single call of tapas_fitModel
    % the_seed is a random seed (int) that will be passed into a tapas_simModel-like function
% output: sim from pal_tapas_simFromConfig (not tapas_simModel)
    
% Input validation and return of []: TBD
if isempty(est)
    disp('warning: empty input') %somehow warning cannot be printed??
    sim = [];
    return
end
if ~exist('the_seed','var')
    sim = pal_tapas_simFromConfig(est.u,...
        est.c_prc,...
        est.p_prc.p,...
        est.c_obs,...
        est.p_obs.p);
else
    sim = pal_tapas_simFromConfig(est.u,...
        est.c_prc,...
        est.p_prc.p,...
        est.c_obs,...
        est.p_obs.p,...
        the_seed);
end

end