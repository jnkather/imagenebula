function m = cell2matnd(c)
% CELL2MATND Convert a cell of matrices into a matrix with N additional dimension.
% [M] = CELL2MATND(C)
% 
% Convert a cell of matrices of the same sizes into a matrix with N
% additional dimension, where N indicates the dimension of the cell C. For 
% example, if C is a cell of the size P*Q, each
% of which is a matrix of the size M*N, then M is a matrix of the size
% M*N*P*Q.
%
%
% INPUTS
%	C	- Cell of matrices of the same sizes.
%
% OUTPUTS
%	M	- Matrix with N additional dimension converted from the cell C.
%
% See also CELL2MAT1D, CELL2MAT, RESHAPE
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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&&&&&&&&&

%% Size and number
sizecell = size(c);
ncell = numel(c);
sizemat = size(c{1});
nmat = numel(c{1});

%% Convert to matrix of the size (N*M) * (P*Q)
m = zeros(nmat, ncell);
for i = 1 : ncell,
    m(:, i) = reshape(c{i}, nmat, 1);
end

%% Reshape to N*M*P*Q
m = reshape(m, [sizemat, sizecell]);