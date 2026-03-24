function c = fminunc_optim_config
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Configuration for wrapper around MATLAB's fminunc
% Defaults to a quasi-newton method
%
% CAVEAT:
% to update the fminunc options, requires:
% est.c_opt.fminuncOptions = optimoptions(est.c_opt.fminuncOptions, 'Display', 'iter');
% this keeps the previous options
% or... use dot notation (est.c_opt.fminuncOptions.Display)
% calling optimoptions will erase previous settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao University of Cambridge
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Config structure
c = struct;

% Algorithm name
c.algorithm = 'fminunc wrapper';

% Verbosity
c.verbose   = false;

% Options related to fitModel, not native to fminunc
c.nRandInit = 0;        % Number of random initializations
c.seedRandInit = NaN;   % Seed for random initialization

% Check the Hessian to prevent LME in complex numbers
c.check_hessian = true;

% IMPORTANT: customise the optimoptions here
% defaults to the default as of December 2025, with Display off to reduce verbosity
% Please note that verbose = true will not turn Display back on; please do so manually
c.fminuncOptions = optimoptions('fminunc',...
    'Algorithm','quasi-newton',...
    'Display','off');
    %'MaxFunctionEvaluations', 1e6,... %the default is 100*n_params, which is low
    %'Display','off');

% Algorithm filehandle
c.opt_algo = @fminunc_optim;

return;