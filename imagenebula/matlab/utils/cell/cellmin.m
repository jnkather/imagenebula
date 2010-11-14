function [m, i] = cellmin(c, type)
% CELLMIN Calculates the smallest elements of a cell
% [M, I] = CELLMIN(C, TYPE)
% 
% Calculate a matrix whose elements are the smallest values of the 
% corrresponding elements among all matrices of the cell.
%
%
% INPUTS
%	C	- Cell of matrices of the same sizes.
%	TYPE	- Minimization type, values should be:
%		'matrix'	- matrix level minimization, fastest, but require the
%			largest memory
%		'row'		- row level minimization
%		'column'	- column level minimization
%		'elem'		- element-wise minimization, slowest, but require less memory
%		Default value indicating the type should be determined by program
%		smartly.
%
% OUTPUTS
%	M	- Matrix with the smallest elements values
%	I	- Indices of the minimum values of C
%
% See also MIN, MAX, CELLMAX
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
if nargin < 2, type = 'row'; end;

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
if strcmpi(type, 'elem')
	% pixel-wise minimization
	m = zeros(sizem);
	i = zeros(sizem);
	tmp = zeros(nc, 1);
	for ipixel = 1 : nm
		for ic = 1 : nc
			tmp(ic) = c{ic}(ipixel);
		end
		[m(ipixel), i(ipixel)] = min(tmp);
	end
elseif strcmpi(type, 'row')
	% row level minimization
	nrow = sizem(1);
	ncol = sizem(2);
	m = zeros(sizem);
	i = zeros(sizem);
	
	tmp = zeros(nc, ncol);
	for irow = 1 : nrow
		for ic = 1 : nc
			tmp(ic, :) = c{ic}(irow, :);
		end
		[m(irow, :), i(irow, :)] = min(tmp, [], 1);
	end
elseif strcmpi(type, 'col') || strcmpi(type, 'column')
	% column level minimization
	nrow = sizem(1);
	ncol = sizem(2);
	m = zeros(sizem);
	i = zeros(sizem);
	
	tmp = zeros(nc, nrow);
	for icol = 1 : ncol
		for ic = 1 : nc
			tmp(ic, :) = c{ic}(:, icol);
		end
		[m(:, icol), i(:, icol)] = min(tmp, [], 1);
	end
elseif strcmpi(type, 'matrix') || strcmpi(type, 'mat')
	% matrix level minimization
	tmp = zeros(nm, nc);
	for i = 1 : nc
		tmp(:, i) = reshape(c{i}, [nm, 1]);
	end

	[m, i] = min(tmp, [], 2);

	m = reshape(m, sizem);
	i = reshape(i, sizem);
else
	error('cellmin:TypeError', 'Type should not be %s', type);
end

