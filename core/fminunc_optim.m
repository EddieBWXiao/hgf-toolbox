function optim = fminunc_optim(f, init, varargin)
% wrapper function around MATLAB fminunc
% wrapped by Bowen Xiao Dec 2025 following the quasinewton_optim style
% 
% INPUT:
%     f            Function handle of the function to be optimised
%     init         The point at which to initialize the algorithm
%     varargin     Optional settings structure that can contain the
%                  following fields:
%       verbose    Boolean flag to turn output on (true) or off (false)
%       other arguments to pass into fminunc (see _config)
%
% OUTPUT:
%     optim        Structure containing results in the following fields
%       valMin     The value of the function at its minimum
%       argMin     The argument of the function at its minimum
%       T          The inverse Hessian at the minimum calculated as a
%                  byproduct of optimization
%                  - IMPORTANT: this will not be assigned if Hessian is undefined / infinite
%       iter       stores the output output of fminunc
%                  - IMPORTANT: unlike quasinewton_optim, fminunc does not transparently track iter...
%
% CAVEATS: see "Additional checks on the Hessian"
%          - assigns Inf for valmin if complex Hessian expected, with hope that increased nRandInit in tapas_fitModel can find better init
%          - raises error if calling tapas_nearest_psd on Sigma risks creating an endless loop
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao University of Cambridge
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% The default arguments to fminunc; use options to override
verbose = false;
check_hessian = true;
fminuncOptions = optimoptions('fminunc'); 
if nargin > 2
    options = varargin{1};

    if isfield(options, 'verbose')
        verbose = options.verbose;
    end
    
    if isfield(options, 'check_hessian')
        check_hessian = options.check_hessian;
    end
    
    if isfield(options, 'fminuncOptions')
        fminuncOptions = options.fminuncOptions;
    end
end

% Initial value for display and iteration tracking
val = f(init);

if verbose
    disp(' ')
    disp(['Initial argument: ', num2str(init')])
    disp(['Initial value: ' num2str(val)])
end

% Call fminunc
try
    [x_opt, fval, ~, output, ~, hessian] = fminunc( ...
            f, init, fminuncOptions);
catch
    disp('Warning: fminunc evaluation failed.')
    hessian = nan(length(init));
    fval = Inf;
    x_opt = init;
    output = struct();
end

% Compute T_opt from the Hessian
% Slightly awkward because the one place that uses it inverts it again, with loss of numerical precision
T_opt = [];
hessian_invalid = any(isnan(hessian(:))) || any(isinf(hessian(:)));
if hessian_invalid
    disp('Warning: Hessian invalid (contains NaN or Inf); may result in undefined Sigma in tapas_fitModel if the alternative Hessian also fails there')
else
    T_opt = inv(hessian);
end
output.hessian_fminunc = hessian; %store the original hessian as a copy

% Additional checks on the Hessian (Bowen Xiao 20251205)
% Purposes: 
    % 1) Do not provide optres.T if it risks infinite loop
        % when T is empty...
        % potential outcome 1: tapas_fitModel handles Hessian appropriately
        % potential outcome 2: Hessian fails; fitModel fails, indicating major problem
    % 2) Check for Hessians that will have a negative determinant in fitModel
if check_hessian && ~hessian_invalid
    
    H = inv(T_opt); % as will be done in tapas_fitModel
    if any(isnan(H(:))) || any(isinf(H(:)))
        
        disp('Warning: inverting T_opt from optimizer produced NaN or Inf.')
        T_opt = []; %remove T_opt; let fitModel handle the missing optres.T
        disp('optres.T not saved; may result in undefined Sigma in tapas_fitModel if the alternative Hessian also fails there')
    
    else
    
        % Will tapas_nearest_psd(Sigma) fail in tapas_fitModel?
        % nearest PSD could fail to reach ~any(eig(X)<0), likely due to some numerical precision issue
        % causes infinite loop during LME calculation
        n_while_loops = 1000;
        if ~internal_nearest_psd_available(T_opt, n_while_loops)
            fprintf('Warning: nearest_psd failed for the inverse Hessian after %i iterations\n', n_while_loops)
            disp('Infinite loop possible for inverse Hessian')
            disp('The offending inverse Hessian:')
            disp(T_opt)
            T_opt = []; %remove T_opt; let fitModel handle the missing optres.T
            disp('optres.T not saved; may result in undefined Sigma in tapas_fitModel if the alternative Hessian also fails there')

        % do the same check on H
        elseif ~internal_nearest_psd_available(H, n_while_loops)
            fprintf('Warning: nearest_psd failed for the Hessian after %i iterations\n', n_while_loops)
            disp('Infinite loop possible for the Hessian')
            disp('The offending Hessian:')
            disp(H)
            T_opt = []; %remove T_opt; let fitModel handle the missing optres.T
            disp('optres.T not saved; may result in undefined Sigma in tapas_fitModel if the alternative Hessian also fails there')

        else
            % if safe to run nearest_psd on H, run this additional check...

            % When the T_opt (optres.T in fitModel) is used to compute the LME...
            % tapas_fitModel catches Hessians that are not positive semi-definite
            % and uses tapas_nearest_psd, which checks the eigenvalues
            % however, it computes LME based on det(H), which can still be negative
            % [yes, for some reason, ~any(eig(X) < 0), can still have det(H)<0 ???]
            % the complex LME prodcued may appear larger than LMEs from other initializations, despite a more problematic Hessian
            % The following code forces the optimization result to be Inf, leading to -Inf LME
            % Users may use new random initializations to explore the parameter space and potentially identify a better Hessian
            H = nearest_psd(H); % there is an infinite loop risk here, but not encountered during use as of Dec 2025
            if det(H) < 0
                disp('Warning: det(H)<0; Hessian not positive semi-definite. If final LME = -Inf, increase nRandInit.')
                fval = Inf;
            end

        end
    end
end

% Collect results
optim.valMin = fval;
optim.argMin = x_opt;
if ~isempty(T_opt)
    % T not assigned here; may cause failure in fitModel with Sigma not defined
    optim.T = T_opt;
end
optim.iter = output; % only field to store other optimiser-related info

end
function success = internal_nearest_psd_available(X, n_iter)
% Finds the nearest positive semi-defnite matrix to X
% Modified by Bowen Xiao 2025 to check for infinite loops
% 
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2020 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.
%
% Input: 
%        X - a square matrix; 
%        n_iter - number of while loops to use for finding nearest PSD
% 
%
% Output: success - whether a nearest positive semi-definite matrix to input X was found

% Ensure symmetry
X = (X' + X)./2;

% Continue until X is positive semi-definite
attempts = 0;
while any(eig(X) < 0) && attempts < n_iter
    % V: right eigenvectors, D: diagonalized X (X*V = V*D <=> X = V*D*V')
    [V, D] = eig(X);
    % Replace negative eigenvalues with 0 in D
    D = max(0, D);
    % Transform back
    X = V*D*V';
    % Ensure symmetry
    X = (X' + X)./2;
    % Count attempts
    attempts = attempts + 1;
end

% check whether the loop was successful
success = ~any(eig(X) < 0);

end