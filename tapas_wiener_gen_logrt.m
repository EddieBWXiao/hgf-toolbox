function y = tapas_wiener_gen_logrt(alpha, tau, beta, delta, varargin)

% just a complete wrapper around tapas_wiener_gen_rts
% to ensure we have log rt (rt in milliseconds)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2025 Bowen Xiao University of Cambridge
% 
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.


y = tapas_wiener_gen_rts(alpha, tau, beta, delta, varargin{:});
y(:,2) = log(y(:,2)*1000);

end