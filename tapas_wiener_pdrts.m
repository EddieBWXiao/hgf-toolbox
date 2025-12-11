function p = tapas_wiener_pdrts(rt, alpha, tau, beta, delta, err)
% Likelihood function for Wiener first passage time to the lower boundary
% pdrts: probability density for reaction time in seconds
% Restricted to four params (no inter-trial variability)
% Does NOT support vectors
% 
% INPUT:
% - rt: reaction time in seconds
% - alpha: boundary separation (>0)
% - tau: non-decision time (>0; unit in seconds)
% - beta: bias ("starting point"); bound between 0-1
% - delta: drift rate (any real number; negative is fine)
% - err: precision threshold 
%        (necessary due to infinite sum; defaults to 1e-9)
%
% OUTPUT:
% - p: returns probability density for rt given the parameters
% 
% Adapted original code implementing Navarro et al 2009 by berwiani from emfit toolbox:
% https://github.com/mpc-ucl/emfit/blob/master/mEffortDDM/libDDM/wfpt_prep.m
% https://github.com/mpc-ucl/emfit/blob/master/mEffortDDM/libDDM/wfpt_all.m
% Released under the terms of the GNU General Public Licence (GPL), either version 3 of the License, or (at your option) any later version.
% 
% Modified by Bowen Xiao 2025 to...
% 1. Improve similarity to RWiener::dwiener and Stan's wiener_lpdf
%    - Notations checked against equations in:
%    https://mc-stan.org/docs/functions-reference/positive_lower-bounded_distributions.html#wiener-first-passage-time-distribution
% 2. Removed derivatives (not used in TAPAS)
% 
% Details about notations:
% - Original Navarro et al. 2009 worked on drift to lower boundary
% - The current code also seems to compute drift to lower boundary
% - For consistency, check against tapas_weiner_gen_rts...
% - Lower boundary is coded as 0; to model the upper (coded as 1), do -delta and 1-beta
% - Accidental flipping should result in delta and beta to be recovered with negative correlations
% - Congruency coding is preferred; 
    % not tested by B.X. for accuracy-coded projects
    % may require wrapper for "correct = upper bound" codes
% 
% default error (a stringent number in Navarro 2009)
if nargin < 6
    err = 1e-29;
end

% the decision time: non-decision time (s) subtracted from reaction time (s) 
%t = max(eps, rt - tau); %use the eps to avoid going negative; not ideal
t = rt - tau;
if t < 0
    % revised solution: do not return fake probability; p=0 means p=0
    p = 0;
    return
end

% Precompute common values
alpha2 = alpha * alpha; %old alpha^2

% use normalized time
tt = t/alpha2;

% calculate number of terms needed for large t
pi_tt = pi * tt; % pre-compute for efficiency
if pi_tt * err < 1 % if error threshold is set low enough
    kl = sqrt(-2 * log(pi_tt * err) / (pi^2 * tt)); % bound
    kl = max(kl,1/(pi*sqrt(tt))); % ensure boundary conditions met
else % if error threshold set too high
    kl = 1/(pi*sqrt(tt)); % set to boundary condition
end

% calculate number of terms needed for small t
sqrt_2pi_tt = sqrt(2 * pi * tt);
if 2 * sqrt_2pi_tt * err < 1 % if error threshold is set low enough
    ks = 2 + sqrt(-2 * tt * log(2 * sqrt_2pi_tt * err)); % bound
    ks = max(ks,sqrt(tt)+1); % ensure boundary conditions are met
else % if error threshold was set too high
    ks=2; % minimal kappa for that case
end

% compute f(tt|0,1,w)
p = 0; %initialize density
if ks < kl % if small t is better...
    K = ceil(ks); % round to smallest integer meeting error
    for k = -floor((K-1)/2):ceil((K-1)/2) % loop over k
        p = p + (2*k + beta)*exp(-((2*k + beta)^2)/(2*(t/(alpha2)))); % increment sum
        % B.X. note: the thing inside exp is messy because it is writing out the expression for normpdf
        % except the 1/sqrt(2*pi) is moved to the "add constant term" below
    end
    p = p/sqrt(2*pi*(t/(alpha2))^3); % add constant term    
else % if large t is better...
    K=ceil(kl); % round to smallest integer meeting error
    for k = 1:K
        p = p + k * exp(-(k^2)*(pi^2)*t/(2*alpha2)) * sin(k*pi*beta); % increment sum
    end
    p = p*pi; % add constant term
end

% convert to f(t|v,a,w); this multipler is the first big part of the last equation in the Stan documentation
p = p*exp(-delta*alpha*beta-(delta^2)*t/2)/alpha2;

end