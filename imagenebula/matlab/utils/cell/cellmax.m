function [m, i] = cellmax(c)
% CELLMIN Calculates the largest elements of a cell
% [M, I] = CELLMAX(C)
% 
% Calculate a matrix whose elements are the largest values of the 
% corrresponding elements among all matrices of the cell.
%
%
% INPUTS
%	C	- Cell of matrices of the same sizes.
%
% OUTPUTS
%	M	- Matrix with the largest elements values
%	I	- Indices of the maxinum values of C
%
% See also MIN, MAX, CELLMIN
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

%% Argument check
if ~iscell(c)
	error('cellmin:InputTypeError', 'Input C should be cell!');
end

nc = numel(c);
if nc <= 0
	error('cellmin:InputNumberError', 'Input C should not be empty');
end

sizem = size(c{1});
nm = numel(c{1});
for i = 1 : nc
	if sizem ~= size(c{i})
		error('cellmin:MatrixSizeError', 'Matrices in C should have the same size!');
	end
end

%% Convert to matrix
tmp = zeros(nm, nc);
for i = 1 : nc
	tmp(:, i) = reshape(c{i}, [nm, 1]);
end

[m, i] = max(tmp, [], 2);

m = reshape(m, sizem);
i = reshape(i, sizem);

