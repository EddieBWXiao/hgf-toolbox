function [p, log_prob] = tapas_wiener_pdlogrt(logrt, alpha, tau, beta, delta, varargin)
% Likelihood function for Wiener first passage time, for log-millisecond data
% 
% Transform logrt to linear RT and compute PDF
% Applies Jacobian adjustment to ensure that the pdf sums to 1
% Returns raw probabilities (p) and log probability (log_prob)
% Handles underflow by returning 0 and -Inf.
% 
% IMPORTANT: returns p for "lower boundary" (coded as 0 in the generative model)
%            see tapas_wiener_pdrts for more details
% 
% INPUT:
% - logrt: MUST be in log milliseconds (consistent with tapas_logrt functions)
% - For other inputs, see tapas_wiener_pdrts; varargin enables complete wrapping
%   
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao 2025 University of Cambridge
% wrapper around tapas_wiener_pdrts to handle log reaction time data
% Gemini 3.0Pro provided initial suggestions for the Jacobian; special thanks to Filippo De Luca for a helpful discussion on the issue 
%  (more info about Jacobian adjustment acquired from https://jsocolar.github.io/jacobians/)
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% transform from log(rt milliseconds) to rt in seconds
rt = exp(logrt)/1000;

% feed the trandformed data into the pdf
p_linear = tapas_wiener_pdrts(rt, alpha, tau, beta, delta, varargin{:});

% Jacobian adjustment by differentiating exp(logrt)/1000 & take log
log_jac = logrt - log(1000);

% apply adjustment
log_prob = log(p_linear) + log_jac;

% output probability
p = exp(log_prob);

end