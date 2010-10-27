function m = cell2mat1d(c)
% CELL2MAT1D Convert a cell of matrices into a matrix with one additional dimension.
% [M] = CELL2MAT1D(C)
% 
% Convert a cell of matrices of the same sizes into a matrix with one
% additional dimension. For example, if C is a cell with P elements, each
% of which is a matrix of the size M*N, then M is a matrix of the size
% M*N*P.
%
%
% INPUTS
%	C	- Cell of matrices of the same sizes.
%
% OUTPUTS
%	M	- Matrix with one additional dimension converted from the cell C.
%
% See also CELL2MATND, CELL2MAT, RESHAPE
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


ncell = numel(c);
nmat = numel(c{1});
sizemat = size(c{1});
m = zeros(nmat, ncell);

for i = 1 : ncell,
    m(:, i) = reshape(c{i}, nmat, 1);
end

m = reshape(m, [sizemat, ncell]);