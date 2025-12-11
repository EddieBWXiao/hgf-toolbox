function [pvec, pstruct] = tapas_ddm_logrt_pwrbp_transp(r, ptrans)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao, University of Cambridge
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

pvec    = NaN(1,length(ptrans));
pstruct = struct;

% prior transformations largely following https://github.com/CCS-Lab/hBayesDM/blob/develop/commons/stan_files/choiceRT_ddm.stan
% but with inv logit (tapas_sgm) rather than Phi approx
% also, ndt is log space, not with the "logit then add boundary" approach
pvec(1)    = exp(ptrans(1));  % 
pvec(2)    = exp(ptrans(2));  %
pvec(3)    = tapas_sgm(ptrans(3),1);  %
pvec(4)    = exp(ptrans(4));
pvec(5)    = ptrans(5); % 
pvec(6)    = tapas_sgm(ptrans(6),1)*0.6-0.3; % IMPORTANT: bounds to -0.3 and 0.3; c.f. https://github.com/CCS-Lab/hBayesDM/blob/develop/commons/stan_files/pstRT_rlddm6.stan)
pstruct.vscale = pvec(1);
pstruct.bb = pvec(2);
pstruct.z = pvec(3);
pstruct.ndt = pvec(4);
pstruct.v0 = pvec(5);
pstruct.bp = pvec(6);

return;