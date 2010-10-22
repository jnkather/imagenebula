function acc = indexedsum(X, IDX, nbins)
%INDEXEDSUM calculate the indexed sum of matrix X with indices specified by IDX
% ACC = INDEXEDSUM(X, IDX, NBINS)
%
% Calculate the indexed sum of matrix X with indices specified by IDX.
% The resulting vector ACC contains the sum of the elements in X whose 
% indices (specified by the corresponding elements of idx) are I.
% That is: acc(i) = x(find(idx == i)).
%
% INPUTS
%   X		- Vector or matrix containing the elements to accumulate.
%   IDX		- Index vector or matrix containing the index of the corresponding
%   elements in X.
%   NBINS	- Number of bins(indexes). if not specified, it will be automatically
%   determined from IDX.
%
% OUTPUTS
%   ACC		- Histogram-like vector containing accumulated sum. Each bin ACC_i
%	is the sum of all elements of matrix X whose index (specified by IDX) is i.
%
% The mex version is 300x faster in R12, and 4x faster in R13.  As far
% as I can tell, there is no way to do this efficiently in matlab R12.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING, USING OR
% MODIFYING.
%
% By downloading, copying, installing, using or modifying this
% software you agree to this license.  If you do not agree to this
% license, do not download, install, copy, use or modifying this
% software.
% 
% Copyright (C) 2010-2010 Baochuan Pang <babypbc@gmail.com>
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
% General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see
% <http://www.gnu.org/licenses/>.
%
% This file is adapted from the code provided by David R. Martin
% <dmartin@eecs.berkeley.edu>.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Arguments
error(nargchk(1, 3, nargin));

% If number of bins(nbins) is not specified, determine the argument using the
% index matrix (idx)
if (nargin < 3),
    nbins = max(IDX(:));
end

%% Implementation
acc = zeros(nbins,1);   % results containing the sums

for i = 1 : numel(X),
    % for each elements in x
	if IDX(i) < 1, continue; end
	if IDX(i) > nbins, continue; end
	
    % Accumulating to the corresponding index
	acc(IDX(i)) = acc(IDX(i)) + X(i);
end
